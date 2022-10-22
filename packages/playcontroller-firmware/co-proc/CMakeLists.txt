project (playcontroller-firmware-coproc)

include(${CMAKE_BINARY_DIR}/cmake/package.cmake)

set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mcpu=cortex-m0")
set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -flto -ffat-lto-objects")

file(GLOB_RECURSE SOURCES ./src/*.c ../shared/*.c)

add_executable(${PROJECT_NAME} ${SOURCES})
target_compile_options(${PROJECT_NAME} PRIVATE -DCORE_M0)

target_include_directories (${PROJECT_NAME} PRIVATE "./src")
target_include_directories (${PROJECT_NAME} PRIVATE "../main/src")
target_include_directories (${PROJECT_NAME} PRIVATE "../shared")
target_include_directories (${PROJECT_NAME} PRIVATE ${CMAKE_BINARY_DIR}/shared/playcontroller)
target_include_directories (${PROJECT_NAME} PRIVATE ${CMAKE_BINARY_DIR}/shared)

target_link_options(${PROJECT_NAME} PUBLIC -Wl,-Map,output.map -Wl,--gc-sections)
target_link_directories(${PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/ld)

set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C)
set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "-TC15_LPC4322_co-proc.ld")
set_target_properties(${PROJECT_NAME} PROPERTIES COMPILE_FLAGS "${CMAKE_C_FLAGS}")

add_custom_command(
  TARGET ${PROJECT_NAME}
  POST_BUILD
  COMMAND 
    arm-none-eabi-objcopy 
      --target elf32-littlearm 
      --verbose --strip-all 
      --remove-section=.ARM.attributes 
      --redefine-sym __vectors_start__=__vectors_start___core_m0app 
      --keep-symbol __vectors_start___core_m0app 
      --redefine-sym _data=__start_data_core_m0app 
      --keep-symbol __start_data_core_m0app 
      --redefine-sym _edata=__end_data_core_m0app 
      --keep-symbol __end_data_core_m0app 
      --remove-section=".bss*" 
      --remove-section=".noinit*" 
      --rename-section .ARM.exidx=".core_m0app.ARM.exidx" 
      --rename-section .ARM.extab=".core_m0app.ARM.extab" 
      --rename-section .text=".core_m0app" 
      --rename-section .data=".core_m0app.data" 
      --rename-section .data_RAM2=".core_m0app.data_RAM2" 
      --rename-section .data_RAM3=".core_m0app.data_RAM3" 
      --rename-section .data_RAM4=".core_m0app.data_RAM4" 
      --rename-section .data_RAM5=".core_m0app.data_RAM5" ${PROJECT_NAME} ${PROJECT_NAME}.o)

include(${CMAKE_BINARY_DIR}/cmake/configuration.cmake)
