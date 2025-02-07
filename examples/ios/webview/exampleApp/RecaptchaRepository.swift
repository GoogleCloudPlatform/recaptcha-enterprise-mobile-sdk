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
import RecaptchaEnterprise

enum RecaptchaRepositoryError: Error {
    case recaptchaNotInitialzied
}

enum RecaptchaRepository {
    static private var recaptchaClient: RecaptchaClient?
    
    static func initRecaptcha(){
      let siteKey: String =
        Bundle.main.object(forInfoDictionaryKey: "SITE_KEY") as? String ?? "NO SITEKEY"
      
      print("SiteKey: " +  siteKey)
        
      Recaptcha.fetchClient(withSiteKey: siteKey) { client, error in
        guard let client = client else {
          print("RecaptchaClient creation error: \(String(describing:error)).")
          return
        }
        self.recaptchaClient = client
      }
    }
    
    static func getToken(action: RecaptchaAction) async -> Result<String,Error> {
        do {
            guard let client = recaptchaClient else {
                throw RecaptchaRepositoryError.recaptchaNotInitialzied
            }
            let token = try await client.execute(withAction: action)
            return .success(token)
        } catch {
            return .failure(error)
        }
    }
}
