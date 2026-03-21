#pragma once

#include <vector>
#include <string>

struct User {
    int id;
    std::string login;
};

struct Post {
    int id;
    int user_id;
    std::string content;
};

struct Message {
    int id;
    int from;
    int to;
    std::string text;
};

inline std::vector<User> users;
inline std::vector<Post> posts;
inline std::vector<Message> messages;