SET(TARGET_MACHINE beaglebone)

add_subdirectory(buildroot)

set(DEPENDENCIES buildroot/buildroot-host.tar buildroot/buildroot-staging.tar)

registerPod("${DEPENDENCIES}" "" "")
add_dependencies(${POD_TARGET} buildroot-staging buildroot-host)
