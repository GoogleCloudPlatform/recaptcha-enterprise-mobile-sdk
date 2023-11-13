package com.google.recaptcha.sample

interface RecaptchaListener {
  fun onLoad()

  fun onVerify(token: String)

  fun onError(error: RecaptchaVisualException)

  fun onExpire()
}
