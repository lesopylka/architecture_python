#include <userver/server/handlers/http_handler_base.hpp>
#include <userver/server/http/http_status.hpp>

namespace {

class AuthHandler final : public userver::server::handlers::HttpHandlerBase {
public:
    static constexpr std::string_view kName = "handler-auth";

    using HttpHandlerBase::HttpHandlerBase;

    std::string HandleRequestThrow(
        const userver::server::http::HttpRequest& request,
        userver::server::request::RequestContext&) const override {

        if (request.GetMethod() != userver::server::http::HttpMethod::kPost) {
            request.SetResponseStatus(userver::server::http::HttpStatus::kMethodNotAllowed);
            return R"({"error":"Only POST allowed"})";
        }

        request.SetResponseStatus(userver::server::http::HttpStatus::kOk);

        return R"({"token":"123"})";
    }
};

}