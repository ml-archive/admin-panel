import Fluent
import Sugar
import Vapor

public struct AdminPanelConfig<U: AdminPanelUserType>: Service {
    public struct ResetPasswordEmail {
        public let fromEmail: String
        public let subject: String

        public static var `default`: ResetPasswordEmail {
            return .init(
                fromEmail: "no-reply@myadminpanel.com",
                subject: "Reset Password"
            )
        }
    }

    public struct SpecifyPasswordEmail {
        public let fromEmail: String
        public let subject: String

        public static var `default`: SpecifyPasswordEmail {
            return .init(
                fromEmail: "no-reply@myadminpanel.com",
                subject: "Specify Password"
            )
        }
    }

    public let name: String
    public let baseUrl: String
    public let endpoints: AdminPanelEndpoints
    public let views: AdminPanelViews
    public let controllers: AdminPanelControllers<U>
    public let sidebarMenuPathGenerator: SidebarMenuPathGenerator<U.Role>
    public let dashboardPath: String?
    public let resetPasswordEmail: ResetPasswordEmail
    public let specifyPasswordEmail: SpecifyPasswordEmail
    public let newUserSetPasswordSigner: ExpireableJWTSigner

    public init(
        name: String,
        baseUrl: String,
        endpoints: AdminPanelEndpoints = .default,
        views: AdminPanelViews = .default,
        controllers: AdminPanelControllers<U> = .default,
        sidebarMenuPathGenerator: @escaping SidebarMenuPathGenerator<U.Role> = U.Role.sidebarMenuPathGenerator,
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
        self.sidebarMenuPathGenerator = sidebarMenuPathGenerator
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
