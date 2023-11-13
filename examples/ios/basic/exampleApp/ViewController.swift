import RecaptchaEnterprise
import UIKit

class ViewController: UIViewController {
  private enum Constants {
    fileprivate static let buttonFrame = CGRect(x: 0, y: 0, width: 100, height: 50)
  }

  private let siteKey: String =
    Bundle.main.object(forInfoDictionaryKey: "SITE_KEY") as? String ?? "NO SITEKEY"
  private var recaptchaClient: RecaptchaClient?
  private var recaptchaToken: String = ""

  private lazy var resultLabel: UILabel = {
    let resultLabel = UILabel()
    resultLabel.numberOfLines = 0
    resultLabel.text = ""
    return resultLabel
  }()

  private lazy var logLabel: UILabel = {
    let logLabel = UILabel()
    logLabel.numberOfLines = 0
    logLabel.text = ""
    return logLabel
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()

    if #available(iOS 13, *) {
      Task {
        await self.callInitAsync(
          withSiteKey: siteKey)
      }
    } else {
      self.callInit(
        withSiteKey: siteKey)
    }
  }

  private func setupUI() {
    let label = UILabel()
    let deviceLog =
      "Running on device:\n\(UIDevice.current.name) - \(UIDevice.current.systemVersion)"
    #if DEBUG_LOG_ENABLED
      RecaptchaLogger.log(deviceLog)
    #endif
    label.text = deviceLog
    label.numberOfLines = 0
    label.textAlignment = .center

    let resultTitle = UILabel()
    resultTitle.text = "Result execution:"

    let logTitle = UILabel()
    logTitle.text = "Log of execution:"

    let executeButton = createButton(id: "recaptchaExecuteButton", title: "Execute")

    if #available(iOS 13, *) {
      executeButton.addTarget(self, action: #selector(launchExecuteAsync), for: .touchUpInside)
    } else {
      executeButton.addTarget(self, action: #selector(launchExecute), for: .touchUpInside)
    }

    let horizontalMenu = createHorizontalMenu(arrangedSubviews: [
      executeButton
    ])

    let mainStackView = UIStackView(arrangedSubviews: [
      label, horizontalMenu, resultTitle, resultLabel, logTitle, logLabel,
    ])
    mainStackView.axis = .vertical

    view.addSubview(mainStackView)
    view.backgroundColor = .white

    mainStackView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
      mainStackView.leftAnchor.constraint(equalTo: view.leftAnchor),
      mainStackView.rightAnchor.constraint(equalTo: view.rightAnchor),
      horizontalMenu.rightAnchor.constraint(equalTo: mainStackView.rightAnchor),
    ])
  }

  private func createButton(id: String, title: String) -> UIButton {
    let button = UIButton(frame: Constants.buttonFrame)
    button.setTitle(title, for: .normal)
    button.setTitleColor(.blue, for: .normal)
    button.titleLabel?.textAlignment = .center
    button.accessibilityIdentifier = id
    return button
  }

  @objc func launchExecute(_ sender: Any) {
    self.callExecute()
  }

  @available(iOS 13.0, *)
  @objc func launchExecuteAsync(_ sender: Any) {
    Task {
      await self.callExecuteAsync()

    }
  }

  private func createHorizontalMenu(arrangedSubviews: [UIView]) -> UIStackView {
    let horizontalMenu = UIStackView(arrangedSubviews: arrangedSubviews)
    horizontalMenu.axis = .horizontal
    horizontalMenu.distribution = .fillEqually
    horizontalMenu.translatesAutoresizingMaskIntoConstraints = false
    return horizontalMenu
  }

  private func callInit(withSiteKey siteKey: String) {
    self.setResultLabel("Initializing client ...")

    Recaptcha.getClientWithRetry(
      withSiteKey: siteKey,
      completion: { client, error in
        DispatchQueue.main.async {
          guard let client = client else {
            self.handleResult(
              "Init failed!", withLogMessage: "Error: \(String(describing:error?.errorMessage))")
            return
          }

          self.recaptchaClient = client
          self.handleResult("Init was successful")
        }
      })
  }

  private func callExecute() {
    guard let recaptchaClient = self.recaptchaClient else {
      print("No client was given")
      return
    }
    self.setResultLabel("Executing Login action ...")
    Recaptcha.executeWithRetry(withClient: recaptchaClient, withAction: RecaptchaAction.login) {
      token, error in
      DispatchQueue.main.async {
        guard let unwrappedToken = token else {
          self.handleResult(
            "Execute failed!", withLogMessage: "Error: \(String(describing:error?.errorMessage))")
          return
        }

        self.recaptchaToken = unwrappedToken
        self.handleResult(
          "Token received", withLogMessage: unwrappedToken)
      }
    }
  }

  @available(iOS 13.0, *)
  private func callInitAsync(withSiteKey siteKey: String) async {
    self.setResultLabel("Initializing client ...")

    do {
      self.recaptchaClient = try await Recaptcha.getClientWithRetryAsync(withSiteKey: siteKey)
      self.handleResult("Init was successful")
    } catch let error as RecaptchaError {
      self.handleResult(
        "Init failed!", withLogMessage: "Error: \(String(describing:error.errorMessage))")
    } catch let error {
      self.handleResult(
        "Init failed!", withLogMessage: "Error: \(error.localizedDescription)")
    }
  }

  @available(iOS 13.0, *)
  private func callExecuteAsync() async {
    guard let recaptchaClient = self.recaptchaClient else {
      print("No client was given")
      return
    }
    self.setResultLabel("Executing Login action ...")
    do {
      self.recaptchaToken = try await Recaptcha.executeWithRetryAsync(
        withClient: recaptchaClient, withAction: RecaptchaAction.login)
      self.handleResult(
        "Token received", withLogMessage: self.recaptchaToken)
    } catch let error as RecaptchaError {
      self.handleResult(
        "Execute failed!", withLogMessage: "Error: \(String(describing:error.errorMessage))")
    } catch let error {
      self.handleResult(
        "Execute failed!", withLogMessage: "Error: \(String(describing:error))")
    }
  }

  private func logOnConsole(_ message: String) {
    print("Recaptcha: \(message)")
  }

  func setResultLabel(_ resultMessage: String) {
    resultLabel.text = resultMessage
  }

  func handleResult(_ resultMessage: String, withLogMessage logMessage: String = "") {
    print(resultMessage)
    print(logMessage)
    setResultLabel(resultMessage)
    logLabel.text = logMessage
  }
}
