// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
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

import PackageDescription

let package = Package(
  name: "RecaptchaEnterprise",
  platforms: [
    .iOS(.v12)
  ],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "RecaptchaEnterprise",
      targets: ["RecaptchaEnterprise"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/google/interop-ios-for-google-sdks.git",
      "101.0.0"..<"102.0.0"
    )
  ],
  targets: [
    .binaryTarget(
      name: "RecaptchaEnterpriseSDK",
     url:
       "https://dl.google.com/recaptchaenterprise/v18.7.0-beta01/RecaptchaEnterpriseSDK_iOS_xcframework/recaptcha-sdk-xcframework.xcframework.zip",
     checksum: "170769f1ba86a0ce422a80f127cd4ffca999b360ad6fc3fcc394eb47e0d97d06"
    ),
    .target(
      name: "RecaptchaEnterprise",
      dependencies: [
        .target(name: "RecaptchaEnterpriseSDK"),
        .product(name: "RecaptchaInterop", package: "interop-ios-for-google-sdks"),
      ]
    ),
  ]
)
