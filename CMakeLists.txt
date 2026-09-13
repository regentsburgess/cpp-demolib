cmake_minimum_required(VERSION 3.30)

# Set value of a variable and then print the variable's value.
macro(set_and_echo VAR_NAME)
    set(${VAR_NAME} ${ARGN})
    message(STATUS "${VAR_NAME}: ${${VAR_NAME}}")
endmacro()

# Per-project Metadata:
## CMake project() Values:
set_and_echo(LIB_PROJECT_NAME "demolib")
set_and_echo(LIB_PROJECT_DESCRIPTION "A demo, reusable C++ library")
set_and_echo(LIB_PROJECT_VERSION "0.1.0")
set_and_echo(LIB_PROJECT_HOMEPAGE_URL "https://github.com/regentsburgess/cpp-demolib")
## Resulting Library:
## The resulting library binary's name, sans any extension.
## Also serves as the CMake target name for the library.
set_and_echo(LIB_TARGET_NAME "demolib")
## Public Include Directory:
## The value of LIB_INCLUDE_DIR_NAME must match ./include/LIB_INCLUDE_DIR_NAME
## It sets the root of import statements (e.g.) include <LIB_INCLUDE_DIR_NAME/someheader.hpp>
set_and_echo(LIB_INCLUDE_DIR_NAME "${LIB_TARGET_NAME}")


# Root project:
project(${LIB_PROJECT_NAME}
    VERSION ${LIB_PROJECT_VERSION}
    DESCRIPTION ${LIB_PROJECT_DESCRIPTION}
    HOMEPAGE_URL ${LIB_PROJECT_HOMEPAGE_URL}
    LANGUAGES CXX
)
message(STATUS "CMAKE_GENERATOR: ${CMAKE_GENERATOR}")
message(STATUS "PROJECT_IS_TOP_LEVEL: ${PROJECT_IS_TOP_LEVEL}")

# Options:
# Settings that an incorporating project might want control of
## clang-format:
option(DEMOLIB_CLANG_FORMAT_ENABLE "Run clang-format, fixing formatting where possible." OFF)
message(STATUS "DEMOLIB_CLANG_FORMAT_ENABLE: ${DEMOLIB_CLANG_FORMAT_ENABLE}")
## Clang address and undefined behavior sanitizers:
option(DEMOLIB_CLANG_SANITIZERS_ENABLE "Instrument ${LIB_PROJECT_NAME} targets with AddressSanitizer and UndefinedBehaviorSanitizer." OFF)
message(STATUS "DEMOLIB_CLANG_SANITIZERS_ENABLE: ${DEMOLIB_CLANG_SANITIZERS_ENABLE}")
## clang-tidy:
option(DEMOLIB_CLANG_TIDY_ENABLE "Run clang-tidy while compiling ${LIB_PROJECT_NAME} targets." OFF)
message(STATUS "DEMOLIB_CLANG_TIDY_ENABLE: ${DEMOLIB_CLANG_TIDY_ENABLE}")
option(DEMOLIB_CLANG_TIDY_WARNINGS_AS_ERRORS "Treat clang-tidy warnings as errors." OFF)
message(STATUS "DEMOLIB_CLANG_TIDY_WARNINGS_AS_ERRORS: ${DEMOLIB_CLANG_TIDY_WARNINGS_AS_ERRORS}")
## Compiler warnings as errors:
option(DEMOLIB_COMPILER_WARNINGS_AS_ERRORS "Treat warnings as errors." ${PROJECT_IS_TOP_LEVEL})
message(STATUS "DEMOLIB_COMPILER_WARNINGS_AS_ERRORS: ${DEMOLIB_COMPILER_WARNINGS_AS_ERRORS}")
## llvm-cov:
option(DEMOLIB_COVERAGE_ENABLE "Instrument ${LIB_PROJECT_NAME} targets for LLVM source-based coverage." OFF)
message(STATUS "DEMOLIB_COVERAGE_ENABLE: ${DEMOLIB_COVERAGE_ENABLE}")
## Install Project:
## True = Install this library's static archive, headers, and CMake package.
## False is useful when this library is being incorporated into another project
option(DEMOLIB_INSTALL "Generate ${LIB_PROJECT_NAME} installation rules." ${PROJECT_IS_TOP_LEVEL})
message(STATUS "DEMOLIB_INSTALL: ${DEMOLIB_INSTALL}")

# Dependencies:
# Test-only at the moment.  See below.

# Clang-Tidy:
# Optionally run clang-tidy during the build process.
if(DEMOLIB_CLANG_TIDY_ENABLE)
    message(STATUS "clang-tidy enabled. Searching for clang-tidy executable.")
    find_program(CLANG_TIDY_EXE NAMES clang-tidy-19 clang-tidy clang-tidy.exe REQUIRED)
    message(STATUS "clang-tidy: ${CLANG_TIDY_EXE}")
else()
    message(STATUS "clang-tidy not enabled.")
endif()

# Common Compile Settings:
## The clang-tidy property must be applied to the compilation target.
## Helper function for applying the project's build options & clang-tidy.
function(demolib_apply_common_compile_settings target_name)
    target_compile_features(${target_name}
        PRIVATE
            cxx_std_20
    )

    target_compile_options(${target_name}
        PRIVATE
            "$<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-Wall;-Wextra;-Wpedantic>"
            "$<$<CXX_COMPILER_ID:MSVC>:/W4>"
    )

    set_target_properties(${target_name} PROPERTIES
        COMPILE_WARNING_AS_ERROR ${DEMOLIB_COMPILER_WARNINGS_AS_ERRORS}
        CXX_EXTENSIONS OFF
        CXX_SCAN_FOR_MODULES OFF
    )

    get_target_property(target_type ${target_name} TYPE)

    if(DEMOLIB_CLANG_SANITIZERS_ENABLE)
        target_compile_options(${target_name} PRIVATE
            -fsanitize=address,undefined
            -fno-omit-frame-pointer
        )
        if(target_type STREQUAL "EXECUTABLE")
            target_link_options(${target_name} PRIVATE
                -fsanitize=address,undefined
            )
        endif()
    endif()

    if(DEMOLIB_COVERAGE_ENABLE)
        target_compile_options(${target_name} PRIVATE
            -fprofile-instr-generate
            -fcoverage-mapping
        )
        if(target_type STREQUAL "EXECUTABLE")
            target_link_options(${target_name} PRIVATE
                -fprofile-instr-generate
            )
        endif()
    endif()

    if(DEMOLIB_CLANG_TIDY_ENABLE)
        set_and_echo(clang_tidy_command "${CLANG_TIDY_EXE}" --quiet)
        if(DEMOLIB_CLANG_TIDY_WARNINGS_AS_ERRORS)
            list(APPEND clang_tidy_command "--warnings-as-errors=*")
        endif()
        set_property(TARGET ${target_name} PROPERTY CXX_CLANG_TIDY "${clang_tidy_command}")
    endif()
endfunction()

if(DEMOLIB_CLANG_SANITIZERS_ENABLE AND DEMOLIB_COVERAGE_ENABLE)
    message(FATAL_ERROR "Sanitizer and coverage instrumentation must use separate build trees.")
endif()
if((DEMOLIB_CLANG_SANITIZERS_ENABLE OR DEMOLIB_COVERAGE_ENABLE) AND NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    message(FATAL_ERROR "DemoLib sanitizer and coverage presets require Clang.")
endif()

# Library:
add_library(${LIB_TARGET_NAME} STATIC
    src/example.cpp
)
add_library(${LIB_PROJECT_NAME}::${LIB_TARGET_NAME} ALIAS ${LIB_TARGET_NAME})
demolib_apply_common_compile_settings(${LIB_TARGET_NAME})
set_target_properties(${LIB_TARGET_NAME} PROPERTIES
    POSITION_INDEPENDENT_CODE ON
)
include(GNUInstallDirs)
target_sources(${LIB_TARGET_NAME}
    PUBLIC
        FILE_SET HEADERS
        BASE_DIRS
            "${CMAKE_CURRENT_SOURCE_DIR}/include"
        FILES
            "${CMAKE_CURRENT_SOURCE_DIR}/include/${LIB_INCLUDE_DIR_NAME}/example.hpp"
)
target_include_directories(${LIB_TARGET_NAME}
    PRIVATE
        "${CMAKE_CURRENT_SOURCE_DIR}/src"
)
target_compile_definitions(${LIB_TARGET_NAME}
    PRIVATE
        DEMOLIB_NAME="${LIB_PROJECT_NAME}"
        DEMOLIB_VERSION="${LIB_PROJECT_VERSION}"
)

# Installation & CMake Package Config:
if(DEMOLIB_INSTALL)
    message(STATUS "${LIB_TARGET_NAME} to be installed/staged to ${CMAKE_INSTALL_PREFIX}")
    include(CMakePackageConfigHelpers)
    install(TARGETS ${LIB_TARGET_NAME}
        EXPORT ${LIB_PROJECT_NAME}Targets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        FILE_SET HEADERS DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
    install(FILES LICENSE
        DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/licenses/${LIB_PROJECT_NAME}
    )
    # SemVer permits breaking changes in a pre-1.0 minor release, while CMake's
    # SameMajorVersion would treat every 0.x release as compatible.
    if(PROJECT_VERSION_MAJOR EQUAL 0)
        set(LIB_VERSION_COMPATIBILITY SameMinorVersion)
    else()
        set(LIB_VERSION_COMPATIBILITY SameMajorVersion)
    endif()
    write_basic_package_version_file(
        "${CMAKE_CURRENT_BINARY_DIR}/${LIB_PROJECT_NAME}ConfigVersion.cmake"
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY ${LIB_VERSION_COMPATIBILITY}
    )
    configure_package_config_file(
        cmake/PackageConfig.cmake.in
        "${CMAKE_CURRENT_BINARY_DIR}/${LIB_PROJECT_NAME}Config.cmake"
        INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${LIB_PROJECT_NAME}
    )
    install(FILES
        "${CMAKE_CURRENT_BINARY_DIR}/${LIB_PROJECT_NAME}Config.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/${LIB_PROJECT_NAME}ConfigVersion.cmake"
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${LIB_PROJECT_NAME}
    )
    install(EXPORT ${LIB_PROJECT_NAME}Targets
        NAMESPACE ${LIB_PROJECT_NAME}::
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${LIB_PROJECT_NAME}
    )
endif()

# Testing:
# BUILD_TESTING is intended to be set via CMakePresets.json.
if(PROJECT_IS_TOP_LEVEL)
    message(STATUS "${LIB_PROJECT_NAME} is the top-level project. Including CTest.")
    include(CTest)

    if(BUILD_TESTING)
        message(STATUS "BUILD_TESTING: ${BUILD_TESTING}.  Including ${LIB_PROJECT_NAME} tests.")

        ## Add CPM (A CMake dependency manager).  At a minimum it's used in ./tests to add googletest
        include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/CPM.cmake)

        message(STATUS "Adding `tests` subdirectory")
        add_subdirectory(tests)
    else()
        message(STATUS "BUILD_TESTING: ${BUILD_TESTING}. Not including ${LIB_PROJECT_NAME} tests.")
    endif()
else()
    message(STATUS "${LIB_PROJECT_NAME} is not the top-level project.  Not including CTest.")
endif()

# clangd + compile_commands.json:
# clangd expects compile_commands.json in a fixed location, while CMake exports it
# into a per-preset build directory. Point a stable alias at the active build tree.
message(STATUS "CMAKE_EXPORT_COMPILE_COMMANDS: ${CMAKE_EXPORT_COMPILE_COMMANDS}")
if(CMAKE_EXPORT_COMPILE_COMMANDS)
    cmake_language(DEFER CALL demolib_symlink_to_exported_compile_commands)

    function(demolib_symlink_to_exported_compile_commands)
        if(NOT PROJECT_IS_TOP_LEVEL)
            return()
        endif()

        set(CLANGD_ALIAS_DIR "${CMAKE_SOURCE_DIR}/build/clangd")
        set(CLANGD_TARGET_DIR "${CMAKE_BINARY_DIR}")
        cmake_path(GET CLANGD_ALIAS_DIR PARENT_PATH CLANGD_ALIAS_PARENT_DIR)
        file(MAKE_DIRECTORY "${CLANGD_ALIAS_PARENT_DIR}")

        message(STATUS "Updating clangd compile db alias: ${CLANGD_ALIAS_DIR} -> ${CLANGD_TARGET_DIR}")

        if(CMAKE_HOST_WIN32)
            cmake_path(NATIVE_PATH CLANGD_ALIAS_DIR NORMALIZE CLANGD_ALIAS_DIR_NATIVE)
            cmake_path(NATIVE_PATH CLANGD_TARGET_DIR NORMALIZE CLANGD_TARGET_DIR_NATIVE)

            execute_process(
                COMMAND cmd /c rmdir "${CLANGD_ALIAS_DIR_NATIVE}"
                OUTPUT_QUIET
                ERROR_QUIET
            )

            execute_process(
                COMMAND cmd /c mklink /J
                    "${CLANGD_ALIAS_DIR_NATIVE}"
                    "${CLANGD_TARGET_DIR_NATIVE}"
                RESULT_VARIABLE CLANGD_ALIAS_RESULT
                OUTPUT_VARIABLE CLANGD_ALIAS_OUTPUT
                ERROR_VARIABLE CLANGD_ALIAS_ERROR
            )
        elseif(CMAKE_HOST_UNIX)
            # Linux and macOS use a symbolic link rather than a Windows junction.
            # Remove only an existing symlink; preserve a real file or directory.
            if(IS_SYMLINK "${CLANGD_ALIAS_DIR}")
                file(REMOVE "${CLANGD_ALIAS_DIR}")
            elseif(EXISTS "${CLANGD_ALIAS_DIR}")
                set(CLANGD_ALIAS_RESULT 1)
                set(CLANGD_ALIAS_ERROR
                    "Alias path already exists and is not a symbolic link; refusing to replace it."
                )
            endif()

            if(NOT DEFINED CLANGD_ALIAS_RESULT)
                execute_process(
                    COMMAND "${CMAKE_COMMAND}" -E create_symlink
                        "${CLANGD_TARGET_DIR}"
                        "${CLANGD_ALIAS_DIR}"
                    RESULT_VARIABLE CLANGD_ALIAS_RESULT
                    OUTPUT_VARIABLE CLANGD_ALIAS_OUTPUT
                    ERROR_VARIABLE CLANGD_ALIAS_ERROR
                )
            endif()
        else()
            set(CLANGD_ALIAS_RESULT 1)
            set(CLANGD_ALIAS_ERROR
                "Unsupported host platform; expected Windows, Linux, or macOS."
            )
        endif()

        if(CLANGD_ALIAS_RESULT EQUAL 0)
            message(STATUS "clangd compile db updated successfully: ${CLANGD_ALIAS_DIR} -> ${CLANGD_TARGET_DIR}")
        else()
            message(WARNING
                "Failed to create clangd compile db alias.\n"
                "Alias: ${CLANGD_ALIAS_DIR}\n"
                "Target: ${CLANGD_TARGET_DIR}\n"
                "Error: ${CLANGD_ALIAS_ERROR}"
            )
        endif()
    endfunction()
endif()
