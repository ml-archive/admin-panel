import HTTP
import Vapor
import Turnstile
import Auth

public class AdminProtectMiddleware: Middleware {
    
    let configuration: Configuration
    
    public init(_ configuration: Configuration) {
        self.configuration = configuration
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            if let backendUser: BackendUser = try request.auth.user() as? BackendUser {
                try request.storage["user"] = backendUser.toBackendView()
            }
            
        } catch {
            if configuration.autoLoginFirstUser, let backendUser: BackendUser = try BackendUser.query().first() {
                
                try request.auth.login(Identifier(id: backendUser.id!))
                
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
