// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "NCMB",
    platforms: [
        .iOS(.v15), .macOS(.v12)
    ],
    products: [
        .library(name: "NCMB", targets: ["NCMB"]),
    ],
    dependencies: {
#if canImport(CommonCrypto)
        return []
#else
        return [
            .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.3.1"),
        ]
#endif
    }(),
    targets: [
        .target(
            name: "NCMB",
            dependencies: {
#if canImport(CommonCrypto)
                return []
#else
                return [
                    .product(name: "CryptoSwift", package: "CryptoSwift"),
                ]
#endif
            }(),
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
