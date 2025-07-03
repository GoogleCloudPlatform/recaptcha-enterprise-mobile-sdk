// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import java.io.FileInputStream
import java.util.Properties

plugins {
  id("com.android.application")
  id("org.jetbrains.kotlin.android")
  id("com.google.devtools.ksp")
}

fun readProperties(propertiesPath: String): Properties? {
  try {
    val properties = Properties()
    properties.load(FileInputStream(file(propertiesPath)))
    return properties
  } catch (e: Exception){
    return null
  }
}

android {
  namespace = "com.google.recaptcha.sample"
  compileSdk = 33

  defaultConfig {
    applicationId = "com.google.recaptcha.sample"
    minSdk = 24
    targetSdk = 33
    versionCode = 1
    versionName = "1.0"

    testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
  }

  buildTypes {
    release {
      isMinifyEnabled = false
      proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
    }
  }

  flavorDimensions += "version"

  productFlavors{

    readProperties("../config/recaptcha_dev.properties")?.let { properties ->
      create("dev"){
        dimension = "version"
        properties.onEach {property ->
          buildConfigField("String", property.key as String, property.value as String)
        }
      }
    }

    readProperties("../config/recaptcha_prod.properties")?.let { properties ->
      create("prod"){
        dimension = "version"
        properties.onEach {property ->
          buildConfigField("String", property.key as String, property.value as String)
        }
      }
    }

    buildFeatures {
      buildConfig = true
    }
  }
  compileOptions {
    sourceCompatibility = JavaVersion.VERSION_1_8
    targetCompatibility = JavaVersion.VERSION_1_8
  }
  kotlinOptions {
    jvmTarget = "1.8"
  }
}

dependencies {
  implementation("androidx.core:core-ktx:1.9.0")
  implementation("androidx.appcompat:appcompat:1.6.1")
  implementation("com.google.android.material:material:1.9.0")
  implementation("androidx.constraintlayout:constraintlayout:2.1.4")
  implementation("com.google.android.recaptcha:recaptcha:18.7.1")
  implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.6.1")
  implementation("androidx.activity:activity-ktx:1.7.2")
  implementation("androidx.fragment:fragment-ktx:1.6.1")

  testImplementation("junit:junit:4.13.2")
  androidTestImplementation("androidx.test.ext:junit:1.1.5")
  androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
}