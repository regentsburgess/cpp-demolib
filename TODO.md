# TODO

1. Get non-embedded CI cross-platform checks working.
   1. [ ] Linux
   2. [ ] macOS
   3. [ ] Windows
2. code quality build preset
   1. clang-format
   2. clang-tidy
   3. clang-coverage
   4. clang-coverage report
3. all workflow preset
4. Check if inclusion of consumer tests should hinge on DEMOLIB_INSTALL's value.  Put differently, will the consumer tests break of DEMOLIB_INSTALL is false?  If so, what to do?  Should the tests not be include?  Should the combination result in an error?  A warning?
5. Root CMakeLists.txt cleanup
   1. Move clangd + compile_commands.json export to separate file
   2. Move common config function to separate file
6. Cross-compilation target(s)?
   1. What's easy, relevant, and instructive?
   2. Existing Docker images or build Docker images for CI-driven builds?
   3. What do by CI providers (GitHub and/or GitLab) support?
   4. Some candidate ideas:
      1. Desktop Linux ARM target
      2. Embedded ARM Linux target
         1. NXP i.MX8
      3. Embedded Bare Metal ARM target
         1. NXP RT1170
         2. STM32 Cortex-M
7. GitLab setup


1. **Install/export support and a consumer smoke test — Highest priority.** Proves another project can install your library, find it with `find_package()`, and link its exported target.
2. **clangd + compilation database — High priority.** Gives developers navigation, completion, and diagnostics through a reproducible editor setup.
3. **`.editorconfig` — High priority.** Keeps indentation, encoding, and line endings consistent across C++, CMake, YAML, and documentation.
4. **Dependency update automation — High priority.** Keeps dependencies and GitHub Actions from quietly becoming stale.
5. **CMake and workflow linting — Medium priority.** Catches problems in the template’s build and CI infrastructure—the parts downstream projects will copy.
6. **API documentation — Medium priority.** Provides an example of documenting and publishing the library’s public interface; Doxygen is one option.
7. **Benchmarks — Optional.** Demonstrates measuring performance separately from correctness tests.
8. **Fuzzing — Optional.** Adds value when the example includes parsers, decoders, or other functions that accept complex input.