import Vapor
import HTTP
import Auth

public final class DashboardController {
    
    public let drop: Droplet
    
    public init(droplet: Droplet) {
        drop = droplet
    }
    
    public func index(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("Dashboard/view", for: request)
    }
    
}
