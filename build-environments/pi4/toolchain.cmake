

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR armv8-a)

set(CMAKE_SYSROOT /)
set(CMAKE_STAGING_PREFIX /staging)
set(TOOLCHAIN_PREFIX aarch64-linux-gnu-)

set(CMAKE_C_COMPILER /usr/bin/aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER /usr/bin/aarch64-linux-gnu-g++)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mlittle-endian -mabi=lp64 -march=armv8-a+crc -fasynchronous-unwind-tables -mcpu=cortex-a72 -mtune=cortex-a72 -Wno-psabi")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "arm64")
SET(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${CMAKE_SOURCE_DIR}/build-tools/pi4/postinst")

SET(TARGET_PLATFORM "pi4")

INCLUDE_DIRECTORIES(SYSTEM /usr/include)