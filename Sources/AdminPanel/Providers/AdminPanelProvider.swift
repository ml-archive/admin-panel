import Vapor
import Fluent
import Leaf
import Sugar
import Authentication
import Flash
import Bootstrap
import Reset
import Submissions

extension AdminPanelProvider {
    public static var tags: [String: TagRenderer] {
        return [
            "adminpanel:config": AdminPanelConfigTag(),
            "adminpanel:sidebar:menuitem": SidebarMenuItemTag(),
            "adminpanel:sidebar:heading": SidebarheadingTag(),
            "adminpanel:avatarurl": AvatarURLTag(),
        ]
        .merging(FlashProvider.tags) { (adminpanel, flash) in adminpanel }
        .merging(BootstrapProvider.tags) { (adminpanel, bootstrap) in adminpanel }
        .merging(SubmissionsProvider.tags) { (adminpanel, submissions) in adminpanel }
    }
}

// MARK: - Commands
extension AdminPanelProvider where U.ID: ExpressibleByStringLiteral, U: Seedable {
    public static func commands(
        databaseIdentifier: DatabaseIdentifier<U.Database>
    ) -> [String: Command] {
        return ["adminpanel:user-seeder": SeederCommand<U>(databaseIdentifier: databaseIdentifier)]
    }
}

public final class AdminPanelProvider<U: AdminPanelUserType>: Provider {
    /// See Service.Provider.repositoryName
    public static var repositoryName: String { return "admin-panel" }
    public let config: AdminPanelConfig

    public var middlewares: AdminPanelMiddlewares

    public init(config: AdminPanelConfig) {
        self.config = config

        let unsecure: [Middleware] = [
            AuthenticationSessionsMiddleware<U>(),
            FlashMiddleware(),
            CurrentUrlMiddleware()
        ]

        let secure = unsecure + [
            RedirectMiddleware<U>(path: AdminPanelEndpoints.default.login)
        ]

        self.middlewares = .init(
            unsecure: unsecure,
            secure: secure
        )
    }

    private var resetProvider: ResetProvider<U>!

    /// See Service.Provider.Register
    public func register(_ services: inout Services) throws {
        try services.register(LeafProvider())
        try services.register(AuthenticationProvider())
        services.register(KeyedCacheSessions.self)
        services.register(config)
        services.register(AdminPanelConfigTagData(
            name: config.name,
            baseUrl: config.baseUrl,
            userMenuPath: config.userMenuPath,
            adminMenuPath: config.adminMenuPath,
            superAdminMenuPath: config.superAdminMenuPath
        ))
        try services.register(FlashProvider())
        try services.register(CurrentURLProvider())
        try services.register(SubmissionsProvider())

        resetProvider = ResetProvider<U>(
            config: .init(
                name: config.name,
                baseUrl: config.baseUrl,
                endpoints: ResetEndpoints(
                    renderResetPasswordRequest: "/admin/users/reset-password/request",
                    resetPasswordRequest: "/admin/users/reset-password/request",
                    renderResetPassword: "/admin/users/reset-password",
                    resetPassword: "/admin/users/reset-password"
                ),
                shouldRegisterRoutes: false,
                signer: ExpireableJWTSigner(
                    expirationPeriod: 3600, // 1 hour
                    signer: .hs256(key: "secret-reset".convertToData())
                ),
                responses: ResetResponses(
                    resetPasswordRequestForm: { req in
                        return try req.privateContainer
                            .make(LeafRenderer.self)
                            // TODO: Remove empty context when this gets fixed
                            // https://github.com/vapor/template-kit/issues/17
                            .render(AdminPanelViews.Login.requestResetPassword, [String: String]())
                            .encode(for: req)
                    },
                    resetPasswordEmailSent: { req in
                        return Future.map(on: req) {
                            req
                                .redirect(to: "/admin/login")
                                .flash(.success, "Email with reset link sent.")
                        }
                    },
                    resetPasswordForm: { req, user in
                        return try req.privateContainer
                            .make(LeafRenderer.self)
                            // TODO: Remove empty context when this gets fixed
                            // https://github.com/vapor/template-kit/issues/17
                            .render(AdminPanelViews.Login.resetPassword, [String: String]())
                            .encode(for: req)
                    },
                    resetPasswordSuccess: { req, user in
                        return Future.map(on: req) {
                            req
                                .redirect(to: "/admin/login")
                                .flash(.success, "Your password has been updated.")
                        }
                    }
                )
            )
        )
        try services.register(resetProvider)
    }

    /// See Service.Provider.boot
    public func didBoot(_ container: Container) throws -> Future<Void> {
        let router = try container.make(Router.self)
        try routes(
            router,
            middlewares: middlewares,
            endpoints: AdminPanelEndpoints.default,
            resetProvider: resetProvider
        )

        return .done(on: container)
    }
}
