
file(READ ${CMAKE_BINARY_DIR}/build-environments/beaglebone/buildroot/pod-checksum BEAGLEBONE_POD_CHECKSUM)

registerPod(DEPENDS_ON_POD ${BEAGLEBONE_POD_CHECKSUM})

SET(RUN_POD podman run --authfile=${CMAKE_BINARY_DIR}/podman-authentication -ti --tls-verify=false --rm -v ${CMAKE_CURRENT_BINARY_DIR}:/out  ${POD_URI})

add_custom_command(
    COMMENT "Build Beaglebone factory rootfs"
    OUTPUT os-beaglebone-factory-rootfs.tar.gz
    DEPENDS ${POD_TARGET}
    VERBATIM
    COMMAND ${RUN_POD} cp /nonlinux/output/images/rootfs.tar.gz /out/os-beaglebone-factory-rootfs.tar.gz
)

add_custom_command(
    COMMENT "Build Beaglebone factory MLO"
    OUTPUT os-beaglebone-factory-MLO
    DEPENDS ${POD_TARGET}
    VERBATIM
    COMMAND ${RUN_POD} cp /nonlinux/output/images/MLO /out/os-beaglebone-factory-MLO
)

add_custom_command(
    COMMENT "Build Beaglebone factory u-boot"
    OUTPUT os-beaglebone-factory-u-boot.img
    DEPENDS ${POD_TARGET}
    VERBATIM
    COMMAND ${RUN_POD} cp /nonlinux/output/images/u-boot.img /out/os-beaglebone-factory-u-boot.img
)

add_custom_target(os-beaglebone-factory-rootfs DEPENDS os-beaglebone-factory-rootfs.tar.gz os-beaglebone-factory-MLO os-beaglebone-factory-u-boot.img)
