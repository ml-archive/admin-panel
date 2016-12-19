import Vapor
import Auth
public final class Provider: Vapor.Provider {
    
    let config: Configuration
    
    public func boot(_ drop: Droplet) {
        
        if let leaf = drop.view as? LeafRenderer {
            leaf.stem.register(Active())
        }
        
        drop.preparations.append(BackendUserResetPasswordTokens.self)
        drop.preparations.append(BackendUserRole.self)
        drop.preparations.append(BackendUser.self)
        
        if(config.loadRoutes) {
            drop.group(AuthMiddleware<BackendUser>(), FlashMiddleware(), ConfigPublishMiddleware(config: config)) { auth in
                auth.grouped("/").collection(LoginRoutes(droplet: drop))
                
                auth.group(AdminProtectMiddleware()) { secured in
                    secured.grouped("/admin/dashboard").collection(DashboardRoutes(droplet: drop))
                    secured.grouped("/admin/backend_users").collection(BackendUsersRoutes(droplet: drop))
                    secured.grouped("/admin/backend_users/roles").collection(BackendUserRolesRoutes(droplet: drop))
                }
            }
        }
    }
    
    
    public init(drop: Droplet) throws {
        config = try Configuration(drop: drop)
    }
    
    public init(config: Config) throws {
        // Don't use this init, it's only there cause of protocol
        throw Abort.serverError
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
