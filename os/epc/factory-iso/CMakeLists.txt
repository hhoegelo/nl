
configure_file(sda.sfdisk sda.sfdisk COPYONLY)
configure_file(install-factory-os.sh install-factory-os.sh COPYONLY)

registerPod(sda.sfdisk install-factory-os.sh)

SET(RUN_POD podman run -ti --privileged --tls-verify=false --rm -v ${CMAKE_CURRENT_BINARY_DIR}:/out  ${POD_URI})

add_custom_command(
    COMMENT "Build epc factory iso image"
    OUTPUT epc-factory.iso
    DEPENDS ${POD_TARGET}
    VERBATIM
    COMMAND ${RUN_POD}
)

add_custom_target(epc-factory-iso DEPENDS epc-factory.iso)
