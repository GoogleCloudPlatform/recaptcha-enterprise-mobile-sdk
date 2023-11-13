package com.google.recaptcha.sample

import androidx.fragment.app.FragmentManager
import java.util.Locale
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Deferred

class RecaptchaVisual(
  private val fragmentManager: FragmentManager,
  private val siteKey: String,
  private val baseUrl: String,
  private val lang: String = Locale.getDefault().getLanguage()
) : RecaptchaListener {
  private var onDone: CompletableDeferred<String> = CompletableDeferred()

  fun runCaptcha(): Deferred<String> {
    val fragment = RecaptchaVisualFragment.newInstance(siteKey, baseUrl, lang)
    fragment.configure(this)
    fragment.show(fragmentManager, "RecaptchaVisual")
    return onDone
  }

  override fun onLoad() {
    // Do nothing
  }

  override fun onVerify(token: String) {
    onDone.complete(token)
  }

  override fun onError(error: RecaptchaVisualException) {
    onDone.completeExceptionally(error)
  }

  override fun onExpire() {
    onDone.completeExceptionally(RecaptchaVisualException("reCAPTCHA Expired"))
  }
}
