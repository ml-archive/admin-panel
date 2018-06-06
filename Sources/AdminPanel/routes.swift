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
    public let renderAdminPanelUserList: String
    public let renderCreateAdminPanelUser: String
    public let createAdminPanelUser: String

    public init(
        login: String,
        logout: String,
        dashboard: String,
        renderAdminPanelUserList: String,
        renderCreateAdminPanelUser: String,
        createAdminPanelUser: String
    ) {
        self.login = login
        self.logout = logout
        self.dashboard = dashboard
        self.renderAdminPanelUserList = renderAdminPanelUserList
        self.renderCreateAdminPanelUser = renderCreateAdminPanelUser
        self.createAdminPanelUser = createAdminPanelUser
    }

    public static var `default`: AdminPanelEndpoints {
        let admin = "/admin"
        return .init(
            login: admin + "/login",
            logout: admin + "/logout",
            dashboard: admin + "/dashboard",
            renderAdminPanelUserList: admin + "/users",
            renderCreateAdminPanelUser: admin + "/users/create",
            createAdminPanelUser: admin + "/users/create"
        )
    }
}

public struct AdminPanelMiddlewares {
    public let unsecure: [Middleware]
    public let secure: [Middleware]
}

internal extension AdminPanelProvider {
    internal func routes(
        _ router: Router,
        middlewares: AdminPanelMiddlewares,
        endpoints: AdminPanelEndpoints,
        resetProvider: ResetProvider<U>
    ) throws {

        let unprotected = router.grouped(middlewares.unsecure)
        let protected = router.grouped(middlewares.secure)

        // MARK: Login routes

        let loginController = LoginController<U>(endpoints: endpoints)
        unprotected.get(endpoints.login, use: loginController.renderLogin)
        unprotected.post(endpoints.login, use: loginController.login)
        unprotected.get(endpoints.logout, use: loginController.logout)

        // MARK: Dashboard routes

        let dashboardController = DashboardController()
        protected.get(loginController.endpoints.dashboard, use: dashboardController.renderDashboard)

        // MARK: Admin Panel User routes
        let adminPanelUserController = AdminPanelUserController()
        protected.get(endpoints.renderAdminPanelUserList, use: adminPanelUserController.renderList)
        protected.get(endpoints.renderCreateAdminPanelUser, use: adminPanelUserController.renderCreate)
        protected.post(endpoints.createAdminPanelUser, use: adminPanelUserController.create)
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
