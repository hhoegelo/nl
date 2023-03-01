cmake_minimum_required(VERSION 3.0)
project(epc-scripts)

file(GLOB_RECURSE SCRIPTS ${CMAKE_CURRENT_SOURCE_DIR}/*.sh)
install(FILES ${SCRIPTS} DESTINATION ${CMAKE_INSTALL_FULL_BINDIR}/scripts
    PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
                GROUP_READ GROUP_WRITE GROUP_EXECUTE
                WORLD_READ WORLD_WRITE WORLD_EXECUTE)

include(${CMAKE_BINARY_DIR}/cmake/package.cmake)
deb("" "Helper scripts running on the C15 embedded PC")