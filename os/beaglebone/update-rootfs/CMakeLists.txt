registerPod("")

SET(RUN_POD podman run --authfile=${CMAKE_BINARY_DIR}/podman-authentication -ti --tls-verify=false --rm -v ${CMAKE_CURRENT_BINARY_DIR}:/out  ${POD_URI})

add_custom_command(
    COMMENT "Build Beaglebone update rootfs"
    OUTPUT beaglebone-update-rootfs.tar.gz
    DEPENDS ${POD_TARGET}
    VERBATIM
    COMMAND ${RUN_POD} cp /nonlinux/output/images/rootfs.tar.gz /out/beaglebone-update-rootfs.tar.gz
)

add_custom_target(beaglebone-update-rootfs DEPENDS beaglebone-update-rootfs.tar.gz)
