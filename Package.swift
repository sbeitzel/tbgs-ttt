// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "tbgs-ttt",
    products: [
        .library(name: "TicTacToe", type: .dynamic, targets: ["TicTacToe"])
    ],
    dependencies: [
        .package(name: "tbgs-shared", path: "../tbgs-shared")
    ],
    targets: [
        .target(name: "TicTacToe", dependencies: [
            .product(name: "TBGSLib", package: "tbgs-shared")
        ])
    ]
)
