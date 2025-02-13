package com.google.recaptcha.sample

import android.content.Context
import android.os.Bundle
import android.util.Log
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import com.google.android.recaptcha.RecaptchaAction
import com.google.android.recaptcha.RecaptchaException
import java.lang.Exception
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

const val JS_OBJECT_NAME: String = "RecaptchaJavascriptChannel"

class RecaptchaWebView(private val webView: WebView, private val context: Context) : RecaptchaListener{
  init {
    configWebView(webView)
    webView.webViewClient = WebViewClient()
    start(context)
  }

  private fun configWebView(view: WebView) {
    WebView.setWebContentsDebuggingEnabled(true)
    val webSettings = view.getSettings()
    webSettings.javaScriptEnabled = true
    webSettings.useWideViewPort = true
    webSettings.setSupportZoom(false)
    webSettings.displayZoomControls = false
    webSettings.cacheMode = WebSettings.LOAD_NO_CACHE
  }

  fun start(context: Context) {
    webView.addJavascriptInterface(RecaptchaJavascriptChannel(this), JS_OBJECT_NAME)

    val htmlTemplate = context.assets.open("rce.html").bufferedReader().use { it.readText() }

    val html =
      htmlTemplate
        .replace("__JS_OBJECT_NAME__", JS_OBJECT_NAME)

    webView.loadDataWithBaseURL("http://localhost", html, "text/html", "UTF-8", null)
  }
  
  override fun onExecute(action: String, resolveFunc: String, rejectFunc: String){
    CoroutineScope(Dispatchers.IO).launch {
      val tokenResult = RecaptchaProvider.executeAction(RecaptchaAction.custom(action))
      webView.post(Runnable {
       if (tokenResult.isSuccess){
          webView.evaluateJavascript("${resolveFunc}(`${tokenResult.getOrNull()}`)", null)
       } else {
          webView.evaluateJavascript("${rejectFunc}(\"${tokenResult.exceptionOrNull()?.message}\")", null)
       }
      })
    }
  }
}