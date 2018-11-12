import Reset
import Sugar
import Vapor

extension AdminPanelUser: AdminPanelUserType {
    public typealias Login = UserLogin
    public typealias Registration = UserRegistration
    public typealias Update = UserUpdate
    public typealias Public = UserPublic
    public typealias Role = AdminPanelUserRole

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
        public let avatarURL: String?

        public init(email: String, name: String, title: String? = nil, avatarURL: String? = nil) {
            self.email = email
            self.name = name
            self.title = title
            self.avatarURL = avatarURL
        }
    }

    public struct UserRegistration: HasReadablePassword, HasReadableUsername {
        public static let readablePasswordKey = \UserRegistration.password
        public static let readableUsernameKey = \UserRegistration.email

        public let email: String
        public let name: String
        public let title: String?
        public let avatarURL: String?
        public let role: AdminPanelUserRole?
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
        public let avatarURL: String?
        public let role: AdminPanelUserRole?
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
            avatarURL: registration.avatarURL,
            role: registration.role,
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

    // MARK: TemplateDataRepresentable

    public func convertToTemplateData() throws -> TemplateData {
        return .dictionary([
            "id": id.map(TemplateData.int) ?? .null,
            "email": .string(email),
            "name": .string(name),
            "title": title.map(TemplateData.string) ?? .null,
            "avatarURL": avatarURL.map(TemplateData.string) ?? .null,
            "role": role.map { .string($0.description) } ?? .null
        ])
    }
}

// MARK: Roles

public enum AdminPanelUserRole: String {
    case superAdmin
    case admin
    case user

    public var weight: UInt {
        switch self {
        case .superAdmin: return 3
        case .admin: return 2
        case .user: return 1
        }
    }

    public typealias RawValue = String

    public init?(rawValue: String?) {
        switch rawValue {
        case AdminPanelUserRole.superAdmin.rawValue: self = .superAdmin
        case AdminPanelUserRole.admin.rawValue: self = .admin
        case AdminPanelUserRole.user.rawValue: self = .user
        default: return nil
        }
    }
}

extension AdminPanelUserRole: ReflectionDecodable {
    public static func reflectDecoded() throws -> (AdminPanelUserRole, AdminPanelUserRole) {
        return (.superAdmin, .admin)
    }
}

extension AdminPanelUserRole: AdminPanelUserRoleType {
    public var menuPath: String {
        switch self {
        case .superAdmin:
            return "AdminPanel/Layout/Partials/Sidebars/superadmin"
        case .admin:
            return "AdminPanel/Layout/Partials/Sidebars/admin"
        case .user:
            return "AdminPanel/Layout/Partials/Sidebars/user"
        }
    }

    public init?(_ description: String) {
        guard let role = AdminPanelUserRole.init(rawValue: description) else {
            return nil
        }

        self = role
    }

    public var description: String {
        return self.rawValue
    }

    public static func < (lhs: AdminPanelUserRole, rhs: AdminPanelUserRole) -> Bool {
        return lhs.weight < rhs.weight
    }

    public static func == (lhs: AdminPanelUserRole, rhs: AdminPanelUserRole) -> Bool {
        return lhs.weight == rhs.weight
    }
}
