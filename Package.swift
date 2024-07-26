// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Rideau",
  platforms: [.iOS(.v13)],
  products: [
    .library(
      name: "Rideau",
      targets: ["Rideau"]
    )
  ],
  dependencies: [],
  targets: [
    .target(
      name: "Rideau",
      dependencies: [],
      path: "Rideau"
    )
  ]
)
