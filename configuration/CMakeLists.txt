set(BUILD_TASK configuration)
set(TARGET_MACHINE devpc)

registerPod()

add_custom_command(
    COMMENT "Build configuration"
    OUTPUT nl-version.h
    DEPENDS main.ts
    DEPENDS ${POD_TARGET}
    COMMAND podman run 
    --tls-verify=false --rm 
    -v ${CMAKE_CURRENT_SOURCE_DIR}:/src ${POD_URI} ts-node /src/main.ts > nl-version.h
)

add_custom_target(configuration DEPENDS nl-version.h)
