/*
import Vapor
import HTTP
import Auth
import Turnstile

public class AuthRedirectMiddleware: Middleware {
    public init() {}
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        // TODO move
        do {
            try request.storage["user"] = request.auth.user()
        } catch {
            // Auto login for debug
            let credentials = UsernamePassword(username: "tech@nodes.dk", password: "admin")
            try request.auth.login(credentials)
            try request.storage["user"] = request.auth.user()
        }
        
        do {
            return try next.respond(to: request)
        } catch AuthError.notAuthenticated {
            return Response(redirect: "/admin/login").flash(.error, "Session expired login again");
        }
    }
}

*/
