add_subdirectory(boot)
add_subdirectory(root)
add_subdirectory(pre)

add_custom_command(
    COMMENT "Build pi4 factory image"
    OUTPUT pi4-factory.img
    DEPENDS pi4-rootfs pi4-bootfs pi4-prefs
    DEPENDS pre/pi4-prefs.img
    DEPENDS root/pi4-rootfs.img
    DEPENDS boot/pi4-bootfs.img
    VERBATIM
    COMMAND truncate -s 2009071616 ${CMAKE_CURRENT_BINARY_DIR}/pi4-factory.img
    COMMAND dd if=${CMAKE_CURRENT_BINARY_DIR}/pre/pi4-prefs.img of=${CMAKE_CURRENT_BINARY_DIR}/pi4-factory.img seek=${PI4_FACTORY_BASE_IMAGE_PRE_FS_POSITION} count=${PI4_FACTORY_BASE_IMAGE_PRE_FS_SIZE}
    COMMAND dd if=${CMAKE_CURRENT_BINARY_DIR}/boot/pi4-bootfs.img of=${CMAKE_CURRENT_BINARY_DIR}/pi4-factory.img seek=${PI4_FACTORY_BASE_IMAGE_BOOT_FS_POSITION} count=${PI4_FACTORY_BASE_IMAGE_BOOT_FS_SIZE}
    COMMAND dd if=${CMAKE_CURRENT_BINARY_DIR}/root/pi4-rootfs.img of=${CMAKE_CURRENT_BINARY_DIR}/pi4-factory.img seek=${PI4_FACTORY_BASE_IMAGE_ROOT_FS_POSITION} count=${PI4_FACTORY_BASE_IMAGE_ROOT_FS_SIZE}
)

add_custom_target(pi4-factory-img DEPENDS pi4-factory.img)
