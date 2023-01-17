add_subdirectory(boot)
add_subdirectory(root)
add_subdirectory(pre)

add_custom_command(
    COMMENT "Build pi4 factory image"
    OUTPUT pi4-factory.img
    DEPENDS pi4-rootfs pi4-bootfs pi4-prefs
    VERBATIM
    COMMAND truncate -s 2009071616 ${CMAKE_CURRENT_BINARY_DIR}/pi4-factory.img
    COMMAND dd if=${CMAKE_CURRENT_BINARY_DIR}/pre/pi4-prefs.img of=${CMAKE_CURRENT_BINARY_DIR}/pi4-factory.img seek=0 count=8192
    COMMAND dd if=${CMAKE_CURRENT_BINARY_DIR}/boot/pi4-bootfs.img of=${CMAKE_CURRENT_BINARY_DIR}/pi4-factory.img seek=8192 count=524288
    COMMAND dd if=${CMAKE_CURRENT_BINARY_DIR}/root/pi4-rootfs.img of=${CMAKE_CURRENT_BINARY_DIR}/pi4-factory.img seek=532480 count=3391488
)

add_custom_target(pi4-factory-img DEPENDS pi4-factory.img)
