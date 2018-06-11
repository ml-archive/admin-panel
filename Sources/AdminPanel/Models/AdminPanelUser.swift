import FluentMySQL
import Vapor

public final class AdminPanelUser: Codable {
    public var id: Int?
    public var email: String
    public var name: String
    public var title: String?
    public var avatarUrl: String?
    public var password: String
    public var passwordChangeCount: Int

    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?

    public init(
        id: Int? = nil,
        email: String,
        name: String,
        title: String? = nil,
        avatarUrl: String? = nil,
        password: String,
        passwordChangeCount: Int = 0
    ) throws {
        self.id = id
        self.email = email
        self.name = name
        self.title = title
        self.avatarUrl = avatarUrl
        self.password = password
        self.passwordChangeCount = passwordChangeCount
    }
}

extension AdminPanelUser: MySQLModel {}
extension AdminPanelUser: Content {}
extension AdminPanelUser: Migration {}
extension AdminPanelUser: Parameter {}
extension AdminPanelUser: Timestampable {
    public static let createdAtKey: WritableKeyPath<AdminPanelUser, Date?> = \AdminPanelUser.createdAt
    public static let updatedAtKey: WritableKeyPath<AdminPanelUser, Date?> = \AdminPanelUser.updatedAt
}
extension AdminPanelUser: SoftDeletable {
    public static let deletedAtKey: WritableKeyPath<AdminPanelUser, Date?> = \AdminPanelUser.deletedAt
}
