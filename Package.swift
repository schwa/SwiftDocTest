// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDocTest",
    platforms: [
        .macOS("13"),
    ],
    products: [
        .plugin(name: "MyCommandPlugin", targets: ["MyCommandPlugin"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", branch: "main"),
        .package(url: "https://github.com/schwa/Everything", branch: "main"),
        .package(url: "https://github.com/stencilproject/Stencil.git", from: "0.15.1"),
    ],
    targets: [
        .executableTarget(
            name: "swift-doc-test",
            dependencies: [
                "SwiftDocTestSupport",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Everything",
            ],
            path: "Sources/SwiftDocTest"
        ),
        .plugin(
            name: "MyCommandPlugin",
            capability: .command(intent: .custom(verb: "TODO", description: "TODO"), permissions: [.writeToPackageDirectory(reason: "TODO")]),
//            capability: .buildTool(),
            dependencies: [
                .product(name: "Everything", package: "Everything"),
                "SwiftDocTestSupport",
            ]),
        .target(name: "SwiftDocTestSupport",
                dependencies: [
                    .product(name: "ArgumentParser", package: "swift-argument-parser"),
                    .product(name: "SwiftParser", package: "swift-syntax"),
                    .product(name: "SwiftSyntax", package: "swift-syntax"),
                    "Everything",
                    "Stencil",
                ],
                resources: [
                    .copy("DocTests.swift.stencil")
                ]),
        .testTarget(
            name: "SwiftDocTestSupportTests",
            dependencies: ["SwiftDocTestSupport"]
        ),
    ]
)
