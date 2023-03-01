cmake_minimum_required(VERSION 3.5)
project(espi-driver)

if(KERNEL_DIR)
    include(GNUInstallDirs)

    file(GLOB_RECURSE SOURCE_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.c)
    file(GLOB_RECURSE HEADER_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.h)

    string(REPLACE ";" " " SOURCE_FILES_STR "${SOURCE_FILES}")
    string(REPLACE ".c" ".o" OBJECT_FILES "${SOURCE_FILES_STR}")

    configure_file(Kbuild.in Kbuild @ONLY)

    foreach(src ${SOURCE_FILES})
    configure_file(${src} ${src} COPYONLY)
    endforeach()

    foreach(src ${HEADER_FILES})
    configure_file(${src} ${src} COPYONLY)
    endforeach()

    add_custom_command(
        OUTPUT espi_driver.ko
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        DEPENDS ${SOURCE_FILES} ${HEADER_FILES} ${CMAKE_CURRENT_BINARY_DIR}/Kbuild
        VERBATIM
        COMMAND ${CMAKE_MAKE_PROGRAM} -j13
            ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} -C ${KERNEL_DIR} M=${CMAKE_CURRENT_BINARY_DIR}
            modules
        COMMAND ${CMAKE_MAKE_PROGRAM} -j13
            ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} -C ${KERNEL_DIR} M=${CMAKE_CURRENT_BINARY_DIR}
            INSTALL_MOD_PATH=${CMAKE_CURRENT_BINARY_DIR} 
            INSTALL_MOD_STRIP=1
            modules_install
        )

    install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib DESTINATION /)

    add_custom_target(espi-driver ALL DEPENDS espi_driver.ko)

    include(${CMAKE_BINARY_DIR}/cmake/package.cmake)
    deb("" "Beaglebon driver to connect to c15 hardware UI")
endif()