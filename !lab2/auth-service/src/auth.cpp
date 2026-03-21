#include <userver/server/handlers/http_handler_base.hpp>

namespace {

class AuthHandler final : public userver::server::handlers::HttpHandlerBase {
public:
    static constexpr std::string_view kName = "handler-auth";

    using HttpHandlerBase::HttpHandlerBase;

    std::string HandleRequestThrow(
        const userver::server::http::HttpRequest&,
        userver::server::request::RequestContext&) const override {

        return R"({"token":"123"})";
    }
};

}