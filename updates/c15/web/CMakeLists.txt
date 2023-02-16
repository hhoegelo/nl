SET(TARGET_MACHINE web)

crossBuild(
    NAME update-c15-web 
    DEPENDS nonmaps mc-view online-help recorder meteor[nonmaps mc-view online-help recorder])
