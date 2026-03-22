#include <userver/server/handlers/http_handler_base.hpp>
#include <userver/formats/json.hpp>
#include "storage.hpp"

namespace {

class UsersHandler final : public userver::server::handlers::HttpHandlerBase {
public:
    static constexpr std::string_view kName = "handler-users";

    using HttpHandlerBase::HttpHandlerBase;

    std::string HandleRequestThrow(
        const userver::server::http::HttpRequest& request,
        userver::server::request::RequestContext&) const override {

        // GET фильтры
        auto login = request.GetArg("login");
        auto name = request.GetArg("name");

        if (request.GetMethod() == userver::server::http::HttpMethod::kGet) {

            userver::formats::json::ValueBuilder arr;

            for (const auto& u : users) {
                if (!login.empty() && u.login != login) continue;
                if (!name.empty() && u.login.find(name) == std::string::npos) continue;

                userver::formats::json::ValueBuilder item;
                item["id"] = u.id;
                item["login"] = u.login;
                arr.PushBack(item.ExtractValue());
            }

            return userver::formats::json::ToString(arr.ExtractValue());
        }

        // POST
        if (request.GetMethod() == userver::server::http::HttpMethod::kPost) {
            auto json = userver::formats::json::FromString(request.RequestBody());

            if (!json.HasMember("login")) {
                request.SetResponseStatus(userver::server::http::HttpStatus::kBadRequest);
                return R"({"error":"login required"})";
            }

            User u;
            u.id = users.size() + 1;
            u.login = json["login"].As<std::string>();

            users.push_back(u);

            request.SetResponseStatus(userver::server::http::HttpStatus::kCreated);

            userver::formats::json::ValueBuilder res;
            res["id"] = u.id;
            res["login"] = u.login;

            return userver::formats::json::ToString(res.ExtractValue());
        }

        request.SetResponseStatus(userver::server::http::HttpStatus::kMethodNotAllowed);
        return R"({"error":"Method not allowed"})";
    }
};

}