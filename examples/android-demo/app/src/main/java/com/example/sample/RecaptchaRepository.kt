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

  private const val SITE_KEY = "SITE_KEY"

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