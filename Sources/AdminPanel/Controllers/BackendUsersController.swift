import Vapor
import HTTP

public final class BackendUsersController {
    
    public let drop: Droplet
    
    public init(droplet: Droplet) {
        drop = droplet
    }
    
    public func logout(request: Request) throws -> ResponseRepresentable {
        try request.auth.logout()
        return Response(redirect: "/admin").flash(.error, "User is logged out");
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
                "roles": BackendUserRole.all().makeNode()
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
            var backendUser = try BackendUser(request: request)
            try backendUser.save()
            
            // TODO Send welcome mail
            
            return Response(redirect: "/admin/backend_users").flash(.success, "User created")
        } catch let error as ValidationErrorProtocol {
            let message = "Validation error: \(error.message)"
            return Response(redirect: "/admin/backend_users/create").flash(.error, message)
        } catch {
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
