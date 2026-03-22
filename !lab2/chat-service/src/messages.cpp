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

        // AUTH
        auto token = request.GetHeader("Authorization");
        if (token != "Bearer 123") {
            request.SetResponseStatus(userver::server::http::HttpStatus::kUnauthorized);
            return R"({"error":"Unauthorized"})";
        }

        // POST
        if (request.GetMethod() == userver::server::http::HttpMethod::kPost) {
            auto json = userver::formats::json::FromString(request.RequestBody());

            if (!json.HasMember("from") || !json.HasMember("to") || !json.HasMember("text")) {
                request.SetResponseStatus(userver::server::http::HttpStatus::kBadRequest);
                return R"({"error":"invalid data"})";
            }

            Message m;
            m.id = messages.size() + 1;
            m.from = json["from"].As<int>();
            m.to = json["to"].As<int>();
            m.text = json["text"].As<std::string>();

            messages.push_back(m);

            request.SetResponseStatus(userver::server::http::HttpStatus::kCreated);

            userver::formats::json::ValueBuilder res;
            res["id"] = m.id;

            return userver::formats::json::ToString(res.ExtractValue());
        }

        // GET
        if (request.GetMethod() == userver::server::http::HttpMethod::kGet) {
            auto user_id = request.GetArg("user_id");

            userver::formats::json::ValueBuilder arr;

            for (const auto& m : messages) {
                if (!user_id.empty()) {
                    int uid = std::stoi(user_id);
                    if (m.from != uid && m.to != uid) continue;
                }

                userver::formats::json::ValueBuilder item;
                item["id"] = m.id;
                item["from"] = m.from;
                item["to"] = m.to;
                item["text"] = m.text;

                arr.PushBack(item.ExtractValue());
            }

            return userver::formats::json::ToString(arr.ExtractValue());
        }

        request.SetResponseStatus(userver::server::http::HttpStatus::kMethodNotAllowed);
        return R"({"error":"Method not allowed"})";
    }
};

}