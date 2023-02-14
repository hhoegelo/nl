
add_custom_command(
    COMMENT "Build pi4 update image"
    OUTPUT pi4-update.img
    DEPENDS ../factory-img/pi4-factory.img
    VERBATIM
    COMMAND cp ../factory-img/pi4-factory.img ./pi4-update.img
)

add_custom_target(pi4-update-img 
    DEPENDS pi4-factory-img
    DEPENDS pi4-update.img)
