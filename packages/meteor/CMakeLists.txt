cmake_minimum_required(VERSION 3.0)

project(meteor)

include(GNUInstallDirs)

file(GLOB_RECURSE ALL_METEOR_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} .meteor/*)
file(GLOB_RECURSE ALL_CLIENT_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} client/*)
list(FILTER ALL_METEOR_FILES EXCLUDE REGEX .meteor/local/)
set(ALL_NODE_FILES .meteorignore package-lock.json package.json)

foreach(FILE ${ALL_METEOR_FILES} ${ALL_CLIENT_FILES} ${ALL_NODE_FILES})
    configure_file(${FILE} ${FILE} COPYONLY)
endforeach()

add_custom_command(
    COMMENT "Build Meteor App"
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/out/index.html
    DEPENDS ${ALL_CLIENT_FILES}
    VERBATIM
    COMMAND node ${NODE_MODULES}/meteor-build-client/main.js ${CMAKE_CURRENT_BINARY_DIR}/out
    )

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/out/ DESTINATION ${CMAKE_INSTALL_DATADIR}/meteor)

add_custom_target(meteor ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/out/index.html)

include(${CMAKE_BINARY_DIR}/cmake/package.cmake)
deb("" "Umbrella for various browser based UI applications for Nonlinear Labs synthesizers")