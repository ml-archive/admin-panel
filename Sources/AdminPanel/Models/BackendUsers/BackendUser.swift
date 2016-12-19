import Vapor
import Fluent
import Foundation
import HTTP
import Turnstile
import TurnstileCrypto
import SwiftDate
import Auth

public final class BackendUser: Auth.User, Model {
    
    public var exists: Bool = false
    public static var entity = "backend_users"
    
    public var id: Node?
    public var name: Valid<NotEmpty>
    public var email: Valid<Email>
    public var password: String
    public var role: String // TODO check
    public var createdAt: DateInRegion
    public var updatedAt: DateInRegion
    public var shouldResetPassword: Bool = false
    
    enum Error: Swift.Error {
        case userNotFound
        case registerNotSupported
        case unsupportedCredentials
    }
    
    public init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        
        let nameTemp: String = try node.extract("name")
        name = try nameTemp.validated()
        
        let emailTemp: String = try node.extract("email")
        email = try emailTemp.validated()
        
        password = try node.extract("password")
        
        role = try node.extract("role")
        
        shouldResetPassword = try node.extract("should_reset_password") ?? false
        
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
    
    public init(credentials: UsernamePassword) throws {
        self.name = try "N/A".validated()
        self.email = try credentials.username.validated()
        self.password = BCrypt.hash(password: credentials.password)
        self.role = ""
        self.updatedAt = DateInRegion()
        self.createdAt = DateInRegion()
    }
    
    public init(request: Request) throws {
        name = try (request.data["name"]?.string ?? "").validated()
        email = try request.data["email"].validated()
        
        // Random password if no password is set
        if let passwordString: String = request.data["password"]?.string {
            _ = try passwordString.validated(by: PasswordStrong())
            
            if(passwordString != "") {
                throw Abort.badRequest
            }
            password = BCrypt.hash(password: passwordString)
        } else {
            password = BCrypt.hash(password: String.randomAlphaNumericString())
        }
        
        role = request.data["role"]?.string ?? "user"
        
        
        if let shouldResetPasswordTemp: String = request.data["should_reset_password"]?.string {
            shouldResetPassword = shouldResetPasswordTemp == "true"
        }
        
        self.updatedAt = DateInRegion()
        self.createdAt = DateInRegion()
    }
    
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name.value,
            "email": email.value,
            "password": password,
            "role": role,
            "should_reset_password": shouldResetPassword,
            "created_at": createdAt.string(custom: "yyyy-MM-dd HH:mm:ss"),
            "updated_at": updatedAt.string(custom: "yyyy-MM-dd HH:mm:ss")
        ])
    }
    
    public static func prepare(_ database: Database) throws {
        try database.create("backend_users") { table in
            table.id()
            table.string("name")
            table.string("email", unique: true)
            table.string("password")
            table.string("role")
            table.bool("should_reset_password", default: Node(false))
            table.custom("created_at", type: "DATETIME", optional: true)
            table.custom("updated_at", type: "DATETIME", optional: true)
        }
        
        //try database.driver.raw("ADD FOREIGN TODO")
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
        
        if try BackendUser.query().filter("email", newUser.email.value).first() == nil {
            try newUser.save()
            return newUser
        } else {
            throw AccountTakenError()
        }
        
    }
}
