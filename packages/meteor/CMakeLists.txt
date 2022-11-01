cmake_minimum_required(VERSION 3.0)

project(meteor)

include(GNUInstallDirs)

install(FILES ${ALL_SRC} DESTINATION ${CMAKE_INSTALL_DATADIR}/meteor)

include(${CMAKE_BINARY_DIR}/cmake/package.cmake)
deb("" "Umbrella for various browser based UI applications for Nonlinear Labs synthesizers")