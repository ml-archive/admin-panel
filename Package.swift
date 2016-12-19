import PackageDescription

let package = Package(
    name: "AdminPanel",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1)
    ]
)
