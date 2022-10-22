project (playcontroller-firmware-main)

include(${CMAKE_BINARY_DIR}/cmake/package.cmake)

file(GLOB_RECURSE SOURCES ./src/*.c ../shared/*.c)
add_executable(${PROJECT_NAME} ${SOURCES} ../co-proc/playcontroller-firmware-coproc.o)
target_compile_options(${PROJECT_NAME} PRIVATE -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard -fsingle-precision-constant -DCORE_M4)
add_dependencies(${PROJECT_NAME} playcontroller-firmware-coproc)
set_source_files_properties(../co-proc/playcontroller-firmware-coproc.o PROPERTIES GENERATED TRUE)

target_include_directories (${PROJECT_NAME} PRIVATE "./src")
target_include_directories (${PROJECT_NAME} PRIVATE "../co-proc/src")
target_include_directories (${PROJECT_NAME} PRIVATE "../shared")
target_include_directories (${PROJECT_NAME} PRIVATE ${CMAKE_BINARY_DIR}/shared/playcontroller)
target_include_directories (${PROJECT_NAME} PRIVATE ${CMAKE_BINARY_DIR}/shared)

target_link_options(${PROJECT_NAME} PUBLIC -Wl,-Map,output.map -Wl,--gc-sections)
target_link_directories(${PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/ld)

set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C)
set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "-TC15_LPC4322_main.ld")
set_target_properties(${PROJECT_NAME} PROPERTIES COMPILE_FLAGS "${CMAKE_C_FLAGS}")

add_custom_command(
  TARGET ${PROJECT_NAME}
  POST_BUILD
  COMMAND arm-none-eabi-objcopy -Obinary ${PROJECT_NAME})

install(TARGETS ${PROJECT_NAME} DESTINATION bin)
include(${CMAKE_BINARY_DIR}/cmake/configuration.cmake)
deb("" "C15 Playcontroller firmware")
