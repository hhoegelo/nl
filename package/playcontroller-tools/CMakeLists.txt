cmake_minimum_required(VERSION 3.0)

project(playcontroller-tools)

# SET
set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O2 -Wall")

# TARGETS
add_executable(playcontroller       src/playcontroller.c        src/linuxgpio.c)
add_executable(playcontroller-read  src/playcontroller-read.c   src/process-read-msgs.c)
add_executable(ehc                  src/ehc.c)
add_executable(ehc-preset           src/ehc-preset.c  ${CMAKE_BINARY_DIR}/shared/playcontroller/EHC-pedal-presets.c)
add_executable(make-cal-bin         src/make-cal-bin.c)

add_custom_command(
    COMMENT "Build link 'lpc'"
    TARGET playcontroller POST_BUILD
    COMMAND ln -s ./playcontroller lpc)

add_custom_command(
    COMMENT "Build link 'lpc-read'"
    TARGET playcontroller-read POST_BUILD
    COMMAND ln -s ./playcontroller-read lpc-read)

include_directories(src)
include_directories(${CMAKE_BINARY_DIR}/shared)

# INSTALL
install(TARGETS playcontroller                      DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)
install(TARGETS playcontroller-read                 DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)
install(TARGETS ehc                                 DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)
install(TARGETS ehc-preset                          DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)
install(TARGETS make-cal-bin                        DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/lpc       DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/lpc-read  DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)

include(${CMAKE_BINARY_DIR}/cmake/package.cmake)
deb("" "Tools running on beaglebone accessing the playcontroller")