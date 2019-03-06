import Sugar

extension AdminPanelUser: Loginable {
    public struct Login: Decodable, HasReadablePassword, HasReadableUsername {
        public static let readablePasswordKey = \Login.password
        public static let readableUsernameKey = \Login.email

        public let email: String
        public let password: String
    }
}
