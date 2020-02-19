// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Tweescord",
    products: [
        .library(name: "Tweescord", targets: ["App"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/console.git", from: "3.0.0"),
        .package(url: "https://github.com/BrettRToomey/Jobs.git", from: "1.1.2")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor", "Console", "Command", "Jobs"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

