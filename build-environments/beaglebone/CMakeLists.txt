SET(TARGET_MACHINE beaglebone)

add_subdirectory(buildroot)

registerPod(BUILT_DEPENDENCIES buildroot/buildroot-host.tar buildroot/buildroot-staging.tar)
add_dependencies(${POD_TARGET} buildroot-staging buildroot-host)
