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

import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.launch

/** Entry class for a demo app showing how reCAPTCHA webiew APIs work with Kotlin. */
class MainActivity : AppCompatActivity() {
  private lateinit var responseTextView: TextView

  private val viewModel: MainActivityViewModel by viewModels()
  private lateinit var recaptcha: RecaptchaVisual

  companion object {
    const val TAG = "sampleVisualTestApp"
    private const val WEB_SITE_KEY = BuildConfig.WEB_SITE_KEY
    private const val BASE_URL = BuildConfig.WEB_BASE_URL
  }

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(R.layout.activity_main)
    setupUiElements()
    setupObservers()
    recaptcha = RecaptchaVisual(supportFragmentManager, WEB_SITE_KEY, BASE_URL)
  }

  private fun setupObservers() {
    viewModel.responseText.observe(this) { response -> responseTextView.text = response }
  }

  private fun setupUiElements() {
    responseTextView = findViewById(R.id.response)
    findViewById<View>(R.id.btn_login).setOnClickListener {
      lifecycleScope.launch {
        try {
          val token = recaptcha.runCaptcha().await()
          viewModel.onLoginButtonClicked(token)
        } catch (error: RecaptchaVisualException) {
          viewModel.onTokenError(error)
        }
      }
    }
  }
}
