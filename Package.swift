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
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/FluidGroup/swiftui-scrollview-interoperable-drag-gesture",
      revision: "6b74e353bbae6b8fbc5afe534c05769b6e4910c0"
    ),
    .package(url: "https://github.com/FluidGroup/swift-rubber-banding", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "Rideau",
      dependencies: [
        .product(
          name: "SwiftUIScrollViewInteroperableDragGesture",
          package: "swiftui-scrollview-interoperable-drag-gesture"
        ),
        .product(name: "RubberBanding", package: "swift-rubber-banding"),
      ],
      path: "Rideau"
    )
  ],
  swiftLanguageModes: [.v5]
)
