#include <demolib/example.hpp>

namespace demolib {

std::string lib_name() {
    return DEMOLIB_NAME;
}

std::string lib_version() {
    return DEMOLIB_VERSION;
}

std::string greet(const std::string& name) {
    if (name.empty()) {
        return "Hello from " + lib_name() + " " + lib_version();
    }

    return "Hello from " + lib_name() + " " + lib_version() + ", " + name + "!";
}

} // namespace demolib
