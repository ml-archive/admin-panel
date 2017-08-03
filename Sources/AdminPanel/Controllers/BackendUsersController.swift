import Vapor
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
        try request.auth.unauthenticate()
        return Response(redirect: "/admin").flash(.error, "User is logged out")
    }
    
    /**
     * List all backend users
     *
     * - param: Request
     * - return: View
     */
    public func index(request: Request) throws -> ResponseRepresentable {
        try Gate.allowOrFail(request, "admin")
        
        let query = try BackendUser.makeQuery()
        if let search: String = request.query?["search"]?.string {
            try query.filter("name", .contains, search)
        }

        let users = try query.paginator(25, request: request)

        return try drop.view.make(
            "BackendUsers/index",
            ["users": users.makeNode(in: nil)],
            for: request
        )
    }

    /**
     * Create user form
     *
     * - param: Request
     * - return: View
     */
    public func create(request: Request) throws -> ResponseRepresentable {
        try Gate.allowOrFail(request, "admin")
        
        let fieldset = try request.storage["_fieldset"] as? Node ?? BackendUserForm.emptyUser.makeNode(in: nil)
        
        return try drop.view.make(
            "BackendUsers/edit",
            [
                "fieldset": fieldset,
                "roles": Configuration.shared?.getRoleOptions(request.authedBackendUser().role).makeNode(in: nil) ?? [:],
                "defaultRole": (Configuration.shared?.defaultRole ?? "user").makeNode(in: nil)
            ],
            for: request
        )
    }
    
    /**
     * Save new user
     *
     * - param: Request
     * - return: View
     */
    public func store(request: Request) throws -> ResponseRepresentable {
        try Gate.allowOrFail(request, "admin")
        
        do {
            // Validate
            let (backendUserForm, hasErrors) = BackendUserForm.validating(request.data)
            if hasErrors {
                let response = Response(redirect: "/admin/backend_users/create").flash(.error, "Validation error")
                let fieldset = try backendUserForm.makeNode(in: nil)
                response.storage["_fieldset"] = fieldset
                return response
            }
            
            // Store
            let backendUser = try BackendUser(form: backendUserForm, request: request)
            try backendUser.save()
            
            // Send welcome mail
            if backendUserForm.sendMail {
                let mailPw: String? = backendUserForm.randomPassword ? backendUserForm.password : nil
                try Mailer.sendWelcomeMail(drop: drop, backendUser: backendUser, password: mailPw)
            }
            
            return Response(redirect: "/admin/backend_users").flash(.success, "User created")
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
    public func edit(request: Request) throws -> ResponseRepresentable {
        let user = try request.parameters.next(BackendUser.self)
        if user.id != request.auth.authenticated(BackendUser.self)?.id {
            try Gate.allowOrFail(request, "admin")
            try Gate.allowOrFail(request, user.role)
        }
        
        let fieldset = try request.storage["_fieldset"] as? Node ?? BackendUserForm.emptyUser.makeNode(in: nil)
        
        return try drop.view.make(
            "BackendUsers/edit",
            [
                "fieldset": fieldset,
                "backendUser": try user.makeNode(in: nil),
                "roles": Configuration.shared?.getRoleOptions(request.authedBackendUser().role).makeNode(in: nil) ?? [:],
                "defaultRole": (Configuration.shared?.defaultRole ?? "user").makeNode(in: nil)
            ],
            for: request
        )
    }
    
    /**
     * Update user
     *
     * - param: Request
     * - param: BackendUser
     * - return: View
     */
    public func update(request: Request) throws -> ResponseRepresentable {
        let backendUser = try request.parameters.next(BackendUser.self)
        guard let id = try backendUser.assertExists().string else {
            throw Abort.notFound
        }
        
        if backendUser.id != request.auth.authenticated(BackendUser.self)?.id {
            try Gate.allowOrFail(request, "admin")
            try Gate.allowOrFail(request, backendUser.role)
        }
        
        do {
            // Validate
            let (backendUserForm, hasErrors) = BackendUserForm.validating(request.data)
            if hasErrors {
                let response = Response(redirect: "/admin/backend_users/edit/" + id).flash(.error, "Validation error")
                let fieldset = try backendUserForm.makeNode(in: nil)
                response.storage["_fieldset"] = fieldset
                return response
            }
            
            // Store
            try backendUser.fill(form: backendUserForm, request: request)
            try backendUser.save()
            
            if Gate.allow(request, "admin") {
               return Response(redirect: "/admin/backend_users").flash(.success, "User updated")
            } else {
               return Response(redirect: "/admin/backend_users/edit/" + id).flash(.success, "User updated")
            }
            
        } catch {
            return Response(redirect: "/admin/backend_users/edit/" + id).flash(.error, "Failed to update user")
        }
    }
    
    /**
     * Delete user
     *
     * - param: Request
     * - param: BackendUser
     * - return: View
     */
    public func destroy(request: Request) throws -> ResponseRepresentable {
        let user = try request.parameters.next(BackendUser.self)

        try Gate.allowOrFail(request, "admin")
        try Gate.allowOrFail(request, user.role)
        do {
            try user.delete()
            return Response(redirect: "/admin/backend_users").flash(.success, "Deleted user")
        } catch {
            return Response(redirect: "/admin/backend_users").flash(.error, "Failed to delete user")
        }
    }
 
}
