import Vapor
import Fluent
import Leaf
import Authentication
import Flash

public protocol LoginControllerType {
    func login(_ req: Request) throws -> Future<Response>
    func renderLogin(_ req: Request) throws -> Future<Response>
    func logout(_ req: Request) throws -> Response
}

public final class LoginController<U: AdminPanelUserType>: LoginControllerType {
    public init() {}

    // MARK: Login

    public func login(_ req: Request) throws -> Future<Response> {
        let endpoints = try req.make(AdminPanelConfig<U>.self).endpoints
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
                    .redirect(to: endpoints.dashboard)
                    .flash(.success, "Logged in as \(user[keyPath: U.usernameKey])")
            }
            .mapIfError { error in
                req
                    .redirect(to: endpoints.login)
                    .flash(.error, "Invalid username and/or password")
            }
    }

    public func renderLogin(_ req: Request) throws -> Future<Response> {
        let config: AdminPanelConfig<U> = try req.make()
        guard try !req.isAuthenticated(U.self) else {
            return Future.map(on: req) {
                req.redirect(to: config.endpoints.dashboard)
            }
        }

        return try req.privateContainer
            .make(LeafRenderer.self)
            .render(config.views.login.index, RenderLogin(queryString: req.http.url.query))
            .encode(for: req)
    }

    // MARK: Log out

    public func logout(_ req: Request) throws -> Response {
        let endpoints = try req.make(AdminPanelConfig<U>.self).endpoints
        try req.unauthenticateSession(U.self)
        return req.redirect(to: endpoints.login).flash(.success, "Logged out")
    }
}

fileprivate extension LoginController {
    private struct Login: Decodable {
        private let email: String
        private let password: String
    }

    fileprivate struct RenderLogin: Encodable {
        fileprivate let queryString: String?
    }
}
