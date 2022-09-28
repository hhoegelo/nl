cmake_minimum_required(VERSION 3.20)
project(audio-engine VERSION 1.0.1)

add_executable(${PROJECT_NAME} main.cpp)
install(TARGETS ${PROJECT_NAME})

include(${CMAKE_BINARY_DIR}/cmake/package.cmake)
addConfiguration()
deb("nltools" "Audio Engine for Nonlinear Labs synthesizers")
