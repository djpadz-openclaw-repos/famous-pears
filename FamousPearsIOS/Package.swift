// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FamousPearsIOS",
    platforms: [
        .iOS(.v16)
    ],
    dependencies: [
        .package(path: "../FamousPearsCore")
    ],
    targets: [
        .executableTarget(
            name: "FamousPearsIOS",
            dependencies: [
                .product(name: "FamousPearsCore", package: "FamousPearsCore")
            ]
        )
    ]
)
