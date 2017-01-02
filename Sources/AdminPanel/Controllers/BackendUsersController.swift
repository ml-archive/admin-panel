import Vapor
import VaporForms
import HTTP
import Fluent

struct UserForm: Form {
    let name: String
    let email: String
    let role: String
    
    static let fieldset = Fieldset([
        "name": StringField(
            label: "Name"
        ),
        "email": StringField(
            label: "Email",

            String.EmailValidator()
        ),
        "role": StringField(
            label: "Role"
        ),
    ], requiring: ["name", "email", "role"])
    
    init(validatedData: [String: Node]) throws {
        print("Inside UserForm validate date")
        
        name = validatedData["name"]!.string!
        email = validatedData["email"]!.string!
        role = validatedData["role"]!.string!
    }
}

public final class BackendUsersController {
    
    public let drop: Droplet
    
    public init(droplet: Droplet) {
        drop = droplet
    }
    
    public func logout(request: Request) throws -> ResponseRepresentable {
        try request.auth.logout()
        return Response(redirect: "/admin").flash(.error, "User is logged out")
    }
    
    /**
     * List all backend users
     *
     * - param: Request
     * - return: View
     */
    public func index(request: Request) throws -> ResponseRepresentable {
        try BackendUser.query().limit = Fluent.Limit(count: 20)
        let users = try BackendUser.all() // todo pagination && search
        
        return try drop.view.make("BackendUsers/index", [
            "users": try users.makeNode()
        ], for: request)
    }

    /**
     * Create user form
     *
     * - param: Request
     * - return: View
     */
    public func create(request: Request) throws -> ResponseRepresentable {
        
        var fieldSet: Node = try UserForm.fieldset.makeNode()
        if let fieldSet2: Node = request.storage["_fieldset"] as? Node {
            fieldSet = fieldSet2
        }
        
        return try drop.view.make("BackendUsers/edit", [
            "roles": BackendUserRole.all().makeNode(),
            "fieldset": fieldSet
        ], for: request)
    }
    
    /**
     * Save new user
     *
     * - param: Request
     * - return: View
     */
    public func store(request: Request) throws -> ResponseRepresentable {
        do {
            // Random the password if no password is set
            var password = String.randomAlphaNumericString(8)
            var randomPassword = true
            if let requestedPassword = request.data["password"]?.string {
                if(requestedPassword != "") {
                    password = requestedPassword
                    randomPassword = false
                }
            }
            
            var fieldSet = UserForm.fieldset
            
            switch fieldSet.validate(request.data) {
            case .success:
                var backendUser = try BackendUser(request: request, password: password)
                try backendUser.save()
                return Response(redirect: "/admin/backend_users").flash(.success, "User created")
            case .failure:
                try request.session().data["_fieldset"] = try fieldSet.makeNode()
                return try Response(redirect: "/admin/backend_users/create").flash(.error, "Validation error")
            }
            
            
            // Send welcome mail
            //if(request.data["send_mail"]?.string == "true") {
            //    try Mailer.sendWelcomeMail(drop: drop, backendUser: backendUser, password: randomPassword ? password : nil)
            //}
            
        }catch {
            print(error)
            return Response(redirect: "/admin/backend_users/create").flash(.error, "Failed to create user")
        }
        
    }
    
    /**
     * Edit user form
     *
     * - param: Request
     * - param: BackendUser
     * - return: View
     */
    public func edit(request: Request, user: BackendUser) throws -> ResponseRepresentable {
        var fieldSet: Node = try UserForm.fieldset.makeNode()
        if let fieldSet2: Node = request.storage["_fieldset"] as? Node {
            fieldSet = fieldSet2
        }
        
        return try drop.view.make("BackendUsers/edit", [
            "fieldset": fieldSet,
            "backendUser": try user.makeNode(),
            "roles": BackendUserRole.all().makeNode()
        ], for: request)
    }
    
    /**
     * Update user
     *
     * - param: Request
     * - param: BackendUser
     * - return: View
     */
    public func update(request: Request) throws -> ResponseRepresentable {
        guard let id = request.data["id"]?.int, let backendUser: BackendUser = try BackendUser.query().filter("id", id).first() else {
            throw Abort.notFound
        }
        
        //var backendUser = user;
        
        // User details
        //backendUser.name = request.data["name"]?.string
        //backendUser.email = try request.data["email"].validated()
        //backendUser.role = request.data["role"]?.string
        /*
        // Change password
        if let password = request.data["password"]?.string, let passwordRepeat = request.data["passwordRepeat"]?.string, password == passwordRepeat {
            backendUser.password = try drop.hash.make(password)
        }
        
        
        // Save
        try backendUser.save()
        */
        
        return Response(redirect: "/admin/backend_users").flash(.success, "User updated")
    }
    
    /**
     * Delete user
     *
     * - param: Request
     * - param: BackendUser
     * - return: View
     */
    public func destroy(request: Request, user: BackendUser) throws -> ResponseRepresentable {
        do {
            try user.delete()
            return Response(redirect: "/admin/backend_users").flash(.success, "Deleted user")
        } catch {
            return Response(redirect: "/admin/backend_users").flash(.error, "Failed to delete user")
        }
    }
 
}
