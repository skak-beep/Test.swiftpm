// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "Test",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .executable(
            name: "Test",
            targets: ["AppModule"]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ]
)
