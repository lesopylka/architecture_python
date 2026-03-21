#include <userver/server/handlers/http_handler_base.hpp>
#include <userver/formats/json.hpp>
#include "storage.hpp"

namespace {

class MessagesHandler final : public userver::server::handlers::HttpHandlerBase {
public:
    static constexpr std::string_view kName = "handler-messages";

    using HttpHandlerBase::HttpHandlerBase;

    std::string HandleRequestThrow(
        const userver::server::http::HttpRequest& request,
        userver::server::request::RequestContext&) const override {

        if (request.GetMethod() == userver::server::http::HttpMethod::kPost) {
            auto json = userver::formats::json::FromString(request.RequestBody());

            Message m;
            m.id = messages.size() + 1;
            m.from = json["from"].As<int>();
            m.to = json["to"].As<int>();
            m.text = json["text"].As<std::string>();

            messages.push_back(m);

            userver::formats::json::ValueBuilder res;
            res["id"] = m.id;

            return userver::formats::json::ToString(res.ExtractValue());
        }

        userver::formats::json::ValueBuilder arr;
        for (const auto& m : messages) {
            userver::formats::json::ValueBuilder item;
            item["id"] = m.id;
            item["text"] = m.text;
            arr.PushBack(item.ExtractValue());
        }

        return userver::formats::json::ToString(arr.ExtractValue());
    }
};

}