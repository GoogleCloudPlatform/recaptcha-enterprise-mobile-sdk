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
import android.content.Context
import android.util.Log
import com.google.android.recaptcha.Recaptcha
import com.google.android.recaptcha.RecaptchaAction
import com.google.android.recaptcha.RecaptchaClient
import com.google.android.recaptcha.RecaptchaErrorCode
import com.google.android.recaptcha.RecaptchaException
import kotlin.math.min
import kotlinx.coroutines.delay

/** Contains init and execute retry wrapper methods for Recaptcha. */
object RecaptchaUtils {
  private const val DEBUG_MODE = true
  private const val MAX_RETRIES = 100
  private const val INITIAL_DELAY_MS = 10L
  private const val MAX_DELAY_MS = 5000L

  /**
   * Attempts to obtain a Recaptcha client with retries.
   *
   * @param application The application instance.
   * @param siteKey The site key for the Recaptcha client.
   * @return The Recaptcha client wrapped in a Result.
   */
  suspend fun getClientWithRetry(
    application: Application,
    siteKey: String
  ): Result<RecaptchaClient> {
    logDebug("Attempting to get client with retry")
    return retryWithBackoffAndNetworkCheck(application.applicationContext) {
      Recaptcha.getClient(application, siteKey)
    }
  }

  /**
   * Executes a Recaptcha action with the provided client and retries if necessary.
   *
   * @param context The context.
   * @param client The Recaptcha client.
   * @param action The Recaptcha action to execute.
   * @return The result of the execution wrapped in a Result.
   */
  suspend fun executeWithRetry(
    context: Context,
    client: RecaptchaClient,
    action: RecaptchaAction
  ): Result<String> {
    logDebug("Attempting to execute with retry")
    return retryWithBackoffAndNetworkCheck(context) { client.execute(action) }
  }

  /**
   * Retries a given block with backoff, ensuring network availability before each attempt.
   *
   * @param context Context for network checks.
   * @param block Block to be retried.
   * @return Result of the block execution.
   */
  private suspend inline fun <T> retryWithBackoffAndNetworkCheck(
    context: Context,
    block: () -> Result<T>
  ): Result<T> {
    logDebug("Inside retryWithBackoffAndNetworkCheck")

    var currentDelay = INITIAL_DELAY_MS
    repeat(MAX_RETRIES) {
      if (!NetworkUtils.isAvailable(context)) {
        logDebug("Network not available. Waiting for availability...")
        NetworkUtils.waitForAvailability(context)
        logDebug("Network became available!...")
      }

      val result = block()

      if (
        result.isSuccess || (result.isFailure && result.exceptionOrNull() !is RecaptchaException)
      ) {
        logDebug("Successful result or non-Recaptcha exception")
        return result
      }

      val exception = result.exceptionOrNull() as RecaptchaException

      if (exception.isNetworkOrInternalError()) {
        logDebug("Encountered network or internal error")
        logDebug(exception.errorMessage)
        currentDelay = min(currentDelay * 2L, MAX_DELAY_MS)
        logDebug("[$it/$MAX_RETRIES] Sleeping for $currentDelay...")
        delay(currentDelay)
      } else {
        logDebug("Other Recaptcha exception")
        return result
      }
    }

    logDebug("Max retries reached")
    return Result.failure(Exception("Max retries reached"))
  }

  private fun logDebug(message: String) {
    if (DEBUG_MODE) {
      Log.d("RecaptchaUtils", message)
    }
  }

  private fun RecaptchaException.isNetworkOrInternalError() =
    this.errorCode == RecaptchaErrorCode.NETWORK_ERROR ||
      this.errorCode == RecaptchaErrorCode.INTERNAL_ERROR
}