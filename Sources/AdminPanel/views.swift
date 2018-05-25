internal enum AdminPanelViews {
    static let prefix = "AdminPanel"

    enum Login {
        static let index = prefix + "/Login/index"
        static let requestResetPassword = prefix + "/Login/request-reset-password"
        static let resetPassword = prefix + "/Login/reset-password"
    }

    enum Dashboard {
        static let index = prefix + "/Dashboard/index"
    }

    enum AdminPanelUser {
        static let index = prefix + "/AdminPanelUser/index"
        static let create = prefix + "/AdminPanelUser/edit"
    }
}
