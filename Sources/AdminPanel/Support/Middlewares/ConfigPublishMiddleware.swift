import HTTP
import Vapor
import Turnstile

public class ConfigPublishMiddleware: Middleware {
    let config: Configuration
    
    public init(config: Configuration) {
        self.config = config
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        
        request.storage["adminPanel"] = config.makeNode()
        
        request.storage["_fieldset"] = try request.session().data["_fieldset"]
        try request.session().data["_fieldset"] = nil
        
        return try next.respond(to: request)
    }
}
