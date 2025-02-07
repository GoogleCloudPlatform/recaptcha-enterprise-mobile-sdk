# Android Sample Bridge

This demonstrates how to bridge from an embedded WebView into the reCAPTCHA SDK.  To use this in a production application, the JS code in the embdded webpage needs to be added to the site/page being displayed in your webview and is designed to detect if it is an Android or iOS WebView containing a bridge.

The sample is configured to be directly open using Android Studio Ladybug. 
After the Gradle Sync phase is done please Setup the site keys before you run 
it.

## Setup site keys

Using the site keys that were generated following the steps at
https://cloud.google.com/recaptcha-enterprise/docs/create-key

You can open the `app > build.gradle.kts` and replace the value with 
the generated key for dev and prod.

Nore that the site key is a mobile sitekey, not a web sitekey.
