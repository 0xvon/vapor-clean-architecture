// swift-tools-version:5.5
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .unsafeFlags(["-Xfrontend", "-disable-availability-checking"])
]

let package = Package(
    name: "Core",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "Persistance", targets: ["Persistance"]),
        .library(name: "Domain", targets: ["Domain"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.18.0"),
        .package(url: "https://github.com/vapor/fluent-mysql-driver.git", from: "4.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.36.0"),
        .package(url: "https://github.com/kateinoigakukun/StubKit.git", from: "0.1.6"),
        .package(path: "../Endpoint"),
    ],
    targets: [
        .target(name: "Persistance", dependencies: [
            .product(name: "FluentKit", package: "fluent-kit"),
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "FluentMySQLDriver", package: "fluent-mysql-driver"),
            .target(name: "Domain"),
        ], swiftSettings: swiftSettings),
        .target(name: "Domain", dependencies: [
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "Endpoint", package: "Endpoint"),
        ], swiftSettings: swiftSettings),
        .testTarget(name: "DomainTests", dependencies: [
            .target(name: "Domain"),
            .product(name: "StubKit", package: "StubKit"),
        ], swiftSettings: swiftSettings),
    ]
)
