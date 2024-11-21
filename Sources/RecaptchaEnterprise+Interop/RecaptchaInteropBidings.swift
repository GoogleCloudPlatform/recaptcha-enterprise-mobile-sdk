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
@_exported import RecaptchaInterop
@_exported import RecaptchaEnterprise

/// Interop class binding the RCAActionProtocol to the RecaptchaAction.
@objc public class RCAAction: NSObject, RCAActionProtocol {
  @objc public static var login: any RCAActionProtocol = RCAAction(customAction: "login")

  @objc public static var signup: any RCAActionProtocol = RCAAction(customAction: "signup")

  public let action: String

  public required init(customAction: String) {
    self.action = customAction
  }
}

/// Interop class binding the RCARecaptchaClientProtocol to the RecaptchaClient.
@objc public class RCAClient: NSObject, RCARecaptchaClientProtocol {

  let client: RecaptchaClient

  required init(_ client: RecaptchaClient) {
    self.client = client
  }

  @objc
  public func execute(
    withAction action: any RCAActionProtocol, withTimeout timeout: Double,
    completion: @escaping (String?, (any Error)?) -> Void
  ) {
    client.execute(
        withAction: RecaptchaAction(customAction: action.action), withTimeout: timeout,
      completion: completion)
  }

  @objc
  public func execute(
    withAction action: any RCAActionProtocol, completion: @escaping (String?, (any Error)?) -> Void
  ) {
    client.execute(withAction: RecaptchaAction(customAction: action.action), completion: completion)
  }
}

/// Interop class binding the RCARecaptchaProtocol to the Recaptcha.
@objc public class RCARecaptcha: NSObject, RCARecaptchaProtocol {

  required init(_ recaptcha: Recaptcha) {}

  @objc
  public static func getClient(
    withSiteKey siteKey: String, withTimeout timeout: Double,
    completion: @escaping ((any RCARecaptchaClientProtocol)?, (any Error)?) -> Void
  ) {
    Recaptcha.getClient(withSiteKey: siteKey, withTimeout: timeout) { client, error in
      var interopClient: RCAClient? = nil
      if let unwrapClient = client {
        interopClient = RCAClient(unwrapClient)
      }
      completion(interopClient, error)
    }
  }

  @objc
  public static func getClient(
    withSiteKey siteKey: String,
    completion: @escaping ((any RCARecaptchaClientProtocol)?, (any Error)?) -> Void
  ) {
    Recaptcha.getClient(withSiteKey: siteKey) { client, error in
      var interopClient: RCAClient? = nil
      if let unwrapClient = client {
        interopClient = RCAClient(unwrapClient)
      }
      completion(interopClient, error)
    }
  }
}
