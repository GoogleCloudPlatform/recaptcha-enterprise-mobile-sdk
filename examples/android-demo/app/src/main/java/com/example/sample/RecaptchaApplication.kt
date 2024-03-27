package com.example.sample

import android.app.Application

class RecaptchaApplication: Application() {
  override fun onCreate() {
    super.onCreate()
    RecaptchaRepository.initializeClient(this)
  }
}