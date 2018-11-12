import Authentication
import Bootstrap
import Flash
import Fluent
import Leaf
import Paginator
import Reset
import Submissions
import Sugar
import Vapor

// MARK: - Commands
public extension AdminPanelProvider where U: Seedable {
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
    public let middlewares: AdminPanelMiddlewares

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

        try services.register(ResetProvider<U>(
            config: .init(
                name: config.name,
                baseURL: config.baseURL,
                endpoints: ResetEndpoints(
                    renderResetPasswordRequest: "/admin/users/reset-password/request",
                    resetPasswordRequest: "/admin/users/reset-password/request",
                    renderResetPassword: "/admin/users/reset-password",
                    resetPassword: "/admin/users/reset-password"
                ),
                signer: ExpireableJWTSigner(
                    expirationPeriod: 1.hoursInSecs,
                    signer: .hs256(key: config.resetPasswordSignerKey.convertToData())
                ),
                controller: AdminPanel.ResetController<U>()
            )
        ))
        try services.register(SubmissionsProvider())

        services.register(AdminPanelConfigTagData<U>(
            name: config.name,
            baseURL: config.baseURL,
            sidebarMenuPathGenerator: config.sidebarMenuPathGenerator,
            environment: config.environment
        ))
        services.register(config)
        services.register(KeyedCacheSessions.self)
        services.register(self.middlewares)
    }

    /// See Service.Provider.boot
    public func didBoot(_ container: Container) throws -> Future<Void> {
        let tags: MutableLeafTagConfig = try container.make()
        tags.use([
            "adminPanel:avatarURL": AvatarURLTag(),
            "adminPanel:config": AdminPanelConfigTag<U>(),
            "adminPanel:sidebar:heading": SidebarHeadingTag(),
            "adminPanel:sidebar:menuItem": SidebarMenuItemTag(),
            "adminPanel:user": CurrentUserTag<U>(),
            "adminPanel:user:requireRole": RequireRoleTag<U>(),
            "adminPanel:user:hasRequiredRole": HasRequiredRole<U>(),
            "submissions:WYSIWYG": InputTag(templatePath: config.tagTemplatePaths.wysiwygField),
            "offsetPaginator": OffsetPaginatorTag(templatePath: "Paginator/offsetpaginator")
        ])

        return .done(on: container)
    }
}
