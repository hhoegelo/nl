cmake_minimum_required(VERSION 3.0)

project(online-help)

include(GNUInstallDirs)

install(DIRECTORY src/ DESTINATION ${CMAKE_INSTALL_DATADIR}/online-help)

include(${CMAKE_BINARY_DIR}/cmake/package.cmake)
deb("" "HTML Manual for Nonlinear Labs C15 synthesizers")