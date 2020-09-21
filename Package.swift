// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "NCMB",
    platforms: [
        .iOS(.v10), .macOS(.v10_12)
    ],
    products: [
        .library(name: "NCMB", targets: ["NCMB"]),
    ],
    targets: [
        .target(
            name: "NCMB",
            dependencies: [],
            path: "NCMB"
        ),
        .testTarget(
            name: "NCMBTests",
            dependencies: ["NCMB"],
            path: "NCMBTests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
