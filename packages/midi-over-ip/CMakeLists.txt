cmake_minimum_required(VERSION 3.5.1)
project(midi-over-ip)

include(GNUInstallDirs)
find_package(PkgConfig REQUIRED)
find_package(Threads REQUIRED)

include(${CMAKE_BINARY_DIR}/cmake/systemd.cmake)
find_systemd()

set(LIBS alsa giomm-2.4 glibmm-2.4)

file(GLOB_RECURSE SOURCE_FILES src/*.cpp)
file(GLOB_RECURSE SERVICES systemd/*.service.in)

add_executable(${PROJECT_NAME} ${SOURCE_FILES})
include (${CMAKE_BINARY_DIR}/cmake/nltools.cmake)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -Wdouble-promotion")

pkg_check_modules(LIBS REQUIRED ${LIBS})
target_include_directories(${PROJECT_NAME} PUBLIC ${LIBS_INCLUDE_DIRS})
target_link_libraries(${PROJECT_NAME} PUBLIC ${LIBS_LIBRARIES})
link_directories(${LIBS_LIBRARY_DIRS})

target_link_libraries(${PROJECT_NAME} PUBLIC pthread)
target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src)

foreach(SERVICE ${SERVICES})
  string(REGEX REPLACE ".in$" "" WITHOUT_IN ${SERVICE})
  get_filename_component(SERVICENAME ${WITHOUT_IN} NAME)
  configure_file(${SERVICE} ${PROJECT_BINARY_DIR}/systemd/${SERVICENAME} @ONLY)
  install(FILES ${PROJECT_BINARY_DIR}/systemd/${SERVICENAME} DESTINATION ${SYSTEMD_SERVICES_INSTALL_DIR} COMPONENT init)
endforeach(SERVICE)

install(DIRECTORY DESTINATION ${SYSTEMD_SERVICES_INSTALL_DIR}/multi-user.target.wants)
install(DIRECTORY DESTINATION ${SYSTEMD_SERVICES_INSTALL_DIR}/sysinit.target.wants)
install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION ${CMAKE_INSTALL_FULL_BINDIR})

include(${CMAKE_BINARY_DIR}/cmake/package.cmake)
include(${CMAKE_BINARY_DIR}/cmake/configuration.cmake)

deb("midi-over-ip" "Bridges alsa midi from BBB to EPC")
