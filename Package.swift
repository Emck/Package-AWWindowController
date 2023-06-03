// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AWWindowController",
    platforms: [.macOS(.v10_13)],
    products: [
        .library(
            name: "AWWindowController",
            targets: ["AWWindowController"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Emck/Package-AWPageControl", branch: "main")
    ],
    targets: [
        .target(
            name: "AWWindowController",
            dependencies: [
                .product(name: "AWPageControl", package: "Package-AWPageControl")
            ],
            publicHeadersPath: "."
        )
    ]
)
