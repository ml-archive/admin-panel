import Vapor
import Leaf

public final class AdminPanelProvider: Provider {
    /// See Service.Provider.repositoryName
    public static let repositoryName = "admin-panel"

    public init() {}

    /// See Service.Provider.Register
    public func register(_ services: inout Services) throws {
        try services.register(LeafProvider())
    }

    /// See Service.Provider.boot
    public func didBoot(_ container: Container) throws -> Future<Void> {
        let router = try container.make(Router.self)

        router.get("/admin") { req -> Future<View> in
            let leaf = try req.make(LeafRenderer.self)
            return leaf.render("AdminPanel/Login/index")
        }

        return .done(on: container)
    }
}
