import Fluent
import Vapor

public struct AdminPanelConfig<U: AdminPanelUserType>: Service {
    let name: String
    let baseUrl: String
    let endpoints: AdminPanelEndpoints
    let controllers: AdminPanelControllers<U>
    let userMenuPath: String?
    let adminMenuPath: String?
    let superAdminMenuPath: String?
    let dashboardPath: String?

    public init(
        name: String,
        baseUrl: String,
        endpoints: AdminPanelEndpoints = .default,
        controllers: AdminPanelControllers<U> = .default,
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

public struct AdminPanelControllers<U: AdminPanelUserType> {
    public let loginController: LoginControllerType
    public let dashboardController: DashboardControllerType
    public let adminPanelUserController: AdminPanelUserControllerType

    public init(
        loginController: LoginControllerType,
        dashboardController: DashboardControllerType,
        adminPanelUserController: AdminPanelUserControllerType
    ) {
        self.loginController = loginController
        self.dashboardController = dashboardController
        self.adminPanelUserController = adminPanelUserController
    }
}

extension AdminPanelControllers {
    public static var `default`: AdminPanelControllers {
        return .init(
            loginController: LoginController<U>(),
            dashboardController: DashboardController<U>(),
            adminPanelUserController: AdminPanelUserController<U>()
        )
    }
}
