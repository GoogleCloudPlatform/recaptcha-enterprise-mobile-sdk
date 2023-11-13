import UIKit

class ViewController: UIViewController, RecaptchaVisualProtocol {
  let WEB_SITE_KEY_CONFIG = "WEB_SITE_KEY"
  let WEB_BASE_URL_CONFIG = "WEB_BASE_URL"

  private lazy var tokenLabel: UILabel = {
    let tokenLabel = UILabel()
    tokenLabel.numberOfLines = 0
    tokenLabel.text = ""
    tokenLabel.accessibilityIdentifier = "RCToken"
    return tokenLabel
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  private func setupUI() {
    let loginButton = createButton(id: "loginButton", title: "Login")
    loginButton.addTarget(self, action: #selector(launchVisual), for: .touchUpInside)

    let mainStackView = UIStackView(arrangedSubviews: [
      loginButton, tokenLabel,
    ])
    mainStackView.axis = .vertical

    view.addSubview(mainStackView)

    view.backgroundColor = .white

    mainStackView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
      mainStackView.leftAnchor.constraint(equalTo: view.leftAnchor),
      mainStackView.rightAnchor.constraint(equalTo: view.rightAnchor),
    ])
  }

  private func createButton(id: String, title: String) -> UIButton {
    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    button.setTitle(title, for: .normal)
    button.setTitleColor(.blue, for: .normal)
    button.titleLabel?.textAlignment = .center
    button.accessibilityIdentifier = id
    return button
  }

  @objc func launchVisual(_ sender: Any) {
    guard let WEB_SITE_KEY = Bundle.main.object(forInfoDictionaryKey: WEB_SITE_KEY_CONFIG) as? String
    else {
      print("WEB_SITE_KEY Not Found")
      return
    }

    guard let WEB_BASE_URL = Bundle.main.object(forInfoDictionaryKey: WEB_BASE_URL_CONFIG) as? String
    else {
      print("WEB_BASE_URL Not Found")
      return
    }

    DispatchQueue.main.async { [self] in
      let recaptcha = RecaptchaVisual(
        viewController: self, siteKey: WEB_SITE_KEY, baseUrl: URL(string: WEB_BASE_URL)!)
      recaptcha.runCaptcha { (token: String?, error: Error?) in
        self.tokenLabel.text =
          token != nil
        ? token : error?.localizedDescription
      }
    }
  }

  func onVerify(token: String) {
    tokenLabel.text = token
  }

  func onError(error: String) {
    tokenLabel.text = error
  }

  func onExpire() {
    tokenLabel.text = "reCAPTCHA Expired"
  }

  func onLoad() {
    // This text is not visible since it is hidden by the webview
    tokenLabel.text = "reCAPTCHA Loaded"
  }
}
