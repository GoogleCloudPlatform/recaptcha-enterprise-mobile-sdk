# Android Sample

The sample is configured to be directly open using Android Studio Hedgehog. 
After the Gradle Sync phase is done please Setup the site keys before you run 
it.

## Setup site keys

Using the site keys that were generated following the steps at
https://cloud.google.com/recaptcha-enterprise/docs/create-key

You can open the `config > recaptcha_pro.properties` and replace the value with
the generated key.

### Dev site keys

For `dev` only site keys please create the a file `recaptcha_dev.properties`
inside the `config` folder with the following values:

```
# This site key is used for development only and should never be exposed to
# customers, copybara is configured to ignore this file and build.gradle
# to only create the dev flavor if this file exist.
SITE_KEY = "YOUR_DEV_SITE_KEY"
```

The `build.gradle` file is already configured to detect the 
`recaptcha_dev.properties` and create a flavor with the configuration that's 
defined in that file.