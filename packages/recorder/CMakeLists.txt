cmake_minimum_required(VERSION 3.0)

project(recorder)

include(GNUInstallDirs)

file(GLOB FONT_FILES ./fonts/*)
file(GLOB IMG_FILES ./img/*)
file(GLOB SRC_FILES *.ico *.html *.css)

configure_file(constants.ts.in constants.ts)
configure_file(tsconfig.json tsconfig.json)

add_custom_command(
    COMMENT "Recorder"
    OUTPUT recorder.js
    DEPENDS ${FONT_FILES} 
    DEPENDS ${IMG_FILES} 
    DEPENDS ${SRC_FILES}
    COMMAND tsc --project ${CMAKE_CURRENT_BINARY_DIR}/tsconfig.json
)

add_custom_target(recorder ALL DEPENDS recorder.js)

install(FILES ${FONT_FILES} DESTINATION ${CMAKE_INSTALL_DATADIR}/recorder/fonts)
install(FILES ${IMG_FILES} DESTINATION ${CMAKE_INSTALL_DATADIR}/recorder/img)
install(FILES ${SRC_FILES} DESTINATION ${CMAKE_INSTALL_DATADIR}/recorder/)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/recorder.js DESTINATION ${CMAKE_INSTALL_DATADIR}/recorder/)

include(${CMAKE_BINARY_DIR}/cmake/package.cmake)
deb("" "HTML UI for built-in flac recorder of Nonlinear Labs synthesizers")
