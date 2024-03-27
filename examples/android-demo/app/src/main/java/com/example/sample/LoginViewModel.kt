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

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.android.recaptcha.RecaptchaAction
import java.lang.Exception
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class LoginViewModel(
  private val demoRepository: DemoRepository,
) : ViewModel() {

  private val _loginState = MutableLiveData(false)
  val loginState: LiveData<Boolean> = _loginState

  private val _errorMessage: MutableLiveData<String> = MutableLiveData(null)
  val errorMessage: LiveData<String?> = _errorMessage

  private val _loggedUser: MutableLiveData<String> = MutableLiveData(null)
  val loggedUser: LiveData<String?> = _loggedUser

  private suspend fun retrieveToken(): Result<String> {
     return RecaptchaRepository.retrieveToken(RecaptchaAction.LOGIN)
  }

  fun onLoginClicked(username: String, password: String) {
    viewModelScope.launch(Dispatchers.IO) {
      try {
        retrieveToken().onSuccess {token ->
          val response = demoRepository.login(username, password, token)
          Log.d(this@LoginViewModel.toString(), "$response")
          if(response["shouldBlock"] as Boolean){
            _errorMessage.postValue("Attestation failed!")
          }else {
            _loginState.postValue( true)
            _loggedUser.postValue(username)
          }
        }.onFailure {
          _errorMessage.postValue("Failed: ${it.localizedMessage}")
        }
      } catch (e: Exception) {
        _errorMessage.postValue(e.localizedMessage ?: "Failed to login, try again latter")
        Log.d(this@LoginViewModel.toString(), "Exception $e")
      }
    }
  }
}