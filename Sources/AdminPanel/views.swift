internal enum AdminPanelViews {
    static let prefix = "AdminPanel"

    enum Login {
        static let index = prefix + "/Login/index"
    }

    enum Dashboard {
        static let index = prefix + "/Dashboard/index"
    }

    enum AdminPanelUser {
        static let index = prefix + "/AdminPanelUser/index"
        static let create = prefix + "/AdminPanelUser/edit"
    }
}
