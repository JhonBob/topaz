// Copyright 2018 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <trace-provider/provider.h>
#include <memory>

#include <fuchsia/cpp/auth.h>

#include "garnet/lib/backoff/exponential_backoff.h"
#include "garnet/lib/network_wrapper/network_wrapper_impl.h"
#include "lib/app/cpp/application_context.h"
#include "lib/fidl/cpp/binding_set.h"
#include "lib/fidl/cpp/interface_request.h"
#include "lib/fsl/tasks/message_loop.h"
#include "lib/fsl/vmo/strings.h"
#include "lib/fxl/command_line.h"
#include "lib/fxl/log_settings_command_line.h"
#include "topaz/auth_providers/spotify/factory_impl.h"

namespace {

class SpotifyAuthProviderApp {
 public:
  SpotifyAuthProviderApp()
      : application_context_(
            component::ApplicationContext::CreateFromStartupInfo()),
        trace_provider_(loop_.async()),
        network_wrapper_(
            loop_.async(), std::make_unique<backoff::ExponentialBackoff>(),
            [this] {
              return application_context_
                  ->ConnectToEnvironmentService<network::NetworkService>();
            }),
        factory_impl_(loop_.task_runner(), application_context_.get(),
                      &network_wrapper_) {
    FXL_DCHECK(application_context_);
  }

  ~SpotifyAuthProviderApp() { loop_.QuitNow(); }

  void Run() {
    application_context_->outgoing_services()
        ->AddService<auth::AuthProviderFactory>(
            [this](fidl::InterfaceRequest<auth::AuthProviderFactory> request) {
              factory_impl_.Bind(std::move(request));
            });
    loop_.Run();
  }

 private:
  fsl::MessageLoop loop_;
  std::unique_ptr<component::ApplicationContext> application_context_;
  trace::TraceProvider trace_provider_;
  network_wrapper::NetworkWrapperImpl network_wrapper_;

  spotify_auth_provider::FactoryImpl factory_impl_;

  FXL_DISALLOW_COPY_AND_ASSIGN(SpotifyAuthProviderApp);
};

}

int main(int argc, const char** argv) {
  auto command_line = fxl::CommandLineFromArgcArgv(argc, argv);
  if (!fxl::SetLogSettingsFromCommandLine(command_line)) {
    return 1;
  }

  SpotifyAuthProviderApp app;
  app.Run();

  return 0;
}
