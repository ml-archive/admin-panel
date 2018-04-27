import Routing
import Vapor
import Authentication

public enum AdminPanelRoutes {
    private static let prefix = "/admin"
    static let login = prefix + "/login"
    static let logout = prefix + "/logout"
    static let dashboard = prefix + "/dashboard"
}

public func routes(_ router: Router) throws {
    let middlewares = [AuthenticationSessionsMiddleware<User>()]
    let redirect = RedirectMiddleware<User>(path: AdminPanelRoutes.login)

    let unprotected = router.grouped(middlewares)
    let protected = unprotected.grouped(redirect)

    // MARK: User routes

    let userController = UserController()
    unprotected.get(AdminPanelRoutes.login, use: userController.renderLogin)
    unprotected.post(AdminPanelRoutes.login, use: userController.login)
    unprotected.get(AdminPanelRoutes.logout, use: userController.logout)

    // MARK: Dashboard routes

    let dashboardController = DashboardController()
    protected.get(AdminPanelRoutes.dashboard, use: dashboardController.renderDashboard)
}
