import Foundation
import UIKit

class RecaptchaVisual: RecaptchaVisualProtocol {
  private var completionHandler: ((String?, Error?) -> Void)?
  private var viewController: UIViewController
  private var recaptchaViewController: RecaptchaViewController

  init(viewController: UIViewController, siteKey: String, baseUrl: URL, lang: String = Locale.current.languageCode ?? "en") {
    completionHandler = nil
    self.viewController = viewController
    self.recaptchaViewController = RecaptchaViewController(
      siteKey: siteKey, baseUrl: baseUrl, lang: lang)
  }

  func runCaptcha(completion: @escaping (String?, Error?) -> Void) {
    recaptchaViewController.delegate = self
    completionHandler = completion

    let navigationController = UINavigationController(rootViewController: recaptchaViewController)
    navigationController.setToolbarHidden(false, animated: false)

    viewController.present(navigationController, animated: true)
  }

  func onVerify(token: String) {
    completionHandler?(token, nil)
  }

  func onError(error: String) {
    completionHandler?(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: error]))
  }

  func onExpire() {
  }

  func onLoad() {
  }
}
