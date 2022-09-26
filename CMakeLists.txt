cmake_minimum_required(VERSION 3.2)

project(nl)

include(CTest)
include(cmake/podman.cmake)

SET(PODMAN_REGISTRY localhost:5000)

add_subdirectory(podman-registry)
add_subdirectory(build-environments)
add_subdirectory(packages)
add_subdirectory(updates)