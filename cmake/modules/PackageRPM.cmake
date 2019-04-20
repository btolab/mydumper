find_program(RPMBUILD
    NAMES rpmbuild
    PATHS "/usr/bin")

if(RPMBUILD)
    get_filename_component(RPMBUILD_PATH ${RPMBUILD} ABSOLUTE)
    message(STATUS "Found rpmbuild: ${RPMBUILD_PATH}")

    set(CPACK_GENERATOR "RPM;${CPACK_GENERATOR}")

    execute_process(
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      COMMAND rpm --eval %{dist}
      OUTPUT_VARIABLE RPM_DIST OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    set(CPACK_PACKAGE_FILE_NAME "${CPACK_SOURCE_PACKAGE_FILE_NAME}${RPM_DIST}.${CMAKE_SYSTEM_PROCESSOR}")

    set(CPACK_RPM_PACKAGE_PACKAGER "${CPACK_PACKAGE_CONTACT}")
    set(CPACK_RPM_PACKAGE_URL "https://github.com/maxbube/mydumper")
    set(CPACK_RPM_PACKAGE_GROUP "Applications/Database")
    set(CPACK_RPM_PACKAGE_LICENSE "GPL")
    set(CPACK_RPM_PACKAGE_RELEASE "${CPACK_PACKAGE_RELEASE}${RPM_DIST}")
    set(CPACK_RPM_PACKAGE_ARCHITECTURE "${CMAKE_SYSTEM_PROCESSOR}")
    set(CPACK_RPM_USER_BINARY_SPECFILE "${CMAKE_SOURCE_DIR}/cmake/templates/specfile")
    set(CPACK_RPM_PACKAGE_DESCRIPTION "This package provides mydumper and myloader MySQL backup tools.

mydumper is a tool used for backing up MySQL database servers much
faster than the mysqldump tool distributed with MySQL. The advantages
of mydumper are: parallelism, easier to manage output, consistency,
manageability.

myloader is a tool used for multi-threaded restoration of mydumper backups.")
endif(RPMBUILD)
