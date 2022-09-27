cmake_minimum_required(VERSION 3.5.1)
project(nltools)

add_library(${PROJECT_NAME} SHARED main.cpp)
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 11)

if(NOT CONFIGURATION_INJECTED)
    add_dependencies(${PROJECT_NAME} configuration)
endif()

target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_BINARY_DIR}/configuration)

install(TARGETS ${PROJECT_NAME} DESTINATION lib)

SET(CPACK_GENERATOR "DEB")
SET(CPACK_BINARY_DEB On)
SET(CPACK_PACKAGE_CONTACT "info@nonlinear-labs.de")
SET(CPACK_DEBIAN_PACKAGE_MAINTAINER "Nonlinear Labs GmbH")
SET(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
SET(CPACK_DEBIAN_PACKAGE_DEPENDS "")
SET(CPACK_DEBIAN_PACKAGE_DESCRIPTION "Tools library for Nonlinear Labs software")
INCLUDE(CPack)