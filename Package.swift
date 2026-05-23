// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Dot",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Dot", targets: ["Dot"])
    ],
    targets: [
        .executableTarget(
            name: "Dot",
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .linkedFramework("Carbon")
            ]
        )
    ]
)
