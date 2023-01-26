set(BOOT_FILES config.txt touch.dtbo touch.dts)

registerPod(USED_VARIABLES ${PI4_FACTORY_BASE_IMAGE} ${PI4_FACTORY_BASE_IMAGE_BOOT_FS_POSITION} ${PI4_FACTORY_BASE_IMAGE_BOOT_FS_SIZE})

foreach(file ${BOOT_FILES})
    configure_file(${file} ${file} COPYONLY)
endforeach()

if(${PI4_Model} MATCHES "CM4")
    SET(PI4_BOOT_FS_COPY_FILES "copy-in")
    foreach(file ${BOOT_FILES})
        SET(PI4_BOOT_FS_COPY_FILES "${PI4_BOOT_FS_COPY_FILES} /out/${file}")
    endforeach()
    SET(PI4_BOOT_FS_COPY_FILES "${PI4_BOOT_FS_COPY_FILES} /")
endif()

if(${PI4_FEATURES} MATCHES ".*NO_CURSOR.*")
    SET(PI4_BOOT_FS_NO_CURSOR "write-append /cmdline.txt 'vt.global_cursor_default=0 '")
endif()

if(${PI4_FEATURES} MATCHES ".*NO_X.*")
    SET(PI4_BOOT_FS_NO_X "write-append /config.txt 'start_x=0  '")
endif()

foreach(file createBootFS.sh)
    configure_file(${file} ${file} @ONLY)
endforeach()

add_custom_command(
    COMMENT "Build pi4 boot partition"
    OUTPUT pi4-bootfs.img
    DEPENDS ${POD_TARGET}
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/createBootFS.sh
    VERBATIM
    COMMAND 
        cat ${CMAKE_CURRENT_BINARY_DIR}/createBootFS.sh | 
        podman run -ti --network=none --authfile=${CMAKE_BINARY_DIR}/podman-authentication
            --tls-verify=false --privileged --rm
            -v ${CMAKE_CURRENT_BINARY_DIR}:/out
            ${POD_URI} -a /bootfs.img
)

add_custom_target(pi4-bootfs DEPENDS pi4-bootfs.img)
