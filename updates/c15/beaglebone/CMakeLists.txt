SET(TARGET_MACHINE beaglebone)

crossBuild(
    NAME update-c15-beaglebone 
    DEPENDS nltools midi-over-ip bridge[nltools] playcontroller-tools)

