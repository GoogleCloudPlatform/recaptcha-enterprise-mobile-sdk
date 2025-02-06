package com.google.recaptcha.sample

interface RecaptchaListener {
  fun onExecute(token: String, resolveFunc: String, rejectFunc: String)
}