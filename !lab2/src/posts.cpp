#include <userver/server/handlers/http_handler_base.hpp>
#include <userver/formats/json.hpp>
#include "storage.hpp"

namespace api {

using namespace userver;

class PostHandler final : public server::handlers::HttpHandlerBase {
public:
    static constexpr std::string_view kName = "handler-posts";

    using HttpHandlerBase::HttpHandlerBase;

    std::string HandleRequestThrow(
        const server::http::HttpRequest& request,
        server::request::RequestContext&) const override {

        auto body = formats::json::FromString(request.RequestBody());

        std::string userId = body["userId"].As<std::string>();

        Post post;
        post.id = std::to_string(rand());
        post.content = body["content"].As<std::string>();

        posts[userId].push_back(post);

        formats::json::ValueBuilder builder;
        builder["postId"] = post.id;

        return formats::json::ToString(builder.ExtractValue());
    }
};

}