list(APPEND CMAKE_MESSAGE_CONTEXT JASP)

# TODOs:
#
# - [ ] Most of these add_definitions should turn into `set_target_definitions`
#       and link to their appropriate targets later on.

find_package(Git)

if(GIT_FOUND AND EXISTS "${CMAKE_SOURCE_DIR}/.git")

  message(CHECK_START "Retrieving the git-branch information")

  execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE GIT_BRANCH
    OUTPUT_STRIP_TRAILING_WHITESPACE)

  execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse --verify HEAD
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE GIT_COMMIT
    OUTPUT_STRIP_TRAILING_WHITESPACE)

  message(CHECK_PASS "done.")

  set(GIT_CURRENT_BRANCH ${GIT_BRANCH})
  set(GIT_CURRENT_COMMIT ${GIT_COMMIT})

  cmake_print_variables(GIT_CURRENT_BRANCH)
  cmake_print_variables(GIT_CURRENT_COMMIT)
endif()

set(JASP_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(JASP_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(JASP_VERSION_PATCH ${PROJECT_VERSION_PATCH})
set(JASP_VERSION_TWEAK ${PROJECT_VERSION_TWEAK})

# Amir: We probably won't need them soon
# option(JASP_LIBJSON_STATIC
#        "Whether or not we are using the 'libjson' as static library?" OFF)

# TODO:
# - [ ] Rename all JASP related variables to `JASP_*`. This way,
#       Qt Creator can categorize them nicely in its CMake configurator
option(JASP_PRINT_ENGINE_MESSAGES
       "Whether or not JASPEngine prints log messages" OFF)
set(PRINT_ENGINE_MESSAGES ${JASP_PRINT_ENGINE_MESSAGES})

option(BUILD_MACOSX_BUNDLE "Whether or not building a macOS Bundle" OFF)

# This is being set using the `Sys.setenv()` and later on when
# we install a module using `{renv}`, the `{credentials}` package
# knows how to read and use it.
set(GITHUB_PAT CACHE STRING "GitHub Personal Access Token")
if(GITHUB_PAT)
  message(STATUS "GITHUB_PAT is set to ${GITHUB_PAT}")
endif()

if(NOT R_REPOSITORY)
  set(R_REPOSITORY
      "http://cran.r-project.org"
      CACHE STRING "The CRAN mirror used by 'renv' and 'install.packages'")
endif()
message(STATUS "CRAN mirror: ${R_REPOSITORY}")

option(BUILDING_JASP "Indicates whether we are building JASP or not.
					  This helps jaspResults to find its lib_json." ON)
if(BUILDING_JASP)
  add_definitions(-DBUILDING_JASP)
endif()

# This one is GLOBAL
option(JASP_DEBUG "Toggle the debug flag" ON)
if(JASP_DEBUG)
  add_definitions(-DJASP_DEBUG)
endif()

option(PRINT_ENGINE_MESSAGES
       "Indicates whether the log contains JASPEngine messages" ON)

option(JASP_USES_QT_HERE "Indicates whether some files are using Qt.
						  This doesn't strike as a very informative name
						  for an option!" ON)

# add_definitions(-DJASP_RESULTS_DEBUG_TRACES)

option(JASP_TIMER_USED "Use JASP timer for profiling" OFF)
if(JASP_TIMER_USED)
  add_definitions(-DPROFILE_JASP)
endif()

# TODO:
# - [ ] Make sure that all variables from .pri and .pro make it to the CMake files
# - [ ] Find the Git location, I think I can use CMake's $ENV{GIT} or something like that
# - [ ] Find a better name for some of these variables
# - [ ] Setup the GITHUB_PAT

list(POP_BACK CMAKE_MESSAGE_CONTEXT)
