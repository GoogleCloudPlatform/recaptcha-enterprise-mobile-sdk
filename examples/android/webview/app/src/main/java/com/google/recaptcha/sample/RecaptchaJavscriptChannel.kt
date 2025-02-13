package com.google.recaptcha.sample

import android.util.Log
import android.webkit.JavascriptInterface

class RecaptchaJavascriptChannel(private val listener: RecaptchaListener) {
  @JavascriptInterface
  fun onExecute(action: String, resolveFunc: String, rejectFunc: String) {
    listener.onExecute(action, resolveFunc, rejectFunc)
  }
}