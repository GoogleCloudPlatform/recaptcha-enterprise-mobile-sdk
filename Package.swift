// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

/*
Copyright 2022 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import PackageDescription

let package = Package(
    name: "RecaptchaEnterpriseSwift",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "RecaptchaEnterpriseSwift",
            targets: ["RecaptchaEnterpriseSwift"]),
    ],
    dependencies: [
        .package(
          name: "GTMSessionFetcher",
          url: "https://github.com/google/gtm-session-fetcher.git",
          .upToNextMinor(from: "1.7.1")
        ),
        .package(
          name: "GoogleDataTransport",
          url: "https://github.com/google/GoogleDataTransport.git",
          .upToNextMinor(from: "9.1.0")
        ),
        .package(
          name: "Promises",
          url: "https://github.com/google/promises.git",
          .upToNextMinor(from: "2.1.0")
        )
    ],
    targets: [
        .target(
            name: "RecaptchaEnterpriseSwift",
            dependencies: ["recaptcha-enterprise"]
        ),
        .target (
            name: "recaptcha-enterprise",
            dependencies: ["recaptcha",
                            "gtm",
                           "Protobuf",
                           .product(name: "GTMSessionFetcherCore", package: "GTMSessionFetcher"),
                           .product(name: "GoogleDataTransport", package: "GoogleDataTransport"),
                           .product(name: "FBLPromises", package: "Promises"),
                           .product(name: "Promises", package: "Promises"),
            ],
            publicHeadersPath: "."
        ),
        .target(
            name: "gtm",
            sources: [ "gtmlibrary"],
            publicHeadersPath: "."
        ),
        .binaryTarget(
            name: "recaptcha",
            url: "https://dl.google.com/recaptchaenterprise/V17.0.0/RecaptchaEnterprise-SPM-17.0.0.zip",
            checksum: "9fd55b6a0c6333c1fb97b236bd04fdcd6f4c9a62f6de042d3c83bfc59301309e"
        ),
        .binaryTarget(
            name: "Protobuf",
            url: "https://dl.google.com/recaptchaenterprise/V17.0.0/protobuf.xcframework.zip",
            checksum: "baa8452205e1faad8f1261a733087a3aefe49bc6607c1d3dbb6ce9d707d38d5c"
        )
    ]
)
