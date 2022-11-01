cmake_minimum_required(VERSION 3.0)

project(mc-view)

include(GNUInstallDirs)

file(GLOB ALL_FONTS fonts/*)
file(GLOB ALL_SRC *.css *.otf *.js *.png *.ico *.html *.js *.svg ${CMAKE_CURRENT_BINARY_DIR}/build-time-info.js)

configure_file(build-time-info.js.in build-time-info.js @ONLY)

install(FILES ${ALL_SRC} DESTINATION ${CMAKE_INSTALL_DATADIR}/mc-view)
install(FILES ${ALL_FONTS} DESTINATION ${CMAKE_INSTALL_DATADIR}/mc-view/fonts)

include(${CMAKE_BINARY_DIR}/cmake/package.cmake)
deb("" "Browser based Macro Control User Interface for Nonlinear Labs synthesizers")