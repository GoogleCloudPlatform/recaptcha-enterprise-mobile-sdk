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
    .iOS(.v11)
  ],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "RecaptchaEnterprise",
      targets: ["recaptcha-enterprise"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/google/interop-ios-for-google-sdks.git",
      "100.0.0"..<"101.0.0"
    )
  ],
  targets: [
    .target(
      name: "recaptcha-enterprise",
      dependencies: [
        "RecaptchaEnterprise",
        .product(name: "RecaptchaInterop", package: "interop-ios-for-google-sdks"),
      ],
      publicHeadersPath: "."
    ),
    .binaryTarget(
      name: "RecaptchaEnterprise",
        "https://dl.google.com/recaptchaenterprise/v18.6.0-beta01/RecaptchaEnterprise_iOS_xcframework/recaptcha-xcframework.xcframework.zip",
      checksum: "a088853a2efb3be8937644ea17d399ac9ef5e3f64ae2f9ef6592256f9559e374"
    ),
  ]
)
