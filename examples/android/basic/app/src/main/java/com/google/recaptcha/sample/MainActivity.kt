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
import com.google.recaptcha.sample.R

/** Entry class for a demo app showing how reCAPTCHA webiew APIs work with Kotlin. */
class MainActivity : AppCompatActivity() {
  private lateinit var responseTextView: TextView

  private val viewModel: MainActivityViewModel by viewModels()

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(R.layout.activity_main)
    setupUiElements()
    setupObservers()
  }

  private fun setupObservers(){
    viewModel.responseText.observe(this) { response ->
      responseTextView.text = response
    }
  }

  private fun setupUiElements() {
    responseTextView = findViewById(R.id.response)
    findViewById<View>(R.id.btn_login).setOnClickListener {
      viewModel.onLoginButtonClicked()
    }
  }

  companion object {
    const val TAG = "sample1PTestApp"
  }
}
