SET(TARGET_MACHINE web)

registerPod()

include(${CMAKE_SOURCE_DIR}/cmake/crossbuild.cmake)


crossBuild(
    NAME web-dev-env-deps
    DEPENDS nonmaps mc-view online-help recorder)

add_custom_command(
    COMMENT "Build web development environment"
    OUTPUT .web-dev-env
    DEPENDS web-dev-env-deps
    DEPENDS ${POD_TARGET}
    VERBATIM
        COMMAND rm -rf ${CMAKE_CURRENT_BINARY_DIR}/project
        COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/project/client
        COMMAND bindfs ${CMAKE_CURRENT_SOURCE_DIR}/packages/meteor/.meteor ${CMAKE_CURRENT_BINARY_DIR}/project/.meteor
        COMMAND bindfs ${CMAKE_CURRENT_SOURCE_DIR}/packages/meteor/client ${CMAKE_CURRENT_BINARY_DIR}/project/client/src
        #COMMAND bindfs ${CMAKE_BINARY_SOURCE_DIR}/generated/foo ${CMAKE_CURRENT_BINARY_DIR}/project/client/generated/
        
)

add_custom_target(web-dev-env DEPENDS .web-dev-env)
