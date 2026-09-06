#include <cstdlib>
#include <demolib/example.hpp>
#include <string>

int main() {
    const auto greeting = demolib::greet("package consumer");
    return greeting.find("package consumer") == std::string::npos ? EXIT_FAILURE : EXIT_SUCCESS;
}
