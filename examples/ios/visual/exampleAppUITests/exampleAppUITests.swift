import XCTest

final class exampleAppUITests: XCTestCase {

  override func setUpWithError() throws {
    continueAfterFailure = false
    XCUIApplication().launch()
  }

  override func tearDownWithError() throws {
  }

  func pressLogin() {
    EarlGrey.selectElement(with: grey_accessibilityID("loginButton"))
      .perform(grey_tap())
  }

  func testRecaptchaRenders() {
    pressLogin()

    let jsResult: EDORemoteVariable<NSString> = EDORemoteVariable()
    let sendToken = "document.querySelector('#recaptcha-container div') ? 'true' : 'false'"
    EarlGrey.selectElement(with: grey_accessibilityID("RCWKWebView")).perform(
      grey_javaScriptExecution(sendToken, jsResult))
    XCTAssertEqual(jsResult.object, "true")
  }

  func testTokenReturned() {
    pressLogin()

    let jsResult: EDORemoteVariable<NSString> = EDORemoteVariable()

    let sendToken =
      "window.webkit.messageHandlers.onVerify.postMessage({'token': 'FAKE TOKEN'}); 'true';"
    EarlGrey.selectElement(with: grey_accessibilityID("RCWKWebView")).perform(
      grey_javaScriptExecution(sendToken, jsResult))
    XCTAssertEqual(jsResult.object, "true")

    EarlGrey.selectElement(with: grey_accessibilityID("RCToken")).assert(grey_text("FAKE TOKEN"))
  }

  func testOnError() {
    pressLogin()

    let jsResult: EDORemoteVariable<NSString> = EDORemoteVariable()

    let sendToken =
      "window.webkit.messageHandlers.onError.postMessage({'error': 'AN ERROR'}); 'true';"
    EarlGrey.selectElement(with: grey_accessibilityID("RCWKWebView")).perform(
      grey_javaScriptExecution(sendToken, jsResult))
    XCTAssertEqual(jsResult.object, "true")

    EarlGrey.selectElement(with: grey_accessibilityID("RCToken")).assert(grey_text("AN ERROR"))
  }
}
