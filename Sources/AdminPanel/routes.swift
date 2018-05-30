import Routing
import Vapor
import Authentication
import Flash
import Reset
import Sugar

public struct AdminPanelEndpoints {
    public let login: String
    public let logout: String
    public let dashboard: String
    public let adminPanelUserList: String
    public let createAdminPanelUser: String

    public init(
        login: String,
        logout: String,
        dashboard: String,
        adminPanelUserList: String,
        createAdminPanelUser: String
    ) {
        self.login = login
        self.logout = logout
        self.dashboard = dashboard
        self.adminPanelUserList = adminPanelUserList
        self.createAdminPanelUser = createAdminPanelUser
    }

    public static var `default`: AdminPanelEndpoints {
        let admin = "/admin"
        return .init(
            login: admin + "/login",
            logout: admin + "/logout",
            dashboard: admin + "/dashboard",
            adminPanelUserList: admin + "/users",
            createAdminPanelUser: admin + "/users/create"
        )
    }
}


internal extension AdminPanelProvider {
    internal func routes(_ router: Router, resetProvider: ResetProvider<U>) throws {
        let loginController = LoginController<U>(endpoints: AdminPanelEndpoints.default)

        let middlewares: [Middleware] = [AuthenticationSessionsMiddleware<U>(), FlashMiddleware(), CurrentUrlMiddleware()]
        let redirect = RedirectMiddleware<U>(path: loginController.endpoints.login)

        let unprotected = router.grouped(middlewares)
        let protected = unprotected.grouped(redirect)

        // MARK: Login routes

        unprotected.get(loginController.endpoints.login, use: loginController.renderLogin)
        unprotected.post(loginController.endpoints.login, use: loginController.login)
        unprotected.get(loginController.endpoints.logout, use: loginController.logout)

        // MARK: Dashboard routes

        let dashboardController = DashboardController()
        protected.get(loginController.endpoints.dashboard, use: dashboardController.renderDashboard)

        // MARK: Admin Panel User routes
        let adminPanelUserController = AdminPanelUserController()
        protected.get(loginController.endpoints.adminPanelUserList, use: adminPanelUserController.renderList)
        protected.get(loginController.endpoints.createAdminPanelUser, use: adminPanelUserController.renderCreate)
        protected.post(loginController.endpoints.createAdminPanelUser, use: adminPanelUserController.create)
        protected.get("/admin/users", AdminPanelUser.parameter, "edit", use: adminPanelUserController.renderEdit)
        protected.post("/admin/users", AdminPanelUser.parameter, "edit", use: adminPanelUserController.edit)
        protected.post("/admin/users", AdminPanelUser.parameter, "delete", use: adminPanelUserController.delete)

        // Reset routes
        let resetEndpoints = resetProvider.config.endpoints
        if let renderResetPasswordRequestPath = resetEndpoints.renderResetPasswordRequest {
            unprotected.get(
                renderResetPasswordRequestPath,
                use: resetProvider.renderResetPasswordRequestForm
            )
        }

        if let resetPasswordRequestPath = resetEndpoints.resetPasswordRequest {
            unprotected.post(
                resetPasswordRequestPath,
                use: resetProvider.resetPasswordRequest
            )
        }

        if let renderResetPasswordPath = resetEndpoints.renderResetPassword {
            unprotected.get(
                renderResetPasswordPath,
                String.parameter,
                use: resetProvider.renderResetPasswordForm
            )
        }

        if let resetPasswordPath = resetEndpoints.resetPassword {
            unprotected.post(
                resetPasswordPath,
                String.parameter,
                use: resetProvider.resetPassword
            )
        }
    }
}
