// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FamousPeersIOS",
    platforms: [
        .iOS(.v16)
    ],
    dependencies: [
        .package(path: "../FamousPeersCore")
    ],
    targets: [
        .executableTarget(
            name: "FamousPeersIOS",
            dependencies: [
                .product(name: "FamousPeersCore", package: "FamousPeersCore")
            ]
        )
    ]
)
