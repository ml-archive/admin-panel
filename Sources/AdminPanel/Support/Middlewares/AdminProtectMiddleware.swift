import HTTP
import Vapor
import Turnstile

public class AdminProtectMiddleware: Middleware {
    
    public init() {
        
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            if let backendUser: BackendUser = try request.auth.user() as? BackendUser {
                try request.storage["user"] = backendUser.toBackendView()
            }
            
        } catch {
            
            let credentials = UsernamePassword(username: "tech@nodes.dk", password: "admin")
            try request.auth.login(credentials)
            
            return Response(redirect: "/admin/login").flash(.error, "Session expired login again")
        }
        
        return try next.respond(to: request)
    }
}
