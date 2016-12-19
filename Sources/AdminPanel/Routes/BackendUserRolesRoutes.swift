import Vapor
import HTTP
import Routing

public struct BackendUserRolesRoutes: RouteCollection {
    
    public typealias Wrapped = Responder
    
    let drop: Droplet
    
    public init(droplet: Droplet) {
        drop = droplet
    }
    
    public func build<Builder: RouteBuilder>(_ builder: Builder) where Builder.Value == Wrapped {
        
        let controller = BackendUserRolesController(droplet: drop)
        
        builder.get("/", handler: controller.index)
        builder.post("/create", handler: controller.store)
        builder.get("/default", BackendUserRole.self, handler: controller.setDeault)
        builder.get("/delete", BackendUserRole.self, handler: controller.delete)
    }
}
