import Foundation
import WebKit

protocol RecaptchaVisualProtocol: AnyObject {
  func onVerify(token: String)
  func onError(error: String)
  func onExpire()
  func onLoad()
}

class RecaptchaVisualBridge: NSObject, WKScriptMessageHandler {
  private let delegate: RecaptchaVisualProtocol

  init(_ delegate: RecaptchaVisualProtocol) {
    self.delegate = delegate
  }

  func userContentController(
    _ userContentController: WKUserContentController, didReceive message: WKScriptMessage
  ) {
    guard let messageHandler = HandlerNames(rawValue: message.name) else {
      return
    }

    guard let messageBody = message.body as? [String: Any] else {
      return
    }

    switch messageHandler {
    case .onVerify: onVerify(messageBody)
    case .onError: onError(messageBody)
    case .onExpire: onExpire(messageBody)
    case .onLoad: onLoad(messageBody)
    }
  }

  enum HandlerNames: String, CaseIterable {
    case onVerify = "onVerify"
    case onError = "onError"
    case onExpire = "onExpire"
    case onLoad = "onLoad"
  }

  private func removeFromWebView(_ webView: WKWebView) {
    for name in HandlerNames.allCases {
      webView.configuration.userContentController.removeScriptMessageHandler(forName: name.rawValue)
    }
  }

  func addToWebView(_ webView: WKWebView) {
    removeFromWebView(webView)
    for name in HandlerNames.allCases {
      webView.configuration.userContentController.add(self, name: name.rawValue)
    }
  }

  private func onVerify(_ messageBody: [String: Any]) {
    guard let token = messageBody["token"] as? String else {
      return
    }
    delegate.onVerify(token: token)
  }

  private func onError(_ messageBody: [String: Any]) {
    guard let error = messageBody["error"] as? String else {
      return
    }
    delegate.onError(error: error)
  }

  private func onLoad(_ messageBody: [String: Any]) {
    delegate.onLoad()
  }

  private func onExpire(_ messageBody: [String: Any]) {
    delegate.onExpire()
  }
}
