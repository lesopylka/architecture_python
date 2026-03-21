#include <hello.hpp>

#include <greeting.hpp>

namespace user_service {

std::string
Hello::HandleRequestThrow(const userver::server::http::HttpRequest& request, userver::server::request::RequestContext&)
    const {
    return SayHelloTo(request.GetArg("name"), UserType::kFirstTime);
}

}  // namespace user_service