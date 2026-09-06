# Installed-Package Consumer Test

This directory contains an end-to-end test of the `demolib` installed as a CMake package. It does not link directly to the target in the main build tree. It behaves like an independent downstream project that has only an installed copy of the library available.

The test verifies that all of these pieces work together:

- the library and public headers are installed;
- `demolibConfig.cmake` can be found and loaded;
- the exported `demolib::demolib` target is usable;
- a separate project can compile and link against that target; and
- the resulting program can call the library successfully.

## TOC

- [TOC](#toc)
- [Overall Flow](#overall-flow)
- [Files](#files)
  - [`CMakeLists.txt`](#cmakeliststxt)
  - [`main.cpp`](#maincpp)
  - [`run_package_consumer.cmake.in`](#run_package_consumercmakein)
    - [The `CMAKE_PREFIX_PATH` Bridge](#the-cmake_prefix_path-bridge)
- [How It Is Registered](#how-it-is-registered)
- [What This Catches](#what-this-catches)

## Overall Flow

```text
  Main demolib build tree
             |
             | cmake --install
             v
  +----------------------------+
  | Temporary install prefix   |
  |                            |
  | include/demolib/...        |
  | lib/libdemolib...          |
  | lib/cmake/demolib/...      |
  +----------------------------+
             |
             | CMAKE_PREFIX_PATH
             v
  +----------------------------+
  | Standalone consumer        |
  |                            |
  | find_package(demolib)      |
  |          |                 |
  |          v                 |
  | link demolib::demolib      |
  +----------------------------+
             |
             | configure and build
             v
  +----------------------------+
  | Consumer executable        |
  | calls demolib::greet()     |
  +----------------------------+
             |
             | CTest runs it
             v
        PASS or FAIL
```

## Files

### `CMakeLists.txt`

This is the standalone consumer project. It deliberately interacts with `demolib` as an installed package:

```cmake
find_package(demolib CONFIG REQUIRED)
target_link_libraries(demolib_package_consumer PRIVATE demolib::demolib)
```

It also registers its executable with CTest. Letting CTest run the executable avoids assuming where a particular generator places build products; both single-config layouts such as Ninja and multi-config layouts such as Visual Studio are supported.

### `main.cpp`

This is a minimal runtime check. It calls `demolib::greet()` through the linked installed library and returns a nonzero exit code if the expected result is not present.

### `run_package_consumer.cmake.in`

This is the driver script template. The main test configuration processes it with `configure_file(... @ONLY)`, replacing placeholders such as `@CMAKE_COMMAND@`, `@CMAKE_GENERATOR@`, and `@CMAKE_CXX_COMPILER@` with values from the main build.

The generated script performs four steps:

1. Remove its previous temporary consumer build and install directories.
2. Install `demolib` into the clean temporary prefix.
3. Configure and build this standalone consumer against that prefix.
4. Run the consumer through CTest.

#### The `CMAKE_PREFIX_PATH` Bridge

The key bit of glue in the consumer configuration command is:

```cmake
"-DCMAKE_PREFIX_PATH=${consumer_install_dir}"
```

This is a command-line cache definition passed to the nested CMake configure. `CMAKE_PREFIX_PATH` supplies one or more installation prefixes that CMake's `find_package()`, `find_library()`, `find_path()`, and related commands should search. Given the temporary prefix, CMake checks its standard package locations—such as `lib/cmake/demolib/`—and discovers the installed `demolibConfig.cmake` naturally.

That pattern may look unusual because an ordinary project often finds dependencies through system paths, a package manager toolchain, or a user-provided global setting. Here the installation is deliberately private and temporary, so the nested consumer must be told where that isolated package root lives. This one argument connects the install phase to the consumer phase without copying files or exposing the main build-tree target.

The test could instead set `demolib_DIR` directly to the directory containing `demolibConfig.cmake`, but `CMAKE_PREFIX_PATH` better represents normal package consumption: the consumer knows the installation prefix, not the package's internal platform-dependent config location. It also continues to work if the standard config directory moves from `lib` to another `CMAKE_INSTALL_LIBDIR` value.

The consumer inherits the main build's generator and configuration. Command-line generators such as Ninja and Makefiles also inherit the exact compiler path; multi-config IDE generators such as Visual Studio select the matching compiler through their generator, platform, and toolset. This prevents the test from accidentally mixing incompatible toolchains or architectures.

Every external command uses `COMMAND_ERROR_IS_FATAL ANY`. Consequently, an installation, configuration, compilation, link, or runtime failure immediately fails the outer `demolib.package_consumer` test.

## How It Is Registered

The parent `tests/CMakeLists.txt` generates the runnable driver in the build tree and registers it as a normal CTest test:

```cmake
configure_file(
    package_consumer/run_package_consumer.cmake.in
    package_consumer/run_package_consumer.cmake
    @ONLY
)

add_test(
    NAME demolib.package_consumer
    # Run the generated driver script...
)
```

It therefore runs as part of the existing test workflow:

```sh
cmake --workflow --preset <linux|macos|windows>-debug-test
```

The generated driver, temporary installation, and consumer build all live under the main build directory. No generated files are written into this source directory.

This temporary installation is deliberately independent of the persistent `build/<os>-debug/stage` or `build/<os>-release/stage` trees produced by the optional `*-test-install` workflows. The test creates its own clean prefix every time and does not read a staged tree. Consequently, the ordinary `*-test` workflows provide the full installed-package test coverage; running an install workflow is only necessary when a developer wants staged files to remain afterward for inspection or ad hoc use.

## What This Catches

This test can detect packaging defects that direct build-tree unit tests cannot, including:

- omitted public headers or library artifacts;
- broken or non-relocatable install paths;
- missing or invalid package configuration files;
- an incorrectly named exported target;
- missing transitive usage requirements or dependencies; and
- differences between build-tree and installed-package behavior.
