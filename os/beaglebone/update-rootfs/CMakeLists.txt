file(READ ${CMAKE_BINARY_DIR}/build-environments/beaglebone/buildroot/pod-checksum BEAGLEBONE_POD_CHECKSUM)

registerPod(DEPENDS_ON_POD ${BEAGLEBONE_POD_CHECKSUM})

SET(RUN_POD podman run --authfile=${CMAKE_BINARY_DIR}/podman-authentication -ti --tls-verify=false --rm -v ${CMAKE_CURRENT_BINARY_DIR}:/out  ${POD_URI})

add_custom_command(
    COMMENT "Build Beaglebone update rootfs"
    OUTPUT os-beaglebone-update-rootfs.tar
    DEPENDS ${POD_TARGET}
    VERBATIM
    COMMAND ${RUN_POD} cp /nonlinux/output/images/rootfs.tar /out/os-beaglebone-update-rootfs.tar
)

add_custom_target(os-beaglebone-update-rootfs DEPENDS os-beaglebone-update-rootfs.tar)
