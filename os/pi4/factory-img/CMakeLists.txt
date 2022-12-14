file(GLOB_RECURSE BOOT_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} boot/*)
file(GLOB_RECURSE ROOT_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} root/*)

registerPod(USED_VARIABLES ${PI4_PACKAGES})

foreach(file ${BOOT_FILES} ${ROOT_FILES})
    configure_file(${file} ${file} COPYONLY)
endforeach()

foreach(file createRootFS.sh)
    configure_file(${file} ${file} @ONLY)
endforeach()

add_custom_command(
    COMMENT "Build pi4 factory image"
    OUTPUT pi4-factory.img
    DEPENDS ${POD_TARGET}
    VERBATIM
    COMMAND podman run 
        --authfile=${CMAKE_BINARY_DIR}/podman-authentication 
        --tls-verify=false
        --privileged 
        --rm 
        -ti
        -v ${CMAKE_CURRENT_BINARY_DIR}:/out 
        ${POD_URI} /out/createRootFS.sh 
)

add_custom_target(pi4-factory-img DEPENDS pi4-factory.img)
