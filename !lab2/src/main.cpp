#include <userver/server/handlers/http_handler_base.hpp>
#include <userver/components/minimal_server_component_list.hpp>
#include <userver/utils/daemon_run.hpp>

#include "auth.cpp"
#include "users.cpp"
#include "posts.cpp"
#include "messages.cpp"

int main(int argc, char* argv[]) {
    return userver::utils::DaemonMain(argc, argv,
        userver::components::MinimalServerComponentList()
            .Append<api::RegisterHandler>()
            .Append<api::GetUserHandler>()
            .Append<api::PostHandler>()
            .Append<api::MessageHandler>()
    );
}