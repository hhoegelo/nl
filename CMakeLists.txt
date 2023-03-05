cmake_minimum_required(VERSION 3.2)

project(nl)

include(CTest)
include(cmake/podman.cmake)

find_program(PODMAN         podman          REQUIRED)
find_program(QEMU           qemu-arm-static REQUIRED)
find_program(JQ             jq              REQUIRED)
find_program(BINDFS         bindfs          REQUIRED)


SET(NONLINEARLABS_SERVER "https://h2949050.stratoserver.net/")
SET(PODMAN_REGISTRY quelltextlabor.de:5001)
SET(DEVELOPER_ROLE "developer" CACHE STRING "developer | pod-maintainer")

if(${DEVELOPER_ROLE} STREQUAL "pod-maintainer")
    if(NOT ${PODMAN_REGISTRY_PASSWORD})
        message(FATAL_ERROR "Pod maintainers have to set a PODMAN_REGISTRY_PASSWORD")
    endif()
endif()

add_subdirectory(cmake)
add_subdirectory(shared)
add_subdirectory(configuration)
add_subdirectory(build-environment)
add_subdirectory(package)
add_subdirectory(update)
add_subdirectory(os)