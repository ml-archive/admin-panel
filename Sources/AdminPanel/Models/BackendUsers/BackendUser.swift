import Vapor
import FluentProvider
import Foundation
import HTTP
import AuthProvider
import MySQLProvider
import Sugar

public final class BackendUser: Model, Timestampable, NodeConvertible, Preparation {
    public let storage = Storage()

    public var name: String
    public var email: String
    public var password: String
    public var role: String
    public var image: String?
    public var shouldResetPassword: Bool = false

    public var imageUrl: String {
        return Configuration.shared?.profileImageFallbackUrl ?? "http://dummyimage.com/250x250"
    }

    public init(row: Row) throws {
        name = try row.get("name")
        email = try row.get("email")
        password = try row.get("password")
        role = try row.get("role")
        image = try row.get("image")
        shouldResetPassword = try row.get("shouldResetPassword")
    }

    public init(node: Node) throws {
        name = try node.get("name")
        email = try node.get("email")
        password = try node.get("password")
        role = try node.get("role")
        shouldResetPassword = try node.get("shouldResetPassword") ?? false
        createdAt = Date()
        updatedAt = Date()
    }

    public init(credentials: Password) throws {
        self.name = ""
        self.email = credentials.username
        self.password = try BCryptHasher().make(credentials.password).makeString()
        self.role = ""
        self.updatedAt = Date()
        self.createdAt = Date()
    }

    public init(form: BackendUserForm, request: Request) throws {
        name = form.name
        email = form.email

        // Only super admins can update roles
        let rolesForUser = try Configuration.shared?.getRoleOptions(request.authedBackendUser().role) ?? [:]
        if rolesForUser[form.role] != nil {
            role = form.role
        } else {
            role = Configuration.shared?.defaultRole ?? "user"
        }

        password = try BCryptHasher().make(form.password).makeString()
        shouldResetPassword = form.shouldResetPassword

        self.updatedAt = Date()
        self.createdAt = Date()
    }

    public func makeRow() throws -> Row {
        var row = Row()

        try row.set("name", self.name)
        try row.set("email", self.email)
        try row.set("password", self.password)
        try row.set("role", self.role)
        try row.set("image", self.image)
        try row.set("shouldResetPassword", self.shouldResetPassword)

        return row
    }

    public func fill(form: BackendUserForm, request: Request) throws {
        name = form.name
        email = form.email

        // Only super admins can update roles
        let rolesForUser = try Configuration.shared?.getRoleOptions(request.authedBackendUser().role) ?? [:]
        if rolesForUser[form.role] != nil {
            role = form.role
        }

        shouldResetPassword = form.shouldResetPassword

        updatedAt = Date()

        if(!form.randomPassword) {
            try setPassword(form.password)
        }
    }

    public func setPassword(_ password: String) throws{
        self.password = try BCryptHasher().make(password).makeString()
    }

    public func toBackendView() throws -> Node {
        return try Node(node: [
            "id": id?.makeNode(in: nil) ?? Node.null,
            "name": name,
            "email": email,
            "password": password,
            "role": role,
            "shouldResetPassword": shouldResetPassword,
            "image": image ?? "",
            "imageUrl": imageUrl,
            ])
    }

    public func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "id": id?.makeNode(in: nil) ?? Node.null,
            "name": name,
            "email": email,
            "password": password,
            "role": role,
            "shouldResetPassword": shouldResetPassword,
            "image": image ?? "",
        ])
    }

    public static func prepare(_ database: Database) throws {
        try database.create(self) { table in
            table.id()
            table.varchar("name", length: 191)
            table.varchar("email", length: 191, unique: true)
            table.varchar("password", length: 191)
            table.varchar("role", length: 191)
            table.varchar("image", length: 191, optional: true)
            table.bool("shouldResetPassword", default: Node(false))
        }

        try database.index("email", for: self)
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: Authentication
extension BackendUser: PasswordAuthenticatable {

    public static let passwordVerifier: PasswordVerifier? = BackendUser.passwordHasher
    public var hashedPassword: String? {
        return password
    }
    public static let passwordHasher = BCryptHasher()

    /*
    public static func authenticate(credentials: Credentials) throws -> Auth.User {
        var user: User?

        switch credentials {
        case let credentials as Password:
            let fetchedUser = try BackendUser.makeQuery().filter("email", credentials.username).first()
            if let password = fetchedUser?.password, password != "", (try? BCryptHasher().verify(password: credentials.password, matches: password)) == true {
                user = fetchedUser
            }

        case let credentials as Identifier: user = try BackendUser.find(credentials.id)

        case let credentials as Auth.AccessToken:
            user = try BackendUser.query().filter("token", credentials.string).first()

        default:
            throw AuthenticationError.unsupportedCredentials
        }

        guard let unwrappedUser: Auth.User = user else {
            throw AuthenticationError.invalidCredentials
        }

        return unwrappedUser
    }
 */

    public static func register(credentials: Credentials) throws -> BackendUser {
        var newUser: BackendUser

        switch credentials {
        case let credentials as Password:
            newUser = try BackendUser(credentials: credentials)

        default: throw AuthenticationError.unsupportedCredentials
        }

        if try BackendUser.makeQuery().filter("email", newUser.email).first() == nil {
            try newUser.save()
            return newUser
        } else {
            throw AuthenticationError.notAuthenticated
        }

    }
}

extension BackendUser: SessionPersistable {}
