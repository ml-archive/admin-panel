import HTTP
import Vapor
import Turnstile
import Auth

public class AdminProtectMiddleware: Middleware {
    
    let configuration: Configuration
    let droplet: Droplet
    
    public init(droplet: Droplet, configuration: Configuration) {
        self.configuration = configuration
        self.droplet = droplet
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            if let backendUser: BackendUser = try request.auth.user() as? BackendUser {
                try request.storage["user"] = backendUser.toBackendView()
            }
            
        } catch {
            if (droplet.environment.description == "local" || request.uri.host == "0.0.0.0") && configuration.autoLoginFirstUser, let backendUser: BackendUser = try BackendUser.query().first() {
                
                try request.auth.login(Identifier(id: backendUser.id ?? 0))
                
                if let backendUser: BackendUser = try request.auth.user() as? BackendUser {
                    try request.storage["user"] = backendUser.toBackendView()
                }
            } else {
                return Response(redirect: "/admin/login?next=" + request.uri.path).flash(.error, "Session expired login again")
            }
        }
        
        return try next.respond(to: request)
    }
}
