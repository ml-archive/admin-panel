import Vapor
import Fluent
import Foundation
import HTTP
import Slugify
import FluentMySQL
import Sugar

public final class BackendUserRole: Model {
    public static var entity = "backend_user_roles"
    public var exists: Bool = false
    
    public var id: Node?
    public var title: String
    public var slug: String
    public var isDefault: Bool
    public var createdAt: Date
    public var updatedAt: Date
    
    
    /// Init
    ///
    /// - Parameters:
    ///   - node: Node
    ///   - context: Context
    /// - Throws: 
    public init(node: Node, in context: Context) throws {
        id = try? node.extract("id")
        title = try node.extract("title")
        slug = try node.extract("slug")
        isDefault = try node.extract("is_default") ?? false
        createdAt = try Date.parse("yyyy-MM-dd HH:mm:ss", node.extract("created_at"), Date())
        updatedAt = try Date.parse("yyyy-MM-dd HH:mm:ss", node.extract("updated_at"), Date())
    }
    
    public init(request: Request) throws {
        title = request.data["title"]?.string ?? ""
        slug = title.slugify()
        isDefault = try BackendUserRole.query().first() != nil ? false : true
        updatedAt = Date()
        createdAt = Date()
    }
    
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "title": title,
            "slug": slug,
            "is_default": isDefault,
            "created_at": try createdAt.toDateTimeString(),
            "updated_at": try updatedAt.toDateTimeString()
        ])
    }
 
    public static func prepare(_ database: Database) throws {
        try database.create("backend_user_roles") { table in
            table.id()
            table.varchar("title", length: 191);
            table.varchar("slug", length: 191, unique: true);
            table.bool("is_default");
            table.timestamps()
        }
        
        try database.index(table: "backend_user_roles", column: "slug")
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete("backend_user_roles")
    }
    
    
    /// Options, retrieve all entries as key/value for html select
    ///
    /// - Returns: key/value
    /// - Throws: Database error
    public static func options() throws -> [String: String] {
        var options: [String: String] = [:]
        
        for role in try self.all() {
            options[role.slug] = role.title
        }
        
        return options
    }
    
    
    /// Retrieve default role
    ///
    /// - Returns: Role
    /// - Throws: Error
    public static func defaultRole() throws -> BackendUserRole {
        guard let role: BackendUserRole =  try self.query().filter("is_default", true).first() else {
            throw Abort.custom(status: .internalServerError, message: "AdminPanel not default role")
        }
        
        return role
    }
}
