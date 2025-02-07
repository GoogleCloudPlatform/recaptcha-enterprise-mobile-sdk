import UIKit
import WebKit

class RecaptchaViewController: UIViewController {
  private let webView: WKWebView = WKWebView(frame: .zero)
  private var bridge: RecaptchaBridge?

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("We aren't using storyboards")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
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
    guard let html = try? String(contentsOfFile: filepath) else {
      print("Can't read file")
      return
    }

    bridge = RecaptchaBridge()
    bridge?.addToWebView(self.webView)

    if #available(iOS 16.4, *) {
      webView.isInspectable = true
    } else {
      // Fallback on earlier versions
    }
    webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
    webView.accessibilityIdentifier = "RCWKWebView"
    webView.loadHTMLString(html, baseURL: URL("http://localhost"))
  }

  @objc func onClose() {
    self.dismiss(animated: true, completion: nil)
  }
}
