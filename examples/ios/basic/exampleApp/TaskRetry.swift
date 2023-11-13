import Foundation
import Network

@available(iOS 13.0, *)
extension Task {
  static func runWithRetries(_ body: @escaping @Sendable () async throws -> Success) -> Task
  where Failure == Error {
    Task {
      printDebug("Starting retry function...")
      var delay = RecaptchaConstants.initialDelayMs

      await NetworkUtils.waitForNetworkConnectionAsync()

      for currentRetry in 0..<RecaptchaConstants.maxRetries {
        do {
          return try await body()
        } catch let error as RecaptchaError? {
          if let err = error,
            err.code == RecaptchaErrorCode.errorNetworkError.rawValue
              || err.code == RecaptchaErrorCode.errorCodeInternalError.rawValue
          {
            printDebug("Retryable error encountered on attempt number \(currentRetry + 1): \(err)")
            printDebug("Sleeping for \(Double(delay)/1000.0)s...")

            try await Task<Never, Never>.sleep(nanoseconds: delay * 1_000_000)
            delay = min(delay * 2, RecaptchaConstants.maxDelayMs)
            continue
          } else if let nonRetryableError = error {
            printDebug(
              "Non-retryable error encountered: \(String(describing: nonRetryableError.errorMessage))"
            )
            throw nonRetryableError
          }
        }
      }
      printDebug("Max retries reached!")
      let retryError = RecaptchaError(
        domain: RecaptchaConstants.recaptchaErrorDomain,
        code: RecaptchaErrorCode.errorCodeUnknown,
        userInfo: [NSLocalizedDescriptionKey: RecaptchaConstants.maxRetriesErrorMessage],
        message: RecaptchaConstants.maxRetriesErrorMessage
      )
      throw retryError
    }
  }
}
