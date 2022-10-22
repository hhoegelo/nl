cmake_minimum_required(VERSION 3.5.1)
project(nltools)

find_package(PkgConfig REQUIRED)
include(GNUInstallDirs)

# add_subdirectory(tests)

file(GLOB_RECURSE HEADER_FILES ./include/*.h)
file(GLOB_RECURSE SOURCE_FILES ./*.cpp)
file(GLOB_RECURSE TEST_FILES ./tests/*)
list(REMOVE_ITEM SOURCE_FILES EXCLUDE REGEX ${TEST_FILES})

add_library(${PROJECT_NAME} SHARED ${SOURCE_FILES})
target_compile_options(${PROJECT_NAME} PRIVATE -std=c++14 -Wdouble-promotion)

pkg_check_modules(LIB REQUIRED glibmm-2.4 giomm-2.4 libsoup-2.4)
target_include_directories(${PROJECT_NAME} PUBLIC ${LIB_INCLUDE_DIRS})
target_link_libraries(${PROJECT_NAME} PUBLIC ${LIB_LIBRARIES})
link_directories(${LIB_LIBRARY_DIRS})

target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include/)
target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src/)

INSTALL(TARGETS ${PROJECT_NAME})
INSTALL(DIRECTORY ./include/ TYPE INCLUDE)

include(${CMAKE_BINARY_DIR}/cmake/package.cmake)
include(${CMAKE_BINARY_DIR}/cmake/configuration.cmake)

deb("" "Tools library for Nonlinear Labs software")
