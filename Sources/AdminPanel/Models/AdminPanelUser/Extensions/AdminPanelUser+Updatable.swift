import Sugar

extension AdminPanelUser: Updatable {
    public func update(_ submission: Submission) throws {
        if let email = submission.email, !email.isEmpty {
            self.email = email
        }

        if let name = submission.name, !name.isEmpty {
            self.name = name
        }

        self.title = submission.title
        self.role = AdminPanelUserRole(rawValue: submission.role)

        if let password = submission.password, !password.isEmpty {
            self.password = try AdminPanelUser.hashPassword(password)
            self.shouldResetPassword = false
        }
    }
}
