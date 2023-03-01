find_package(PkgConfig REQUIRED)

pkg_check_modules(SYSTEMD "systemd")

if (SYSTEMD_FOUND AND !DEV_PC)
    execute_process(COMMAND ${PKG_CONFIG_EXECUTABLE} --variable=systemdsystemunitdir systemd OUTPUT_VARIABLE SYSTEMD_SERVICES_INSTALL_DIR)
    string(REGEX REPLACE "[ \t\n]+" "" SYSTEMD_SERVICES_INSTALL_DIR "${SYSTEMD_SERVICES_INSTALL_DIR}")
else ()
    set(SYSTEMD_SERVICES_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/lib/systemd/system)
endif ()
