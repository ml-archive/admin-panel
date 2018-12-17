import Reset
import Sugar
import Vapor

extension AdminPanelUser: AdminPanelUserType {
    public typealias Role = AdminPanelUserRole

    public static let usernameKey: WritableKeyPath<AdminPanelUser, String> = \.email
    public static let passwordKey: WritableKeyPath<AdminPanelUser, String> = \.password

    public struct Login: SelfCreatable, HasReadablePassword, HasReadableUsername {
        public static let readablePasswordKey = \Login.password
        public static let readableUsernameKey = \Login.email

        public let email: String
        public let password: String
    }

    public struct Public: Content {
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

    public func didCreate(on req: Request) throws -> Future<Void> {
        struct ShouldSpecifyPassword: Decodable {
            let shouldSpecifyPassword: Bool?
        }

        guard
            try req.content.syncDecode(ShouldSpecifyPassword.self).shouldSpecifyPassword == true
        else {
            let config: ResetConfig<AdminPanelUser> = try req.make()
            return try config.reset(self, context: .newUserWithoutPassword, on: req)
        }

        return req.future()
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
        guard let role = AdminPanelUserRole(rawValue: description) else {
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
