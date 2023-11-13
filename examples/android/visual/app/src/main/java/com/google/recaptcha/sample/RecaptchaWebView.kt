package com.google.recaptcha.sample

import android.content.Context
import android.os.Bundle
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient

const val JS_OBJECT_NAME: String = "RecaptchaJavascriptChannel"

class RecaptchaWebView(private val webView: WebView, private val arguments: Bundle) {
  companion object {
    const val SITE_KEY = "SITE_KEY"
    const val BASE_URL = "BASE_URL"
    const val LANG = "LANG"
  }

  init {
    configWebView(webView)
    webView.webViewClient = WebViewClient()
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

  fun start(listener: RecaptchaListener, context: Context) {
    webView.addJavascriptInterface(RecaptchaJavascriptChannel(listener), JS_OBJECT_NAME)
    val siteKey = arguments.getString(SITE_KEY)
    val baseUrl = arguments.getString(BASE_URL)
    val lang = arguments.getString(LANG)

    val htmlTemplate = context.assets.open("rce.html").bufferedReader().use { it.readText() }

    val html =
      htmlTemplate
        .replace("__SITE_KEY__", siteKey ?: "NO_SITEKEY")
        .replace("__LANG__", "&hl=$lang" ?: "")
        .replace("__JS_OBJECT_NAME__", JS_OBJECT_NAME)

    webView.loadDataWithBaseURL(baseUrl, html, "text/html", "UTF-8", null)
  }
}
