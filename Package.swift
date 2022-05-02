// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "虎.engine.puzzle",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "虎.engine.puzzle",
            targets: ["虎.engine.puzzle"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/waterdine/hu.engine.base.git", .upToNextMajor(from: "0.0.1")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "虎.engine.puzzle",
            dependencies: [.product(name: "虎.engine.base", package: "hu.engine.base")],
            resources: [
              .copy("Resources/Scenes")
            ]),
        .testTarget(
            name: "虎.engine.puzzle.tests",
            dependencies: ["虎.engine.puzzle"]),
    ]
)
