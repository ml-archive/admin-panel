import Vapor
import Fluent
import Foundation
import HTTP
import Turnstile
import TurnstileCrypto
import Auth
//import Storage

public final class BackendUser: Auth.User, Model {
    
    public var exists: Bool = false
    public static var entity = "backend_users"
    
    public var id: Node?
    public var name: Valid<NotEmpty>
    public var email: Valid<Email>
    public var password: String
    public var role: String // TODO check
    public var image: String?
    public var createdAt: Date
    public var updatedAt: Date
    public var shouldResetPassword: Bool = false
    
    public var imageUrl: String {
        return Configuration.shared?.profileImageFallbackUrl ?? "http://dummyimage.com/250x250"
    }
    
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
        
        
        createdAt = try Date.parse("yyyy-MM-dd HH:mm:ss", node.extract("created_at"))
        updatedAt = try Date.parse("yyyy-MM-dd HH:mm:ss", node.extract("updated_at"))
    }
    
    public init(credentials: UsernamePassword) throws {
        self.name = try "N/A".validated()
        self.email = try credentials.username.validated()
        self.password = BCrypt.hash(password: credentials.password)
        self.role = ""
        self.updatedAt = Date()
        self.createdAt = Date()
    }
    
    public init(request: Request, password: String) throws {
        name = try (request.data["name"]?.string ?? "").validated()
        email = try request.data["email"].validated()
        
        _ = try password.validated(by: PasswordStrong())
        self.password = BCrypt.hash(password: password)
        
        role = request.data["role"]?.string ?? "user"
        
        if let shouldResetPasswordTemp: String = request.data["should_reset_password"]?.string {
            shouldResetPassword = shouldResetPasswordTemp == "true"
        }
        
        /*
        if let file: Multipart.File = request.multipart?["image"]?.file {
            do {
                //image = try Storage.upload(bytes: file.data)
            } catch {
                print(error)
            }
        }
         */
        
        self.updatedAt = Date()
        self.createdAt = Date()
    }
    
    public func setPassword(_ password: String) throws {
        self.password = BCrypt.hash(password: password)
    }
    
    public func toBackendView() throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name.value,
            "email": email.value,
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
            "name": name.value,
            "email": email.value,
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
            table.string("name")
            table.string("email", unique: true)
            table.string("password")
            table.string("role")
            table.string("image", optional: true)
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
