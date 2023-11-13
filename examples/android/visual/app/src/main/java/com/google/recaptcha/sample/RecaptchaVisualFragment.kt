package com.google.recaptcha.sample

import android.app.Dialog
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.webkit.WebView
import androidx.fragment.app.DialogFragment

class RecaptchaVisualFragment : DialogFragment(), RecaptchaListener {
  private lateinit var recaptchaWebView: RecaptchaWebView
  private lateinit var listener: RecaptchaListener

  companion object {
    fun newInstance(siteKey: String, baseUrl: String, lang: String?): RecaptchaVisualFragment {
      val f = RecaptchaVisualFragment()
      val args = Bundle()
      args.putString(RecaptchaWebView.SITE_KEY, siteKey)
      args.putString(RecaptchaWebView.BASE_URL, baseUrl)
      args.putString(RecaptchaWebView.LANG, lang)
      f.arguments = args
      return f
    }
  }

  override fun onCreateView(
    inflater: LayoutInflater,
    container: ViewGroup?,
    savedInstanceState: Bundle?
  ): View? {
    val view = inflater.inflate(R.layout.recaptcha, container, false)
    val webView = view.findViewById<WebView>(R.id.recaptchaWebview)
    recaptchaWebView = RecaptchaWebView(webView, requireArguments())
    recaptchaWebView.start(this, requireContext())

    view.findViewById<View>(R.id.cancelButton).setOnClickListener {
      onError(RecaptchaVisualException("User pressed cancel"))
    }
    return view
  }

  override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
    super.onViewCreated(view, savedInstanceState)
    dialog
      ?.window
      ?.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
  }

  override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
    return object : Dialog(requireActivity(), theme) {
      override fun onBackPressed() {
        dialog?.dismiss()
        listener.onError(RecaptchaVisualException("User pressed back"))
      }
    }
  }

  override fun onLoad() {
    listener.onLoad()
  }

  override fun onVerify(token: String) {
    dialog?.dismiss()
    listener.onVerify(token)
  }

  override fun onError(error: RecaptchaVisualException) {
    dialog?.dismiss()
    listener.onError(error)
  }

  override fun onExpire() {
    dialog?.dismiss()
    listener.onExpire()
  }

  fun configure(listener: RecaptchaListener) {
    this.listener = listener
  }
}
