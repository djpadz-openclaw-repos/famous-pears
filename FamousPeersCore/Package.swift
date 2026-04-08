// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FamousPeersCore",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "FamousPeersCore",
            targets: ["FamousPeersCore"]
        )
    ],
    targets: [
        .target(
            name: "FamousPeersCore",
            dependencies: [],
            resources: [
                .process("Resources/cards.json")
            ]
        ),
        .testTarget(
            name: "FamousPeersCoreTests",
            dependencies: ["FamousPeersCore"],
            resources: [
                .process("Resources/test-cards.json")
            ]
        )
    ]
)
