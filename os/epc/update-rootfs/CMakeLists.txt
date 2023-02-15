SET(ARCH_VERSION_YEAR 2022)
SET(ARCH_VERSION_MONTH 09)
SET(ARCH_VERSION_DAY 25)
SET(ARCH_VERSION ${ARCH_VERSION_YEAR}${ARCH_VERSION_MONTH}${ARCH_VERSION_DAY}.0.89186)

SET(PACKAGES alsa-lib alsa-tools alsa-utils arch-install-scripts base boost 
             cpupower dnsmasq flac freetype2 glibmm linux-firmware libpng linux-rt
             libsoup lm_sensors mc nano networkmanager png++ shared-mime-info 
             sudo sshfs lsof systemd-sysvcompat vi)

STRING(REPLACE ";" " " PACKAGES "${PACKAGES}")

configure_file(build-rootfs.sh build-rootfs.sh)
configure_file(pacstrap pacstrap COPYONLY)
configure_file(arch-chroot arch-chroot COPYONLY)

registerPod()

SET(RUN_POD podman run  --privileged 
                        --authfile=${CMAKE_BINARY_DIR}/podman-authentication 
                        --tls-verify=false 
                        --rm 
                        -v ${CMAKE_CURRENT_BINARY_DIR}:/out 
                        ${POD_URI})

add_custom_command(
    COMMENT "Build epc update rootfs"
    OUTPUT epc-update-rootfs.img
    DEPENDS ${POD_TARGET}
    VERBATIM
    COMMAND ${RUN_POD} /out/build-rootfs.sh
)

add_custom_target(os-epc-update-rootfs DEPENDS epc-update-rootfs.img)