import Vapor
import HTTP
import Routing

public struct DashboardRoutes: RouteCollection {
    
    public typealias Wrapped = Responder
    
    let drop: Droplet
    
    public init(droplet: Droplet) {
        drop = droplet
    }
    
    public func build<Builder: RouteBuilder>(_ builder: Builder) where Builder.Value == Wrapped {
        
        let controller = DashboardController(droplet: drop)
        
        builder.get("/", handler: controller.index);
    }
}
