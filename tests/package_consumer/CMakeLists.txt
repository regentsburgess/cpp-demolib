cmake_minimum_required(VERSION 3.30)

project(demolib_package_consumer LANGUAGES CXX)

find_package(demolib CONFIG REQUIRED)

add_executable(demolib_package_consumer main.cpp)
target_link_libraries(demolib_package_consumer PRIVATE demolib::demolib)

enable_testing()
add_test(NAME demolib_package_consumer COMMAND demolib_package_consumer)
