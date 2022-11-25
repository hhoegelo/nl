file(GLOB_RECURSE BOOT_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} boot/*)
file(GLOB_RECURSE ROOT_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} root/*)
set(DEPS ${BOOT_FILES} ${ROOT_FILES} createRootFS.sh)

foreach(FILE ${DEPS})
  configure_file(${FILE} ${FILE} COPYONLY)
endforeach()

registerPod(${DEPS})

SET(RUN_POD podman run --authfile=${CMAKE_BINARY_DIR}/podman-authentication -ti --privileged --tls-verify=false --rm -v ${CMAKE_CURRENT_BINARY_DIR}:/out  ${POD_URI})

add_custom_command(
    COMMENT "Build pi4 factory image"
    OUTPUT pi4-factory.img
    DEPENDS ${POD_TARGET}
    VERBATIM
    COMMAND ${RUN_POD} /createRootFS.sh
)

add_custom_target(pi4-factory-img DEPENDS pi4-factory.img)