import Vapor
import Fluent
import Leaf
import Authentication
import Flash

internal final class UserController<U: AdminPanelUser> {
    internal let endpoints: AdminPanelEndpoints

    init(endpoints: AdminPanelEndpoints) {
        self.endpoints = endpoints
    }

    // MARK: Login

    func login(_ req: Request) throws -> Future<Response> {
        return try req
            .content
            .decode(U.Login.self)
            .flatMap(to: U.self) { login in
                U.logIn(with: login, on: req)
            }
            .map(to: U.self) { (user: U) -> U in
                try req.authenticate(user)
                return user
            }
            .map(to: Response.self) { user in
                req
                    .redirect(to: self.endpoints.dashboard)
                    .flash(.success, "Logged in as \(user[keyPath: U.usernameKey])")
            }
            .mapIfError { error in
                req
                    .redirect(to: self.endpoints.login)
                    .flash(.error, "Invalid username and/or password")
            }
    }

    func renderLogin(_ req: Request) throws -> Future<Response> {
        guard try !req.isAuthenticated(U.self) else {
            return Future.map(on: req) {
                req.redirect(to: self.endpoints.dashboard)
            }
        }

        return try req.privateContainer
            .make(LeafRenderer.self)
            .render(AdminPanelViews.User.login)
            .encode(for: req)
    }

    // MARK: Log out

    func logout(_ req: Request) throws -> Response {
        try req.unauthenticateSession(U.self)
        return req.redirect(to: endpoints.login).flash(.success, "Logged out")
    }
}

extension UserController {
    struct Login: Decodable {
        let email: String
        let password: String
    }
}
