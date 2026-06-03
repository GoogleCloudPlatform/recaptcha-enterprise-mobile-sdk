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

For development, add your site key to `DebugSettings.xcconfig`:

```
SITE_KEY = YOUR_SITE_KEY
```

## Running Tests

1. Ensure you have configured a valid site key in `DebugSettings.xcconfig`.
2. Run the tests using Xcode (Product -> Test) or via command line:

   ```bash
   xcodebuild test -project exampleApp.xcodeproj -scheme exampleApp -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'
   ```

