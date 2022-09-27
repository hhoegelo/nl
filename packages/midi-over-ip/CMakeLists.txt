cmake_minimum_required(VERSION 3.5.1)
project(midi-over-ip)

add_executable(${PROJECT_NAME} main.cpp)
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 11)

if(NOT CONFIGURATION_INJECTED)
    add_dependencies(${PROJECT_NAME} configuration)
endif()

target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_BINARY_DIR}/configuration)

install(TARGETS ${PROJECT_NAME} DESTINATION bin)

SET(CPACK_GENERATOR "DEB")
SET(CPACK_BINARY_DEB On)
SET(CPACK_PACKAGE_CONTACT "info@nonlinear-labs.de")
SET(CPACK_DEBIAN_PACKAGE_MAINTAINER "Nonlinear Labs GmbH")
SET(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
SET(CPACK_DEBIAN_PACKAGE_DEPENDS "nltools")
SET(CPACK_DEBIAN_PACKAGE_DESCRIPTION "Midi netwrok bridge to make midi devices connected to the beaglebone available on epc")
INCLUDE(CPack) 