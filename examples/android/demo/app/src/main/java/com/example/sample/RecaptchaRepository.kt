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

package com.example.sample

import android.app.Application
import android.content.Context
import com.google.android.recaptcha.Recaptcha
import com.google.android.recaptcha.RecaptchaAction
import com.google.android.recaptcha.RecaptchaClient
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.launch

/**
 * Repository used to hold the reference to the RecaptchaClient
 *
 * In a production code this is ideally a class provided using any dependency injection framework
 * that can be mocked and replaced in unit tests.
 */
object RecaptchaRepository {

  private lateinit var recaptchaClient: Deferred<Result<RecaptchaClient>>

  const val SITE_KEY = "SITE_KEY"

  fun initializeClient(context: Context) {
    CoroutineScope(Dispatchers.IO).launch {
      recaptchaClient = async {
        Recaptcha.getClient(context.applicationContext as Application, SITE_KEY)
      }
    }
  }

  suspend fun retrieveToken(action: RecaptchaAction): Result<String> {
   return recaptchaClient.await().map {
     it.execute(action).getOrThrow()
    }
  }
}