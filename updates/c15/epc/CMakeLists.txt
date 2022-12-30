SET(TARGET_MACHINE epc)

crossBuild(
    NAME update-c15-epc 
    DEPENDS nltools audio-engine[nltools] playground[nltools])
