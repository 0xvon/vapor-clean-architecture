// swift-tools-version:5.5
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .unsafeFlags(["-Xfrontend", "-disable-availability-checking"])
]

let package = Package(
    name: "vapor-clean-architecture",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .executable(name: "Run", targets: ["Run"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.54.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.4.0"),
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.3.0"),
        .package(url: "https://github.com/kateinoigakukun/StubKit.git", from: "0.1.6"),
        .package(path: "Modules/Core"),
        .package(path: "Modules/Endpoint"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "JWTKit", package: "jwt-kit"),
                .product(name: "Persistance", package: "Core"),
                .product(name: "Endpoint", package: "Endpoint"),
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides/blob/main/docs/building.md#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ] + swiftSettings
        ),
        .target(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
            .product(name: "StubKit", package: "StubKit")
        ])
    ]
)
