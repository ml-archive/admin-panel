import Fluent
import Sugar
import Authentication

public final class User: Codable {
    //public static let bCryptCost = 4

    public var id: Int?
    public var email: String
    public var password: String//HashedPassword
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
    ) throws {
        self.id = id
        self.email = email
        self.password = password //try User.hashPassword(password)
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

extension User {
    struct Login {
        public let email: String
        public let password: String
    }
}

extension User: PasswordAuthenticatable {
    public static var usernameKey: WritableKeyPath<User, String> {
        return \.email
    }

    public static var passwordKey: WritableKeyPath<User, String> {
        return \.password
    }
}
