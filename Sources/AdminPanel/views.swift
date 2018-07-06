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

    public let login: Login
    public let dashboard: Dashboard
    public let adminPanelUser: AdminPanelUser

    public init(
        login: Login = Login(),
        dashboard: Dashboard = Dashboard(),
        adminPanelUser: AdminPanelUser = AdminPanelUser()
    ) {
        self.login = login
        self.dashboard = dashboard
        self.adminPanelUser = adminPanelUser
    }

    public static var `default`: AdminPanelViews {
        return .init(
            login: .init(),
            dashboard: .init(),
            adminPanelUser: .init()
        )
    }
}
