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
        return U
            .logIn(on: req)
            .try {
                try req.authenticate($0)
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
            return req.future(req.redirect(to: config.endpoints.dashboard))
        }

        return try req
            .view()
            .render(config.views.login.index, RenderLogin(queryString: req.http.url.query), on: req)
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
