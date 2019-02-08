import Authentication
import Flash
import Vapor

/// Basic middleware to redirect users that needs to reset their password to the supplied path
public struct ShouldResetPasswordMiddleware<U>: Middleware where U: AdminPanelUserType {

    /// The path to redirect to
    let path: String

    /// Initialise the `ShouldResetPasswordMiddleware`
    ///
    /// - parameters:
    ///    - authenticatableType: The type to check if reset password is required
    ///    - path: The path to redirect to if the user needs to reset their password
    public init(U authenticatableType: U.Type = U.self, path: String) {
        self.path = path
    }

    /// See `Middleware.respond`.
    public func respond(to req: Request, chainingTo next: Responder) throws -> Future<Response> {
        guard
            let user = try req.authenticated(U.self),
            user.shouldResetPassword,
            req.http.urlString != path
        else {
            return try next.respond(to: req)
        }

        let redirect = req.redirect(to: path).flash(.info, "Please update your password.")
        return req.eventLoop.newSucceededFuture(result: redirect)
    }

    /// Use this middleware to redirect users away from
    /// protected content to a edit page when they need to reset their password
    public static func shouldResetPassword(
        path: String = "/admin/users/me/edit"
    ) -> ShouldResetPasswordMiddleware {
        return ShouldResetPasswordMiddleware(path: path)
    }
}
