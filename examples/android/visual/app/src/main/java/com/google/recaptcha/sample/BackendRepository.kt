// Copyright 2022 Google LLC
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

package com.google.recaptcha.sample

/**
 * Simulates a repository that will send the token to the backend and receive back the assessment.
 */
class BackendRepository {

  /**
   * Sends the token to the backend and receives the assessment if the user can login or not. In
   * this simple mock we are returning true for any token that we receive.
   */
  fun assessLoginAction(token: String) : Boolean {
    return true
  }
}