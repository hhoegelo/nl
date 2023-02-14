SET(PROJECT c15)

add_subdirectory(pi4)
add_subdirectory(web)

include(${CMAKE_SOURCE_DIR}/cmake/pi4-image-def.cmake)

registerPod()

# this belongs into a cmake file
function(buildImage)
    cmake_parse_arguments(BUILD_IMAGE "" "NAME;BASE;POST_PROCESS_POD;POST_PROCESS_SCRIPT" "ADD;DEPENDS" ${ARGN} )

    configure_file(${BUILD_IMAGE_POST_PROCESS_SCRIPT} ${BUILD_IMAGE_POST_PROCESS_SCRIPT})

    foreach(PACKAGE_TO_ADD ${BUILD_IMAGE_ADD})
        string(APPEND PCKGS " ${CMAKE_BINARY_DIR}/${PACKAGE_TO_ADD}")
    endforeach()

    if(BUILD_IMAGE_POST_PROCESS_POD)
        add_custom_command(
            OUTPUT ${BUILD_IMAGE_NAME}.tar.gz
            DEPENDS ${BUILD_IMAGE_DEPENDS}
            COMMAND podman run 
                --network=none
                --authfile=${CMAKE_BINARY_DIR}/podman-authentication 
                --tls-verify=false
                --privileged 
                --rm 
                -ti
                -v ${CMAKE_BINARY_DIR}:${CMAKE_BINARY_DIR} 
                ${BUILD_IMAGE_POST_PROCESS_POD} ${CMAKE_CURRENT_BINARY_DIR}/${BUILD_IMAGE_POST_PROCESS_SCRIPT} ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_BINARY_DIR}/${BUILD_IMAGE_BASE} ${PCKGS}
        )
    else()
        add_custom_command(
            OUTPUT ${BUILD_IMAGE_NAME}.tar.gz
            DEPENDS ${BUILD_IMAGE_DEPENDS}
            COMMAND ${CMAKE_CURRENT_BINARY_DIR}/${BUILD_IMAGE_POST_PROCESS_SCRIPT} ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_BINARY_DIR}/${BUILD_IMAGE_BASE} ${PCKGS}
        )
    endif() 
  
    add_custom_target(
        ${BUILD_IMAGE_NAME}
        DEPENDS ${BUILD_IMAGE_NAME}.tar.gz        
    )
endfunction()

buildImage(
    NAME update-c16
    DEPENDS ${POD_TARGET}
    DEPENDS pi4-update-img
    DEPENDS update-c16-web
    DEPENDS update-c16-pi4
    BASE os/pi4/update-img/pi4-update.img
    ADD updates/c16/pi4/update-c16-pi4.tar.gz
    ADD updates/c16/web/update-c16-web.tar.gz
    POST_PROCESS_POD ${POD_URI}
    POST_PROCESS_SCRIPT bundle.sh)