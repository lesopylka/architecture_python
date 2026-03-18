#include <userver/server/handlers/http_handler_base.hpp>
#include <userver/formats/json.hpp>
#include "storage.hpp"

namespace api {

using namespace userver;

class GetUserHandler final : public server::handlers::HttpHandlerBase {
public:
    static constexpr std::string_view kName = "handler-users";

    using HttpHandlerBase::HttpHandlerBase;

    std::string HandleRequestThrow(
        const server::http::HttpRequest& request,
        server::request::RequestContext&) const override {

        auto login = request.GetPathArg("login");

        if (users.find(login) == users.end()) {
            request.SetResponseStatus(server::http::HttpStatus::kNotFound);
            return "Not found";
        }

        auto& user = users[login];

        formats::json::ValueBuilder builder;
        builder["id"] = user.id;
        builder["firstName"] = user.first_name;
        builder["lastName"] = user.last_name;

        return formats::json::ToString(builder.ExtractValue());
    }
};

}