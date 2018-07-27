public struct AdminPanelViews {
    public static let prefix = "AdminPanel"

    public struct Login {
        public let index: String
        public let requestResetPassword: String
        public let resetPassword: String

        public init(
            index: String = prefix + "/Login/index",
            requestResetPassword: String = prefix + "/Login/request-reset-password",
            resetPassword: String = prefix + "/Login/reset-password"
        ) {
            self.index = index
            self.requestResetPassword = requestResetPassword
            self.resetPassword = resetPassword
        }
    }

    public struct Dashboard {
        public let index: String

        public init(index: String = prefix + "/Dashboard/index") {
            self.index = index
        }
    }

    public struct AdminPanelUser {
        public let index: String
        public let editAndCreate: String

        public init(
            index: String = prefix + "/AdminPanelUser/index",
            editAndCreate: String = prefix + "/AdminPanelUser/edit"
        ) {
            self.index = index
            self.editAndCreate = editAndCreate
        }
    }

    public struct Reset {
        public let requestResetPasswordEmail: String
        public let newUserResetPasswordEmail: String

        public init(
            requestResetPasswordEmail: String = prefix + "/Reset/request-reset-password-email",
            newUserResetPasswordEmail: String = prefix + "/Reset/new-user-reset-password-email"
        ) {
            self.requestResetPasswordEmail = requestResetPasswordEmail
            self.newUserResetPasswordEmail = newUserResetPasswordEmail
        }
    }

    public let login: Login
    public let dashboard: Dashboard
    public let adminPanelUser: AdminPanelUser
    public let reset: Reset

    public init(
        login: Login = Login(),
        dashboard: Dashboard = Dashboard(),
        adminPanelUser: AdminPanelUser = AdminPanelUser(),
        reset: Reset = Reset()
    ) {
        self.login = login
        self.dashboard = dashboard
        self.adminPanelUser = adminPanelUser
        self.reset = reset
    }

    public static var `default`: AdminPanelViews {
        return .init(
            login: .init(),
            dashboard: .init(),
            adminPanelUser: .init(),
            reset: .init()
        )
    }
}
