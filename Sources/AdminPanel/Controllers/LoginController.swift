import Foundation
import Vapor
import Auth
import HTTP
import Turnstile
import TurnstileCrypto
import TurnstileWeb

public final class LoginController {
    
    public let drop: Droplet
    
    public init(droplet: Droplet) {
        drop = droplet
    }
    
    /**
     * Landing page
     *
     * - param: Request
     * - return: Response
     */
    public func landing(request: Request) throws -> ResponseRepresentable {
        do {
            guard let user: BackendUser = try request.auth.user() as? BackendUser else {
                throw Abort.custom(status: .forbidden, message: "Forbidden")
            }
            
            return Response(redirect: "/admin/dashboard").flash(.success, "Logged in as \(user.email.value)")
        } catch {
            return Response(redirect: "/admin/login").flash(.error, "Please login")
        }
    }
    
    /**
     * Reset password form
     *
     * - param: Request
     * - return: View
     */
    public func resetPasswordForm(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("Login/reset", for: request)
    }
    
    /**
     * Reset password submit
     *
     * - param: Request
     * - return: View
     */
    public func resetPasswordSubmit(request: Request) throws -> ResponseRepresentable {
        guard let email = request.data["email"]?.string else {
            throw Abort.custom(status: Status.badRequest, message: "Missing email")
        }
        
        guard let user: BackendUser = try BackendUser.query().filter("email", email).first() else {
            throw Abort.custom(status: Status.badRequest, message: "Email doesn ot exist")
        }
        
        // Consider expiring old tokes for this user
        
        // Make a token
        var token = try BackendUserResetPasswordTokens(email: user.email.value)
        try token.save()
        
        return Response(redirect: "/admin/login").flash(.success, "Message sent")
    }
    
    /**
     * Login form
     *
     * - param: Request
     * - return: View
     */
    public func form(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("Login/login", [
            "next": request.query?["next"]?.node ?? nil
        ], for: request)
    }
    
    /**
     * Submit login
     *
     * - param: Request
     * - return: Response
     */
    public func submit(request: Request) throws -> ResponseRepresentable {
        
        // Guard credentials
        guard let username = request.data["email"]?.string, let password = request.data["password"]?.string else {
            throw Abort.custom(status: Status.badRequest, message: "Missing username or password")
        }
        
        do {
            try request.auth.login(UsernamePassword(username: username, password: password))
            
            // Generate redirect path
            var redirect = "/admin/dashboard"
            if let next: String = request.query?["next"]?.string, !next.isEmpty {
                redirect = next
            }
            
            // TODO, "remember me"            
        
            return Response(redirect: redirect).flash(.success, "Logged in as \(username)")
        } catch {
            return Response(redirect: "/admin/login").flash(.error, "Failed to login")
        }
    }
}
