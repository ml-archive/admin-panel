import HTTP
import Vapor
import Turnstile

public class FieldsetMiddleware: Middleware {
    public init() {}
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        // Add fieldset to next request
        request.storage["_fieldset"] = try request.session().data["_fieldset"]
        try request.session().data["_fieldset"] = nil
        
        return try next.respond(to: request)
    }
}
