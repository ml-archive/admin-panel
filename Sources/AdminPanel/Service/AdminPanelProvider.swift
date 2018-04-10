import Vapor
import Leaf

extension AdminPanelProvider {
    public static var tags:  [String: TagRenderer] {
        return ["adminpanel:config": AdminPanelConfigTag()]
    }
}

public final class AdminPanelProvider: Provider {
    /// See Service.Provider.repositoryName
    public static let repositoryName = "admin-panel"
    public let config: AdminPanelConfig

    public init(config: AdminPanelConfig) {
        self.config = config
    }

    /// See Service.Provider.Register
    public func register(_ services: inout Services) throws {
        try services.register(LeafProvider())
        services.register(AdminPanelConfigTagData(name: config.name, baseUrl: config.baseUrl))
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
