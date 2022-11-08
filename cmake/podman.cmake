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
      OUTPUT .podman-${DOCKERFILE_SHA1}
      DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/Dockerfile
      DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/runPodman.sh
      DEPENDS ${DEPENDECIES}
      VERBATIM
      COMMAND ${CMAKE_CURRENT_BINARY_DIR}/runPodman.sh
      COMMAND touch .podman-${DOCKERFILE_SHA1}
      )
    
    message("Add target ${POD_TARGET} for ${CMAKE_CURRENT_SOURCE_DIR}")
    add_custom_target(${POD_TARGET} DEPENDS .podman-${DOCKERFILE_SHA1})
  endif()
endfunction()

function(crossBuild NAME)
  MESSAGE("crossBuild: ${NAME}")

  file(SHA1 ${CMAKE_BINARY_DIR}/build-environments/${TARGET_MACHINE}/Dockerfile DOCKERFILE_SHA1)

  # commands for cross building all the desired packages
  foreach(PACKAGE ${ARGN})

    message("Processing package ${PACKAGE}")

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
      -v ${CMAKE_BINARY_DIR}/ccache:/root/.ccache
      -w /build
      ${PODMAN_REGISTRY}/generic:${DOCKERFILE_SHA1})

    file(GLOB_RECURSE ALL_PROJECT_FILES ${CMAKE_SOURCE_DIR}/packages/${PACKAGE}/*)
    file(GLOB_RECURSE ALL_CONFIGURATION_FILES ${CMAKE_SOURCE_DIR}/configuration/*)

    if(EXISTS "${CMAKE_SOURCE_DIR}/build-environments/${TARGET_MACHINE}/toolchain.cmake")
      SET(TOOLCHAIN -DCMAKE_TOOLCHAIN_FILE=/build-environment/toolchain.cmake)
    endif()

    if(PACKAGE_DEPS)
      add_custom_command(
        COMMENT "Clean up sysroot for x-build for ${PACKAGE} for ${TARGET_MACHINE}"
        OUTPUT .${PACKAGE}-sysroot-clean
        COMMAND rm -rf ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE}-sysroot
        COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE}-sysroot
        COMMAND touch .${PACKAGE}-sysroot-clean
      )

      foreach(DEP ${PACKAGE_DEPS})
        add_custom_command(
          COMMENT "Prepare sysroot for x-build for ${PACKAGE} for ${TARGET_MACHINE} - install ${DEP}"
          OUTPUT .${PACKAGE}-sysroot-${DEP}
          DEPENDS .${PACKAGE}-sysroot-clean
          DEPENDS ${DEP}.deb
          COMMAND dpkg-deb -x ${DEP}.deb ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE}-sysroot 
          COMMAND touch .${PACKAGE}-sysroot-${DEP}
        )
      endforeach()

      list(TRANSFORM PACKAGE_DEPS PREPEND ".${PACKAGE}-sysroot-" OUTPUT_VARIABLE DEB_INSTALL_TARGET)

      add_custom_command(
        COMMENT "Prepare sysroot for x-build for ${PACKAGE} for ${TARGET_MACHINE}"
        OUTPUT .${PACKAGE}-sysroot
        DEPENDS ${DEB_INSTALL_TARGET}
        COMMAND touch .${PACKAGE}-sysroot
      )
    else()
      add_custom_command(
        COMMENT "No sysroot to prepare for x-build for ${PACKAGE} for ${TARGET_MACHINE}"
        OUTPUT .${PACKAGE}-sysroot
        COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE}-sysroot
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
      COMMAND mkdir -p ${CMAKE_BINARY_DIR}/ccache
      COMMAND ${RUN_POD} cmake -DCROSS_BUILD=On ${TOOLCHAIN} -D CMAKE_BUILD_TYPE=Release /src
      COMMAND ${RUN_POD} cmake --build .
      COMMAND ${RUN_POD} cmake --install .
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
    COMMAND tar -czf ${NAME}.tar.gz -C ${CMAKE_CURRENT_BINARY_DIR} ${DEPENDENCIES_FILES}
  )

  add_custom_target(${NAME} DEPENDS ${NAME}.tar.gz)
endfunction()