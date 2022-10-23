cmake_minimum_required(VERSION 3.20)
project(audio-engine VERSION 1.0.1)

SET(RECORDER_WEBSOCKET_PORT 8889)
SET(RECORDER_HTTPSERVER_PORT 8890)

if(NOT ARCHITECTURE)
  SET(ARCHITECTURE native)
endif()

find_package(PkgConfig REQUIRED)
find_package(OpenMP REQUIRED)

pkg_check_modules(LIBS REQUIRED glibmm-2.4 giomm-2.4 alsa flac libsoup-2.4)

file(GLOB_RECURSE SOURCE_FILES ./src/*.cpp)

add_executable(${PROJECT_NAME} ${SOURCE_FILES})

set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 20)

target_compile_options(${PROJECT_NAME} PRIVATE -march=${ARCHITECTURE})
target_compile_options(${PROJECT_NAME} PRIVATE ${OpenMP_CXX_FLAGS})

target_compile_definitions(${PROJECT_NAME} PRIVATE RECORDER_WEBSOCKET_PORT=${RECORDER_WEBSOCKET_PORT} RECORDER_HTTPSERVER_PORT=${RECORDER_HTTPSERVER_PORT})

target_link_options(${PROJECT_NAME} PRIVATE ${OpenMP_EXE_LINKER_FLAGS})

target_include_directories(${PROJECT_NAME} PUBLIC ${LIBS_INCLUDE_DIRS} ./src)
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_BINARY_DIR}/shared)

target_link_libraries(${PROJECT_NAME} PUBLIC ${LIBS_LIBRARIES})

install(TARGETS ${PROJECT_NAME})

include(${CMAKE_BINARY_DIR}/cmake/ccache.cmake)
include(${CMAKE_BINARY_DIR}/cmake/configuration.cmake)
include(${CMAKE_BINARY_DIR}/cmake/nltools.cmake)
include(${CMAKE_BINARY_DIR}/cmake/package.cmake)

deb("nltools" "Audio Engine for Nonlinear Labs synthesizers")
