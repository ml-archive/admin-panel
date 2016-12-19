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
    
    public func resetPasswordForm(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("Login/reset", for: request)
    }
    
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
        
        return Response(redirect: "/admin/login").flash(.success, "Message sent");
    }
    
    public func form(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("Login/login", for: request)
    }
    
    public func submit(request: Request) throws -> ResponseRepresentable {
        // Get our credentials
        guard let username = request.data["email"]?.string, let password = request.data["password"]?.string else {
            throw Abort.custom(status: Status.badRequest, message: "Missing username or password")
        }
        let credentials = UsernamePassword(username: username, password: password)
    
        do {
            try request.auth.login(credentials)
            
            // Todo deal with remember me
        
            return Response(redirect: "/admin/dashboard").flash(.success, "Logged in as \(credentials.username)")
        } catch {
            return Response(redirect: "/admin/login").flash(.error, "Failed to login");
        }
        
    }
}
