# iOS Sample

The sample is configured to directly open using XCode. The sample code
demonstrates both older style callback-based integration and modern async/await.
If you are only targeting iOS13 and greater use the the async/await code,
otherwise omit the async/await code and use the callbacks.

## Setup site keys

Using the site keys that were generated following the steps at
https://cloud.google.com/recaptcha-enterprise/docs/create-key

Make sure you create a an *iOS Key* and configure it with the sample bundle
identifier as this app.

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
