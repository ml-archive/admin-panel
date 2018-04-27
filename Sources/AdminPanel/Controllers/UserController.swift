import Vapor
import Fluent
import Leaf
import Authentication
import Flash

internal final class UserController {
    // MARK: Login

    func login(_ req: Request) throws -> Future<Response> {
        return try req
            .content
            .decode(Login.self)
            .flatMap(to: User?.self) { login in
                User.authenticate(
                    username: login.email,
                    password: login.password,
                    using: PlaintextVerifier(),
                    on: req
                )
            }
            .map(to: User.self, userOrNotFound)
            .map(to: User.self) { (user: User) -> User in
                try req.authenticate(user)
                return user
            }
            .map(to: Response.self) { user in
                req
                    .redirect(to: AdminPanelRoutes.dashboard)
                    .flash(.success, "Logged in as \(user.name)")
            }
            .mapIfError { error in
                req
                    .redirect(to: AdminPanelRoutes.login)
                    .flash(.error, "Invalid username and/or password")
            }
    }

    func renderLogin(_ req: Request) throws -> Future<Response> {
        guard try !req.isAuthenticated(User.self) else {
            return Future.map(on: req) {
                req.redirect(to: AdminPanelRoutes.dashboard)
            }
        }

        return try req
            .make(LeafRenderer.self)
            .render(AdminPanelViews.User.login)
            .encode(for: req)
    }

    // MARK: Log out

    func logout(_ req: Request) throws -> Response {
        try req.unauthenticateSession(User.self)
        return req.redirect(to: AdminPanelRoutes.login).flash(.success, "Logged out")
    }
}

extension UserController {
    struct Login: Decodable {
        let email: String
        let password: String
    }
}

private func userOrNotFound<U>(_ user: U?) throws -> U {
    guard let user = user else {
        throw AdminPanelError.userNotFound
    }

    return user
}
