import UIKit

class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    launchBridge()
  }
  
  func launchBridge() {
    let recaptchaViewController = RecaptchaViewController()

    self.present(recaptchaViewController, animated: true)
  }
}
