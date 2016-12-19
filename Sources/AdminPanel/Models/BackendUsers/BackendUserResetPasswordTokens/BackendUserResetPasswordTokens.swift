import Vapor
import Fluent
import Foundation
import HTTP
import SwiftDate

public final class BackendUserResetPasswordTokens: Model {
 
    public var exists: Bool = false
    public static var entity = "backend_reset_password_tokens"
    
    public var id: Node?
    public var token: String
    public var email: Valid<Email>
    public var expireAt: DateInRegion
    public var usedAt: DateInRegion?
    public var createdAt: DateInRegion
    public var updatedAt: DateInRegion
    
    public init(email: String) throws {
        self.email = try email.validated()
        token = BackendUserResetPasswordTokens.randomAlphaNumericString(length: 64)
        expireAt = DateInRegion() + 1.hour
        createdAt = DateInRegion()
        updatedAt = DateInRegion()
    }
    
    static func randomAlphaNumericString(length: Int) -> String {
        
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in 0..<length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
    
    public init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        token = try node.extract("token")
        let emailTemp: String = try node.extract("email")
        email = try emailTemp.validated()
        
        do {
            usedAt = try DateInRegion(string: node.extract("used_at"), format: .custom("yyyy-MM-dd HH:mm:ss"))
        } catch {
            usedAt = nil
        }
        
        do {
            expireAt = try DateInRegion(string: node.extract("expire_at"), format: .custom("yyyy-MM-dd HH:mm:ss"))
        } catch {
            expireAt = DateInRegion()
        }
        
        do {
            createdAt = try DateInRegion(string: node.extract("created_at"), format: .custom("yyyy-MM-dd HH:mm:ss"))
        } catch {
            createdAt = DateInRegion()
        }
        
        do {
            updatedAt = try DateInRegion(string: node.extract("updated_at"), format: .custom("yyyy-MM-dd HH:mm:ss"))
        } catch {
            updatedAt = DateInRegion()
        }
    }
  
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "email": email.value,
            "token": token,
            "used_at": usedAt?.string(custom: "yyyy-MM-dd HH:mm:ss") ?? nil,
            "expire_at": expireAt.string(custom: "yyyy-MM-dd HH:mm:ss"),
            "created_at": createdAt.string(custom: "yyyy-MM-dd HH:mm:ss"),
            "updated_at": updatedAt.string(custom: "yyyy-MM-dd HH:mm:ss")
        ])
    }
    
    public static func prepare(_ database: Database) throws {
        try database.create("backend_reset_password_tokens") { table in
            table.id()
            table.string("email", unique: true)
            table.string("token")
            table.custom("used_at", type: "DATETIME", optional: true)
            table.custom("expire_at", type: "DATETIME", optional: true)
            table.custom("created_at", type: "DATETIME", optional: true)
            table.custom("updated_at", type: "DATETIME", optional: true)
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete("backend_reset_password_tokens")
    }
}
