import HTTP
import Vapor
import Turnstile

public class AdminProtectMiddleware: Middleware {
    
    public init() {
        
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            try request.storage["user"] = request.auth.user()
        } catch {
            /*
            let credentials = UsernamePassword(username: "tech@nodes.dk", password: "admin")
            try request.auth.login(credentials)
            */
            return Response(redirect: "/admin/login").flash(.error, "Session expired login again")
        }
        
        return try next.respond(to: request)
    }
}
