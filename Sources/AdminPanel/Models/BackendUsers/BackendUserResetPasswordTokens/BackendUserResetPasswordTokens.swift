import Vapor
import Fluent
import Foundation
import HTTP

public final class BackendUserResetPasswordTokens: Model {
 
    public var exists: Bool = false
    public static var entity = "backend_reset_password_tokens"
    
    public var id: Node?
    public var token: String
    public var email: String
    public var expireAt: Date
    public var usedAt: Date?
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(email: String) {
        self.email = email
        token = String.randomAlphaNumericString(64)
        expireAt = Date().addingTimeInterval(60 * 60) // 1h
        createdAt = Date()
        updatedAt = Date()
    }
    
    public init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        token = try node.extract("token")
        email = try node.extract("email")
        createdAt = try Date.parse("yyyy-MM-dd HH:mm:ss", node.extract("created_at"), Date())
        updatedAt = try Date.parse("yyyy-MM-dd HH:mm:ss", node.extract("updated_at"), Date())
        expireAt = try Date.parseOrFail(.dateTime, node.extract("expire_at"))
        
        if let usedAt: String = try node.extract("used_at") {
            self.usedAt = Date.parse(.dateTime, usedAt)
        }
    }
  
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "email": email,
            "token": token,
            "used_at": try usedAt?.toDateTimeString() ?? nil,
            "expire_at": try expireAt.toDateTimeString(),
            "created_at": try createdAt.toDateTimeString(),
            "updated_at": try updatedAt.toDateTimeString()
        ])
    }
    
    public func canBeUsed() -> Bool {
        if usedAt != nil {
            return false
        }
        
        if expireAt.isPast() {
            return false
        }
        
        return true
    }
    
    public static func prepare(_ database: Database) throws {
        try database.create("backend_reset_password_tokens") { table in
            table.id()
            table.string("email", unique: true)
            table.string("token")
            table.datetime("used_at", optional: true)
            table.datetime("expire_at", optional: true)
            table.timestamps()
        }
        
        try database.index(table: "backend_reset_password_tokens", column: "email")
        try database.index(table: "backend_reset_password_tokens", column: "token")
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete("backend_reset_password_tokens")
    }
}
