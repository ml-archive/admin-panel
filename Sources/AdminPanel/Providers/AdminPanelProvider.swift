import Authentication
import Bootstrap
import Flash
import Fluent
import JWT
import Leaf
import Paginator
import Reset
import Submissions
import Sugar
import Vapor

// MARK: - Commands
public extension AdminPanelProvider where U: Seedable {
    static func commands(
        databaseIdentifier: DatabaseIdentifier<U.Database>
    ) -> [String: Command] {
        return ["adminpanel:user-seeder": SeederCommand<U>(databaseIdentifier: databaseIdentifier)]
    }
}

public final class AdminPanelProvider<U: AdminPanelUserType>: Provider {
    /// See Service.Provider.repositoryName
    public static var repositoryName: String { return "admin-panel" }

    private let configFactory: (Container) throws -> AdminPanelConfig<U>

    public init(configFactory: @escaping (Container) throws -> AdminPanelConfig<U>) {
        self.configFactory = configFactory
    }

    /// See Service.Provider.Register
    public func register(_ services: inout Services) throws {
        try services.register(AuthenticationProvider())
        try services.register(CurrentURLProvider())
        try services.register(CurrentUserProvider<U>())
        try services.register(FlashProvider())
        try services.register(LeafProvider())

        services.register(factory: configFactory)

        try services.register(ResetProvider<U> { container in
            let config: AdminPanelConfig<U> = try container.make()
            return ResetConfig(
                name: config.name,
                baseURL: config.baseURL,
                endpoints: config.resetEndpoints,
                signer: config.resetSigner,
                responses: .adminPanel(config: config),
                controller: AdminPanel.ResetController<U>()
            )
        })
        try services.register(SubmissionsProvider())

        services.register { container -> AdminPanelConfigTagData<U> in
            let config: AdminPanelConfig<U> = try container.make()
            return .init(
                name: config.name,
                baseURL: config.baseURL,
                sidebarMenuPathGenerator: config.sidebarMenuPathGenerator,
                environment: config.environment
            )
        }
        services.register(KeyedCacheSessions.self)
        services.register { container -> AdminPanelMiddlewares in
            let config: AdminPanelConfig<U> = try container.make()
            let unsecure: [Middleware] = [
                AuthenticationSessionsMiddleware<U>(),
                FlashMiddleware(),
                CurrentURLMiddleware()
            ]

            let endpoints = config.endpoints
            let secure: [Middleware] = unsecure + [
                RedirectMiddleware<U>(path: config.endpoints.login),
                ShouldResetPasswordMiddleware<U>(path:
                    "\(endpoints.adminPanelUserBasePath)/\(endpoints.meSlug)/\(endpoints.editSlug)"
                ),
                CurrentUserMiddleware<U>()
            ]

            return .init(
                secure: secure,
                unsecure: unsecure
            )
        }
    }

    /// See Service.Provider.boot
    public func didBoot(_ container: Container) throws -> Future<Void> {
        return .done(on: container)
    }
}

extension ResetResponses {
    static func adminPanel<U: AdminPanelUserType>(config: AdminPanelConfig<U>) -> ResetResponses {
        return ResetResponses(
            resetPasswordRequestForm: { [config] req in
                try req
                    .view()
                    .render(config.views.login.requestResetPassword, on: req)
                    .encode(for: req)
            },
            resetPasswordUserNotified: { [config] req in
                req.future(req
                    .redirect(to: config.endpoints.login)
                    .flash(.success, "Email with reset link sent.")
                )
            },
            resetPasswordForm: { [config] req, _ in
                try req.addFields(forType: U.self)
                return try req
                    .view()
                    .render(config.views.login.resetPassword, on: req)
                    .encode(for: req)
            },
            resetPasswordSuccess: { [config] req, _ in
                req.future(req
                    // TODO: make configurable
                    .redirect(to: config.endpoints.login)
                    .flash(.success, "Your password has been updated.")
                )
            }
        )
    }
}

public extension LeafTagConfig {
    mutating func useAdminPanelLeafTags<U: AdminPanelUserType>(
        _ type: U.Type,
        paths: TagTemplatePaths = .init()
    ) {
        useBootstrapLeafTags()
        use([
            "adminPanel:avatarURL": AvatarURLTag(),
            "adminPanel:config": AdminPanelConfigTag<U>(),
            "adminPanel:sidebar:heading": SidebarHeadingTag(),
            "adminPanel:sidebar:menuItem": SidebarMenuItemTag(),
            "adminPanel:user": CurrentUserTag<U>(),
            "adminPanel:user:requireRole": RequireRoleTag<U>(),
            "adminPanel:user:hasRequiredRole": HasRequiredRole<U>(),
            "number": NumberFormatTag(),
            "offsetPaginator": OffsetPaginatorTag(templatePath: "Paginator/offsetpaginator"),
            "submissions:WYSIWYG": InputTag(templatePath: paths.wysiwygField)
        ])
    }
}
