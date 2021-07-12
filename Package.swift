// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "AsyncUI",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "AsyncUI",
            targets: ["AsyncUI"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/lucamegh/CombineHelpers", from: "1.0.0"),
        .package(url: "https://github.com/lucamegh/LoadingState", from: "1.0.0"),
        .package(url: "https://github.com/lucamegh/Portal", from: "1.0.0"),
        .package(url: "https://github.com/lucamegh/UIKitHelpers", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "AsyncUI",
            dependencies: [
                "CombineHelpers",
                "LoadingState",
                "Portal",
                "UIKitHelpers"
            ]
        ),
        .testTarget(
            name: "AsyncUITests",
            dependencies: ["AsyncUI"]
        )
    ]
)
