cmake_minimum_required(VERSION 3.18.4)
include(${CMAKE_BINARY_DIR}/cmake/ccache.cmake)

######################################################
######################################################
# PLAYGROUND LIBRARY #################################
project(playground-lib) ##############################
######################################################
######################################################

SET(PLAYGROUND_HTTPSERVER_PORT      8080)
SET(PLAYGROUND_OLED_WEBSOCKET_PORT  8891)
SET(PLAYGROUND_PRESETLOAD_LOG_PORT  8892)
SET(SYNCJS_WEBSOCKET_PORT           8893)
SET(LIBNAME ${PROJECT_NAME})

if(NOT ARCHITECTURE)
  SET(ARCHITECTURE native)
endif()

find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBS REQUIRED glibmm-2.4 giomm-2.4 gio-unix-2.0 freetype2 uuid libpng libsoup-2.4)


include(GNUInstallDirs)

configure_file(src/CompileTimeOptions.h.in src/CompileTimeOptions.h)
configure_file(src/proxies/hwui/panel-unit/boled/setup/UISoftwareVersionEditor.cpp.in src/UISoftwareVersionEditor.cpp)
configure_file(src/device-info/BuildVersion.cpp.in src/BuildVersion.cpp)

file(GLOB_RECURSE LIB_SOURCE_FILES ./src/*.cpp)
list(FILTER LIB_SOURCE_FILES  EXCLUDE REGEX /src/testing/)
list(FILTER LIB_SOURCE_FILES  EXCLUDE REGEX /src/playground.cpp)

add_library(${PROJECT_NAME} 
  ${LIB_SOURCE_FILES} 
  src/UISoftwareVersionEditor.cpp 
  src/BuildVersion.cpp
  ${CMAKE_BINARY_DIR}/shared/playcontroller/EHC-pedal-presets.c
  )

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)
target_link_libraries(${LIBNAME} PRIVATE Threads::Threads)

set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 17)

target_compile_definitions(${PROJECT_NAME} PRIVATE PLAYGROUND_HTTPSERVER_PORT=${PLAYGROUND_HTTPSERVER_PORT})
target_compile_definitions(${PROJECT_NAME} PRIVATE PLAYGROUND_OLED_WEBSOCKET_PORT=${PLAYGROUND_OLED_WEBSOCKET_PORT})
target_compile_definitions(${PROJECT_NAME} PRIVATE PLAYGROUND_PRESETLOAD_LOG_PORT=${PLAYGROUND_PRESETLOAD_LOG_PORT})
target_compile_definitions(${PROJECT_NAME} PRIVATE SYNCJS_WEBSOCKET_PORT=${SYNCJS_WEBSOCKET_PORT})

target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/src)
target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_BINARY_DIR}/shared)
target_include_directories(${PROJECT_NAME} PUBLIC ./src)
target_include_directories(${PROJECT_NAME} PUBLIC ${LIBS_INCLUDE_DIRS})

target_link_directories(${PROJECT_NAME} PRIVATE ${LIBS_LIBRARY_DIRS})
target_link_libraries(${PROJECT_NAME} PRIVATE ${LIBS_LIBRARIES})

include(${CMAKE_BINARY_DIR}/cmake/configuration.cmake)
include(${CMAKE_BINARY_DIR}/cmake/nltools.cmake)
include(${CMAKE_BINARY_DIR}/cmake/package.cmake)

######################################################
######################################################
# PLAYGROUND BINARY ##################################
project(playground) ##################################
######################################################
######################################################

add_executable(${PROJECT_NAME} ./src/playground.cpp )

set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 17)

target_link_directories(${PROJECT_NAME} PRIVATE ${LIBS_LIBRARY_DIRS})
target_link_libraries(${PROJECT_NAME} PRIVATE ${LIBS_LIBRARIES} ${LIBNAME})

install(TARGETS ${PROJECT_NAME})
install(DIRECTORY ./resources/ DESTINATION ${CMAKE_INSTALL_DATADIR}/playground)

include(${CMAKE_BINARY_DIR}/cmake/nltools.cmake)
include(${CMAKE_BINARY_DIR}/cmake/package.cmake)
deb("nltools" "UI and Preset Management for Nonlinear Labs synthesizers")

######################################################
######################################################
# PLAYGROUND TESTS BINARY ############################
project(playground-tests) ############################
######################################################
######################################################

file(GLOB_RECURSE TEST_SOURCE_FILES ./src/testing/*.cpp)

add_executable(${PROJECT_NAME} ${TEST_SOURCE_FILES})

set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 17)

target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_BINARY_DIR}/shared/third-party)

target_link_directories(${PROJECT_NAME} PRIVATE ${LIBS_LIBRARY_DIRS})
target_link_libraries(${PROJECT_NAME} PRIVATE ${LIBS_LIBRARIES} ${LIBNAME})

include(${CMAKE_BINARY_DIR}/cmake/nltools.cmake)
include(${CMAKE_BINARY_DIR}/cmake/configuration.cmake)
