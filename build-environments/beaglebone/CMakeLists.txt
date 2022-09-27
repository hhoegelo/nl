SET(TARGET_MACHINE beaglebone)

add_subdirectory(buildroot)

registerPod()
add_dependencies(${POD_TARGET} buildroot-staging buildroot-host)
