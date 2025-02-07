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

import android.app.Application
import android.util.Log
import com.google.android.recaptcha.Recaptcha
import com.google.android.recaptcha.RecaptchaAction
import com.google.android.recaptcha.RecaptchaClient
import com.google.android.recaptcha.RecaptchaException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.withContext

/**
 * Provider to serve as a data source for all Recaptcha relative APIs. In an environment with
 * dependency injection using Hilt or Koin this can be a class instead of an Object that's
 * instantiated once and the following executes are done by referencing the provider.
 */
object RecaptchaProvider {

  private lateinit var recaptchaClient: RecaptchaClient
  private val SITE_KEY = BuildConfig.SITE_KEY

  /**
   * Trigger the initialization of the RecaptchaClient in the IO scope.
   *
   * @param application The Application context.
   */
  fun initRecaptcha(application: Application) {
    try {
      CoroutineScope(Dispatchers.IO).async {
        recaptchaClient = Recaptcha.fetchClient(application, SITE_KEY)
      }
    } catch(exception: RecaptchaException){
      RecaptchaUtils.logDebug("Encountered error in fetchClient")
      RecaptchaUtils.logDebug(exception.errorMessage)
    }
  }

  /**
   * Executes the action in the RecaptchaClient that was initialized using the [initRecaptcha]
   * method.
   *
   * @param action The action that will be protected using Recaptcha.
   * @return A Result containing the Token that will be sent to the backend for assessment
   *  retrieval.
   */
  suspend fun executeAction(action: RecaptchaAction): Result<String> =
    withContext(Dispatchers.IO) {
        recaptchaClient.execute(action)
      }
    }
