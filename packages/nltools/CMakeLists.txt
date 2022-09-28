cmake_minimum_required(VERSION 3.5.1)
project(nltools)

add_library(${PROJECT_NAME} SHARED main.cpp)
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 11)

install(TARGETS ${PROJECT_NAME} DESTINATION lib)

include(${CMAKE_BINARY_DIR}/cmake/package.cmake)
addConfiguration()
deb("" "Tools library for Nonlinear Labs software")
