# Tests

DemoLib classifies its CTest tests with labels so each CI workflow runs the appropriate scope.

| Label         | Tests                                                                   | Where they run                                    |
| ------------- | ----------------------------------------------------------------------- | ------------------------------------------------- |
| `unit`        | Tests discovered from the `demolib_tests` GoogleTest executable         | Ordinary test workflows, ASan+UBSan, and coverage |
| `metadata`    | Repository and release metadata checks such as `demolib.ci_tag_version` | Ordinary test workflows                           |
| `integration` | Standalone source and installed-package consumer tests                  | Ordinary test workflows                           |

`gtest_discover_tests()` assigns the `unit` label to every test it discovers from `demolib_tests`, so new GoogleTest cases automatically participate in sanitizer and coverage runs. Tests registered separately with `add_test()` must be labeled explicitly.

The sanitizer and coverage presets include only the `unit` label. Metadata tests do not execute instrumented library code, and integration tests create separate consumer builds that intentionally do not inherit CI-only sanitizer or coverage flags. Ordinary Debug and Release workflows do not filter by label and continue to run every test category.
