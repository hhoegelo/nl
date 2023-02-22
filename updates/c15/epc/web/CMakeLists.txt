SET(TARGET_MACHINE web)

crossBuild(
    NAME update-c15-epc-web 
    DEPENDS nonmaps mc-view online-help recorder meteor[nonmaps mc-view online-help recorder])
