if(NOT CROSS_BUILD)
    add_dependencies(${PROJECT_NAME} configuration)
endif()

target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_BINARY_DIR}/configuration/generated)
