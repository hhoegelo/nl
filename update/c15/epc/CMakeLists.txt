add_subdirectory(web)

crossBuild(
    NAME update-c15-epc-bins 
    MACHINE epc
    DEPENDS nltools audio-engine[nltools] playground[nltools] epc-scripts)

registerPod()

configure_file(backdoor.sh backdoor.sh)
configure_file(C15.nmconnection C15.nmconnection)
configure_file(post-install.sh post-install.sh)
configure_file(wpa_supplicant.conf wpa_supplicant.conf)

buildImage(
    NAME update-c15-epc
    DEPENDS ${POD_TARGET}
    DEPENDS update-c15-epc-bins
    DEPENDS update-c15-epc-web
    DEPENDS os-epc-update-rootfs
    BASE os/epc/update-rootfs/os-epc-update-rootfs.tar
    ADD update/c15/epc/update-c15-epc-bins.tar
    ADD update/c15/epc/web/update-c15-epc-web.tar
    POST_PROCESS_POD ${POD_URI}
    POST_PROCESS_SCRIPT bundle.sh)