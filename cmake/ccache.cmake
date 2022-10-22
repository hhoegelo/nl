find_program(CCACHE_FOUND ccache)

IF(CCACHE_FOUND)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ccache)
ENDIF()
