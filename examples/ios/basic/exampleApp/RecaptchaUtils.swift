import Foundation
import Network
import RecaptchaEnterprise

extension Recaptcha {
  /// Retries a given closure if it fails, until the maximum number of retries is reached or
  /// a non-retryable error is encountered.
  /// - Parameters:
  ///   - body: The function to be run with retries.
  ///   - completion: Completion callback to be executed when the function completes or fails.
  private static func runWithRetries<T>(
    _ body: @escaping (@escaping (T?, RecaptchaError?) -> Void) -> Void,
    completion: @escaping (T?, RecaptchaError?) -> Void
  ) {
    printDebug("Starting retry function...")
    var currentRetry = 0
    var delay = RecaptchaConstants.initialDelayMs

    // Recursive function to perform retries
    func attemptRetry() {
      if currentRetry < RecaptchaConstants.maxRetries {
        printDebug("Attempt number: \(currentRetry + 1)")
        NetworkUtils.waitForNetworkConnection {
          printDebug("Connection is available")

          body { (result, error) in
            if let err = error,
              err.code == RecaptchaErrorCode.errorNetworkError.rawValue
                || err.code == RecaptchaErrorCode.errorCodeInternalError.rawValue
            {
              printDebug(
                "Retryable error encountered on attempt number \(currentRetry + 1): \(err)")
              currentRetry += 1
              let sleep = TimeInterval(delay) / 1000.0
              printDebug("Sleeping for \(sleep)s...")
              DispatchQueue.main.asyncAfter(deadline: .now() + sleep) {
                delay = min(delay * 2, RecaptchaConstants.maxDelayMs)
                attemptRetry()
              }
            } else if let nonRetryableError = error {
              printDebug(
                "Non-retryable error encountered: \(String(describing: nonRetryableError.errorMessage))"
              )
              completion(nil, nonRetryableError)
            } else if let res = result {
              completion(res, nil)
            }
          }
        }
      } else {
        printDebug("Max retries reached!")
        let retryError = RecaptchaError(
          domain: RecaptchaConstants.recaptchaErrorDomain,
          code: RecaptchaErrorCode.errorCodeUnknown,
          userInfo: [NSLocalizedDescriptionKey: RecaptchaConstants.maxRetriesErrorMessage],
          message: RecaptchaConstants.maxRetriesErrorMessage
        )
        completion(nil, retryError)
      }
    }

    attemptRetry()
  }

  /// Retrieves a reCAPTCHA client with retry capabilities.
  static func getClientWithRetry(
    withSiteKey siteKey: String, completion: @escaping (RecaptchaClient?, RecaptchaError?) -> Void
  ) {
    printDebug("Getting RecaptchaClient with retry for siteKey: \(siteKey)")
    runWithRetries(
      { internalCompletion in
        Recaptcha.getClient(withSiteKey: siteKey) { client, error in
          // Convert any error to RecaptchaError
          let recaptchaError =
            error as? RecaptchaError?
            ?? RecaptchaError(
              domain: RecaptchaConstants.recaptchaErrorDomain,
              code: RecaptchaErrorCode.errorCodeUnknown,
              userInfo: nil,
              message: error?.localizedDescription ?? "Unknown error occurred."
            )
          internalCompletion(client, recaptchaError)
        }
      },
      completion: { client, error in
        completion(client, error)
      })
  }

  /// Executes a reCAPTCHA action with retry capabilities.
  static func executeWithRetry(
    withClient client: RecaptchaClient, withAction action: RecaptchaAction,
    completion: @escaping (String?, RecaptchaError?) -> Void
  ) {
    printDebug("Executing Recaptcha action with retry for action: \(action)")
    runWithRetries(
      { internalCompletion in
        client.execute(withAction: action) { token, error in
          // Convert any error to RecaptchaError
          let recaptchaError =
            error as? RecaptchaError?
            ?? RecaptchaError(
              domain: RecaptchaConstants.recaptchaErrorDomain,
              code: RecaptchaErrorCode.errorCodeUnknown,
              userInfo: nil,
              message: error?.localizedDescription ?? "Unknown error occurred."
            )
          internalCompletion(token, recaptchaError)
        }
      },
      completion: { token, error in
        completion(token, error)
      })
  }

  @available(iOS 13.0, *)
  static func getClientWithRetryAsync(withSiteKey siteKey: String) async throws -> RecaptchaClient {
    do {
      return try await Task.runWithRetries {
        return try await Recaptcha.getClient(withSiteKey: siteKey)
      }.value
    } catch let error as RecaptchaError {
      print("RecaptchaClient creation error: \(String(describing: error.errorMessage)).")
      throw error
    }
  }

  @available(iOS 13.0, *)
  static func executeWithRetryAsync(
    withClient client: RecaptchaClient, withAction action: RecaptchaAction
  ) async throws -> String {
    do {
      return try await Task.runWithRetries {
        return try await client.execute(withAction: action)
      }.value
    } catch let error as RecaptchaError {
      print("RecaptchaClient creation error: \(String(describing: error.errorMessage)).")
      throw error
    }
  }
}

/// Prints a debug message if the DEBUG compiler flag is set.
func printDebug(_ message: String) {
  #if DEBUG
    print("[Recaptcha] \(message)")
  #endif
}
