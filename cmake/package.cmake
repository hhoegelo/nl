function(deb DEPENDENCIES DESCRIPTION)
    SET(CPACK_GENERATOR "DEB")
    SET(CPACK_BINARY_DEB On)
    SET(CPACK_STRIP_FILES On)    
    SET(CPACK_PACKAGE_CONTACT "info@nonlinear-labs.de")
    SET(CPACK_DEBIAN_PACKAGE_MAINTAINER "Nonlinear Labs GmbH")
    SET(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
    SET(CPACK_DEBIAN_PACKAGE_DEPENDS ${DEPENDENCIES})
    SET(CPACK_DEBIAN_PACKAGE_DESCRIPTION ${DESCRIPTION})
    INCLUDE(CPack)
endfunction()