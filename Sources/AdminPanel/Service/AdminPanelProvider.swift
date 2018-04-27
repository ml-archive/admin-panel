import Vapor
import Fluent
import Leaf
import Sugar
import Authentication

extension AdminPanelProvider {
    public static var tags: [String: TagRenderer] {
        return ["adminpanel:config": AdminPanelConfigTag()]
    }

    public static func commands(databaseIdentifier: DatabaseIdentifier<User.Database>) -> [String: Command] {
        return ["adminpanel:user-seeder": SeederCommand<User>(databaseIdentifier: databaseIdentifier)]
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
        try services.register(AuthenticationProvider())
//        services.register(KeyedCacheSessions.self)
        services.register(AdminPanelConfigTagData(name: config.name, baseUrl: config.baseUrl))
    }

    /// See Service.Provider.boot
    public func didBoot(_ container: Container) throws -> Future<Void> {
        let router = try container.make(Router.self)

//        let redis = try container.make(KeyedCacheSessions.self)

//        let foo = SessionsMiddleware(cookieName: "vapor-sessions", sessions: redis)

//        let middlewares: [Middleware] = [foo, AuthenticationSessionsMiddleware<User>()]
//        router.grouped(middlewares).get(AdminPanelRoutes.login, use: UserController().renderLogin)


        try routes(router)

        return .done(on: container)
    }
}
