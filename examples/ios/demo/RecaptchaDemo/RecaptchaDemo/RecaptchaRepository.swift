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
    
    static let siteKey: String = "SITE_KEY"
    
    static private var recaptchaClient: Result<RecaptchaClient,Error>?
    
    static func initRecaptcha(){
        Task.detached {
            do {
                recaptchaClient = .success(try await Recaptcha.getClient(withSiteKey: siteKey))
            } catch {
                recaptchaClient = .failure(error)
            }
        }
    }
    
    static func getToken(action: RecaptchaAction) async -> Result<String,Error> {
        do {
            guard let client = try recaptchaClient?.get() else {
                throw RecaptchaRepositoryError.recaptchaNotInitialzied
            }
            let token = try await client.execute(withAction: action) 
            return .success(token)
        } catch {
            return .failure(error)
        }
    }
}
