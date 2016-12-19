import Vapor
import HTTP
import Routing

public struct BackendUsersRoutes: RouteCollection {
    
    public typealias Wrapped = Responder
    
    let drop: Droplet
    
    public init(droplet: Droplet) {
        drop = droplet
    }
    
    public func build<Builder: RouteBuilder>(_ builder: Builder) where Builder.Value == Wrapped {
        
        let controller = BackendUsersController(droplet: drop)
        
        builder.get("/", handler: controller.index)
        builder.get("/create", handler: controller.create)
        builder.post("/create", handler: controller.store)
        builder.get("/logout", handler: controller.logout);
        
        builder.get("/edit", BackendUser.self, handler: controller.edit)
        builder.post("/edit", BackendUser.self, handler: controller.update)
        builder.get("/delete", BackendUser.self, handler: controller.destroy)
    }
}
