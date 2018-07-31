import Fluent
import Sugar
import Vapor

public struct AdminPanelConfig<U: AdminPanelUserType>: Service {
    public struct ResetPasswordEmail {
        let fromEmail: String
        let subject: String

        public static var `default`: ResetPasswordEmail {
            return .init(
                fromEmail: "no-reply@myadminpanel.com",
                subject: "Reset Password"
            )
        }
    }

    public struct SpecifyPasswordEmail {
        let fromEmail: String
        let subject: String

        public static var `default`: SpecifyPasswordEmail {
            return .init(
                fromEmail: "no-reply@myadminpanel.com",
                subject: "Specify Password"
            )
        }
    }

    let name: String
    let baseUrl: String
    let endpoints: AdminPanelEndpoints
    let views: AdminPanelViews
    let controllers: AdminPanelControllers<U>
    let userMenuPath: String?
    let adminMenuPath: String?
    let superAdminMenuPath: String?
    let dashboardPath: String?
    let resetPasswordEmail: ResetPasswordEmail
    let specifyPasswordEmail: SpecifyPasswordEmail
    let newUserSetPasswordSigner: ExpireableJWTSigner

    public init(
        name: String,
        baseUrl: String,
        endpoints: AdminPanelEndpoints = .default,
        views: AdminPanelViews = .default,
        controllers: AdminPanelControllers<U> = .default,
        userMenuPath: String? = nil,
        adminMenuPath: String? = nil,
        superAdminMenuPath: String? = nil,
        dashboardPath: String? = nil,
        resetPasswordEmail: ResetPasswordEmail = .default,
        specifyPasswordEmail: SpecifyPasswordEmail = .default,
        newUserSetPasswordSigner: ExpireableJWTSigner
    ) {
        self.name = name
        self.baseUrl = baseUrl
        self.endpoints = endpoints
        self.views = views
        self.controllers = controllers
        self.userMenuPath = userMenuPath
        self.adminMenuPath = adminMenuPath
        self.superAdminMenuPath = superAdminMenuPath
        self.dashboardPath = dashboardPath
        self.resetPasswordEmail = resetPasswordEmail
        self.specifyPasswordEmail = specifyPasswordEmail
        self.newUserSetPasswordSigner = newUserSetPasswordSigner
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
