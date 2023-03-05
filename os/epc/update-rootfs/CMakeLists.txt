SET(ARCH_VERSION_YEAR 2022)
SET(ARCH_VERSION_MONTH 09)
SET(ARCH_VERSION_DAY 25)
SET(ARCH_VERSION ${ARCH_VERSION_YEAR}${ARCH_VERSION_MONTH}${ARCH_VERSION_DAY}.0.89186)

SET(package alsa-lib alsa-tools alsa-utils arch-install-scripts base boost 
             cpupower dnsmasq flac freetype2 glibmm libpng libsoup lm_sensors 
             mc nano networkmanager png++ shared-mime-info 
             sudo sshfs lsof systemd-sysvcompat vi)

STRING(REPLACE ";" " " package "${package}")

configure_file(build-rootfs.sh build-rootfs.sh)
configure_file(pacstrap pacstrap COPYONLY)
configure_file(arch-chroot arch-chroot COPYONLY)

registerPod()

SET(RUN_POD podman run  --privileged 
                        --authfile=${CMAKE_BINARY_DIR}/podman-authentication 
                        --tls-verify=false
                        --network=none
                        --rm 
                        -v ${CMAKE_CURRENT_BINARY_DIR}:/out 
                        ${POD_URI})

add_custom_command(
    COMMENT "Build epc update rootfs"
    OUTPUT os-epc-update-rootfs.tar
    DEPENDS ${POD_TARGET}
    DEPENDS build-rootfs.sh
    VERBATIM
    COMMAND ${RUN_POD} /out/build-rootfs.sh
)

add_custom_target(os-epc-update-rootfs DEPENDS os-epc-update-rootfs.tar)
