registerPod()

add_custom_command(
    COMMENT "Build Beaglebone rootfs"
    OUTPUT beaglebone-factory-rootfs.tar.gz
    DEPENDS ${POD_TARGET}
    COMMAND touch beaglebone-factory-rootfs.tar.gz
)

add_custom_target(beaglebone-factory-rootfs DEPENDS beaglebone-factory-rootfs.tar.gz)
