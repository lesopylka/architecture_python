#include <userver/server/handlers/http_handler_base.hpp>
#include <userver/formats/json.hpp>
#include "storage.hpp"
#include <uuid/uuid.h>

namespace api {

using namespace userver;

class RegisterHandler final : public server::handlers::HttpHandlerBase {
public:
    static constexpr std::string_view kName = "handler-auth-register";

    using HttpHandlerBase::HttpHandlerBase;

    std::string HandleRequestThrow(
        const server::http::HttpRequest& request,
        server::request::RequestContext&) const override {

        auto body = formats::json::FromString(request.RequestBody());

        std::string login = body["login"].As<std::string>();

        if (users.find(login) != users.end()) {
            request.SetResponseStatus(server::http::HttpStatus::kConflict);
            return "User exists";
        }

        User user;
        user.id = std::to_string(rand());
        user.login = login;
        user.password = body["password"].As<std::string>();
        user.first_name = body["firstName"].As<std::string>();
        user.last_name = body["lastName"].As<std::string>();

        users[login] = user;

        formats::json::ValueBuilder builder;
        builder["userId"] = user.id;
        builder["accessToken"] = user.id;

        return formats::json::ToString(builder.ExtractValue());
    }
};

} 