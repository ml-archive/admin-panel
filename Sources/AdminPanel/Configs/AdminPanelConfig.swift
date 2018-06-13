import Fluent
import Vapor

public struct AdminPanelConfig: Service {
    let name: String
    let baseUrl: String
    let endpoints: AdminPanelEndpoints
    let controllers: AdminPanelControllers
    let userMenuPath: String?
    let adminMenuPath: String?
    let superAdminMenuPath: String?
    let dashboardPath: String?

    public init(
        name: String,
        baseUrl: String,
        endpoints: AdminPanelEndpoints = AdminPanelEndpoints.default,
        controllers: AdminPanelControllers = .default,
        userMenuPath: String? = nil,
        adminMenuPath: String? = nil,
        superAdminMenuPath: String? = nil,
        dashboardPath: String? = nil
    ) {
        self.name = name
        self.baseUrl = baseUrl
        self.endpoints = endpoints
        self.controllers = controllers
        self.userMenuPath = userMenuPath
        self.adminMenuPath = adminMenuPath
        self.superAdminMenuPath = superAdminMenuPath
        self.dashboardPath = dashboardPath
    }
}

public struct AdminPanelControllers {
    public let loginController: LoginControllerType
    public let dashboardController: DashboardControllerType
    public let adminPanelUserController: AdminPanelUserControllerType
}

extension AdminPanelControllers {
    public static var `default`: AdminPanelControllers {
        return .init(
            loginController: LoginController<AdminPanelUser>(),
            dashboardController: DashboardController(),
            adminPanelUserController: AdminPanelUserController<AdminPanelUser>()
        )
    }
}
