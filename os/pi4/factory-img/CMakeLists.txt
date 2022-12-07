file(GLOB_RECURSE BOOT_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} boot/*)
file(GLOB_RECURSE ROOT_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} root/*)

registerPod(CONFIGURED_DEPENDENCIES_COPYONLY ${BOOT_FILES} ${ROOT_FILES} createRootFS.sh)

add_custom_command(
    COMMENT "Copy raspios image from container into host"
    OUTPUT raspios.img
    DEPENDS ${POD_TARGET}
    VERBATIM
    COMMAND podman run 
        --authfile=${CMAKE_BINARY_DIR}/podman-authentication 
        --tls-verify=false 
        --rm 
        -v ${CMAKE_CURRENT_BINARY_DIR}:/out 
        ${POD_URI} echo "1" #cp /raspios.img /out/
)

add_custom_command(
    COMMENT "Mount raspios image into host filesystem"
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mnt/boot/cmdline.txt
    DEPENDS raspios.img
    VERBATIM
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/mountImage.sh ${CMAKE_CURRENT_BINARY_DIR} 
)


add_custom_command(
    COMMENT "Build pi4 factory image"
    OUTPUT pi4-factory.img
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/mnt/boot/cmdline.txt
    VERBATIM
    COMMAND echo "2"
    # COMMAND ${RUN_POD} /createRootFS.sh
)

add_custom_target(pi4-factory-img DEPENDS pi4-factory.img)
