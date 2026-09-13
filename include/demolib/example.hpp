#pragma once

#include <string>

namespace demolib {

/// Returns the library project name as a string.
std::string_view lib_name();

/// Returns the library version as a string.
std::string_view lib_version();

/// Returns a friendly greeting message for the given user name.
auto greet(const std::string& name) -> std::string;

} // namespace demolib
