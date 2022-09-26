registerPod()

add_custom_command(
    COMMENT "Build Beaglebone rootfs"
    OUTPUT beaglebone-factory-rootfs.tar.gz
    COMMAND touch beaglebone-factory-rootfs.tar.gz
)

add_custom_target(beaglebone-factory-rootfs DEPENDS beaglebone-factory-rootfs.tar.gz)
add_dependencies(beaglebone-factory-rootfs ${BUILD_TASK}-${TARGET_MACHINE})