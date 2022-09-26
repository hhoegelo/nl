function(registerPod)
  configure_file(Dockerfile.in ${CMAKE_CURRENT_BINARY_DIR}/Dockerfile @ONLY)
  file(SHA1 ${CMAKE_CURRENT_BINARY_DIR}/Dockerfile DOCKERFILE_SHA1)
  
  set(DOCKERNAME ${BUILD_TASK}-${TARGET_MACHINE})

  configure_file(${CMAKE_SOURCE_DIR}/cmake/runPodman.sh.in ${CMAKE_CURRENT_BINARY_DIR}/runPodman.sh)
  
  add_custom_command(
    COMMENT "Provide Podman for ${DOCKERNAME}"
    OUTPUT .podman
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/Dockerfile
    VERBATIM
    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/runPodman.sh)
  
  message("Add pod ${DOCKERNAME}")
  add_custom_target(${DOCKERNAME} DEPENDS .podman)
  add_dependencies(${DOCKERNAME} podman-registry)
endfunction()

function(crossBuild NAME)
  MESSAGE("crossBuild: ${NAME}")

  file(SHA1 ${CMAKE_BINARY_DIR}/build-environments/${TARGET_MACHINE}/Dockerfile DOCKERFILE_SHA1)
  set(DOCKERNAME build-environment-${TARGET_MACHINE})

  # commands for cross building all the desired packages
  foreach(PACKAGE ${ARGN})
    string(TOUPPER ${PACKAGE} PACKAGE_CANONIC)
    string(REPLACE "-" "_" PACKAGE_CANONIC ${PACKAGE_CANONIC})
    set(POD podman run 
      --tls-verify=false --rm 
      -v ${CMAKE_SOURCE_DIR}/packages/${PACKAGE}:/src 
      -v ${CMAKE_CURRENT_BINARY_DIR}/build-${PACKAGE}:/build 
      -w /build
      ${PODMAN_REGISTRY}/${DOCKERNAME}:${DOCKERFILE_SHA1})

    file(GLOB_RECURSE ALL_PROJECT_FILES ${CMAKE_SOURCE_DIR}/packages/${PACKAGE}/*)

    add_custom_command(
      COMMENT "X-Building ${PACKAGE} for ${TARGET_MACHINE}"
      OUTPUT ${PACKAGE}.deb
      DEPENDS ${ALL_PROJECT_FILES}
      VERBATIM
      COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/build-${PACKAGE}
      COMMAND ${POD} cmake -S /src -B /build
      COMMAND ${POD} make -C /build install
      COMMAND ${POD} cpack -D CPACK_PACKAGE_FILE_NAME=${PACKAGE}
      COMMAND cp ${CMAKE_CURRENT_BINARY_DIR}/build-${PACKAGE}/${PACKAGE}.deb ${CMAKE_CURRENT_BINARY_DIR})
  endforeach()

  SET(DEPENDENCIES ${ARGN})
  list(TRANSFORM DEPENDENCIES APPEND .deb)
  SET(DEPENDENCIES_FILES ${DEPENDENCIES})
  list(TRANSFORM DEPENDENCIES PREPEND ${CMAKE_CURRENT_BINARY_DIR}/)

  add_custom_command(
    COMMENT Build ${NAME}
    DEPENDS ${DEPENDENCIES}
    OUTPUT ${NAME}.tar.gz
    COMMAND echo "pack the deps into a tar gz"
    COMMAND tar -czf ${NAME}.tar.gz -C ${CMAKE_CURRENT_BINARY_DIR} ${DEPENDENCIES_FILES}
  )

  add_custom_target(${NAME} DEPENDS ${NAME}.tar.gz)
  add_dependencies(${NAME} build-environment-${TARGET_MACHINE})
endfunction()