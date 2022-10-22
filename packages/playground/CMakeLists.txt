cmake_minimum_required(VERSION 3.20)

project(playground)

SET(PLAYGROUND_HTTPSERVER_PORT 8080)
SET(PLAYGROUND_OLED_WEBSOCKET_PORT 8891)
SET(PLAYGROUND_PRESETLOAD_LOG_PORT 8892)
SET(SYNCJS_WEBSOCKET_PORT 8893)


find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBS REQUIRED glibmm-2.4 freetype2)

configure_file(src/CompileTimeOptions.h.in src/CompileTimeOptions.h)

file(GLOB_RECURSE SOURCE_FILES ./src/*.cpp)

add_executable(${PROJECT_NAME} ${SOURCE_FILES})

target_compile_definitions(${PROJECT_NAME} PRIVATE PLAYGROUND_HTTPSERVER_PORT=${PLAYGROUND_HTTPSERVER_PORT})
target_compile_definitions(${PROJECT_NAME} PRIVATE PLAYGROUND_OLED_WEBSOCKET_PORT=${PLAYGROUND_OLED_WEBSOCKET_PORT})
target_compile_definitions(${PROJECT_NAME} PRIVATE PLAYGROUND_PRESETLOAD_LOG_PORT=${PLAYGROUND_PRESETLOAD_LOG_PORT})
target_compile_definitions(${PROJECT_NAME} PRIVATE SYNCJS_WEBSOCKET_PORT=${SYNCJS_WEBSOCKET_PORT})

target_include_directories(${PROJECT_NAME} PRIVATE ./src)
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/src)
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_BINARY_DIR}/shared)
target_include_directories(${PROJECT_NAME} PRIVATE ${LIBS_INCLUDE_DIRS})

target_link_directories(${PROJECT_NAME} PRIVATE ${LIBS_LIBRARY_DIRS})
target_link_libraries(${PROJECT_NAME} PUBLIC ${LIBS_LIBRARIES})

install(TARGETS ${PROJECT_NAME})

include(${CMAKE_BINARY_DIR}/cmake/ccache.cmake)
include(${CMAKE_BINARY_DIR}/cmake/configuration.cmake)
include(${CMAKE_BINARY_DIR}/cmake/nltools.cmake)
include(${CMAKE_BINARY_DIR}/cmake/package.cmake)

deb("nltools" "UI and Preset Management for Nonlinear Labs synthesizers")
