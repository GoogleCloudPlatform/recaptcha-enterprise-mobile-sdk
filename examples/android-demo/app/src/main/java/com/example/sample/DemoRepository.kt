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

      val request = Request.Builder()
        // Localhost running from emulator.
        .url("http://10.0.2.2:8080/login")
        .post(jsonObject.toString().toRequestBody(mediaType))
        .build()

      val response = client.newCall(request).execute()
      JSONObject(response.body?.string())
    }
}