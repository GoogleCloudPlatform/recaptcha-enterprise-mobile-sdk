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

enum DemoRepositoryError: Error {
    case unableToCreateUrl
    case emptyData
    case unableToParseResponse
}

enum DemoRepository {
    
    static func login(_ username: String, _ password: String, _ token: String) async throws -> Bool {
        return try await withCheckedThrowingContinuation{ continuation in
            do {
                guard let url = URL(string: "http://127.0.0.1:8080/login") else {
                    throw DemoRepositoryError.unableToCreateUrl
                }
                
                let json = [
                    "username": username,
                    "password": password,
                    "token": token,
                    "siteKey": RecaptchaRepository.siteKey,
                ]
                
                let jsonData = try JSONEncoder().encode(json)
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                URLSession.shared.dataTask(with: request){ data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    }
                    
                    guard let data = data else {
                        continuation.resume(throwing: DemoRepositoryError.emptyData)
                        return
                    }
                    
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let shouldBlock = json["shouldBlock"] as? Bool else  {
                        continuation.resume(throwing: DemoRepositoryError.unableToParseResponse)
                        return
                    }
                    
                    continuation.resume(returning: !shouldBlock)
                }.resume()
            } catch{
                continuation.resume(throwing: error)
            }
        }
    }
}
