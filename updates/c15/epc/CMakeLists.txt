SET(TARGET_MACHINE epc)

add_subdirectory(web)

crossBuild(
    NAME update-c15-epc-bins 
    DEPENDS nltools audio-engine[nltools] playground[nltools])

registerPod()

buildImage(
    NAME update-c15-epc
    DEPENDS ${POD_TARGET}
    DEPENDS update-c15-epc-bins
    DEPENDS update-c15-epc-web
    DEPENDS os-epc-update-rootfs
    BASE os/epc/update-rootfs/os-epc-update-rootfs.tar
    ADD updates/c15/epc/update-c15-epc-bins.tar
    ADD updates/c15/epc/web/update-c15-epc-web.tar
    POST_PROCESS_POD ${POD_URI}
    POST_PROCESS_SCRIPT bundle.sh)