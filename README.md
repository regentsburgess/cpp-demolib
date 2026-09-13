# C++ DemoLib

A cross-platform, IDE-agnostic CMake demo project for building a reusable C++ library.  

- Supports Linux, macOS, Windows
- CI pipelines on GitHub & GitLab
- GoogleTest for unit testing
- Supports consumption through CMake `FetchContent`, [CPM](https://github.com/cpm-cmake/cpm.cmake), Git submodules, or an installed CMake package
- Modern CMake features, including presets and workflows
- IDE-independent 
- Exports `compile_commands.json` to a stable location for dev tooling
- MIT licensed

This is one of many ways to setup a CMake project for a reusable C++ library. It began as a learning exercise and is intended as an example rather than a universal template; adapt its conventions to the needs of your project.  If CMake and C++ are old hat, this may not be the project you are looking for.

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Planned Platforms and Tooling Support](#planned-platforms-and-tooling-support)
- [Building](#building)
  - [CMake Presets](#cmake-presets)
  - [Workflow Presets](#workflow-presets)
  - [Config, Build, and Test Presets](#config-build-and-test-presets)
  - [Build Options](#build-options)
- [Continuous Integration](#continuous-integration)
  - [Code Quality Checks](#code-quality-checks)
- [Use C++ DemoLib in Another CMake Project](#use-c-demolib-in-another-cmake-project)
  - [Add to Project as a subdirectory](#add-to-project-as-a-subdirectory)
  - [Fetch with CPM](#fetch-with-cpm)
  - [Fetch with CMake FetchContent](#fetch-with-cmake-fetchcontent)
  - [Including in Source Files](#including-in-source-files)
- [License](#license)

## Prerequisites

The following are needed to build C++ DemoLib.  They should be accessible via `PATH`:

- [CMake](https://cmake.org) 3.30+
- [C++ compiler](https://en.wikipedia.org/wiki/List_of_compilers#C++_compilers), e.g.: AppleClang, Clang, GCC, MSVC.
- [Git](https://git-scm.com)
- [Ninja](https://github.com/ninja-build/ninja)

## Quick Start

Assuming the [prerequisites](#prerequisites) are met:

```
git clone https://github.com/regentsburgess/cpp-demolib.git
cd cpp-demolib
cmake --workflow --preset <os>-test-debug
```

_`<os>` should match one of `linux`, `macos`, or `windows`._

## Planned Platforms and Tooling Support

| OS    | Arch  | Compiler      | Format       | Static Analysis | Sanitizers  | Coverage        | Status |
| ----- | ----- | ------------- | ------------ | --------------- | ----------- | --------------- | ------ |
| Linux | arm64 | Clang 20      | clang-format | clang-tidy      | ASan, UBSan | llvm-cov        |        |
| Linux | arm64 | GCC 15        | clang-format | clang-tidy      | ASan, UBSan | gcov            |        |
| Linux | x64   | Clang 20      | clang-format | clang-tidy      | ASan, UBSan | llvm-cov        |        |
| Linux | x64   | GCC 15        | clang-format | clang-tidy      | ASan, UBSan | gcov            |        |
| macOS | arm64 | AppleClang 21 | clang-format | clang-tidy      | ASan, UBSan | llvm-cov        | WIP    |
| macOS | arm64 | Clang 20      | clang-format | clang-tidy      | ASan, UBSan | llvm-cov        |        |
| macOS | arm64 | GCC 15        | clang-format | clang-tidy      | ---         | gcov            |        |
| macOS | x64   | AppleClang 21 | clang-format | clang-tidy      | ASan, UBSan | llvm-cov        | WIP    |
| macOS | x64   | Clang 20      | clang-format | clang-tidy      | ASan, UBSan | llvm-cov        |        |
| macOS | x64   | GCC 15        | clang-format | clang-tidy      | ASan, UBSan | gcov            |        |
| Win   | arm64 | clang-cl 22   | clang-format | clang-tidy      | ---         | llvm-cov        |        |
| Win   | arm64 | MSVC 14.51    | clang-format | MSVC /analyze   | ---         | ---             |        |
| Win   | x64   | clang-cl 20   | clang-format | clang-tidy      | ASan, UBSan | llvm-cov        |        |
| Win   | x64   | GCC 15        | clang-format | clang-tidy      | ---         | gcov            |        |
| Win   | x64   | LLVM-MinGW 20 | clang-format | clang-tidy      | ASan, UBSan | llvm-cov        |        |
| Win   | x64   | MSVC 14.51    | clang-format | MSVC /analyze   | ASan        | OpenCppCoverage |        |

## Building

### CMake Presets

[CMake presets](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html) are named, predefined configurations for CMake phases and workflows.  Presets are defined in [`CMakePresets.json`](./CMakePresets.json), `CMakeUserPresets.json`, and any additional JSON files they include.

To list all presets: `cmake --list-presets=all`

### Workflow Presets

Workflow presets run a predefined set of other presets (e.g., configure, build, and test presets).  They can run multiple phases of the build lifecycle with one command.

To configure, build, and test on macOS: `cmake --workflow --preset macos-test-debug`

To list all workflow presets: `cmake --list-presets=workflow`

### Config, Build, and Test Presets

Running the configure, build, and test presets separately provides flexibility that workflow presets do not.  For example, suppose you wanted a quick build-test loop.

To focus on test `DemoLibGreet.PreservesWhitespaceAndPunctuation`:

```
cmake --preset macos-debug
cmake --build --preset macos-debug
ctest --preset macos-debug-test -R '^DemoLibGreet.PreservesWhitespaceAndPunctuation$'
```

Running the steps separately, like in the example above, can make focused development loops faster.  Builds are incremental and only the tests matching the pattern are run.

To list configure, build, and test presets, respectively:

```
cmake --list-presets
cmake --list-presets=build
cmake --list-presets=test
```

### Build Options

C++ DemoLib has a number of build options to tailor behavior for different scenarios (top-level vs used in another project).  The general rule is that C++ DemoLib should not dictate build behavior of a parent project, e.g. treating compiler warnings as errors.

These build options are implemented as [CMake Cache](https://cmake.org/cmake/help/book/mastering-cmake/chapter/CMake%20Cache.html) variables.  Their values are initialized when a build tree is first configured.  They may be overridden via the command line or via user-defined presets in `CMakeUserPresets.json`.

- `BUILD_TESTING`. Include C++ DemoLib tests if enabled.
  - Top-level: Defaults to `ON`.
  - Consumed: Value of `BUILD_TESTING` is ignored and C++ DemoLib tests are not included.
- `DEMOLIB_CLANG_TIDY_WARNINGS_AS_ERRORS`. Treat clang-tidy warnings as errors.
  - Defaults to `OFF`.
- `DEMOLIB_CLANG_TIDY_ENABLE`. Run clang-tidy while compiling C++ DemoLib targets.
  - Defaults to `OFF`.
- `DEMOLIB_COVERAGE_ENABLE`. Instrument C++ DemoLib targets for LLVM source-based coverage.
  - Defaults to `OFF`.
- `DEMOLIB_CLANG_SANITIZERS_ENABLE`. Instrument C++ DemoLib with Clang's [AddressSanitizer](https://clang.llvm.org/docs/AddressSanitizer.html) and [UndefinedBehaviorSanitizer](https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html).
  - Defaults to `OFF`.
- `DEMOLIB_COMPILER_WARNINGS_AS_ERRORS`. Value is passed to CMake's `COMPILE_WARNING_AS_ERROR`. 
  - Top-level: Defaults to `ON`.
  - Consumed: Defaults to `OFF`
- `DEMOLIB_INSTALL`. Generate C++ DemoLib installation rules if truthy.
  - Top-level: Defaults to `ON`.
  - Consumed: Defaults to `OFF`

## Continuous Integration

C++ DemoLib uses GitHub and GitLab CI pipelines for:

- Cross-platform build support checks
- Code quality checks

GitLab pipelines are configured via `.gitlab-ci.yml`; GitHub Actions via `.github/workflows/*.yml`. 


### Code Quality Checks



## Use C++ DemoLib in Another CMake Project

```
TODO
```

### Add to Project as a subdirectory

During development, the simplest option is to add the library as a subdirectory:

```cmake
add_subdirectory(path/to/demolib)
target_link_libraries(your_target PRIVATE demolib::demolib)
```

### Fetch with CPM

```cmake
# Download from https://github.com/cpm-cmake/cpm.cmake
include(${CMAKE_SOURCE_DIR}/cmake/CPM.cmake)

CPMAddPackage(
    NAME demolib
    GITHUB_REPOSITORY regentsburgess/demolib
    GIT_TAG v0.1.0
)

target_link_libraries(your_target PRIVATE demolib::demolib)
```

### Fetch with CMake FetchContent

```cmake
include(FetchContent)

FetchContent_Declare(
    demolib
    GIT_REPOSITORY https://github.com/regentsburgess/demolib.git
    GIT_TAG v0.1.0
    GIT_SHALLOW TRUE
)
FetchContent_MakeAvailable(demolib)

target_link_libraries(your_target PRIVATE demolib::demolib)
```

When they fetch the source, both CPM and `FetchContent_MakeAvailable()` incorporate DemoLib with `add_subdirectory()` semantics. Accordingly, DemoLib is no longer a top level project and thus tests are not added, installation and warnings-as-errors default to disabled, and the consumer's selected compiler and toolchain build DemoLib from source.

### Including in Source Files

Public headers are included from the `demolib` root:

```cpp
#include <demolib/example.hpp>
```

## License

C++ DemoLib is available under the [MIT License](LICENSE).

If this project helps you learn C++ and CMake or serves as the basis for your own project, the attribution required by the license is sufficient; additional credit is appreciated but not expected.
