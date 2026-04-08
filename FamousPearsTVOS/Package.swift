// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FamousPearsTVOS",
    platforms: [
        .tvOS(.v16)
    ],
    dependencies: [
        .package(path: "../FamousPearsCore")
    ],
    targets: [
        .executableTarget(
            name: "FamousPearsTVOS",
            dependencies: [
                .product(name: "FamousPearsCore", package: "FamousPearsCore")
            ]
        )
    ]
)
