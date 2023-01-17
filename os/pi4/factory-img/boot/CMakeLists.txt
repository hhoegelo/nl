set(BOOT_FILES config.txt touch.dtbo touch.dts)

registerPod()

foreach(file ${BOOT_FILES})
    configure_file(${file} ${file} COPYONLY)
endforeach()

foreach(file createBootFS.sh)
    configure_file(${file} ${file} @ONLY)
endforeach()

add_custom_command(
    COMMENT "Build pi4 boot partition"
    OUTPUT pi4-bootfs.img
    DEPENDS ${POD_TARGET}
    DEPENDS createBootFS.sh
    VERBATIM
    COMMAND 
        cat ${CMAKE_CURRENT_BINARY_DIR}/createBootFS.sh | 
        podman run -ti --network=none --authfile=${CMAKE_BINARY_DIR}/podman-authentication
            --tls-verify=false --privileged --rm
            -v ${CMAKE_CURRENT_BINARY_DIR}:/out
            ${POD_URI} -a /bootfs.img
)

add_custom_target(pi4-bootfs DEPENDS pi4-bootfs.img)
