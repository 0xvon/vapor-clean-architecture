// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Endpoint",
    products: [
        .library(name: "Endpoint", targets: ["Endpoint"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kateinoigakukun/CodableURL.git", from: "0.3.1"),
        .package(path: "../DomainEntity"),
    ],
    targets: [
        .target(name: "Endpoint", dependencies: ["DomainEntity", "CodableURL"]),
    ]
)
