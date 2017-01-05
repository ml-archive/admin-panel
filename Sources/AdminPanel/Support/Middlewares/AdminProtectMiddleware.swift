import HTTP
import Vapor
import Turnstile
import Auth

public class AdminProtectMiddleware: Middleware {
    
    let configuration: Configuration
    let droplet: Droplet
    
    
    /// Init
    ///
    /// - Parameters:
    ///   - droplet: Droplet
    ///   - configuration: Configuration
    public init(droplet: Droplet, configuration: Configuration) {
        self.configuration = configuration
        self.droplet = droplet
    }
    
    /// Response
    ///
    /// - Parameters:
    ///   - request: Request
    ///   - next: Responder
    /// - Returns: Response
    /// - Throws: Error
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            // Retrieve authed user and add it to request storage
            if let backendUser: BackendUser = try request.auth.user() as? BackendUser {
                try request.storage["authedBackendUser"] = backendUser.toBackendView()
            }
            
        } catch {
            // If local & config is true & first backend user
            if (droplet.environment.description == "local" || request.uri.host == "0.0.0.0") && configuration.autoLoginFirstUser, let backendUser: BackendUser = try BackendUser.query().first() {
                
                // Login user & add storage
                try request.auth.login(Identifier(id: backendUser.id ?? 0))
                try request.storage["authedBackendUser"] = backendUser.toBackendView()
                
            } else {
                return Response(redirect: "/admin/login?next=" + request.uri.path).flash(.error, "Session expired login again")
            }
        }
        
        return try next.respond(to: request)
    }
}
