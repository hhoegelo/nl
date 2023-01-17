SET(TARGET_MACHINE pi4)

crossBuild(
    NAME update-c16-pi4 
    DEPENDS nltools audio-engine[nltools] playground[nltools])
