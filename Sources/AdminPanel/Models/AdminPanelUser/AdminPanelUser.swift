import FluentMySQL
import MySQL
import Vapor

public final class AdminPanelUser: Codable {
    public var id: Int?
    public var email: String
    public var name: String
    public var title: String?
    public var avatarURL: String?
    public var role: AdminPanelUserRole?
    public var password: String
    public var passwordChangeCount: Int
    public var shouldResetPassword: Bool

    public var createdAt: Date?
    public var deletedAt: Date?
    public var updatedAt: Date?

    public init(
        id: Int? = nil,
        email: String,
        name: String,
        title: String? = nil,
        avatarURL: String? = nil,
        role: AdminPanelUserRole?,
        password: String,
        passwordChangeCount: Int = 0,
        shouldResetPassword: Bool = false
    ) throws {
        self.id = id
        self.email = email
        self.name = name
        self.title = title
        self.avatarURL = avatarURL
        self.role = role
        self.password = password
        self.passwordChangeCount = passwordChangeCount
        self.shouldResetPassword = shouldResetPassword
    }
}

extension AdminPanelUser: Content {}
extension AdminPanelUser: Migration {
    public static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(self, on: connection) { builder in
            try addProperties(to: builder, excluding: [
                AdminPanelUser.reflectProperty(forKey: \.role)
            ])

            builder.field(
                for: \.role,
                type: .enum([
                    AdminPanelUserRole.superAdmin.rawValue,
                    AdminPanelUserRole.admin.rawValue,
                    AdminPanelUserRole.user.rawValue
                ]))
        }
    }
}
extension AdminPanelUser: MySQLModel {
    public static let createdAtKey: TimestampKey? = \.createdAt
    public static let updatedAtKey: TimestampKey? = \.updatedAt
    public static let deletedAtKey: TimestampKey? = \.deletedAt
}
extension AdminPanelUser: Parameter {}
