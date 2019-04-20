cmake_minimum_required(VERSION 2.8)
project(mydumper)
set(VERSION 0.9.5)
set(RELEASE 2)

#Required packages
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/modules)
find_package(MySQL)
find_package(ZLIB)
find_package(GLIB2)
find_package(PCRE)

# Version
include(VersionGit)
if(FOUND_GIT)
  string(REGEX REPLACE "^v" "" VERSION "${GIT_TAG}")
  set(RELEASE "${GIT_RELEASE}")
  set(BUILD_CONTACT "${GIT_USER_NAME}")
endif(FOUND_GIT)

string(REPLACE "." " " VERSION_LIST "${VERSION}")
separate_arguments(VERSION_LIST)
list(GET VERSION_LIST 0 VERSION_MAJOR)
list(GET VERSION_LIST 1 VERSION_MINOR)
list(GET VERSION_LIST 2 VERSION_PATCH)

message(STATUS "Version: major=${VERSION_MAJOR} minor=${VERSION_MINOR} patch=${VERSION_PATCH} release=${RELEASE}")

option(BUILD_DOCS "Build the documentation" ON)

if (BUILD_DOCS)
  add_subdirectory(docs)
endif (BUILD_DOCS)

option(WITH_BINLOG "Build binlog dump options" OFF)
option(WITH_SSL "Build SSL support" ON)

set(CMAKE_C_FLAGS "-Wall -Wno-deprecated-declarations -Wunused -Wwrite-strings -Wno-strict-aliasing -Wextra -Wshadow -Werror -O3 -g ${MYSQL_CFLAGS}")

include_directories(${MYDUMPER_SOURCE_DIR} ${MYSQL_INCLUDE_DIR} ${GLIB2_INCLUDE_DIR} ${PCRE_INCLUDE_DIR} ${ZLIB_INCLUDE_DIRS})

if (NOT CMAKE_INSTALL_PREFIX)
  SET(CMAKE_INSTALL_PREFIX "/usr/local" CACHE STRING "Install path" FORCE)
endif (NOT CMAKE_INSTALL_PREFIX)
MARK_AS_ADVANCED(CMAKE)

CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/config.h.in ${CMAKE_CURRENT_SOURCE_DIR}/config.h)


if (WITH_BINLOG)

  add_executable(mydumper mydumper.c binlog.c server_detect.c g_unix_signal.c connection.c getPassword.c)
else (WITH_BINLOG)
  add_executable(mydumper mydumper.c server_detect.c g_unix_signal.c connection.c getPassword.c)
endif (WITH_BINLOG)
target_link_libraries(mydumper ${MYSQL_LIBRARIES} ${GLIB2_LIBRARIES} ${GTHREAD2_LIBRARIES} ${PCRE_PCRE_LIBRARY} ${ZLIB_LIBRARIES} stdc++)


add_executable(myloader myloader.c connection.c getPassword.c)
target_link_libraries(myloader ${MYSQL_LIBRARIES} ${GLIB2_LIBRARIES} ${GTHREAD2_LIBRARIES} ${PCRE_PCRE_LIBRARY} ${ZLIB_LIBRARIES} stdc++)

INSTALL(TARGETS mydumper myloader
  RUNTIME DESTINATION bin
)

add_custom_target(dist
  COMMAND ${CMAKE_MAKE_PROGRAM} package_source)

OPTION(RUN_CPPCHECK "Run cppcheck" OFF)

IF(RUN_CPPCHECK)
  include(CppcheckTargets)
  add_cppcheck(mydumper)
  add_cppcheck(myloader)
ENDIF(RUN_CPPCHECK)

# CPACK
string(REPLACE "." " " VERSION_LIST ${VERSION})

set(CPACK_PACKAGING_INSTALL_PREFIX "/usr")
#set(CPACK_SET_DESTDIR ON)
set(CPACK_PACKAGE_VERSION "${VERSION}")
set(CPACK_PACKAGE_VERSION_MAJOR "${VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${VERSION_PATCH}")
set(CPACK_PACKAGE_RELEASE "${RELEASE}")
set(CPACK_STRIP_FILES ON)
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "mydumper and myloader MySQL backup tools")
set(CPACK_PACKAGE_VENDOR "${BUILD_VENDOR}")
set(CPACK_PACKAGE_CONTACT "${BUILD_CONTACT}")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
set(CPACK_SOURCE_GENERATOR "TGZ")
set(CPACK_SOURCE_PACKAGE_FILE_NAME
    "${CMAKE_PROJECT_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_PACKAGE_RELEASE}")
set(CPACK_SOURCE_IGNORE_FILES
    ".git*;.bzr*;~$;${CMAKE_BINARY_DIR};${CPACK_SOURCE_IGNORE_FILES}")
set(CPACK_PACKAGE_FILE_NAME "${CPACK_SOURCE_PACKAGE_FILE_NAME}${RPM_DIST}.${CMAKE_SYSTEM_PROCESSOR}")

include(PackageRPM)
include(CPack)

MESSAGE(STATUS "------------------------------------------------")
MESSAGE(STATUS "MYSQL_CONFIG = ${MYSQL_CONFIG}")
MESSAGE(STATUS "CMAKE_INSTALL_PREFIX = ${CMAKE_INSTALL_PREFIX}")
MESSAGE(STATUS "BUILD_DOCS = ${BUILD_DOCS}")
MESSAGE(STATUS "WITH_BINLOG = ${WITH_BINLOG}")
MESSAGE(STATUS "RUN_CPPCHECK = ${RUN_CPPCHECK}")
MESSAGE(STATUS "Change a values with: cmake -D<Variable>=<Value>")
MESSAGE(STATUS "------------------------------------------------")
MESSAGE(STATUS)

