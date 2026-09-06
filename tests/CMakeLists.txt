# Define a custom target for including private headers.
# Because the target is defined in the `test` subtree, only tests can link to this.
add_library(private_headers_for_testing INTERFACE)
target_include_directories(private_headers_for_testing INTERFACE
    "${PROJECT_SOURCE_DIR}/src"
)

# Add googletest via CPM.
CPMAddPackage(
    NAME googletest
    GITHUB_REPOSITORY google/googletest
    GIT_TAG v1.17.0
    OPTIONS
        "INSTALL_GTEST OFF"
)
include(GoogleTest)


# Tests:
set(TEST_TARGET "${LIB_TARGET_NAME}_tests")

add_executable(${TEST_TARGET}
    demolib_tests.cpp
)
target_link_libraries(${TEST_TARGET}
    PRIVATE
        GTest::gtest_main
        private_headers_for_testing
        ${LIB_PROJECT_NAME}::${LIB_TARGET_NAME}
)
target_compile_definitions(${TEST_TARGET}
    PRIVATE
        EXPECTED_LIB_NAME="${LIB_PROJECT_NAME}"
        EXPECTED_LIB_VERSION="${LIB_PROJECT_VERSION}"
)
demolib_apply_common_compile_settings(${TEST_TARGET})

gtest_discover_tests(${TEST_TARGET}
    PROPERTIES
        LABELS unit
)

# On a CI tag pipeline, require the tag to agree with the CMake project version.
configure_file(
    ci_tag_version.cmake.in
    ci_tag_version.cmake
    @ONLY
)
add_test(
    NAME ${LIB_PROJECT_NAME}.ci_tag_version
    COMMAND ${CMAKE_COMMAND}
        -P "${CMAKE_CURRENT_BINARY_DIR}/ci_tag_version.cmake"
)
set_tests_properties(${LIB_PROJECT_NAME}.ci_tag_version PROPERTIES LABELS metadata)

# Compile each public header as the first and only include in its own translation
# unit. This catches missing direct includes and include-order dependencies.
# This is intentionally a normal build target rather than a CTest test: compilation
# is the assertion, so every build enforces it without CTest launching a nested build.
set(HEADER_SELF_CONTAINMENT_TARGET "${LIB_TARGET_NAME}_header_self_containment")
add_library(${HEADER_SELF_CONTAINMENT_TARGET} OBJECT
    header_self_containment/example.cpp
)
target_link_libraries(${HEADER_SELF_CONTAINMENT_TARGET}
    PRIVATE
        ${LIB_PROJECT_NAME}::${LIB_TARGET_NAME}
)
demolib_apply_common_compile_settings(${HEADER_SELF_CONTAINMENT_TARGET})

# Verify source-tree consumption from a standalone parent project. The nested
# configure ensures demolib behaves correctly when it is not the top-level project.
configure_file(
    subdirectory_consumer/run_subdirectory_consumer.cmake.in
    subdirectory_consumer/run_subdirectory_consumer.cmake
    @ONLY
)
add_test(
    NAME ${LIB_PROJECT_NAME}.subdirectory_consumer
    COMMAND ${CMAKE_COMMAND}
        -DTEST_CONFIG=$<CONFIG>
        -P "${CMAKE_CURRENT_BINARY_DIR}/subdirectory_consumer/run_subdirectory_consumer.cmake"
)
set_tests_properties(${LIB_PROJECT_NAME}.subdirectory_consumer PROPERTIES LABELS integration)

# Verify the installed package from a standalone downstream project. This catches
# problems that direct links to the build-tree target cannot detect.
configure_file(
    package_consumer/run_package_consumer.cmake.in
    package_consumer/run_package_consumer.cmake
    @ONLY
)
add_test(
    NAME ${LIB_PROJECT_NAME}.package_consumer
    COMMAND ${CMAKE_COMMAND}
        -DTEST_CONFIG=$<CONFIG>
        -P "${CMAKE_CURRENT_BINARY_DIR}/package_consumer/run_package_consumer.cmake"
)
set_tests_properties(${LIB_PROJECT_NAME}.package_consumer PROPERTIES LABELS integration)
