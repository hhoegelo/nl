macro(registerPod DOCKERFILE)
  configure_file(${DOCKERFILE} ${CMAKE_CURRENT_BINARY_DIR}/Dockerfile @ONLY)
  file(SHA1 ${CMAKE_CURRENT_BINARY_DIR}/Dockerfile DOCKERFILE_SHA1)
  
  string(LENGTH ${CMAKE_BINARY_DIR} PREFIX_LENGTH)
  MATH(EXPR PREFIX_LENGTH "${PREFIX_LENGTH}+1")
  string(SUBSTRING ${CMAKE_CURRENT_BINARY_DIR} ${PREFIX_LENGTH} -1 DOCKERNAME)
  string(REPLACE "/" "-" DOCKERNAME ${DOCKERNAME})
  string(TOUPPER DOCKERNAME_UPPER ${DOCKERNAME})
  
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
  
  message("Add target ${DOCKERNAME}")
  add_custom_target(${DOCKERNAME} DEPENDS .podman)
  
  SET(RUN_ON_${DOCKERNAME_UPPER}_POD podman run --rm --userns=keep-id --tls-verify=false --rm ${PODMAN_REGISTRY}/${DOCKERNAME}:${DOCKERFILE_SHA1})  
endmacro()