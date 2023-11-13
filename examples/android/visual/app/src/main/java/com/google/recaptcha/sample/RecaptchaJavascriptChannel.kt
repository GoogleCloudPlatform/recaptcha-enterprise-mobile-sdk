package com.google.recaptcha.sample

import android.webkit.JavascriptInterface

class RecaptchaJavascriptChannel(private val listener: RecaptchaListener) {
  @JavascriptInterface
  fun onLoad() {
    listener.onLoad()
  }

  @JavascriptInterface
  fun onVerify(token: String) {
    listener.onVerify(token)
  }

  @JavascriptInterface
  fun onError(error: String) {
    listener.onError(RecaptchaVisualException(error))
  }

  @JavascriptInterface
  fun onExpire() {
    listener.onExpire()
  }
}
