import Vapor
import Paginator
import Flash
import AuthProvider
import HTTP
import Sugar
import LeafProvider
import Sessions

public final class Provider: Vapor.Provider {
    public static var repositoryName: String = "AdminPanel"

    var adminPanelConfig: Configuration
    var ssoProvider: SSOProtocol?

    public func boot(_ config: Config) throws {
        config.addConfigurable(command: Seeder.init, name: "admin-panel:seeder")

        config.preparations.append(BackendUserResetPasswordToken.self)
        config.preparations.append(BackendUser.self)

        // Init middlewares
        let middlewares: [Middleware] = [
            FlashMiddleware(),
            PersistMiddleware(BackendUser.self),
            ConfigPublishMiddleware(config: adminPanelConfig),
            FieldsetMiddleware()
        ]

        var protectedMiddlewares = middlewares
        protectedMiddlewares.append(ProtectMiddleware(config: config, adminPanelConfiguration: adminPanelConfig))

        // Apply
        Middlewares.unsecured = middlewares
        Middlewares.secured = protectedMiddlewares
    }

    public func boot(_ droplet: Droplet) throws {
        if let leaf = droplet.view as? LeafRenderer {
            // AdminPanel
            leaf.stem.register(Active())
            leaf.stem.register(FormOpen())
            leaf.stem.register(FormClose())
            leaf.stem.register(FormTextGroup())
            leaf.stem.register(FormTextAreaGroup())
            leaf.stem.register(FormEmailGroup())
            leaf.stem.register(FormPasswordGroup())
            leaf.stem.register(FormNumberGroup())
            leaf.stem.register(FormCheckboxGroup())
            leaf.stem.register(FormSelectGroup())
            leaf.stem.register(Allow())
            
            //Paginator
            leaf.stem.register(PaginatorTag())
        }
        
        droplet.storage["adminPanelConfig"] = adminPanelConfig
        Configuration.shared = adminPanelConfig
    }

    public init(config: Config) throws {
        adminPanelConfig = try Configuration(config: config)
    }
    
    public convenience init(drop: Droplet, ssoProvider: SSOProtocol? = nil) throws {
        try self.init(drop: drop)
        
        adminPanelConfig.ssoProvider = ssoProvider
    }

    public func beforeRun(_ droplet: Droplet) throws {
        if (adminPanelConfig.loadRoutes) {
            let unsecured = droplet.grouped(Middlewares.unsecured)
            try unsecured.collection(LoginRoutes(droplet: droplet, config: adminPanelConfig))

            let secured = droplet.grouped(Middlewares.secured)
            if adminPanelConfig.loadDashboardRoute {
                try secured.grouped("/admin/dashboard").collection(DashboardRoutes(droplet: droplet))
            }
            try secured.grouped("/admin/backend_users/").collection(BackendUsersRoutes(droplet: droplet))
        }
    }
}
