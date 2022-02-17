// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "DomainEntity",
    products: [
        .library(name: "DomainEntity", targets: ["DomainEntity"]),
    ],
    targets: [
        .target(name: "DomainEntity"),
    ]
)
