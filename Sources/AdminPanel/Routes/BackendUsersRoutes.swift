import Vapor
import HTTP
import Routing

public struct BackendUsersRoutes: RouteCollection {
    
    public typealias Wrapped = Responder
    
    let drop: Droplet
    
    public init(droplet: Droplet) {
        drop = droplet
    }
    
    public func build(_ builder: RouteBuilder) {
        
        let controller = BackendUsersController(droplet: drop)
        
        builder.get("/", handler: controller.index)
        builder.get("/create", handler: controller.create)
        builder.post("/store", handler: controller.store)
        builder.get("/logout", handler: controller.logout);
        
        builder.get("/edit", BackendUser.parameter, handler: controller.edit)
        builder.post("/update", BackendUser.parameter, handler: controller.update)
        builder.post("/delete", BackendUser.parameter, handler: controller.destroy)
    }
}
