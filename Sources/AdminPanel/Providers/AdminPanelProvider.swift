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
                        let config: AdminPanelConfig<U> = try req.make()
                        return try req.privateContainer
                            .make(LeafRenderer.self)
                            .render(config.views.login.requestResetPassword)
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
                        let config: AdminPanelConfig<U> = try req.make()
                        return try req.privateContainer
                            .make(LeafRenderer.self)
                            .render(config.views.login.resetPassword)
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
        try services.register(MutableLeafTagConfigProvider())
        try services.register(LeafProvider())

        try services.register(resetProvider)
        try services.register(submissionsProvider)

        services.register(AdminPanelConfigTagData<U>(
            name: config.name,
            baseUrl: config.baseUrl,
            sidebarMenuPathGenerator: config.sidebarMenuPathGenerator,
            environment: config.environment
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

        let tags: MutableLeafTagConfig = try container.make()
        tags.use([
            "adminPanel:avatarURL": AvatarURLTag(),
            "adminPanel:config": AdminPanelConfigTag<U>(),
            "adminPanel:sidebar:heading": SidebarHeadingTag(),
            "adminPanel:sidebar:menuItem": SidebarMenuItemTag(),
            "adminPanel:user": CurrentUserTag<U>(),
            "adminPanel:user:requireRole": RequireRoleTag<U>(),
            "adminPanel:user:hasRequiredRole": HasRequiredRole<U>(),
            "submissions:WYSIWYG": InputTag(templatePath: config.tagTemplatePaths.wysiwygField)
        ])

        return .done(on: container)
    }
}
