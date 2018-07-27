import Reset
import Sugar
import Vapor

extension AdminPanelUser: AdminPanelUserType {
    public typealias Login = UserLogin
    public typealias Registration = UserRegistration
    public typealias Update = UserUpdate
    public typealias Public = UserPublic

    public static let usernameKey: WritableKeyPath<AdminPanelUser, String> = \.email
    public static let passwordKey: WritableKeyPath<AdminPanelUser, String> = \.password

    public struct UserLogin: HasReadablePassword, HasReadableUsername {
        public static let readablePasswordKey = \UserLogin.password
        public static let readableUsernameKey = \UserLogin.email

        public let email: String
        public let password: String
    }

    public struct UserPublic: Content {
        public let email: String
        public let name: String
        public let title: String?
        public let avatarUrl: String?
    }

    public struct UserRegistration: HasReadablePassword, HasReadableUsername {
        public static let readablePasswordKey = \UserRegistration.password
        public static let readableUsernameKey = \UserRegistration.email

        public let email: String
        public let name: String
        public let title: String?
        public let avatarUrl: String?
        public let password: String
        public let passwordRepeat: String
        public let shouldResetPassword: Bool?
    }

    public struct UserUpdate: Decodable, HasUpdatableUsername, HasUpdatablePassword {
        public static let oldPasswordKey = \UserUpdate.oldPassword
        public static let updatablePasswordKey = \UserUpdate.password
        public static let updatableUsernameKey = \UserUpdate.email

        public let email: String?
        public let name: String?
        public let title: String?
        public let avatarUrl: String?
        public let password: String?
        public let oldPassword: String?
        public let passwordRepeat: String?
        public let shouldResetPassword: Bool?
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

    public func didCreate(with submission: Submission, on req: Request) throws -> Future<Void> {
        guard submission.shouldSpecifyPassword == true else {
            let config: ResetConfig<AdminPanelUser> = try req.make()
            return try config.reset(
                self,
                context: AdminPanelResetPasswordContext.newUserWithoutPassword,
                on: req
            )
        }

        return Future.transform(to: (), on: req)
    }
}
