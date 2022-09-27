cmake_minimum_required(VERSION 3.5.1)
project(bridge)

find_package(PkgConfig REQUIRED)

add_executable(${PROJECT_NAME} main.cpp)
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 11)

pkg_check_modules(LIBS REQUIRED alsa glibmm-2.4 giomm-2.4)
target_include_directories(${PROJECT_NAME} PUBLIC ${LIBS_INCLUDE_DIRS})
target_link_libraries(${PROJECT_NAME} PUBLIC ${LIBS_LIBRARIES})
link_directories(${LIBS_LIBRARY_DIRS})

if(NOT CONFIGURATION_INJECTED)
    add_dependencies(${PROJECT_NAME} configuration)
else()
    if(NOT EXISTS ${CMAKE_BINARY_DIR}/configuration/nl-version.h)
        message(FATAL_ERROR "Injecting the configuration did not work!")
    endif()
endif()

target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_BINARY_DIR}/configuration)

install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION bin)

SET(CPACK_GENERATOR "DEB")
SET(CPACK_BINARY_DEB On)
SET(CPACK_PACKAGE_CONTACT "info@nonlinear-labs.de")
SET(CPACK_DEBIAN_PACKAGE_MAINTAINER "Nonlinear Labs GmbH")
SET(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
SET(CPACK_DEBIAN_PACKAGE_DEPENDS "nltools")
SET(CPACK_DEBIAN_PACKAGE_DESCRIPTION "Bridge between C15 hardware UI and playround")
INCLUDE(CPack) 