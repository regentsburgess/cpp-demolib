#include <cstdlib>
#include <demolib/example.hpp>
#include <string>

int main() {
    const auto greeting = demolib::greet("subdirectory consumer");
    return greeting.find("subdirectory consumer") == std::string::npos ? EXIT_FAILURE
                                                                       : EXIT_SUCCESS;
}
