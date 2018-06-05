import Fluent
import Vapor

public struct AdminPanelConfig: Service {
    let name: String
    let baseUrl: String
    let userMenuPath: String?
    let adminMenuPath: String?
    let superAdminMenuPath: String?
    let dashboardPath: String?

    public init(
        name: String,
        baseUrl: String,
        userMenuPath: String? = nil,
        adminMenuPath: String? = nil,
        superAdminMenuPath: String? = nil,
        dashboardPath: String? = nil
    ) {
        self.name = name
        self.baseUrl = baseUrl
        self.userMenuPath = userMenuPath
        self.adminMenuPath = adminMenuPath
        self.superAdminMenuPath = superAdminMenuPath
        self.dashboardPath = dashboardPath
    }
}
