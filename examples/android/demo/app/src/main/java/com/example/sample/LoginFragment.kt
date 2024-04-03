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

import android.os.Bundle
import android.view.View
import android.widget.Button
import androidx.fragment.app.Fragment
import com.google.android.material.textfield.TextInputEditText
import com.google.android.material.textview.MaterialTextView
import com.google.recaptcha.sample.R

class LoginFragment(
  private val loginViewModel: LoginViewModel,
) : Fragment(R.layout.login_view) {

  private lateinit var errorView: MaterialTextView

  override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
    super.onViewCreated(view, savedInstanceState)

    view.findViewById<Button>(R.id.btn_login).setOnClickListener {
      val username =
        view.findViewById<TextInputEditText>(R.id.edit_text_login_username).text.toString()
      val password =
        view.findViewById<TextInputEditText>(R.id.edit_text_login_password).text.toString()

      loginViewModel.onLoginClicked(username, password)
    }

    errorView = view.findViewById(R.id.txt_login_error)
    initObservers()
  }

  private fun initObservers(){
    loginViewModel.errorMessage.observe(viewLifecycleOwner){ message ->
      toggleErrorMessage(message)
    }
  }

  private fun toggleErrorMessage(errorMessage: String?){
    if(errorMessage != null){
      errorView.text = errorMessage
      errorView.visibility = View.VISIBLE
    } else {
      errorView.visibility = View.GONE
    }
  }
}