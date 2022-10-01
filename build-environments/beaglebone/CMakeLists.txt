SET(TARGET_MACHINE beaglebone)

add_subdirectory(buildroot)

registerPod(buildroot/buildroot-host.tar buildroot/buildroot-staging.tar)
add_dependencies(${POD_TARGET} buildroot-staging buildroot-host)
