import HTTP
import Vapor
import Turnstile
import Auth

class ProtectMiddleware: Middleware {
    
    let configuration: Configuration
    let droplet: Droplet
    
    /// Init
    ///
    /// - Parameters:
    ///   - droplet: Droplet
    init(droplet: Droplet) {
        self.droplet = droplet
        self.configuration = Configuration.shared!
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
                if backendUser.shouldResetPassword {
                    
                    let redirectPath = "/admin/backend_users/edit/" + (backendUser.id?.string ?? "0")
                    
                    // Only redirect if not already there!
                    if redirectPath != request.uri.path {
                        return Response(redirect: redirectPath).flash(.error, "Please change your password")
                    }
                }
                
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
