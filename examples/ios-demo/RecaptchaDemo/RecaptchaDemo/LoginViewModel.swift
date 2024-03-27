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

@Observable
class LoginViewModel {
    
    var username: String = ""
    var password: String = ""
    
    var isLogged: Bool = false
    var errorMessage: String? = nil
    
    func login(){
        Task.detached(priority: .background){
            do {
                let tokenResult = await RecaptchaRepository.getToken(action:.login)
                switch tokenResult {
                case .success(let token):
                    let response = try await DemoRepository.login(self.username, self.password, token)
                    self.isLogged = response
                case .failure(let failure):
                    if let recaptchaError = failure as? RecaptchaError {
                        self.errorMessage = recaptchaError.errorMessage
                    }else {
                        self.errorMessage = failure.localizedDescription
                    }
                }
            }catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
