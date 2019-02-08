import Sugar

extension AdminPanelUser: Creatable {
    public struct Create: Decodable, HasReadablePassword, HasReadableUsername {
        public static let readablePasswordKey = \Create.password
        public static var readableUsernameKey = \Create.email

        let email: String
        let name: String
        let title: String?
        let role: String?
        let password: String
        let shouldResetPassword: Bool?
        let shouldSpecifyPassword: Bool?
    }

    public convenience init(_ create: Create) throws {
        let password: String
        if create.shouldSpecifyPassword == true {
            password = create.password
        } else {
            password = String.randomAlphaNumericString(12)
        }

        try self.init(
            email: create.email,
            name: create.name,
            title: create.title,
            role: AdminPanelUserRole(rawValue: create.role),
            password: AdminPanelUser.hashPassword(password),
            shouldResetPassword: create.shouldResetPassword ?? false
        )
    }
}
