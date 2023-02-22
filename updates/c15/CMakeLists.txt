SET(PROJECT c15)

add_subdirectory(beaglebone)
add_subdirectory(epc)
add_subdirectory(playcontroller)

configure_file(bundle.sh bundle.sh)

file(GLOB_RECURSE UPDATE_SCRIPTS ${CMAKE_SOURCE_DIR}/update_scripts/*)

foreach(FILE ${UPDATE_SCRIPTS})
    configure_file(${FILE} ${FILE})
endforeach()

registerPod()

add_custom_command(
    OUTPUT update-c15.tar
    DEPENDS ${POD_TARGET}
    DEPENDS os-beaglebone-factory-rootfs # for MLO and u-boot
    DEPENDS update-c15-beaglebone 
    DEPENDS update-c15-epc 
    DEPENDS update-c15-playcontroller
    DEPENDS ${CMAKE_BINARY_DIR}/updates/c15/beaglebone/update-c15-beaglebone.tar
    DEPENDS ${CMAKE_BINARY_DIR}/updates/c15/epc/update-c15-epc.tar
    DEPENDS ${CMAKE_BINARY_DIR}/updates/c15/playcontroller/update-c15-playcontroller.tar
    DEPENDS ${CMAKE_BINARY_DIR}/os/beaglebone/factory-rootfs/os-beaglebone-factory-MLO
    DEPENDS ${CMAKE_BINARY_DIR}/os/beaglebone/factory-rootfs/os-beaglebone-factory-u-boot.img
    VERBATIM
    COMMAND podman run 
        --authfile=${CMAKE_BINARY_DIR}/podman-authentication
        --tls-verify=false --rm -ti
        -v ${CMAKE_BINARY_DIR}:/bindir
        -v ${CMAKE_CURRENT_BINARY_DIR}:/out 
        ${PODMAN_REGISTRY}/generic:${DOCKERFILE_SHA1} /out/bundle.sh 
            /out
            /bindir/os/beaglebone/factory-rootfs/os-beaglebone-factory-MLO
            /bindir/os/beaglebone/factory-rootfs/os-beaglebone-factory-u-boot.img
            /out/beaglebone/update-c15-beaglebone.tar
            /out/epc/update-c15-epc.tar
            /out/playcontroller/update-c15-playcontroller.tar
)

add_custom_target(update-c15 DEPENDS update-c15.tar)