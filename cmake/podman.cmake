function(registerPod DEPENDECIES)
  configure_file(Dockerfile.in ${CMAKE_CURRENT_BINARY_DIR}/Dockerfile @ONLY)
  file(SHA1 ${CMAKE_CURRENT_BINARY_DIR}/Dockerfile DOCKERFILE_SHA1)

  set(POD_TARGET pod-${DOCKERFILE_SHA1})
  
  set(POD_TARGET ${POD_TARGET} PARENT_SCOPE)
  set(POD_URI ${PODMAN_REGISTRY}/generic:${DOCKERFILE_SHA1} PARENT_SCOPE)

  if (NOT TARGET ${POD_TARGET})
    configure_file(${CMAKE_SOURCE_DIR}/cmake/runPodman.sh.in ${CMAKE_CURRENT_BINARY_DIR}/runPodman.sh)
    
    add_custom_command(
      COMMENT "Provide Podman for ${BUILD_TASK}/${TARGET_MACHINE}/${DOCKERFILE_SHA1}"
      OUTPUT .podman
      DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/Dockerfile
      DEPENDS ${DEPENDECIES}
      VERBATIM
      COMMAND ${CMAKE_CURRENT_BINARY_DIR}/runPodman.sh)
    
    message("Add pod ${POD_TARGET} for ${CMAKE_CURRENT_SOURCE_DIR}")
    add_custom_target(${POD_TARGET} DEPENDS .podman)
  endif()
endfunction()

function(crossBuild NAME)
  MESSAGE("crossBuild: ${NAME}")

  file(SHA1 ${CMAKE_BINARY_DIR}/build-environments/${TARGET_MACHINE}/Dockerfile DOCKERFILE_SHA1)

  # commands for cross building all the desired packages
  foreach(PACKAGE ${ARGN})

    string(REGEX MATCH \\[.*\\] PACKAGE_DEPS ${PACKAGE})
    string(REGEX REPLACE \\[ "" PACKAGE_DEPS "${PACKAGE_DEPS}")
    string(REGEX REPLACE \\] "" PACKAGE_DEPS "${PACKAGE_DEPS}")
    string(REGEX REPLACE \\[.*\\] "" PACKAGE ${PACKAGE})

    SET(DEPENDENCIES ${DEPENDENCIES} ${PACKAGE})

    string(TOUPPER ${PACKAGE} PACKAGE_CANONIC)
    
    string(REPLACE "-" "_" PACKAGE_CANONIC ${PACKAGE_CANONIC})
    set(RUN_POD podman run 
      --tls-verify=false --rm -ti
      -v ${CMAKE_SOURCE_DIR}/packages/${PACKAGE}:/src 
      -v ${CMAKE_SOURCE_DIR}/build-environments/${TARGET_MACHINE}:/build-environment 
      -v ${CMAKE_CURRENT_BINARY_DIR}/build-${PACKAGE}:/build
      -v ${CMAKE_BINARY_DIR}/configuration:/build/configuration
      -v ${CMAKE_BINARY_DIR}/shared:/build/shared
      -v ${CMAKE_BINARY_DIR}/cmake:/build/cmake
      -v ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE}-sysroot:/staging
      -w /build
      ${PODMAN_REGISTRY}/generic:${DOCKERFILE_SHA1})

    file(GLOB_RECURSE ALL_PROJECT_FILES ${CMAKE_SOURCE_DIR}/packages/${PACKAGE}/*)
    file(GLOB_RECURSE ALL_CONFIGURATION_FILES ${CMAKE_SOURCE_DIR}/configuration/*)

    if(EXISTS "${CMAKE_SOURCE_DIR}/build-environments/${TARGET_MACHINE}/toolchain.cmake")
      SET(TOOLCHAIN -DCMAKE_TOOLCHAIN_FILE=/build-environment/toolchain.cmake)
    endif()

    if(PACKAGE_DEPS)
      add_custom_command(
        COMMENT "Prepare sysroot for x-build for ${PACKAGE} for ${TARGET_MACHINE}"
        OUTPUT .${PACKAGE}-sysroot
        DEPENDS ${PACKAGE_DEPS}
        DEPENDS ${PACKAGE_DEPS}.deb
        COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE}-sysroot
        COMMAND dpkg-deb -x ${PACKAGE_DEPS}.deb ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE}-sysroot 
        COMMAND touch .${PACKAGE}-sysroot
      )
    else()
      add_custom_command(
        COMMENT "No sysroot to prepare for x-build for ${PACKAGE} for ${TARGET_MACHINE}"
        OUTPUT .${PACKAGE}-sysroot
        COMMAND COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE}-sysroot
        COMMAND touch .${PACKAGE}-sysroot
      )
    endif()

    add_custom_command(
      COMMENT "X-Building ${PACKAGE} for ${TARGET_MACHINE}"
      OUTPUT ${PACKAGE}.deb
      DEPENDS configuration
      DEPENDS pod-${DOCKERFILE_SHA1}
      DEPENDS ${ALL_PROJECT_FILES}
      DEPENDS ${ALL_CONFIGURATION_FILES}
      DEPENDS .${PACKAGE}-sysroot
      VERBATIM
      COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/build-${PACKAGE}
      COMMAND ${RUN_POD} cmake -DCROSS_BUILD=On ${TOOLCHAIN} /src
      COMMAND ${RUN_POD} make -C /build install
      COMMAND ${RUN_POD} cpack -D CPACK_PACKAGE_FILE_NAME=${PACKAGE}
      COMMAND cp ${CMAKE_CURRENT_BINARY_DIR}/build-${PACKAGE}/${PACKAGE}.deb ${CMAKE_CURRENT_BINARY_DIR})
  endforeach()

  list(TRANSFORM DEPENDENCIES APPEND .deb)
  SET(DEPENDENCIES_FILES ${DEPENDENCIES})
  list(TRANSFORM DEPENDENCIES PREPEND ${CMAKE_CURRENT_BINARY_DIR}/)

  add_custom_command(
    COMMENT "Build ${NAME}"
    DEPENDS ${DEPENDENCIES}
    OUTPUT ${NAME}.tar.gz
    COMMAND echo "pack the deps into a tar gz"
    COMMAND tar -czf ${NAME}.tar.gz -C ${CMAKE_CURRENT_BINARY_DIR} ${DEPENDENCIES_FILES}
  )

  add_custom_target(${NAME} DEPENDS ${NAME}.tar.gz)
endfunction()