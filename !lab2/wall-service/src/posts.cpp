#include <userver/server/handlers/http_handler_base.hpp>
#include <userver/formats/json.hpp>
#include "storage.hpp"

namespace {

class PostsHandler final : public userver::server::handlers::HttpHandlerBase {
public:
    static constexpr std::string_view kName = "handler-posts";

    using HttpHandlerBase::HttpHandlerBase;

    std::string HandleRequestThrow(
        const userver::server::http::HttpRequest& request,
        userver::server::request::RequestContext&) const override {

        // AUTH
        auto token = request.GetHeader("Authorization");
        if (token != "Bearer 123") {
            request.SetResponseStatus(userver::server::http::HttpStatus::kUnauthorized);
            return R"({"error":"Unauthorized"})";
        }

        // POST
        if (request.GetMethod() == userver::server::http::HttpMethod::kPost) {
            auto json = userver::formats::json::FromString(request.RequestBody());

            if (!json.HasMember("user_id") || !json.HasMember("content")) {
                request.SetResponseStatus(userver::server::http::HttpStatus::kBadRequest);
                return R"({"error":"invalid data"})";
            }

            Post p;
            p.id = posts.size() + 1;
            p.user_id = json["user_id"].As<int>();
            p.content = json["content"].As<std::string>();

            posts.push_back(p);

            request.SetResponseStatus(userver::server::http::HttpStatus::kCreated);

            userver::formats::json::ValueBuilder res;
            res["id"] = p.id;

            return userver::formats::json::ToString(res.ExtractValue());
        }

        // GET
        if (request.GetMethod() == userver::server::http::HttpMethod::kGet) {
            auto user_id = request.GetArg("user_id");

            userver::formats::json::ValueBuilder arr;

            for (const auto& p : posts) {
                if (!user_id.empty() && p.user_id != std::stoi(user_id)) continue;

                userver::formats::json::ValueBuilder item;
                item["id"] = p.id;
                item["user_id"] = p.user_id;
                item["content"] = p.content;

                arr.PushBack(item.ExtractValue());
            }

            return userver::formats::json::ToString(arr.ExtractValue());
        }

        request.SetResponseStatus(userver::server::http::HttpStatus::kMethodNotAllowed);
        return R"({"error":"Method not allowed"})";
    }
};

}