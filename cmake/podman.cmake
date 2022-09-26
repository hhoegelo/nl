function(registerPod DOCKERFILE)
  configure_file(${DOCKERFILE} ${CMAKE_CURRENT_BINARY_DIR}/Dockerfile @ONLY)
  file(SHA1 ${CMAKE_CURRENT_BINARY_DIR}/Dockerfile DOCKERFILE_SHA1)
  
  set(DOCKERNAME ${PROJECT_NAME})
  
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
endfunction()

function(crossBuild TARGET PACKAGE)
  STRING(TOUPPER PACKAGE ${PACKAGE})

  file(SHA1 ${CMAKE_BINARY_DIR}/build-environments/${TARGET}/Dockerfile DOCKERFILE_SHA1)
  set(DOCKERNAME build-environment-${TARGET})

  SET(POD 
    "podman run 
    --tls-verify=false 
    --rm 
    -v ${CMAKE_SOURCE_DIR}:/src 
    -v ${CMAKE_CURRENT_BINARY_DIR}:/build 
    ${PODMAN_REGISTRY}/${DOCKERNAME}:${DOCKERFILE_SHA1}")

    MESSAGE("POD: ${POD}")

  SET(TARGETNAME ${PROJECT_NAME}-${PACKAGE})

  add_custom_command(
    COMMENT "X-Building ${PACKAGE} for ${TARGET}"
    OUTPUT ${TARGETNAME}-update.tar
    #COMMAND ${POD} "cmake -S /src -B /build -DBUILD_${PACKAGE}=On"
    #COMMAND ${POD} "make -C /build"
    COMMAND echo "foo"
  )

  add_custom_target(${TARGETNAME} DEPENDS ${TARGETNAME}-update.tar)
  add_dependencies(${TARGETNAME} build-environment-${TARGET})
endfunction()