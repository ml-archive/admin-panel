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
        public let avatarUrl: String?
    }

    public struct UserRegistration: HasReadablePassword, HasReadableUsername {
        public static let readablePasswordKey = \UserRegistration.password
        public static let readableUsernameKey = \UserRegistration.email

        public let email: String
        public let name: String
        public let title: String?
        public let avatarUrl: String?
        public let role: AdminPanelUserRole
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
            avatarUrl: registration.avatarUrl,
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
}

// MARK: Roles

public enum AdminPanelUserRole: String {
    case superAdmin
    case admin
    case user
    case unknown

    public var weight: UInt {
        switch self {
        case .superAdmin: return 3
        case .admin: return 2
        case .user: return 1
        case .unknown: return 0
        }
    }

    public typealias RawValue = String

    public init(rawValue: String?) {
        guard let rawValue = rawValue else { self = .unknown; return }

        switch rawValue {
            case AdminPanelUserRole.superAdmin.rawValue: self = .superAdmin
            case AdminPanelUserRole.admin.rawValue: self = .admin
            case AdminPanelUserRole.user.rawValue: self = .user
            default: self = .unknown
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
        case .unknown:
            return ""
        }
    }

    public init?(_ description: String) {
        self = AdminPanelUserRole.init(rawValue: description)
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
