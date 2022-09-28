cmake_minimum_required(VERSION 3.5.1)
project(bridge)

find_package(PkgConfig REQUIRED)

add_executable(${PROJECT_NAME} main.cpp)
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 11)

pkg_check_modules(LIBS REQUIRED alsa glibmm-2.4 giomm-2.4)
target_include_directories(${PROJECT_NAME} PUBLIC ${LIBS_INCLUDE_DIRS})
target_link_libraries(${PROJECT_NAME} PUBLIC ${LIBS_LIBRARIES})
link_directories(${LIBS_LIBRARY_DIRS})

install(TARGETS ${PROJECT_NAME} DESTINATION bin)

include(${CMAKE_BINARY_DIR}/cmake/package.cmake)
addConfiguration()
deb("nltools" "Bridge from LPC to EPC on NL C15 Synthesizer")
