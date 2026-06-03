// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import XCTest

final class exampleAppUITests: XCTestCase {

  override func setUpWithError() throws {
    continueAfterFailure = false
    XCUIApplication().launch()
  }

  override func tearDownWithError() throws {
  }

  func testTokenReturned() throws {
    let app = XCUIApplication()
    
    // Tap the Execute button
    let executeButton = app.buttons["recaptchaExecuteButton"]
    XCTAssertTrue(executeButton.exists, "Execute button not found")
    executeButton.tap()
    
    // Wait for the token to be received
    let resultLabel = app.staticTexts["recaptchaResultLabel"]
    XCTAssertTrue(resultLabel.exists, "Result label not found")
    
    // We expect the result label to eventually show "Token received"
    let existsPredicate = NSPredicate(format: "text == 'Token received'")
    let expectation = expectation(for: existsPredicate, evaluatedWith: resultLabel, handler: nil)
    
    // Wait up to 10 seconds for the token to be returned
    let result = XCTWaiter().wait(for: [expectation], timeout: 10)
    
    XCTAssertEqual(result, .completed, "Failed to receive token within timeout")
    
    // Verify that the log label contains the token (and is not an error message)
    let logLabel = app.staticTexts["recaptchaLogLabel"]
    XCTAssertTrue(logLabel.exists, "Log label not found")
    
    let logText = logLabel.label
    XCTAssertFalse(logText.isEmpty, "Token is empty")
    XCTAssertFalse(logText.hasPrefix("Error"), "Received error instead of token: \(logText)")
  }
}
