SET(TARGET_MACHINE playcontroller)

crossBuild(
    NAME update-c15-playcontroller 
    DEPENDS playcontroller-firmware)