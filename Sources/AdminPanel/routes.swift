import Routing
import Vapor
import Authentication
import Flash

public struct AdminPanelEndpoints {
    public let login: String
    public let logout: String
    public let dashboard: String

    public init(
        login: String,
        logout: String,
        dashboard: String
    ) {
        self.login = login
        self.logout = logout
        self.dashboard = dashboard
    }

    public static var `default`: AdminPanelEndpoints {
        let admin = "/admin"
        return .init(
            login: admin + "/login",
            logout: admin + "/logout",
            dashboard: admin + "/dashboard"
        )
    }
}


internal extension AdminPanelProvider {
    internal func routes(_ router: Router) throws {
        let userController = UserController<U>(endpoints: AdminPanelEndpoints.default)

        let middlewares: [Middleware] = [AuthenticationSessionsMiddleware<U>(), FlashMiddleware()]
        let redirect = RedirectMiddleware<U>(path: userController.endpoints.login)

        let unprotected = router.grouped(middlewares)
        let protected = unprotected.grouped(redirect)

        // MARK: User routes

        unprotected.get(userController.endpoints.login, use: userController.renderLogin)
        unprotected.post(userController.endpoints.login, use: userController.login)
        unprotected.get(userController.endpoints.logout, use: userController.logout)

        // MARK: Dashboard routes

        let dashboardController = DashboardController()
        protected.get(userController.endpoints.dashboard, use: dashboardController.renderDashboard)
    }
}
