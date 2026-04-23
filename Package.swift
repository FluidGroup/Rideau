// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Rideau",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "Rideau",
            targets: ["Rideau"]
        ),
    ],
    dependencies: [
        .package(path: "submodules/swiftui-scrollview-interoperable-drag-gesture"),
    ],
    targets: [
        .target(
          name: "Rideau",
          dependencies: [
            .product(
              name: "SwiftUIScrollViewInteroperableDragGesture",
              package: "swiftui-scrollview-interoperable-drag-gesture"
            ),
          ],
          path: "Rideau"
        ),
    ]
)
