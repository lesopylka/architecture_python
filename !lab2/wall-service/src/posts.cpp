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

        if (request.GetMethod() == userver::server::http::HttpMethod::kPost) {
            auto json = userver::formats::json::FromString(request.RequestBody());

            Post p;
            p.id = posts.size() + 1;
            p.user_id = json["user_id"].As<int>();
            p.content = json["content"].As<std::string>();

            posts.push_back(p);

            userver::formats::json::ValueBuilder res;
            res["id"] = p.id;

            return userver::formats::json::ToString(res.ExtractValue());
        }

        userver::formats::json::ValueBuilder arr;
        for (const auto& p : posts) {
            userver::formats::json::ValueBuilder item;
            item["id"] = p.id;
            item["content"] = p.content;
            arr.PushBack(item.ExtractValue());
        }

        return userver::formats::json::ToString(arr.ExtractValue());
    }
};

}