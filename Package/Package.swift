// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Package",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "Feature", targets: ["Feature"]),
    ],
    dependencies: [
        .package(url: "https://github.com/awslabs/aws-sdk-swift.git", from: "0.10.0")
    ],
    targets: [
        .target(name: "Feature", dependencies: [
            "Core",
            "Infra"
        ]),
        .target(name: "Infra", dependencies: [
            "Core",
            .product(name: "AWSTimestreamQuery", package: "aws-sdk-swift")
        ]),
        .target(name: "Core", dependencies: []),
        .testTarget(name: "FeatureTests", dependencies: [
            "Feature"
        ]),
    ]
)
