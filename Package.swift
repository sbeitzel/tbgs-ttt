// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "tbgs-ttt",
    platforms: [ .iOS(.v13), .macOS(.v12) ],
    products: [
        .library(name: "TicTacToe", type: .dynamic, targets: ["TicTacToe"])
    ],
    dependencies: [
        .package(url: "https://github.com/sbeitzel/tbgs-shared.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "TicTacToe", dependencies: [
            .product(name: "TBGSLib", package: "tbgs-shared")
        ])
    ]
)
