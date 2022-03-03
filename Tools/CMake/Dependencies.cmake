list(APPEND CMAKE_MESSAGE_CONTEXT Dependencies)

# Notes:
#
# - FetchContent variables will be lower cased, that's why we have
#   weird variable names like r_win_exe_POPULATED.
# - "CMake 3.22 updated the FindPkgConfig module to allow passing
#   arbitrary arguments to the pkgconfig executable." This could come handy
#   later on when dealing with some of the more annoying dependencies

# Adding caching for CPM, this is going to be useful later that we
# want to have CI builds on GitHub, see here: https://github.com/cpm-cmake/CPM.cmake/wiki/Caching-with-CPM.cmake-and-ccache-on-GitHub-Actions
# set(CPM_SOURCE_CACHE ${PROJECT_SOURCE_DIR}/.cache/CPM)
# set(CPM_USE_LOCAL_PACKAGES ON)

add_custom_target(Dependencies)

add_dependencies(Dependencies readstat)

# ----- readstat -----
#
# This might look a bit unusual but it is fine. I had to do it this
# way because CMake was not being very smart about it, and was
# reconfiguring the entire readstat everytime during build even if
# it was already built!

fetchcontent_declare(
  readstat
  URL "https://github.com/WizardMac/ReadStat/releases/download/v1.1.7/readstat-1.1.7.tar.gz"
  URL_HASH
    SHA256=400b8e6a5f0f6458227b454785d68beadd8a88870a7745d49def49740e3971a8)

message(CHECK_START "Downloading 'readstat'")

fetchcontent_makeavailable(readstat)

if(USE_CONAN)
  set(Iconv_FLAGS_FOR_READSTAT --with-libiconv-prefix=${Iconv_LIB_DIRS}/..
                               --without-libiconv-prefix)
endif()

if(readstat_POPULATED)

  message(CHECK_PASS "successful.")

  add_custom_command(
    WORKING_DIRECTORY ${readstat_SOURCE_DIR}
    OUTPUT ${readstat_BINARY_DIR}/include/readstat.h
           ${readstat_BINARY_DIR}/lib/libreadstat.a
    COMMAND ./configure --enable-static --prefix=${readstat_BINARY_DIR}
            ${Iconv_FLAGS_FOR_READSTAT}
    COMMAND ${MAKE}
    COMMAND ${MAKE} install
    COMMENT "----- Preparing 'readstat'")

  add_custom_target(readstat DEPENDS ${readstat_BINARY_DIR}/include/readstat.h)

  set(LIBREADSTAT_INCLUDE_DIRS ${readstat_BINARY_DIR}/include)
  set(LIBREADSTAT_LIBRARY_DIRS ${readstat_BINARY_DIR}/lib)
  set(LIBREADSTAT_LIBRARIES ${LIBREADSTAT_LIBRARY_DIRS}/libreadstat.a)

else()

  message(CHECK_FAIL "failed.")

endif()

unset(DOWNLOAD_DIR)
unset(INSTALL_DIR)

list(POP_BACK CMAKE_MESSAGE_CONTEXT)
