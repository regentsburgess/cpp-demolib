cmake_minimum_required(VERSION 3.30)

project(demolib_subdirectory_consumer LANGUAGES CXX)

add_subdirectory(../.. demolib)

add_executable(demolib_subdirectory_consumer main.cpp)
target_link_libraries(demolib_subdirectory_consumer PRIVATE demolib::demolib)

enable_testing()
add_test(NAME demolib_subdirectory_consumer COMMAND demolib_subdirectory_consumer)
