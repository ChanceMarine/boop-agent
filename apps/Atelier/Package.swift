// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Atelier",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Atelier", targets: ["Atelier"])
    ],
    targets: [
        .executableTarget(
            name: "Atelier",
            path: "Sources/Atelier"
        )
    ]
)
