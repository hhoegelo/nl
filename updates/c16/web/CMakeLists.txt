SET(TARGET_MACHINE web)

SET(DEVELOPMENT_TARGETS meteor)

crossBuild(
    NAME update-c16-web 
    DEPENDS nonmaps mc-view online-help recorder meteor[nonmaps mc-view online-help recorder])
