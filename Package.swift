// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "TinyCombine",
    products: [
        .library(name: "TinyCombine", targets: [ "TinyCombine", ]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "5.0.0"
        ),
    ],
    targets: [
        .target(name: "TinyCombine", dependencies: [ "RxSwift", ]),
        .testTarget(name: "TinyCombineTests", dependencies: [ "TinyCombine", ]),
    ]
)
