import PackageDescription

let package = Package(
    name: "AdminPanel",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1),
        .Package(url: "https://github.com/nodes-vapor/storage", majorVersion: 0)
    ]
)
