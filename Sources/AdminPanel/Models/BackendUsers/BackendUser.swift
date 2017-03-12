import Vapor
import Fluent
import Foundation
import HTTP
import Turnstile
import TurnstileCrypto
import Auth
import FluentMySQL
import Sugar

public final class BackendUser: Auth.User, Model {
    
    public var exists: Bool = false
    public static var entity = "backend_users"
    
    public var id: Node?
    public var name: String
    public var email: String
    public var password: String
    public var role: String
    public var image: String?
    public var createdAt: Date
    public var updatedAt: Date
    public var shouldResetPassword: Bool = false
    
    public var imageUrl: String {
        return Configuration.shared?.profileImageFallbackUrl ?? "http://dummyimage.com/250x250"
    }
    
    public init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        email = try node.extract("email")
        password = try node.extract("password")
        role = try node.extract("role")
        shouldResetPassword = try node.extract("should_reset_password") ?? false
        createdAt = try Date.parse("yyyy-MM-dd HH:mm:ss", node.extract("created_at"), Date())
        updatedAt = try Date.parse("yyyy-MM-dd HH:mm:ss", node.extract("updated_at"), Date())
    }
    
    public init(credentials: UsernamePassword) throws {
        self.name = ""
        self.email = credentials.username
        self.password = BCrypt.hash(password: credentials.password)
        self.role = ""
        self.updatedAt = Date()
        self.createdAt = Date()
    }
    
    public init(form: BackendUserForm){
        name = form.name
        email = form.email
        role = form.role
        password = BCrypt.hash(password: form.password)
        shouldResetPassword = form.shouldResetPassword
        
        self.updatedAt = Date()
        self.createdAt = Date()
    }
    
    public func fill(form: BackendUserForm, request: Request) {
        name = form.name
        email = form.email
        
        // Only super admins can update roles
        if Gate.allow(request, "super-admin") {
            role = form.role
        }
        
        updatedAt = Date()
        
        if(!form.randomPassword) {
            setPassword(form.password)
        }
    }
    
    public func setPassword(_ password: String) {
        self.password = BCrypt.hash(password: password)
    }
    
    public func toBackendView() throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "email": email,
            "password": password,
            "role": role,
            "should_reset_password": shouldResetPassword,
            "image": image,
            "imageUrl": imageUrl,
            "created_at": try createdAt.toDateTimeString(),
            "updated_at": try updatedAt.toDateTimeString()
            ])
    }
    
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "email": email,
            "password": password,
            "role": role,
            "should_reset_password": shouldResetPassword,
            "image": image,
            "created_at": try createdAt.toDateTimeString(),
            "updated_at": try updatedAt.toDateTimeString()
        ])
    }
    
    public static func prepare(_ database: Database) throws {
        try database.create("backend_users") { table in
            table.id()
            table.varchar("name", length: 191)
            table.varchar("email", length: 191, unique: true)
            table.varchar("password", length: 191)
            table.varchar("role", length: 191)
            table.varchar("image", length: 191, optional: true)
            table.bool("should_reset_password", default: Node(false))
            table.timestamps()
        }
        
        try database.index(table: "backend_users", column: "email")
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete("backend_users")
    }
}

// MARK: Authentication
extension BackendUser {
    @discardableResult
    
    public static func authenticate(credentials: Credentials) throws -> Auth.User {
        var user: User?
        
        switch credentials {
        case let credentials as UsernamePassword:
            let fetchedUser = try BackendUser.query().filter("email", credentials.username).first()
            if let password = fetchedUser?.password, password != "", (try? BCrypt.verify(password: credentials.password, matchesHash: password)) == true {
                user = fetchedUser
            }
            
        case let credentials as Identifier: user = try BackendUser.find(credentials.id)
            
        case let credentials as Auth.AccessToken:
            user = try BackendUser.query().filter("token", credentials.string).first()
            
        default:
            throw UnsupportedCredentialsError()
        }
        
        guard let unwrappedUser: Auth.User = user else {
            throw IncorrectCredentialsError()
        }
        
        return unwrappedUser
    }
    
    @discardableResult
    public static func register(credentials: Credentials) throws -> Auth.User {
        var newUser: BackendUser
        
        switch credentials {
        case let credentials as UsernamePassword:
            newUser = try BackendUser(credentials: credentials)
            
        default: throw UnsupportedCredentialsError()
        }
        
        if try BackendUser.query().filter("email", newUser.email).first() == nil {
            try newUser.save()
            return newUser
        } else {
            throw AccountTakenError()
        }
        
    }
}
