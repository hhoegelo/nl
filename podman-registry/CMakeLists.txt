
add_custom_command(
    COMMENT "Provide local container registry"
    OUTPUT .registry
    VERBATIM
    COMMAND 
        mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/registry
    COMMAND 
        podman ps | grep docker.io/library/registry:2 
        || podman run -d -p 5000:5000 -v ${CMAKE_CURRENT_BINARY_DIR}/registry:/var/lib/registry docker.io/registry:2
)

add_custom_target(podman-registry DEPENDS .registry)