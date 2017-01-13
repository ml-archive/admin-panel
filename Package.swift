import PackageDescription

let package = Package(
    name: "AdminPanel",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1),
        .Package(url: "https://github.com/nodes-vapor/sugar.git", majorVersion: 1),
        .Package(url: "https://github.com/bygri/vapor-forms.git", majorVersion: 0),
        .Package(url: "https://github.com/nodes-vapor/slugify.git", majorVersion: 1),
        .Package(url: "https://github.com/nodes-vapor/flash.git", majorVersion: 0),
        .Package(url: "https://github.com/nodes-vapor/paginator.git", majorVersion: 0),
    ]
)
