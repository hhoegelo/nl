project(parameterDB-new)

set(BUILD_TASK configuration)
set(TARGET_MACHINE devpc)

registerPod("package.json" "package.json" "")

include(GNUInstallDirs)

file(GLOB_RECURSE YAML_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.yaml)
file(GLOB_RECURSE IN_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.in)
file(GLOB_RECURSE TYPESCRIPT_FILES ${CMAKE_CURRENT_SOURCE_DIR}/lib/*.ts)
file(GLOB_RECURSE SHELL_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.sh)

configure_file(package.json package.json COPYONLY)

add_custom_command(
        COMMENT "build generated parameter-list from configuration YAML"
        DEPENDS ${YAML_FILES}
        DEPENDS ${IN_FILES}
        DEPENDS ${TYPESCRIPT_FILES}
        DEPENDS ${SHELL_FILES}
        DEPENDS ${POD_TARGET}
        DEPENDS tsconfig.json
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/generated/.done
        VERBATIM
        COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/generated
        COMMAND 
            podman run 
            --authfile=${CMAKE_BINARY_DIR}/podman-authentication 
            -ti --tls-verify=false --rm 
            -v ${CMAKE_CURRENT_SOURCE_DIR}:/root/src 
            -v ${CMAKE_CURRENT_BINARY_DIR}/generated:/generated 
            ${POD_URI} /root/src/process.sh
        COMMAND touch ${CMAKE_CURRENT_BINARY_DIR}/generated/.done
)

add_custom_target(
        configuration
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/generated/.done
)
