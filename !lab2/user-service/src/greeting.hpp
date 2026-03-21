#pragma once

#include <string>
#include <string_view>

namespace user_service {

enum class UserType { kFirstTime, kKnown };

std::string SayHelloTo(std::string_view name, UserType type);

}  // namespace user_service