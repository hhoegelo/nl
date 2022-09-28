cmake_minimum_required(VERSION 3.20)
project(playground)

add_executable(${PROJECT_NAME} main.cpp)

install(TARGETS ${PROJECT_NAME})

include(${CMAKE_BINARY_DIR}/cmake/package.cmake)
addConfiguration()
deb("nltools" "UI and Preset Management for Nonlinear Labs synthesizers")