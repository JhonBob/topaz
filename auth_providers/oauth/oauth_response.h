// Copyright 2018 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef TOPAZ_AUTH_PROVIDERS_OAUTH_OAUTH_RESPONSE_H_
#define TOPAZ_AUTH_PROVIDERS_OAUTH_OAUTH_RESPONSE_H_

#include "garnet/public/lib/auth/fidl/auth_provider.fidl.h"
#include "lib/network/fidl/network_service.fidl.h"

#include "third_party/rapidjson/rapidjson/document.h"

namespace auth_providers {
namespace oauth {

struct OAuthResponse {
  const auth::AuthProviderStatus status;
  const std::string error_description;
  rapidjson::Document json_response;

  OAuthResponse(const auth::AuthProviderStatus& status,
                const std::string& error_description,
                rapidjson::Document json_response)
      : status(status),
        error_description(error_description),
        json_response(std::move(json_response)) {}
};

OAuthResponse ParseOAuthResponse(network::URLResponsePtr response);

}  // namespace oauth
}  // namespace auth_providers

#endif  // TOPAZ_AUTH_PROVIDERS_OAUTH_OAUTH_RESPONSE_H_