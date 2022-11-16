set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR cortex-a8)

set(CMAKE_SYSROOT /nonlinux/output/host/usr/arm-buildroot-linux-gnueabihf/sysroot)
set(CMAKE_STAGING_PREFIX /nonlinux/output/staging)

set(ENV{PKG_CONFIG_PATH} "${CMAKE_STAGING_PREFIX}/usr/lib/pkgconfig")
set(ENV{PKG_CONFIG_LIBDIR} "${CMAKE_STAGING_PREFIX}/usr/lib/pkgconfig")
set(ENV{PKG_CONFIG_SYSROOT_DIR} ${CMAKE_STAGING_PREFIX})

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)


set(CMAKE_AR                        /nonlinux/output/host/usr/bin/arm-buildroot-linux-gnueabihf-ar)
set(CMAKE_ASM_COMPILER              /nonlinux/output/host/usr/bin/arm-buildroot-linux-gnueabihf-gcc)
set(CMAKE_C_COMPILER                /nonlinux/output/host/usr/bin/arm-buildroot-linux-gnueabihf-gcc)
set(CMAKE_CXX_COMPILER              /nonlinux/output/host/usr/bin/arm-buildroot-linux-gnueabihf-g++)
set(CMAKE_LINKER                    /nonlinux/output/host/usr/bin/arm-buildroot-linux-gnueabihf-ld)
set(CMAKE_OBJCOPY                   /nonlinux/output/host/usr/bin/arm-buildroot-linux-gnueabihf-objcopy CACHE INTERNAL "")
set(CMAKE_RANLIB                    /nonlinux/output/host/usr/bin/arm-buildroot-linux-gnueabihf-ranlib CACHE INTERNAL "")
set(CMAKE_SIZE                      /nonlinux/output/host/usr/bin/arm-buildroot-linux-gnueabihf-size CACHE INTERNAL "")
set(CMAKE_STRIP                     /nonlinux/output/host/usr/bin/arm-buildroot-linux-gnueabihf-strip CACHE INTERNAL "")

set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "armhf")

SET(TARGET_PLATFORM "beaglebone")