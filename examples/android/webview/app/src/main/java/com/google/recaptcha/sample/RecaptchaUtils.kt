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

import android.util.Log

/** Contains init and execute retry wrapper methods for Recaptcha. */
object RecaptchaUtils {
  private const val DEBUG_MODE = true

  fun logDebug(message: String) {
    if (DEBUG_MODE) {
      Log.d("RecaptchaUtils", message)
    }
  }
}