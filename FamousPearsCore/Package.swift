// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FamousPearsCore",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "FamousPearsCore",
            targets: ["FamousPearsCore"]
        )
    ],
    targets: [
        .target(
            name: "FamousPearsCore",
            dependencies: [],
            resources: [
                .process("Resources/cards.json")
            ]
        )
    ]
)
