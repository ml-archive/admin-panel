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
    public let adminPanelUserBasePath: String

    public let createSlug: String
    public let deleteSlug: String
    public let editSlug: String
    public let meSlug: String

    public init(
        adminPanelUserBasePath: String = "/admin/users",
        dashboard: String = "/admin",
        login: String = "/admin/login",
        logout: String = "/admin/logout",

        createSlug: String = "create",
        deleteSlug: String = "delete",
        editSlug: String = "edit",
        meSlug: String = "me"
    ) {
        self.login = login
        self.logout = logout
        self.dashboard = dashboard
        self.adminPanelUserBasePath = adminPanelUserBasePath

        self.createSlug = createSlug
        self.deleteSlug = deleteSlug
        self.editSlug = editSlug
        self.meSlug = meSlug
    }

    public static var `default`: AdminPanelEndpoints {
        return .init()
    }
}

public struct AdminPanelMiddlewares: Service {
    public let secure: [Middleware]
    public let unsecure: [Middleware]
}

public extension Router {
    func useAdminPanelRoutes<U: AdminPanelUserType>(
        _ type: U.Type,
        on container: Container
    ) throws {
        let config: AdminPanelConfig<U> = try container.make()
        let middlewares: AdminPanelMiddlewares = try container.make()

        let unprotected = grouped(middlewares.unsecure)
        let protected = grouped(middlewares.secure)

        let endpoints = config.endpoints
        let controllers = config.controllers

        // MARK: Login routes

        unprotected.get(endpoints.login, use: controllers.loginController.renderLogin)
        unprotected.post(endpoints.login, use: controllers.loginController.login)
        unprotected.get(endpoints.logout, use: controllers.loginController.logout)

        // MARK: Dashboard routes

        protected.get(
            endpoints.dashboard,
            use: controllers.dashboardController.renderDashboard
        )

        // MARK: Admin Panel User routes

        protected.get(
            endpoints.adminPanelUserBasePath,
            use: controllers.adminPanelUserController.renderList
        )
        protected.get(
            endpoints.adminPanelUserBasePath,
            endpoints.createSlug,
            use: controllers.adminPanelUserController.renderCreate
        )
        protected.post(
            endpoints.adminPanelUserBasePath,
            endpoints.createSlug,
            use: controllers.adminPanelUserController.create
        )
        protected.get(
            endpoints.adminPanelUserBasePath,
            U.parameter,
            endpoints.editSlug,
            use: controllers.adminPanelUserController.renderEditUser
        )
        protected.post(
            endpoints.adminPanelUserBasePath,
            U.parameter,
            endpoints.editSlug,
            use: controllers.adminPanelUserController.editUser
        )
        protected.post(
            endpoints.adminPanelUserBasePath,
            U.parameter,
            endpoints.deleteSlug,
            use: controllers.adminPanelUserController.delete
        )
        protected.get(
            endpoints.adminPanelUserBasePath,
            endpoints.meSlug,
            endpoints.editSlug,
            use: controllers.adminPanelUserController.renderEditMe
        )
        protected.post(
            endpoints.adminPanelUserBasePath,
            endpoints.meSlug,
            endpoints.editSlug,
            use: controllers.adminPanelUserController.editMe
        )

        // MARK: Reset routes

        try unprotected.useResetRoutes(type, on: container)
    }
}
