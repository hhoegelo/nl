SET(PROJECT c15)

add_subdirectory(beaglebone)
add_subdirectory(epc)
add_subdirectory(playcontroller)
add_subdirectory(web)

add_custom_target(update-c15 
    DEPENDS update-c15-beaglebone 
    DEPENDS update-c15-epc 
    DEPENDS update-c15-playcontroller 
    DEPENDS update-c15-web)