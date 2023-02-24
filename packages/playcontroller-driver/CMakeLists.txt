cmake_minimum_required(VERSION 3.5)

project(playcontroller-driver)

if(KERNEL_DIR)
    include(GNUInstallDirs)

    set(SOURCE_FILES lpc_bb_driver.c)

    configure_file(Kbuild.in Kbuild @ONLY)
    configure_file(lpc_bb_driver.c lpc_bb_driver.c COPYONLY)

    add_custom_command(
        OUTPUT lpc_bb_driver.ko
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

    add_custom_target(playcontroller-driver ALL DEPENDS lpc_bb_driver.ko)

    include(${CMAKE_BINARY_DIR}/cmake/package.cmake)
    deb("playcontroller-driver" "Beaglebon driver to connect to c15 playcontroller chip")
endif()