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

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject

class DemoRepository {

  private val client = OkHttpClient()
  suspend fun login(username: String, password: String, token: String): JSONObject =
    withContext(Dispatchers.IO) {
      val mediaType = "application/json; charset=utf-8".toMediaType()
      val jsonObject = JSONObject()
      jsonObject.put("username", username)
      jsonObject.put("password", password)
      jsonObject.put("token", token)
      jsonObject.put("siteKey", RecaptchaRepository.SITE_KEY)

      val request = Request.Builder()
        // Localhost running from emulator.
        .url("http://10.0.2.2:8080/login")
        .post(jsonObject.toString().toRequestBody(mediaType))
        .build()

      val response = client.newCall(request).execute()
      JSONObject(response.body?.string() ?: "")
    }
}