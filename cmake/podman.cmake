function(registerPod DOCKERFILE)
  configure_file(${DOCKERFILE} ${CMAKE_CURRENT_BINARY_DIR}/Dockerfile @ONLY)
  file(SHA1 ${CMAKE_CURRENT_BINARY_DIR}/Dockerfile DOCKERFILE_SHA1)
  
  set(DOCKERNAME ${BUILD_TASK}-${TARGET_MACHINE})
  
  add_custom_command(
    COMMENT "Provide Podman for ${DOCKERNAME}"
    OUTPUT .podman
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/Dockerfile
    VERBATIM
    COMMAND
      podman run --tls-verify=false --rm ${PODMAN_REGISTRY}/${DOCKERNAME}:${DOCKERFILE_SHA1} 
      || podman build -t ${DOCKERNAME}:${DOCKERFILE_SHA1} .
        && podman push --tls-verify=false ${DOCKERNAME}:${DOCKERFILE_SHA1} ${PODMAN_REGISTRY}/${DOCKERNAME}:${DOCKERFILE_SHA1}
    )
  
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
    STRING(TOUPPER ${PACKAGE} PACKAGE_CANONIC)
    STRING(REPLACE "-" "_" PACKAGE_CANONIC ${PACKAGE_CANONIC})
    add_custom_command(
      COMMENT "X-Building ${PACKAGE} for ${TARGET_MACHINE}"
      OUTPUT ${PACKAGE}.deb
      VERBATIM
      COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/build-${PACKAGE}
      COMMAND podman run --tls-verify=false --rm 
        -v ${CMAKE_SOURCE_DIR}/packages/${PACKAGE}:/src
        -v ${CMAKE_CURRENT_BINARY_DIR}/build-${PACKAGE}:/build
        ${PODMAN_REGISTRY}/${DOCKERNAME}:${DOCKERFILE_SHA1} cmake -S /src -B /build
      COMMAND podman run --tls-verify=false --rm 
        -v ${CMAKE_SOURCE_DIR}/packages/${PACKAGE}:/src 
        -v ${CMAKE_CURRENT_BINARY_DIR}/build-${PACKAGE}:/build
        ${PODMAN_REGISTRY}/${DOCKERNAME}:${DOCKERFILE_SHA1} make -C /build 
      COMMAND podman run --tls-verify=false --rm 
        -v ${CMAKE_SOURCE_DIR}/packages/${PACKAGE}:/src
        -v ${CMAKE_CURRENT_BINARY_DIR}/build-${PACKAGE}:/build
        -w /build
        ${PODMAN_REGISTRY}/${DOCKERNAME}:${DOCKERFILE_SHA1} cpack
     )
  endforeach()

  SET(DEPENDENCIES ${ARGN})
  list(TRANSFORM DEPENDENCIES PREPEND ${CMAKE_CURRENT_BINARY_DIR}/)
  list(TRANSFORM DEPENDENCIES APPEND .deb)

  add_custom_command(
    COMMENT Build ${NAME}
    DEPENDS ${DEPENDENCIES}
    OUTPUT ${NAME}.tar.gz
    COMMAND echo "pack the deps into a tar gz"
    COMMAND tar -czf ${NAME}.tar.gz ${DEPENDENCIES}
  )

  add_custom_target(${NAME} DEPENDS ${NAME}.tar.gz)
  add_dependencies(${NAME} build-environment-${TARGET_MACHINE})
endfunction()