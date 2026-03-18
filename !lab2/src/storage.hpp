#pragma once

#include <unordered_map>
#include <vector>
#include <string>

struct User {
    std::string id;
    std::string login;
    std::string password;
    std::string first_name;
    std::string last_name;
};

struct Post {
    std::string id;
    std::string content;
};

struct Message {
    std::string id;
    std::string text;
};

inline std::unordered_map<std::string, User> users;
inline std::unordered_map<std::string, std::vector<Post>> posts;
inline std::unordered_map<std::string, std::vector<Message>> messages;