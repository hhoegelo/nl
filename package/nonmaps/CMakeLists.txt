cmake_minimum_required(VERSION 3.18)
project(nonmaps)

include(GNUInstallDirs)

file(GLOB_RECURSE SOURCE_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*)
set(GWT_VERSION 2.10.0)

IF(NOT CROSS_BUILD)
  set(GWT_INSTALL_PATH ${CMAKE_CURRENT_BINARY_DIR}/gwt)
  if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/gwt-${GWT_VERSION}.zip)
    file(DOWNLOAD ${NONLINEARLABS_SERVER}/web/gwt-${GWT_VERSION}.zip ${CMAKE_CURRENT_BINARY_DIR}/gwt-${GWT_VERSION}.zip SHOW_PROGRESS)
    file(ARCHIVE_EXTRACT INPUT ${CMAKE_CURRENT_BINARY_DIR}/gwt-${GWT_VERSION}.zip DESTINATION ${GWT_INSTALL_PATH})
  endif()
  set(GWT_PATH ${GWT_INSTALL_PATH}/gwt-${GWT_VERSION})
endif()

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/src/main/webapp/NonMaps.js.in ${CMAKE_CURRENT_BINARY_DIR}/NonMaps.js @ONLY)

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/war/nonmaps/compilation-mappings.txt
  COMMAND 
    /usr/bin/java 
      -Xmx512m 
      -classpath ${CMAKE_CURRENT_SOURCE_DIR}/src/main/java:${GWT_PATH}/gwt-user.jar:${GWT_PATH}/gwt-dev.jar:${GWT_PATH}/gwt-elemental.jar 
      com.google.gwt.dev.Compiler 
        -optimize 9 
        -gen ${CMAKE_CURRENT_BINARY_DIR}/obj 
        -logLevel WARN 
        -style OBF 
        -war ./war 
        -localWorkers 4 
        com.nonlinearlabs.NonMaps
  DEPENDS ${SOURCE_FILES})

add_custom_target(nonmaps ALL
  DEPENDS ./war/nonmaps/compilation-mappings.txt)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/war/nonmaps/ DESTINATION ${CMAKE_INSTALL_DATADIR}/nonmaps)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src/main/webapp/ DESTINATION ${CMAKE_INSTALL_DATADIR}/nonmaps)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/NonMaps.js DESTINATION ${CMAKE_INSTALL_DATADIR}/nonmaps)

include(${CMAKE_BINARY_DIR}/cmake/package.cmake)
deb("" "Browser based User Interface for Nonlinear Labs synthesizers")
