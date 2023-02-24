cmake_minimum_required(VERSION 3.5.1)
project(text2soled)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(GNUInstallDirs)
find_package(PkgConfig REQUIRED)

set(LIBS giomm-2.4 freetype2)

configure_file(src/CompileTimeInfo.h.in src/CompileTimeInfo.h)

file(GLOB_RECURSE SOURCE_FILES src/*.cpp)
file(GLOB_RECURSE RESOURCE_FILES resources/*)

add_executable(${PROJECT_NAME} ${SOURCE_FILES})

pkg_check_modules(LIBS REQUIRED ${LIBS})
target_include_directories(${PROJECT_NAME} PUBLIC ${LIBS_INCLUDE_DIRS})
target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/src)
target_link_libraries(${PROJECT_NAME} PUBLIC ${LIBS_LIBRARIES})
link_directories(${LIBS_LIBRARY_DIRS})

target_link_libraries(${PROJECT_NAME} PUBLIC pthread)
target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src)

install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION ${CMAKE_INSTALL_FULL_BINDIR})
install(FILES ${RESOURCE_FILES} DESTINATION ${CMAKE_INSTALL_FULL_DATADIR}/text2soled)

include(${CMAKE_BINARY_DIR}/cmake/package.cmake)
include(${CMAKE_BINARY_DIR}/cmake/configuration.cmake)
deb("text2soled" "Display text on soled or boled of c15")
