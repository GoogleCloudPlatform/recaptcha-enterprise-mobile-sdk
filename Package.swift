// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

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
          name: "GoogleUtilities",
          url: "https://github.com/google/GoogleUtilities.git",
          .upToNextMinor(from: "7.7.1")
        ),
        .package(
          name: "Promises",
          url: "https://github.com/google/promises.git",
          .upToNextMinor(from: "1.2.8")
        )
    ],
    targets: [
        .target(
            name: "RecaptchaEnterpriseSwift",
            dependencies: ["recaptcha-enterprise"]//,
        ),
        .target (
            name: "recaptcha-enterprise",
            dependencies: ["recaptcha",
                           "Protobuf",
                           .product(name: "GTMSessionFetcherCore", package: "GTMSessionFetcher"),
                           .product(name: "GoogleDataTransport", package: "GoogleDataTransport"),
                           .product(name: "GULNSData", package: "GoogleUtilities"),
                           .product(name: "FBLPromises", package: "Promises"),
                           .product(name: "Promises", package: "Promises"),
            ]
        ),
        .binaryTarget(
            name: "recaptcha",
            url: "https://dl.google.com/recaptchaenterprise/V17.0.0/recaptcha.zip",
            checksum: "137c9707bed94e327dd7dd6a4fa5d953fdb4da3c74ba103d56e11303209a33b0"
        ),
        .binaryTarget(
            name: "Protobuf",
            url: "https://dl.google.com/recaptchaenterprise/V17.0.0/protobuf.xcframework.zip",
            checksum: "f9cbed5e7d1c1b4d3df521273b43b68bc0582c7641b40e0c36d087e23deed8c5"
        )
    ]
)
