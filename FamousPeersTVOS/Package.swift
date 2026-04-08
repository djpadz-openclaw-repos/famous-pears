// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FamousPeersTVOS",
    platforms: [
        .tvOS(.v16)
    ],
    dependencies: [
        .package(path: "../FamousPeersCore")
    ],
    targets: [
        .executableTarget(
            name: "FamousPeersTVOS",
            dependencies: [
                .product(name: "FamousPeersCore", package: "FamousPeersCore")
            ]
        )
    ]
)
