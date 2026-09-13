cmake_minimum_required(VERSION 3.30)

# Notice. This script correct operation depends on its location - directory depth - within
# the project, i.e. move it and it might break.  See PROJECT_ROOT below for more.

# Cross-platform CMake script for formatting the project's C/C++ source files using clang-format.
#
# Usage:
#   Fix formatting in place:
#     cmake -P cmake/format.cmake
#
#   Check formatting without modifying files:
#     cmake -DMODE=check -P cmake/format.cmake
#
#   Enable verbose output to list discovered files:
#     cmake -DVERBOSE=ON -P cmake/format.cmake
#
#   Options may be combined:
#     cmake -DMODE=check -DVERBOSE=ON -P cmake/format.cmake
#
# A CMake script is used instead of platform-specific shell scripts to avoid differences between
# PowerShell/cmd.exe and POSIX shells, and to avoid introducing additional scripting dependencies,
# e.g., python.

if(NOT DEFINED VERBOSE)
    set(VERBOSE OFF)
endif()

find_program(CLANG_FORMAT clang-format REQUIRED)
message(STATUS "CLANG_FORMAT: ${CLANG_FORMAT}")

# Establish the project's root based on the location of this file.
get_filename_component(PROJECT_ROOT
    "${CMAKE_CURRENT_LIST_DIR}/.."
    ABSOLUTE
)
message(STATUS "PROJECT_ROOT: ${PROJECT_ROOT}")

# Set clang-format args based on MODE
if(NOT DEFINED MODE)
    set(MODE "fix")
endif()
if(MODE STREQUAL "fix")
    set(FORMAT_ARGS -i)
elseif(MODE STREQUAL "check")
    set(FORMAT_ARGS --dry-run --Werror)
else()
    message(FATAL_ERROR "Unknown MODE: '${MODE}'; expected 'check' or 'fix'.")
endif()
message(STATUS "MODE: ${MODE}")

# Directory trees to search for C/C++ source files
set(FORMAT_DIRS
    "${PROJECT_ROOT}/include"
    "${PROJECT_ROOT}/src"
    "${PROJECT_ROOT}/tests"
)

# C/C++ source file extensions to match on
set(FORMAT_EXTENSIONS
    c
    cc
    cpp
    cxx
    h
    hh
    hpp
    hxx
)

# Build a list of C/C++ source file globbing patterns from all combinations of the
# specified FORMAT_DIRS and FORMAT_EXTENSIONS
set(FORMAT_PATTERNS)
foreach(DIR IN LISTS FORMAT_DIRS)
    foreach(EXT IN LISTS FORMAT_EXTENSIONS)
        list(APPEND FORMAT_PATTERNS "${DIR}/*.${EXT}")
    endforeach()
endforeach()

if(VERBOSE)
    message(STATUS "Format patterns:")
    foreach(PATTERN IN LISTS FORMAT_PATTERNS)
        message(STATUS "  ${PATTERN}")
    endforeach()
endif()

# Find files that match the glob patterns.
file(GLOB_RECURSE FORMAT_FILES ${FORMAT_PATTERNS})

if(NOT FORMAT_FILES)
    message(STATUS "No C/C++ source files found.")
    return()
endif()

# Convert to relative paths
# The list of files to check is being passed on the command line.  Different platforms have
# different command line length limitations, Windows typically having a shorter limit.
# Convert to relative paths to allow inclusion of more files before that limit is hit.
# Once the limit is hit, files will need to be formatted in batches.
set(FORMAT_FILES_RELATIVE)
foreach(FILE IN LISTS FORMAT_FILES)
    file(RELATIVE_PATH RELATIVE_FILE
        "${PROJECT_ROOT}"
        "${FILE}"
    )
    list(APPEND FORMAT_FILES_RELATIVE "${RELATIVE_FILE}")
endforeach()

# Sort for consistent ordering across platforms
list(SORT FORMAT_FILES_RELATIVE)

# Output number of files found
list(LENGTH FORMAT_FILES_RELATIVE FORMAT_FILE_COUNT)
message(STATUS "Running ${CLANG_FORMAT} on ${FORMAT_FILE_COUNT} files.")

if(VERBOSE)
    foreach(FILE IN LISTS FORMAT_FILES_RELATIVE)
        message(STATUS "  ${FILE}")
    endforeach()
endif()

# Run clang-format on matching files
execute_process(
    COMMAND "${CLANG_FORMAT}" ${FORMAT_ARGS} ${FORMAT_FILES_RELATIVE}
    WORKING_DIRECTORY "${PROJECT_ROOT}"
    COMMAND_ERROR_IS_FATAL ANY
)