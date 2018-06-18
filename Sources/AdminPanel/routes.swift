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
    public let renderEditMe: String

    public init(
        login: String,
        logout: String,
        dashboard: String,
        renderAdminPanelUserList: String,
        renderCreateAdminPanelUser: String,
        createAdminPanelUser: String,
        renderEditMe: String
    ) {
        self.login = login
        self.logout = logout
        self.dashboard = dashboard
        self.renderAdminPanelUserList = renderAdminPanelUserList
        self.renderCreateAdminPanelUser = renderCreateAdminPanelUser
        self.createAdminPanelUser = createAdminPanelUser
        self.renderEditMe = renderEditMe
    }

    public static var `default`: AdminPanelEndpoints {
        let admin = "/admin"
        return .init(
            login: admin + "/login",
            logout: admin + "/logout",
            dashboard: admin + "/dashboard",
            renderAdminPanelUserList: admin + "/users",
            renderCreateAdminPanelUser: admin + "/users/create",
            createAdminPanelUser: admin + "/users/create",
            renderEditMe: admin + "/users/me/edit"
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
        resetProvider: ResetProvider<U>,
        config: AdminPanelConfig<U>
    ) throws {

        let unprotected = router.grouped(middlewares.unsecure)
        let protected = router.grouped(middlewares.secure)

        // MARK: Login routes

        unprotected.get(endpoints.login, use: config.controllers.loginController.renderLogin)
        unprotected.post(endpoints.login, use: config.controllers.loginController.login)
        unprotected.get(endpoints.logout, use: config.controllers.loginController.logout)

        // MARK: Dashboard routes

        protected.get(
            config.endpoints.dashboard,
            use: config.controllers.dashboardController.renderDashboard
        )

        // MARK: Admin Panel User routes

        protected.get(
            config.endpoints.renderAdminPanelUserList,
            use: config.controllers.adminPanelUserController.renderList
        )
        protected.get(
            config.endpoints.renderCreateAdminPanelUser,
            use: config.controllers.adminPanelUserController.renderCreate
        )
        protected.post(
            config.endpoints.createAdminPanelUser,
            use: config.controllers.adminPanelUserController.create
        )
        protected.get(
            "/admin/users",
            U.parameter,
            "edit",
            use: config.controllers.adminPanelUserController.renderEditUser
        )
        protected.post(
            "/admin/users",
            U.parameter,
            "edit",
            use: config.controllers.adminPanelUserController.editUser
        )
        protected.post(
            "/admin/users",
            U.parameter,
            "delete",
            use: config.controllers.adminPanelUserController.delete
        )
        protected.get(
            "/admin/users/me/edit",
            use: config.controllers.adminPanelUserController.renderEditMe
        )
        protected.post(
            "/admin/users/me/edit",
            use: config.controllers.adminPanelUserController.editMe
        )

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
