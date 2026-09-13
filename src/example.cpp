#include <demolib/example.hpp>

namespace demolib {

std::string_view lib_name() {
    return DEMOLIB_NAME;
}

std::string_view lib_version() {
    return DEMOLIB_VERSION;
}

std::string greet(const std::string& name) {
    std::string result{"Hello from "};
    result += lib_name();
    result += ' ';
    result += lib_version();
    if (!name.empty()) {
        result += ", ";
        result += name;
        result += '!';
    }

    return result;
}

} // namespace demolib
