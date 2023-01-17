SET(PROJECT c15)

add_subdirectory(pi4)
add_subdirectory(web)

add_custom_target(update-c16
    DEPENDS update-c16-pi4 
    DEPENDS update-c16-web)

#buildImage(
#    NAME update-c16
#    BASE pi4-update-img
#    ADD update-c16-pi4
#    ADD update-c16-web    
#    POST_PROCESS bundle.sh
#)