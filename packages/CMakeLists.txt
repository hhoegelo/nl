add_subdirectory(bridge/)
add_subdirectory(midi-over-ip/)
add_subdirectory(nltools/)
add_subdirectory(playground/)
add_subdirectory(audio-engine/)

if(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "ARM")
    message("Building playcontroller")
    add_subdirectory(playcontroller-firmware/)
else()
    message("Not building playcontroller")
endif()

add_subdirectory(playcontroller-tools/)
