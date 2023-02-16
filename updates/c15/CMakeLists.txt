SET(PROJECT c15)

add_subdirectory(beaglebone)
add_subdirectory(epc)
add_subdirectory(playcontroller)
add_subdirectory(web)

registerPod()

buildImage(
    NAME update-c15
    DEPENDS ${POD_TARGET}
    DEPENDS update-c15-beaglebone 
    DEPENDS update-c15-epc 
    DEPENDS update-c15-playcontroller 
    DEPENDS update-c15-web
    DEPENDS os-epc-update-rootfs
    BASE os/epc/update-rootfs/os-epc-update-rootfs.tar
    ADD updates/c15/beaglebone/update-c15-beaglebone.tar
    ADD updates/c15/epc/update-c15-epc.tar
    ADD updates/c15/playcontroller/update-c15-playcontroller.tar
    ADD updates/c15/web/update-c15-web.tar
    POST_PROCESS_POD ${POD_URI}
    POST_PROCESS_SCRIPT bundle.sh)