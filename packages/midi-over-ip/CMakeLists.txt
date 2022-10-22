cmake_minimum_required(VERSION 3.5.1)
project(midi-over-ip)

add_executable(${PROJECT_NAME} main.cpp)
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 11)

install(TARGETS ${PROJECT_NAME} DESTINATION bin)

include(${CMAKE_BINARY_DIR}/cmake/package.cmake)
include(${CMAKE_BINARY_DIR}/cmake/configuration.cmake)
deb("nltools" "Makes midi devices connected to local usb port available for network devices")
