// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "MSelect",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "MSelect",
            targets: ["MSelect"]
        ),
    ],
    targets: [
        .target(
            name: "MSelect",
        ),
    ]
)