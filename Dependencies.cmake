cmake_minimum_required(VERSION 3.21)

include(ExternalProject)
include(Tools/cmake/CPM.cmake)

# FetchContent variables will be lowercased, that's why we have
# werid variable names like r_win_exe_POPULATED

# Here,we download the R binary, extract its content and copy it into the
# right place.
#   - [ ] I still have to test the windows version
#   - On macOS, this will place the R.framework into the ${CMAKE_SOURCE_DIR}/Frameworks
#
if(WIN32)
  find_program(EXTRACT NAMES extract)

  set(R_PACKAGE_NAME "R-${R_VERSION}.pkg")
  set(R_DOWNLOAD_URL
      "https://cran.r-project.org/bin/windows/base/R-${R_VERSION}-win.exe")
  set(R_PACKAGE_HASH "776384c989ea061728e781b6b9ce5b92")

  fetchcontent_declare(
    r_win_exe
    URL ${R_DOWNLOAD_URL}
    URL_HASH MD5=${R_PACKAGE_HASH}
    DOWNLOAD_NO_EXTRACT ON
    DOWNLOAD_NAME ${R_PACKAGE_NAME})

  fetchcontent_populate(r_win_exe)
  fetchcontent_getproperties(r_win_exe)

  if(r_win_exe_POPULATED)
    execute_process(
      WORKING_DIRECTORY ${r_win_exe_SOURCE_DIR}
      COMMAND extract /c ${R_PACKAGE_NAME} /l ${r_win_exe_BINARY_DIR}
      COMMAND cp -r ${r_win_exe_BINARY_DIR} ${CMAKE_SOURCE_DIR}/R)
  endif()

elseif(APPLE)

  if(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "arm64")
    set(R_PACKAGE_NAME "R-${R_VERSION}-${CMAKE_HOST_SYSTEM_PROCESSOR}.pkg")
    set(R_DOWNLOAD_URL
        "https://cran.r-project.org/bin/macosx/big-sur-arm64/base/R-${R_VERSION}-arm64.pkg"
    )
    set(R_PACKAGE_HASH "69e8845ffa134c822d4bdcf458220e841a9eeaa5")
  else()
    set(R_PACKAGE_NAME "R-${R_VERSION}.pkg")
    set(R_DOWNLOAD_URL
        "https://cran.r-project.org/bin/macosx/base/R-${R_VERSION}.pkg")
    set(R_PACKAGE_HASH "61d3909bc070f7fb86c5a2bd67209fda9408faaa")
  endif()

  if(NOT EXISTS ${CMAKE_SOURCE_DIR}/Frameworks/R.framework)

    fetchcontent_declare(
      r_pkg
      URL ${R_DOWNLOAD_URL}
      URL_HASH SHA1=${R_PACKAGE_HASH}
      DOWNLOAD_NO_EXTRACT ON
      DOWNLOAD_NAME ${R_PACKAGE_NAME})

    fetchcontent_populate(r_pkg)
    fetchcontent_getproperties(r_pkg)

    if(r_pkg_POPULATED)
      execute_process(
        WORKING_DIRECTORY ${r_pkg_SOURCE_DIR}
        COMMAND xar -xf ${R_PACKAGE_NAME}
        COMMAND tar xvf R-fw.pkg/Payload
        COMMAND cp -r R.framework ${CMAKE_SOURCE_DIR}/Frameworks/)
    endif()

  endif()

else()

endif()

set(CPM_USE_LOCAL_PACKAGES ON)

# This is rather slow because it has to download all the submodules,
# when the final version of 1.78.0 is released, we can replace it
# with the .tar.gz to have a faster download.
# cpmaddpackage(
#   NAME
#   Boost
#   VERSION
#   1.78.0
#   OPTIONS
#   "BUILD_TESTING OFF"
#   GITHUB_REPOSITORY
#   "boostorg/boost"
#   GIT_TAG
#   "boost-1.78.0.beta1")

# cpmaddpackage(
#   NAME
#   jsoncpp
#   VERSION
#   1.9.5
#   OPTIONS
#   "JSONCPP_WITH_TESTS OFF"
#   "JSONCPP_WITH_POST_BUILD_UNITTEST OFF"
#   GITHUB_REPOSITORY
#   "open-source-parsers/jsoncpp"
#   GIT_TAG
#   "1.9.5")

# cpmaddpackage(
#   NAME
#   LibArchive
#   VERSION
#   3.5.2
#   OPTIONS
#   "ENABLE_TEST OFF"
#   "JSONCPP_WITH_POST_BUILD_UNITTEST OFF"
#   GITHUB_REPOSITORY
#   "libarchive/libarchive"
#   GIT_TAG
#   "v3.5.2")

# cpmaddpackage(
#   NAME
#   ZLIB
#   VERSION
#   1.2.11
#   GITHUB_REPOSITORY
#   "madler/zlib"
#   GIT_TAG
#   "v1.2.11")

find_program(MAKE NAMES gmake nmake make)
find_program(ACLOCAL NAMES aclocal)
find_program(AUTOCONF NAMES autoconf)
find_program(AUTORECONF NAMES autoreconf)

# Installing Irregular Dependencies
#
# - [ ] CMake caches the build and everything, but it does it
#       after running the `./configure`. I think I can simply
#       and if they exist, ignore the process! For now, I leave
#       it like this that I can be sure that raising issues is not
#       due to this. So, be prepared for some extra ./configure
#       messages.

# I would love to have these active that we don't get a lot
# of build messages, but CMake proved to be not so good at
# dealing with a tiniest anomoly that the build process throw
# at it, so, if even a warning happens, it stops the build!
#
# - LOG_CONFIGURE ON
# - LOG_BUILD ON
# - LOG_INSTALL ON
# - LOG_OUTPUT_ON_FAILURE ON
externalproject_add(
  readstat
  PREFIX _deps/readstat
  GIT_REPOSITORY "https://github.com/WizardMac/ReadStat"
  GIT_TAG "v1.1.7"
  BUILD_IN_SOURCE ON
  STEP_TARGETS configure build install
  CONFIGURE_COMMAND ./autogen.sh
  COMMAND autoupdate
  COMMAND ./configure --prefix=<DOWNLOAD_DIR>/readstat-install
  BUILD_COMMAND ${MAKE})

externalproject_get_property(readstat DOWNLOAD_DIR)
set(readstat_DOWNLOAD_DIR ${DOWNLOAD_DIR})
set(readstat_BUILD_DIR ${readstat_DOWNLOAD_DIR}/readstat-build)
set(readstat_INCLUDE_DIRS ${readstat_DOWNLOAD_DIR}/readstat-install/include)
set(readstat_LIBRARY_DIRS ${readstat_DOWNLOAD_DIR}/readstat-install/lib)

# Installing JAGS
#
# - JAGS needs GNU Bison v3, https://www.gnu.org/software/bison.
# - With this, we can build JAGS, and link it, or even place it inside the the `R.framework`
# - You can run `make jags-build` or `make jags-install` to just play with JAGS target
externalproject_add(
  jags
  PREFIX _deps/jags
  HG_REPOSITORY "http://hg.code.sf.net/p/mcmc-jags/code-0"
  HG_TAG "release-4_3_0"
  BUILD_IN_SOURCE ON
  STEP_TARGETS configure build install
  CONFIGURE_COMMAND ${ACLOCAL}
  COMMAND ${AUTORECONF} -fi
  COMMAND ./configure --disable-dependency-tracking
          --prefix=<DOWNLOAD_DIR>/jags-install
  BUILD_COMMAND ${MAKE})

externalproject_get_property(jags DOWNLOAD_DIR)
set(jags_DOWNLOAD_DIR ${DOWNLOAD_DIR})
set(jags_BUILD_DIR ${jags_DOWNLOAD_DIR}/jags-build)
set(jags_INCLUDE_DIRS ${jags_DOWNLOAD_DIR}/jags-install/include)
set(jags_LIBRARY_DIRS ${jags_DOWNLOAD_DIR}/jags-install/lib)
set(jags_PKG_CONFIG_PATH ${jags_DOWNLOAD_DIR}/jags-install/lib/pkgconfig/)
