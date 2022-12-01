registerPod()

SET(RUN_POD podman run --authfile=${CMAKE_BINARY_DIR}/podman-authentication -ti --tls-verify=false --rm -v ${CMAKE_CURRENT_BINARY_DIR}:/out  ${POD_URI})

add_custom_command(
    COMMENT "Build Beaglebone factory rootfs"
    OUTPUT beaglebone-factory-rootfs.tar.gz
    DEPENDS ${POD_TARGET}
    VERBATIM
    COMMAND ${RUN_POD} cp /nonlinux/output/images/rootfs.tar.gz /out/beaglebone-factory-rootfs.tar.gz
)

add_custom_target(beaglebone-factory-rootfs DEPENDS beaglebone-factory-rootfs.tar.gz)
