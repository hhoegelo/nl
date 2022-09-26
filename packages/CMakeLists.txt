
if(BUILD_PLAYGROUND OR BUILD_AUDIOENGINE)
 add_subdirectory(nltools/)
endif()

if(BUILD_PLAYGROUND)
  add_subdirectory(playground/)
endif()

if(BUILD_AUDIOENGINE)
  add_subdirectory(audio-engine/)
endif()