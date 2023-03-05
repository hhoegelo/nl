SET(BUILD_TASK update)

include(${CMAKE_SOURCE_DIR}/cmake/crossbuild.cmake)

add_subdirectory(c15)
add_subdirectory(c16)

add_custom_target(update DEPENDS update-c15)