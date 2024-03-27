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

import SwiftUI

struct LoginView: View {
    
    @State 
    private var loginViewModel: LoginViewModel
    
    init(_ loginViewModel: LoginViewModel){
        self.loginViewModel = loginViewModel
    }
    
    var body: some View {
        VStack {
            Text("RecaptchaDemo").padding(12)
            TextField("Username", text: $loginViewModel.username).padding(.vertical,5).padding(.horizontal,20)
            SecureField("Password", text: $loginViewModel.password).padding(.horizontal,20)
            Button("Login"){
                loginViewModel.login()
            }.padding(.vertical,5)
            
            if let errorMessage = loginViewModel.errorMessage{
                Text("Failed: \(errorMessage)")
                    .foregroundStyle(.red)
            }
        }
        .padding()
    }
}

#Preview {
    LoginView(LoginViewModel())
}
