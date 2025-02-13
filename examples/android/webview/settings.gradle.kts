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
/* Used for internal testing of SDK releases
    maven {
      url = uri("http://localhost:1480")
      isAllowInsecureProtocol = true
    }
 */
    google()
    mavenCentral()
  }
}

rootProject.name = "recaptchaWithRetryApp"
include(":app")
 