import Vapor
import Paginator
import Flash
import Auth
import HTTP
import Sugar

public final class Provider: Vapor.Provider {
    
    var config: Configuration
    var ssoProvider: SSOProtocol?
    
    public func boot(_ droplet: Droplet) {
        
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
        
        droplet.preparations.append(BackendUserResetPasswordTokens.self)
        droplet.preparations.append(BackendUser.self)
        
        droplet.commands.append(Seeder(dropet: droplet))
        
        // Init middlewares
        let middlewares: [Middleware] = [
            AuthMiddleware<BackendUser>(cache: droplet.cache),
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
            droplet.group(collection: Middlewares.unsecured) { unsecured in
                unsecured.grouped("/").collection(LoginRoutes(droplet: droplet, config: config))
            }
            
            droplet.group(collection: Middlewares.secured) { secured in
                if config.loadDashboardRoute {
                    secured.grouped("/admin/dashboard").collection(DashboardRoutes(droplet: droplet))
                }
                
                secured.grouped("/admin/backend_users").collection(BackendUsersRoutes(droplet: droplet))
            }
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
    
    
    // is automatically called directly after boot()
    public func afterInit(_ drop: Droplet) {
    }
    
    // is automatically called directly after afterInit()
    public func beforeRun(_: Droplet) {
    }
    
    public func beforeServe(_: Droplet) {
    }
}
