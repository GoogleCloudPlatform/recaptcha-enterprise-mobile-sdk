# iOS Sample WebView Bridge

This demonstrates how to bridge from an embedded WebView into the reCAPTCHA SDK.  To use this in a production application, the JS code in the embdded webpage needs to be added to the site/page being displayed in your webview and is designed to detect if it is an Android or iOS WebView containing a bridge.

The sample is configured to directly open using XCode and uses Swift Package Manager to import the SDK.


## Setup site keys

Using the site keys that were generated following the steps at
https://cloud.google.com/recaptcha-enterprise/docs/create-key

Note: The sitekey used here is a mobile sitekey not a web one.

### Dev site keys

For `dev` only site keys please add the keys to the `DebugSettings.xcconfig
file` with the following values:

```
# This site key is used for development only and should never be exposed to
# customers, copybara is configured to ignore this file and build.gradle
# to only create the dev flavor if this file exist.
WEB_SITE_KEY = "YOUR_DEV_SITE_KEY"
WEB_BASE_URL = "http://YOURDOMAIN"
```
