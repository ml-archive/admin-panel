import Vapor
import HTTP
import Routing

public struct LoginRoutes: RouteCollection {
    
    public typealias Wrapped = Responder
    
    let drop: Droplet
    let config: Configuration
    
    public init(droplet: Droplet, config: Configuration) {
        drop = droplet
        self.config = config
    }
    
    public func build<Builder: RouteBuilder>(_ builder: Builder) where Builder.Value == Wrapped {
        
        let controller = LoginController(droplet: drop)

        // General
        builder.get("/", handler: controller.landing);
        builder.get("/admin", handler: controller.landing);
        
        // Login
        builder.get("/admin/login", handler: controller.form);
        builder.post("/admin/login", handler: controller.submit);
        
        // Reset password
        builder.get("/admin/login/reset", handler: controller.resetPasswordForm);
        builder.post("/admin/login/reset", handler: controller.resetPasswordSubmit);
        builder.get("/admin/login/reset/:token", handler: controller.resetPasswordTokenForm);
        builder.post("/admin/login/reset/change", handler: controller.resetPasswordTokenSubmit);
        
        // SSO
        if config.ssoProvider != nil {
            builder.get("/admin/login/sso", handler: controller.sso);
            builder.post("/admin/login/sso", handler: controller.sso);
        }
    }
}
