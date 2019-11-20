// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "TinyCombine",
    products: [
        .library(name: "TinyCombine", targets: [ "TinyCombine", ]),
    ],
    targets: [
        .target(name: "TinyCombine"),
        .target(name: "TinyCombineTesting", dependencies: [ "TinyCombine", ]),
        .testTarget(
            name: "TinyCombineTests",
            dependencies: [ "TinyCombine", "TinyCombineTesting", ]
        ),
    ]
)
