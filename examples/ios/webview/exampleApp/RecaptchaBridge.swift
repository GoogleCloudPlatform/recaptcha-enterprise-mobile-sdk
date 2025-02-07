import Foundation
import WebKit
import RecaptchaEnterprise

class RecaptchaBridge: NSObject, WKScriptMessageHandler {
  
  private var webView: WKWebView?

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
    case .onExecute: onExecute(messageBody)
    }
  }
  
  enum HandlerNames: String, CaseIterable {
    case onExecute = "onExecute"
  }
  
  private func removeFromWebView(_ webView: WKWebView) {
    self.webView = nil

    for name in HandlerNames.allCases {
      webView.configuration.userContentController.removeScriptMessageHandler(forName: name.rawValue)
    }
  }
  
  func addToWebView(_ webView: WKWebView) {
    removeFromWebView(webView)
    self.webView = webView
    
    for name in HandlerNames.allCases {
      webView.configuration.userContentController.add(self, name: name.rawValue)
    }
  }
  
  private func onExecute(_ messageBody: [String: Any]) {
    guard let action = messageBody["action"] as? String,
          let bridgeResolve = messageBody["bridgeResolve"] as? String,
          let bridgeReject = messageBody["bridgeReject"] as? String
    else {
      return
    }
    print (self.webView?.debugDescription ?? "webView is nil")
    Task.detached(priority: .background){
        let tokenResult = await RecaptchaRepository.getToken(action: RecaptchaAction(customAction:action))
        var cmd: String = ""
      
        switch tokenResult {
        case .success(let token):
          cmd = bridgeResolve + "(`" + token + "`)"
        case .failure(let failure):
          if let recaptchaError = failure as? RecaptchaError {
            cmd = bridgeReject + "(`" + recaptchaError.errorMessage + "`)"
          } else {
            cmd = bridgeReject + "(`" + failure.localizedDescription + "`)"
          }
        }
        self.webView?.evaluateJavaScript(cmd, completionHandler: nil)
    }
    
    
  }
}
