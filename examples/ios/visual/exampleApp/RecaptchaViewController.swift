import UIKit
import WebKit

class RecaptchaViewController: UIViewController, RecaptchaVisualProtocol {
  private let webView: WKWebView = WKWebView(frame: .zero)
  private var bridge: RecaptchaVisualBridge?
  var delegate: RecaptchaVisualProtocol?

  private let siteKey: String
  private let baseUrl: URL
  private let lang: String

  private let SITE_KEY_MACRO = "__SITE_KEY__"
  private let LANG_MACRO = "__LANG__"

  init(siteKey: String, baseUrl: URL, lang: String = "en") {
    self.siteKey = siteKey
    self.baseUrl = baseUrl
    self.lang = lang
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("We aren't using storyboards")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .cancel, target: self, action: #selector(onClose))

    webView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(webView)

    NSLayoutConstraint.activate([
      webView.topAnchor.constraint(equalTo: view.topAnchor),
      webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    guard let filepath = Bundle.main.path(forResource: "rce", ofType: "html") else {
      print("Can't get path")
      return
    }
    guard let HTML_TEMPLATE = try? String(contentsOfFile: filepath) else {
      print("Can't read file")
      return
    }

    let html =
      HTML_TEMPLATE.replacingOccurrences(of: SITE_KEY_MACRO, with: siteKey).replacingOccurrences(
        of: LANG_MACRO, with: "&hl=\(lang)")
    bridge = RecaptchaVisualBridge(self)
    bridge?.addToWebView(self.webView)

    webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
    webView.accessibilityIdentifier = "RCWKWebView"
    webView.loadHTMLString(html, baseURL: baseUrl)
  }

  @objc func onClose() {
    self.dismiss(animated: true, completion: nil)
    delegate?.onError(error: "User Closed View")
  }

  func onVerify(token: String) {
    onClose()
    delegate?.onVerify(token: token)
  }

  func onError(error: String) {
    onClose()
    delegate?.onError(error: error)
  }

  func onExpire() {
    delegate?.onExpire()
  }

  func onLoad() {
    delegate?.onLoad()
  }
}
