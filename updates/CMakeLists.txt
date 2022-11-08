SET(BUILD_TASK update)

add_subdirectory(c15)

add_custom_target(update DEPENDS update-c15)