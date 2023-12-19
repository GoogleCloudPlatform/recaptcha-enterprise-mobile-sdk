# recaptcha-enterprise

Please note that issues filed in this repository are not an official Google
support channel and are answered on a best effort basis. For official support,
please visit:
[https://cloud.google.com/support-hub](https://cloud.google.com/support-hub).

To integrate reCAPTCHA Enterprise, please follow the instructions for
[iOS](https://cloud.google.com/recaptcha-enterprise/docs/instrument-ios-apps)
and
[Android](https://cloud.google.com/recaptcha-enterprise/docs/instrument-android-apps).

### Security Vulnerability in SDKs Below 18.4.0

A critical security vulnerability was discovered in reCAPTCHA Enterprise for Mobile. The vulnerability has been patched in the latest SDK release. Customers will need to update their Android application with the reCAPTCHA Enterprise for Mobile SDK, version 18.4.0 or above. We strongly recommend you update to the latest version as soon as possible.

### Upgrading from 18.X.X to 18.2.0 in Android

WARNING: Due to a bug described in
[Issue 52](https://github.com/GoogleCloudPlatform/recaptcha-enterprise-mobile-sdk/issues/52),
some users may experience unrecoverable errors if you have used a version of the
SDK < 18.2.0 and then upgrade to 18.2.0. Instead please upgrade directly to
18.2.1.

## Example Implementations

# Basic

The basic example applications demonstrate how to implement the reCAPTCHA
Enterprise score-based challenges in mobile applications. These implementations
demonstrate best practices with init started at app startup, retries, and
waiting for network connectivity.

# Visual

The visual example applications demonstrate how to incorporate visual challenges
into a mobile application using a webview.

## Troubleshoot
