import Fluent

public final class User: Codable {
    public var id: Int?
    public var email: String
    public var password: String
    public var name: String
    public var title: String?
    public var avatarUrl: String?

    public init(
        id: Int? = nil,
        email: String,
        password: String,
        name: String,
        title: String? = nil,
        avatarUrl: String? = nil
    ) {
        self.id = id
        self.email = email
        self.password = password
        self.name = name
        self.title = title
        self.avatarUrl = avatarUrl
    }
}

import FluentMySQL
extension User: MySQLModel {}
extension User: Migration {}

import Vapor
extension User: Content {}
extension User: Parameter {}
