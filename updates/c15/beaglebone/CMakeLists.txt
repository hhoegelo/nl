SET(TARGET_MACHINE beaglebone)

registerPod()

crossBuild(
    NAME update-c15-beaglebone-bins
    DEPENDS nltools text2soled bridge[nltools] midi-over-ip[nltools] playcontroller-tools espi-driver playcontroller-driver)

buildImage(
    NAME update-c15-beaglebone
    DEPENDS ${POD_TARGET}
    DEPENDS update-c15-beaglebone-bins
    DEPENDS os-beaglebone-update-rootfs
    DEPENDS ${CMAKE_BINARY_DIR}/os/beaglebone/update-rootfs/os-beaglebone-update-rootfs.tar
    DEPENDS update-c15-beaglebone-bins.tar
    BASE os/beaglebone/update-rootfs/os-beaglebone-update-rootfs.tar
    ADD updates/c15/beaglebone/update-c15-beaglebone-bins.tar
    POST_PROCESS_POD ${POD_URI}
    POST_PROCESS_SCRIPT bundle.sh)

