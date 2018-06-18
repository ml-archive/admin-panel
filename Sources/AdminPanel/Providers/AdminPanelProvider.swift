import Authentication
import Bootstrap
import Flash
import Fluent
import Leaf
import Reset
import Submissions
import Sugar
import Vapor

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
    public let config: AdminPanelConfig<U>

    public var middlewares: AdminPanelMiddlewares

    private let resetProvider: ResetProvider<U>
    private let submissionsProvider: SubmissionsProvider

    public init(config: AdminPanelConfig<U>) {
        self.config = config

        let unsecure: [Middleware] = [
            AuthenticationSessionsMiddleware<U>(),
            FlashMiddleware(),
            CurrentURLMiddleware()
        ]

        let secure: [Middleware] = unsecure + [
            RedirectMiddleware<U>(path: AdminPanelEndpoints.default.login),
            ShouldResetPasswordMiddleware<U>(path: AdminPanelEndpoints.default.renderEditMe),
            CurrentUserMiddleware<U>()
        ]

        self.middlewares = .init(
            unsecure: unsecure,
            secure: secure
        )

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
        submissionsProvider = SubmissionsProvider()
    }

    /// See Service.Provider.Register
    public func register(_ services: inout Services) throws {
        try services.register(AuthenticationProvider())
        try services.register(BootstrapProvider())
        try services.register(CurrentURLProvider())
        try services.register(CurrentUserProvider<U>())
        try services.register(FlashProvider())

        try services.register(resetProvider)
        try services.register(submissionsProvider)

        services.register(AdminPanelConfigTagData(
            name: config.name,
            baseUrl: config.baseUrl,
            userMenuPath: config.userMenuPath,
            adminMenuPath: config.adminMenuPath,
            superAdminMenuPath: config.superAdminMenuPath
        ))
        services.register(config)
        services.register(KeyedCacheSessions.self)
    }

    /// See Service.Provider.boot
    public func didBoot(_ container: Container) throws -> Future<Void> {
        try routes(
            container.make(),
            middlewares: middlewares,
            endpoints: AdminPanelEndpoints.default,
            resetProvider: resetProvider,
            config: container.make()
        )

        let tags: LeafTagConfig = try container.make()
        tags.use([
            "adminpanel:avatarurl": AvatarURLTag(),
            "adminpanel:config": AdminPanelConfigTag(),
            "adminpanel:sidebar:heading": SidebarHeadingTag(),
            "adminpanel:sidebar:menuitem": SidebarMenuItemTag(),
            "adminpanel:user": UserTag()
        ])

        return .done(on: container)
    }
}
