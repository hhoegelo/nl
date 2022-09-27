function(addConfiguration)
    if(NOT CONFIGURATION_INJECTED)
        add_dependencies(${PROJECT_NAME} configuration)
    endif()

    target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_BINARY_DIR}/configuration)
endfunction()