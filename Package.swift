// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDocTest",
    platforms: [
        .macOS("13"),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", branch: "main"),
        .package(url: "https://github.com/stencilproject/Stencil.git", from: "0.15.1"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/schwa/Everything", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "SwiftDocTest",
            dependencies: [
                "SwiftDocTestSupport",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Everything",
            ]
        ),
        .target(name: "SwiftDocTestSupport",
                dependencies: [
                    .product(name: "SwiftParser", package: "swift-syntax"),
                    .product(name: "SwiftSyntax", package: "swift-syntax"),
                    "Stencil",
                    .product(name: "ArgumentParser", package: "swift-argument-parser"),
                    "Everything",
                ],
                resources: [
                    .copy("DocTests.swift.stencil")
                ]),
        .testTarget(
            name: "SwiftDocTestTests",
            dependencies: ["SwiftDocTestSupport"]
        ),
    ]
)
