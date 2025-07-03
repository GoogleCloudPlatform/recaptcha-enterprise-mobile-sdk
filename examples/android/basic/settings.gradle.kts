pluginManagement {
  repositories {
    google()
    mavenCentral()
    gradlePluginPortal()
  }
}
dependencyResolutionManagement {
  repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
  repositories {
  // Used for internal testing of SDK releases*/
/*  
    maven {
      url = uri("http://adt-proxy.uplink2.goog:999/BB4d3gcrTY63P_93mtRMVw")
      isAllowInsecureProtocol = true
    }
*/
    google()
    mavenCentral()
  }
}

rootProject.name = "recaptchaWithRetryApp"
include(":app")
 