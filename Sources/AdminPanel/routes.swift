import Authentication
import Flash
import Reset
import Routing
import Sugar
import Vapor

public struct AdminPanelEndpoints {
    public let login: String
    public let logout: String
    public let dashboard: String
    public let renderAdminPanelUserList: String
    public let renderCreateAdminPanelUser: String
    public let createAdminPanelUser: String
    public let renderEditMe: String

    public init(
        login: String = "/admin/login",
        logout: String = "/admin/logout",
        dashboard: String = "/admin",
        renderAdminPanelUserList: String = "/admin/users",
        renderCreateAdminPanelUser: String = "/admin/users/create",
        createAdminPanelUser: String = "/admin/users/create",
        renderEditMe: String = "/admin/users/me/edit"
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
        return .init()
    }
}

public struct AdminPanelMiddlewares: Service {
    public let unsecure: [Middleware]
    public let secure: [Middleware]
}

public extension Router {
    public func useAdminPanelRoutes<U: AdminPanelUserType>(
        _ type: U.Type,
        on container: Container
    ) throws {
        let config: AdminPanelConfig<U> = try container.make()
        let middlewares: AdminPanelMiddlewares = try container.make()

        let unprotected = self.grouped(middlewares.unsecure)
        let protected = self.grouped(middlewares.secure)

        // MARK: Login routes

        unprotected.get(config.endpoints.login, use: config.controllers.loginController.renderLogin)
        unprotected.post(config.endpoints.login, use: config.controllers.loginController.login)
        unprotected.get(config.endpoints.logout, use: config.controllers.loginController.logout)

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

        // MARK: Reset routes

        try unprotected.useResetRoutes(type, on: container)
    }
}
