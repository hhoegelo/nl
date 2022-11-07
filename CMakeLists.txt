cmake_minimum_required(VERSION 3.2)

project(nl)

include(CTest)
include(cmake/podman.cmake)

SET(NONLINEARLABS_SERVER "https://h2949050.stratoserver.net/")
SET(PODMAN_REGISTRY quelltextlabor.de:5001)

add_subdirectory(cmake)
add_subdirectory(shared)
add_subdirectory(configuration)
add_subdirectory(build-environments)
add_subdirectory(packages)
add_subdirectory(updates)
add_subdirectory(os)