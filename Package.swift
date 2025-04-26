// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "CoreMLDemo",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.0"),
        .package(url: "https://github.com/MacPaw/OpenAI.git", .upToNextMinor(from: "0.3.5")),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "0.1.0")
    ],
    targets: [
        .executableTarget(
            name: "CoreMLDemo",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
                "ZIPFoundation",
                .product(name: "OpenAI", package: "OpenAI"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ],
            resources: [
                .copy("Models")
            ],
            swiftSettings: [
                .define("ENABLE_GUI", .when(configuration: .debug))
            ]
        )
    ]
)
