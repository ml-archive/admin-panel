import Vapor
import HTTP
import Auth

public class FlashMiddleware: Middleware {
    public init() {}
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        
        // Take flash session and apply to storage, while moving new to old
        try Helper.handleRequest(request)
    
        let response = try next.respond(to: request)
        
        // Check if new sessions are added to response and move them to session
        try Helper.handleResponse(response, request)
        
        return response
    }
}

