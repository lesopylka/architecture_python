#include <userver/server/handlers/http_handler_base.hpp>
#include <userver/formats/json.hpp>
#include "storage.hpp"

namespace api {

using namespace userver;

class MessageHandler final : public server::handlers::HttpHandlerBase {
public:
    static constexpr std::string_view kName = "handler-messages";

    using HttpHandlerBase::HttpHandlerBase;

    std::string HandleRequestThrow(
        const server::http::HttpRequest& request,
        server::request::RequestContext&) const override {

        auto body = formats::json::FromString(request.RequestBody());

        std::string toUserId = body["toUserId"].As<std::string>();

        Message msg;
        msg.id = std::to_string(rand());
        msg.text = body["text"].As<std::string>();

        messages[toUserId].push_back(msg);

        formats::json::ValueBuilder builder;
        builder["messageId"] = msg.id;

        return formats::json::ToString(builder.ExtractValue());
    }
};

}