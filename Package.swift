// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdminPanel",
    products: [
        .library(
            name: "AdminPanel",
            targets: ["AdminPanel"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc"),
        .package(url: "https://github.com/nodes-vapor/sugar.git", .branch("vapor-3")),
        .package(url: "https://github.com/nodes-vapor/flash.git", .branch("master")),
        .package(url: "https://github.com/nodes-vapor/bootstrap.git", .branch("master")),
        .package(url: "https://github.com/nodes-vapor/reset.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "AdminPanel",
            dependencies: [
                "Vapor",
                "Fluent",
                "FluentMySQL",
                "Leaf",
                "Authentication",
                "Sugar",
                "Flash",
                "Bootstrap",
                "Reset"
            ]),
        .testTarget(
            name: "AdminPanelTests",
            dependencies: ["AdminPanel"]),
    ]
)
