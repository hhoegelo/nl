cmake_minimum_required(VERSION 3.0)
project(nonmaps)

file(GLOB_RECURSE SOURCE_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*)

IF(NOT GWT_PATH)
  message(FATAL_ERROR "You have to specifiy the path to a GWT installation like this: cmake -DGWT_PATH=/unpacked/gwt/zip")
  message(FATAL_ERROR "GWT can be doenloaded at https://github.com/gwtproject/gwt/releases/download/2.10.0/gwt-2.10.0.zip")
endif()

add_custom_command(
  COMMENT "Generate nonmaps-version.txt"
  DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/nonmaps-version.txt
  DEPENDS ${CMAKE_SOURCE_DIR}/cmake/generate-version.cmake
  DEPENDS ${CMAKE_SOURCE_DIR}/.git/index
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  COMMAND ${CMAKE_COMMAND}
    -D INPUT_FILE=${CMAKE_CURRENT_SOURCE_DIR}/nonmaps-version.txt
    -D OUTPUT_FILE=${CMAKE_CURRENT_BINARY_DIR}/nonmaps-version.txt
    -P ${CMAKE_SOURCE_DIR}/cmake/generate-version.cmake
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/nonmaps-version.txt     
)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/src/main/webapp/NonMaps.js.in ${CMAKE_CURRENT_BINARY_DIR}/NonMaps.js @ONLY)

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/war/nonmaps/compilation-mappings.txt
  COMMAND /usr/bin/java -Xmx512m -classpath ${CMAKE_CURRENT_SOURCE_DIR}/src/main/java:${CMAKE_CURRENT_BINARY_DIR}/gwt-${GWT_VERSION}/gwt-user.jar:${CMAKE_CURRENT_BINARY_DIR}/gwt-${GWT_VERSION}/gwt-dev.jar:${CMAKE_CURRENT_BINARY_DIR}/gwt-${GWT_VERSION}/gwt-elemental.jar com.google.gwt.dev.Compiler -optimize 9 -gen ${CMAKE_CURRENT_BINARY_DIR}/obj -logLevel WARN -style OBF -war ./war -localWorkers 4 com.nonlinearlabs.NonMaps
  DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/gwt-${GWT_VERSION}/gwt-dev.jar
  DEPENDS ${SOURCE_FILES})

add_custom_target(nonmaps 
  DEPENDS ./war/nonmaps/compilation-mappings.txt
  DEPENDS ./nonmaps-version.txt)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/war/nonmaps/ DESTINATION ${CMAKE_INSTALL_DATADIR}/nonmaps)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src/main/webapp/ DESTINATION ${CMAKE_INSTALL_DATADIR}/nonmaps)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/NonMaps.js ${CMAKE_CURRENT_BINARY_DIR}/nonmaps-version.txt DESTINATION ${CMAKE_INSTALL_DATADIR}/nonmaps)

include(${CMAKE_BINARY_DIR}/cmake/package.cmake)
deb("" "Browser based User Interface for Nonlinear Labs synthesizers")
