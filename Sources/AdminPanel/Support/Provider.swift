import Vapor
import Paginator

public final class Provider: Vapor.Provider {
    
    var config: Configuration
    var ssoProvider: SSOProtocol?
    
    public func boot(_ dropet: Droplet) {
        
        if let leaf = dropet.view as? LeafRenderer {
            // AdminPanel
            leaf.stem.register(Active());
            leaf.stem.register(FormOpen());
            leaf.stem.register(FormClose());
            leaf.stem.register(FormTextGroup());
            leaf.stem.register(FormEmailGroup());
            leaf.stem.register(FormPasswordGroup());
            leaf.stem.register(FormNumberGroup());
            leaf.stem.register(FormCheckboxGroup());
            leaf.stem.register(FormSelectGroup());
            
            //Paginator
            leaf.stem.register(PaginatorTag())
        }
        
        dropet.storage["adminPanelConfig"] = config
        Configuration.shared = config
        
        dropet.preparations.append(BackendUserResetPasswordTokens.self)
        dropet.preparations.append(BackendUserRole.self)
        dropet.preparations.append(BackendUser.self)
        
        dropet.commands.append(Seeder(dropet: dropet))
        
        if(config.loadRoutes) {
            dropet.group(AdminPanelMiddleware(droplet: dropet)) { auth in
                auth.grouped("/").collection(LoginRoutes(droplet: dropet, config: config))
                
                auth.group(ProtectMiddleware(droplet: dropet)) { secured in
                    secured.grouped("/admin/dashboard").collection(DashboardRoutes(droplet: dropet))
                    secured.grouped("/admin/backend_users").collection(BackendUsersRoutes(droplet: dropet))
                    secured.grouped("/admin/backend_users/roles").collection(BackendUserRolesRoutes(droplet: dropet))
                }
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
