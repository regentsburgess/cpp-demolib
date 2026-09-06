# TODO

1. Check if inclusion of consumer tests should hinge on DEMOLIB_INSTALL's value.  Put differently, will the consumer tests break of DEMOLIB_INSTALL is false?  If so, what to do?  Should the tests not be include?  Should the combination result in an error?  A warning?
3. Root CMakeLists.txt cleanup
   1. Move clangd + compile_commands.json export to separate file
   2. Move common config function to separate file
4. Cross-compilation target(s)?
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
