import Vapor
import VaporForms
import HTTP
import Fluent
import Flash
import Paginator

public final class BackendUsersController {
    
    public let drop: Droplet
    
    public init(droplet: Droplet) {
        drop = droplet
    }
    
    /**
     * Logout, will logout auther user and redirect back to login
     *
     * - param: Request
     * - return: Response
     */
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
        
        let query = try BackendUser.query()
        if let search: String = request.query?["search"]?.string {
            try query.filter("name", contains: search)
        }
        let users = try query.paginator(25, request: request)
        
        // Search
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
        return try drop.view.make("BackendUsers/edit", [
            "roles": Configuration.shared?.roleOptions.makeNode() ?? [],
            "fieldset": BackendUserForm.getFieldset(request),
            "defaultRole": Configuration.shared?.defaultRole ?? "admin"
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
            // Validate
            let backendUserForm = try BackendUserForm(validating: request.data)
            
            // Store
            var backendUser = BackendUser(form: backendUserForm)
            try backendUser.save()
            
            // Send welcome mail
            if backendUserForm.sendMail {
                let mailPw: String? = backendUserForm.randomPassword ? backendUserForm.password : nil
                try Mailer.sendWelcomeMail(drop: drop, backendUser: backendUser, password: mailPw)
            }
            
            return Response(redirect: "/admin/backend_users").flash(.success, "User created")
        }catch FormError.validationFailed(let fieldSet) {
            return Response(redirect: "/admin/backend_users/create").flash(.error, "Validation error").withFieldset(fieldSet)
        }catch {
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
            "fieldset": BackendUserForm.getFieldset(request),
            "backendUser": try user.makeNode(),
            "roles": Configuration.shared?.roleOptions.makeNode() ?? [],
            "defaultRole": Configuration.shared?.defaultRole ?? "admin"
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
        guard let id = request.data["id"]?.int, var backendUser = try BackendUser.query().filter("id", id).first() else {
            throw Abort.notFound
        }
        
        do {
            // Validate
            let backendUserForm = try BackendUserForm(validating: request.data)
            
            // Store
            backendUser.fill(form: backendUserForm)
            try backendUser.save()
            
            return Response(redirect: "/admin/backend_users").flash(.success, "User updated")
        }catch FormError.validationFailed(let fieldSet) {
            return Response(redirect: "/admin/backend_users/edit/" + String(id)).flash(.error, "Validation error").withFieldset(fieldSet)
        }catch {
            return Response(redirect: "/admin/backend_users/edit/" + String(id)).flash(.error, "Failed to update user")
        }
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
