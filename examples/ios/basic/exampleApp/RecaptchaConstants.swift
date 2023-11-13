struct RecaptchaConstants {
  static let maxRetries = 10
  static let initialDelayMs: UInt64 = 1000
  static let maxDelayMs: UInt64 = 5000
  static let networkWaitTimeout: DispatchTimeInterval = .seconds(3600)
  static let recaptchaErrorDomain = "com.recaptcha"
  static let maxRetriesErrorMessage = "Maximum retries reached"
}
