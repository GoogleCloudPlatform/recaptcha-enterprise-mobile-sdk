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
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.google.android.recaptcha.RecaptchaAction
import kotlinx.coroutines.launch

class MainActivityViewModel(
  private val application: Application,
): AndroidViewModel(application) {

  private val backendRepository: BackendRepository = BackendRepository()

  companion object {
    const val TAG = "sample1PTestApp"
  }

  private val _currentResponseText = MutableLiveData<String>()
  val responseText: LiveData<String>
    get() = _currentResponseText

  init {
    RecaptchaProvider.initRecaptcha(application)
  }

  fun onLoginButtonClicked(){
    updateText("Loading ...")
    viewModelScope.launch {
      RecaptchaProvider.executeAction(application, RecaptchaAction.LOGIN).onSuccess {token ->
        // Send token to backend and receive verdict
        if(backendRepository.assessLoginAction(token)){
          updateText("User can Login")
        }else {
          updateText("User can't Login")
        }
      }.onFailure {
        // Handle failure.
        updateText("User blocked from Login.")
      }
    }
  }

  private fun updateText(message: String){
    _currentResponseText.value = message
    Log.d(TAG, message)
  }

}
