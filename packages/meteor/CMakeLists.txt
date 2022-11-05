cmake_minimum_required(VERSION 3.0)

project(meteor)

include(GNUInstallDirs)

add_custom_command(
    COMMENT "Build Meteor App"
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/.meteor
    VERBATIM
    COMMAND echo "foo bar" > ${CMAKE_CURRENT_BINARY_DIR}/.meteor
    )

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/.meteor DESTINATION ${CMAKE_INSTALL_DATADIR}/meteor)

add_custom_target(meteor ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/.meteor)

include(${CMAKE_BINARY_DIR}/cmake/package.cmake)
deb("" "Umbrella for various browser based UI applications for Nonlinear Labs synthesizers")