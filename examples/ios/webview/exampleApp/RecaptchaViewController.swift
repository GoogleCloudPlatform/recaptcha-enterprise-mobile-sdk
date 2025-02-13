import UIKit
import WebKit

class RecaptchaViewController: UIViewController {

  private var bridge: RecaptchaBridge?
  private lazy var webView: WKWebView = {
    let preferences = WKPreferences()
    preferences.javaScriptEnabled = true
    let configuration = WKWebViewConfiguration()
    configuration.preferences = preferences
    return WKWebView(frame: .zero, configuration: configuration)
  }()

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

    webView.loadHTMLString(html, baseURL: nil)
  }

  @objc func onClose() {
    self.dismiss(animated: true, completion: nil)
  }
}
