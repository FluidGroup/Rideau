// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Rideau",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "Rideau",
            targets: ["Rideau"]),
    ],
    dependencies: [
        .package(url: "https://github.com/immortal79/TransitionPatch.git", from: "1.0.3")
    ],
    targets: [
        .target(
            name: "Rideau",
            dependencies: ["TransitionPatch"],
            path: "Rideau"),
    ]
)
