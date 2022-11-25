SET(DEPS sda.sfdisk install-factory-os.sh generatePkgBuild.sh install.sh hook/nlhook hook/oroot install/nlhook install/oroot)

foreach(FILE ${DEPS})
  configure_file(${FILE} ${FILE} COPYONLY)
endforeach()

registerPod("${DEPS}" "${DEPS}" "")

SET(RUN_POD podman run --authfile=${CMAKE_BINARY_DIR}/podman-authentication -ti --privileged --tls-verify=false --rm -v ${CMAKE_CURRENT_BINARY_DIR}:/out  ${POD_URI})

add_custom_command(
    COMMENT "Build epc factory iso image"
    OUTPUT epc-factory.iso
    DEPENDS ${POD_TARGET}
    VERBATIM
    COMMAND ${RUN_POD}
)

add_custom_target(epc-factory-iso DEPENDS epc-factory.iso)
