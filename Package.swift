// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "mehitabel",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        .package(url: "https://github.com/DavidSkrundz/CLua", from: "5.2.4"),
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "CLua"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

