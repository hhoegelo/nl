
registerPod()

add_custom_command(
    COMMENT "Build pi4 prefs"
    OUTPUT pi4-prefs.img
    DEPENDS ${POD_TARGET}
    VERBATIM
    COMMAND podman run 
        --network=none
        --authfile=${CMAKE_BINARY_DIR}/podman-authentication 
        --tls-verify=false
        --rm 
        -ti
        -v ${CMAKE_CURRENT_BINARY_DIR}:/out 
        ${POD_URI} cp /prefs.img /out/pi4-prefs.img
)

add_custom_target(pi4-prefs DEPENDS pi4-prefs.img)
