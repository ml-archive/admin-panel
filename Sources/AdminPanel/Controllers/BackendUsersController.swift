import Vapor
import VaporForms
import HTTP

struct UserForm: Form {
    let name: String
//    let email: String
    
    static var fieldset = Fieldset([
        "name": StringField(
            label: "Name"
        )
    ], requiring: ["name"])
    
    init(validatedData: [String: Node]) throws {
        print("hvorfor kommer du aldrig her til :D ")
        // validatedData is guaranteed to contain correct field names and values.
        /*
        firstName = validated["firstName"]!.string!
        lastName = validated["lastName"]!.string!
        email = validated["email"]!.string!
 */
        name = validatedData["name"]!.string!
//        email = validatedData["email"]!.string!
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
        let users = try BackendUser.all().makeNode() // todo pagination && search
        
        return try drop.view.make("BackendUsers/index", [
            "users": users
        ], for: request)
    }

    /**
     * Create user form
     *
     * - param: Request
     * - return: View
     */
    public func create(request: Request) throws -> ResponseRepresentable {
        
 
        return try drop.view.make("BackendUsers/edit", [
            "roles": BackendUserRole.all().makeNode(),
            "fieldset": UserForm.fieldset,
            "foo": 21,
            "bar": 21.3436
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
            
            let form = try UserForm(validating: request.data)
            
            var fieldSet = UserForm.fieldset
            
            switch fieldSet.validate(request.data) {
            case .success:
                var backendUser = try BackendUser(request: request, password: password)
                try backendUser.save()
                return Response(redirect: "/admin/backend_users").flash(.success, "User created")
            case .failure:
                try request.flash.add(.error, "FEJL")
                try Helper.handleRequest(request)
                return try drop.view.make("BackendUsers/edit", [
                    "roles": BackendUserRole.all().makeNode(),
                    "fieldset": fieldSet,
                    "foo": 21,
                    "bar": 21.3436
                    ], for: request)
            }
            
            
            // Send welcome mail
            //if(request.data["send_mail"]?.string == "true") {
            //    try Mailer.sendWelcomeMail(drop: drop, backendUser: backendUser, password: randomPassword ? password : nil)
            //}
            
            
        } catch let error as ValidationErrorProtocol {
            let message = "Validation error: \(error.message)"
            return Response(redirect: "/admin/backend_users/create").flash(.error, message)
        } catch {
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
        return try drop.view.make("BackendUsers/edit", [
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
    public func update(request: Request, user: BackendUser) throws -> ResponseRepresentable {
        var backendUser = user;
        
        // User details
        //backendUser.name = request.data["name"]?.string
        backendUser.email = try request.data["email"].validated()
        //backendUser.role = request.data["role"]?.string
        
        // Change password
        if let password = request.data["password"]?.string, let passwordRepeat = request.data["passwordRepeat"]?.string, password == passwordRepeat {
            backendUser.password = try drop.hash.make(password)
        }
        
        // Save
        try backendUser.save()
        
        return Response(redirect: "/admin/backend_users")
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
