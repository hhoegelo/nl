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
    BASE os/epc/update-img/epc-update.img
    POST_PROCESS_POD ${POD_URI}
    POST_PROCESS_SCRIPT bundle.sh)