registerPod()

SET(RUN_POD podman run --tls-verify=false --rm -v ${CMAKE_CURRENT_BINARY_DIR}:/out  ${POD_URI})

add_custom_command(
    COMMENT "Extract Staging from Buildroot"
    DEPENDS ${POD_TARGET}
    OUTPUT buildroot-staging.tar
    VERBATIM
    COMMAND ${RUN_POD} tar -czf /out/buildroot-staging.tar -C /nonlinux/output/staging .
)

add_custom_command(
    COMMENT "Extract Host tools from Buildroot"
    DEPENDS ${POD_TARGET}
    OUTPUT buildroot-host.tar
    VERBATIM
    COMMAND ${RUN_POD} tar -czf /out/buildroot-host.tar -C /nonlinux/output/host .
)

add_custom_target(buildroot-staging DEPENDS buildroot-staging.tar)
add_custom_target(buildroot-host DEPENDS buildroot-host.tar)
SET(BUILDROOT_POD_URI ${POD_URI} PARENT_SCOPE)