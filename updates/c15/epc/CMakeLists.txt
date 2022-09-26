project(c15-update-epc)

crossBuild(epc nltools)
crossBuild(epc audio-engine)
crossBuild(epc playground)

add_custom_command(
    COMMENT Build ${PROJECT_NAME}
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/nltools.deb
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/audio-engine.deb
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/playground.deb
    OUTPUT ${PROJECT_NAME}.tar.gz
    COMMAND echo "pack the deps into a tar gz"
)

add_custom_target(${PROJECT_NAME} depends ${PROJECT_NAME}.tar.gz)
add_dependencies(${PROJECT_NAME} c15-update-epc-nltools c15-update-epc-audio-engine c15-update-epc-playground)