// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import RecaptchaInterop
@_exported import RecaptchaEnterpriseSDK

/// Interop class binding the RCAActionProtocol to the RecaptchaAction.
@objc class RCAAction: NSObject, RCAActionProtocol {
  @objc static var login: any RCAActionProtocol = RCAAction(customAction: "login")

  @objc static var signup: any RCAActionProtocol = RCAAction(customAction: "signup")

  let action: String

  required init(customAction: String) {
    self.action = customAction
  }
}

/// Interop class binding the RCARecaptchaClientProtocol to the RecaptchaClient.
@objc class RCAClient: NSObject, RCARecaptchaClientProtocol {

  let client: RecaptchaClient

  required init(_ client: RecaptchaClient) {
    self.client = client
  }

  @objc
  func execute(
    withAction action: any RCAActionProtocol, withTimeout timeout: Double,
    completion: @escaping (String?, (any Error)?) -> Void
  ) {
    client.execute(
        withAction: RecaptchaAction(customAction: action.action), withTimeout: timeout,
      completion: completion)
  }

  @objc
  func execute(
    withAction action: any RCAActionProtocol, completion: @escaping (String?, (any Error)?) -> Void
  ) {
    client.execute(withAction: RecaptchaAction(customAction: action.action), completion: completion)
  }
}

/// Interop class binding the RCARecaptchaProtocol to the Recaptcha.
@objc class RCARecaptcha: NSObject, RCARecaptchaProtocol {

  required init(_ recaptcha: Recaptcha) {}

  @objc
  static func fetchClient(
    withSiteKey siteKey: String,
    completion: @escaping ((any RCARecaptchaClientProtocol)?, (any Error)?) -> Void
  ) {
      Recaptcha.fetchClient(withSiteKey: siteKey) { client, error in
      var interopClient: RCAClient? = nil
      if let unwrapClient = client {
        interopClient = RCAClient(unwrapClient)
      }
      completion(interopClient, error)
    }
  }
}
