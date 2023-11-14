# iOS Sample

The sample is configured to directly open using XCode.

## Setup site keys

Using the site keys that were generated following the steps at
https://cloud.google.com/recaptcha-enterprise/docs/create-key

Make sure you create a *website* key to utilize visual challenges and *not and
Android or iOS Key*. Create a checkbox challenge key and set the difficulty to
medium or higher.

Run `pod install` to install the pods for testing.

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
