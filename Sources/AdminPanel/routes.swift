import Routing
import Vapor

public enum AdminPanelRoutes {
    private static let prefix = "/admin"
    static let login = prefix + "/login"
    static let dashboard = prefix + "/dashboard"
}

public func routes(_ router: Router) throws {
    // MARK: User routes

    let userController = UserController()
    router.get(AdminPanelRoutes.login, use: userController.renderLogin)
    router.post(AdminPanelRoutes.login, use: userController.login)

    // MARK: Dashboard routes

    let dashboardController = DashboardController()
    router.get(AdminPanelRoutes.dashboard, use: dashboardController.renderDashboard)
}
