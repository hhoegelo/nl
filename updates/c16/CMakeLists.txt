SET(PROJECT c15)

add_subdirectory(pi4)

include(${CMAKE_SOURCE_DIR}/cmake/pi4-image-def.cmake)

registerPod()

buildImage(
    NAME update-c16
    DEPENDS ${POD_TARGET}
    DEPENDS pi4-update-img
    DEPENDS update-c16-web
    DEPENDS update-c16-pi4
    BASE os/pi4/update-img/pi4-update.img
    ADD updates/c16/pi4/update-c16-pi4.tar.gz
    ADD updates/c16/web/update-c16-web.tar.gz
    POST_PROCESS_POD ${POD_URI}
    POST_PROCESS_SCRIPT bundle.sh)