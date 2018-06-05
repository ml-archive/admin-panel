import Sugar
import Vapor

extension AdminPanelUser: AdminPanelUserType {
    public typealias Login = UserLogin
    public typealias Registration = UserRegistration
    public typealias Update = UserUpdate
    public typealias Public = UserPublic

    public static var usernameKey: WritableKeyPath<AdminPanelUser, String> {
        return \.email
    }

    public static var passwordKey: WritableKeyPath<AdminPanelUser, String> {
        return \.password
    }

    public struct UserLogin: HasReadablePassword, HasReadableUser {
        public let email: String
        public let password: String

        public var username: String {
            return email
        }
    }

    public struct UserPublic: Content {
        public let email: String
        public let name: String
        public let title: String?
        public let avatarUrl: String?
    }

    public struct UserRegistration: HasReadablePassword, HasReadableUser {
        public let email: String
        public let name: String
        public let title: String?
        public let avatarUrl: String?
        public let password: String
        public let passwordRepeat: String
        public let shouldResetPassword: Bool?

        public var username: String {
            return email
        }
    }

    public struct UserUpdate: Decodable, HasUpdatableUsername, HasUpdatablePassword {
        public let email: String?
        public let name: String?
        public let title: String?
        public let avatarUrl: String?
        public let password: String?
        public let oldPassword: String?
        public let passwordRepeat: String?
        public let shouldResetPassword: Bool?

        public var username: String? {
            return email
        }
    }

    public func convertToPublic() -> UserPublic {
        return UserPublic(
            email: email,
            name: name,
            title: title,
            avatarUrl: avatarUrl
        )
    }

    // Registration is handled by Submittable (see AdminPanelUser+Submittable).
    public convenience init(_ registration: UserRegistration) throws {
        try self.init(
            email: registration.email,
            name: registration.name,
            title: registration.title,
            avatarUrl: registration.avatarUrl,
            password: AdminPanelUser.hashPassword(registration.password)
        )
    }

    // Update is handled by Submittable (see AdminPanelUser+Submittable).
    public func update(with updated: UserUpdate) throws {}
}
