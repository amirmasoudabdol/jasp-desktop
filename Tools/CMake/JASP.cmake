# JASP.cmake sets a lot of JASP parameters, e.g., version. In addition to adding
# some of the CMake variables, it also add some _global_ definition to the compiler
# based on the value of those variables, e.g., `-DJASP_DEBUG`.
#
#
# TODOs:
#   - [ ] Most of these add_definitions should turn into `set_target_definitions`
#       and link to their appropriate targets later on.

list(APPEND CMAKE_MESSAGE_CONTEXT JASP)

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

set(JASP_VERSION ${CMAKE_PROJECT_VERSION})
set(JASP_SHORT_VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR})

message(STATUS "Version: ${CMAKE_PROJECT_VERSION}")

# TODO:
# - [ ] Rename all JASP related variables to `JASP_*`. This way,
#       Qt Creator can categorize them nicely in its CMake configurator
option(JASP_PRINT_ENGINE_MESSAGES
       "Whether or not JASPEngine prints log messages" ON)

if(NOT R_REPOSITORY)
  set(R_REPOSITORY
      "http://cran.r-project.org"
      CACHE STRING "The CRAN mirror used by 'renv' and 'install.packages'")
endif()

if(FLATPAK_USED AND LINUX)
  set(R_REPOSITORY "file:///app/lib64/local-cran")
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

option(JASP_USES_QT_HERE "Indicates whether some projects are using Qt" ON)

# add_definitions(-DJASP_RESULTS_DEBUG_TRACES)

option(JASP_TIMER_USED "Use JASP timer for profiling" OFF)
if(JASP_TIMER_USED)
  add_definitions(-DPROFILE_JASP)
endif()

option(UPDATE_JASP_SUBMODULES
       "Whether to automatically initialize and update the submodules" OFF)

# Dealing with Git submodules

if(UPDATE_JASP_SUBMODULES)
  if(GIT_FOUND AND EXISTS "${PROJECT_SOURCE_DIR}/.git")
    # Update submodules as needed
    message(STATUS "Submodule update")
    execute_process(
      COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      RESULT_VARIABLE GIT_SUBMOD_RESULT)
    if(NOT
       GIT_SUBMOD_RESULT
       EQUAL
       "0")
      message(
        FATAL_ERROR
          "git submodule update --init --recursive failed with ${GIT_SUBMOD_RESULT}, please checkout submodules"
      )
    endif()
  endif()
endif()

list(POP_BACK CMAKE_MESSAGE_CONTEXT)
