import Vapor
import FluentProvider
import Foundation
import HTTP
import MySQLProvider

public final class BackendUserResetPasswordTokens: Model, Timestampable, Preparation {
    public let storage = Storage()

    public static var entity = "backend_reset_password_tokens"
    public var token: String
    public var email: String
    public var expireAt: Date
    public var usedAt: Date?

    public init(row: Row) throws{
        self.token = try row.get("token")
        self.email = try row.get("email")
        self.expireAt = try row.get("expireAt")
        self.usedAt = try row.get("usedAt")
    }

    public init(email: String) {
        self.email = email
        token = String.randomAlphaNumericString(64)
        expireAt = Date().addingTimeInterval(60 * 60) // 1h
        createdAt = Date()
        updatedAt = Date()
    }

    public func makeRow() throws -> Row {
        var row = Row()

        try row.set("token", self.token)
        try row.set("email", self.email)
        try row.set("expireAt", self.expireAt)
        try row.set("usedAt", self.usedAt)

        return row
    }

    public func canBeUsed() -> Bool {
        if usedAt != nil {
            return false
        }

        if expireAt.isFuture() {
            return false
        }
        
        return true
    }
    
    public static func prepare(_ database: Database) throws {
        try database.create(self) { table in
            table.id()
            table.varchar("email", length: 191, unique: true)
            table.varchar("token", length: 191)
            table.datetime("used_at", optional: true)
            table.datetime("expire_at", optional: true)
        }
        
        try database.index(table: "backend_reset_password_tokens", column: "email")
        try database.index(table: "backend_reset_password_tokens", column: "token")
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
