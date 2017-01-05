import HTTP
import Vapor
import Auth
import Flash
import Paginator

public class AdminPanelProtectedMiddleware: Middleware {
    
    let droplet: Droplet
    let configuration: Configuration
    let authMiddleware: AuthMiddleware<BackendUser>
    let flashMiddleware: FlashMiddleware
    let configPulbishMiddleware: ConfigPublishMiddleware
    let fieldsetMiddleware: FieldsetMiddleware
    let protectMiddleware: ProtectMiddleware
    
    public init(droplet: Droplet) {
        self.droplet = droplet
        configuration = Configuration.shared!
        
        authMiddleware = AuthMiddleware<BackendUser>()
        flashMiddleware = FlashMiddleware()
        configPulbishMiddleware = ConfigPublishMiddleware(config: configuration)
        fieldsetMiddleware = FieldsetMiddleware()
        protectMiddleware = ProtectMiddleware(droplet: droplet)
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let _ = try authMiddleware.respond(to: request, chainingTo: next)
        let _ = try flashMiddleware.respond(to: request, chainingTo: next)
        let _ = try configPulbishMiddleware.respond(to: request, chainingTo: next)
        let _ = try fieldsetMiddleware.respond(to: request, chainingTo: next)
        let _ = try protectMiddleware.respond(to: request, chainingTo: next)
        
        return try next.respond(to: request)
    }
}
