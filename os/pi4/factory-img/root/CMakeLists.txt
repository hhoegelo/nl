set(ROOT_FILES backlight.sh configure-lcd-pwm.service configure-lcd-pwm.sh configure-neopixel-spi.service configure-neopixel-spi.sh max-cpu.service)

foreach(file ${ROOT_FILES})
    configure_file(${file} ${file} COPYONLY)
endforeach()

foreach(file createRootFS.sh)
    configure_file(${file} ${file} @ONLY)
endforeach()

registerPod(
    TWEAK_IMAGE tweakImage.sh
    USED_VARIABLES ${PI4_package} ${PI4_FACTORY_BASE_IMAGE} ${PI4_FACTORY_BASE_IMAGE_ROOT_FS_POSITION} ${PI4_FACTORY_BASE_IMAGE_ROOT_FS_SIZE})

add_custom_command(
    COMMENT "Build pi4 rootfs"
    OUTPUT pi4-rootfs.img
    DEPENDS ${POD_TARGET}
    DEPENDS createRootFS.sh
    VERBATIM
    COMMAND podman run 
        --network=none
        --authfile=${CMAKE_BINARY_DIR}/podman-authentication 
        --tls-verify=false
        --privileged 
        --rm 
        -ti
        -v ${CMAKE_CURRENT_BINARY_DIR}:/out 
        ${POD_URI} /out/createRootFS.sh
)

add_custom_target(pi4-rootfs DEPENDS pi4-rootfs.img)
