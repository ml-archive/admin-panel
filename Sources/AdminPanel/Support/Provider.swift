import Vapor
import Paginator
import Flash
import AuthProvider
import HTTP
import Sugar
import LeafProvider

public final class Provider: Vapor.Provider {
    public static var repositoryName: String = "AdminPanel"


    var config: Configuration
    var ssoProvider: SSOProtocol?
    
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
        
        droplet.storage["adminPanelConfig"] = config
        Configuration.shared = config

        droplet.config.preparations.append(BackendUserResetPasswordTokens.self)
        droplet.config.preparations.append(BackendUser.self)

        droplet.config.addConfigurable(command: Seeder.init, name: "admin-panel:seeder")

        // Init middlewares
        let middlewares: [Middleware] = [
            PasswordAuthenticationMiddleware(BackendUser.self),
            FlashMiddleware(),
            ConfigPublishMiddleware(config: config),
            FieldsetMiddleware()
        ]
        
        var protectedMiddlewares: [Middleware] = middlewares
        protectedMiddlewares.append(ProtectMiddleware(droplet: droplet))
        
        // Apply
        Middlewares.unsecured = middlewares
        Middlewares.secured = protectedMiddlewares
        
        if(config.loadRoutes) {

            let unsecured = droplet.grouped(Middlewares.unsecured)
            try unsecured.grouped("/").collection(LoginRoutes(droplet: droplet, config: config))

            let secured = droplet.grouped(Middlewares.secured)
            if config.loadDashboardRoute {
                try secured.grouped("/admin/dashboard").collection(DashboardRoutes(droplet: droplet))
            }
            try secured.grouped("/admin/backend_users").collection(BackendUsersRoutes(droplet: droplet))
        }
    }
    
    public init(drop: Droplet) throws {
        config = try Configuration(drop: drop)
    }
    
    public init(config: Config) throws {
        self.config = try Configuration(config: config)
    }
    
    public convenience init(drop: Droplet, ssoProvider: SSOProtocol? = nil) throws {
        try self.init(drop: drop)
        
        config.ssoProvider = ssoProvider
    }

    public func boot(_ config: Config) throws {}
    
    // is automatically called directly after boot()
    public func afterInit(_ drop: Droplet) {
    }
    
    // is automatically called directly after afterInit()
    public func beforeRun(_: Droplet) {
    }
    
    public func beforeServe(_: Droplet) {
    }
}
