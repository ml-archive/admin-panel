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
                return User.authenticate(
                    username: login.email,
                    password: login.password,
                    using: PlaintextVerifier(),
                    on: req
                )
            }
            .map(to: User.self, userOrNotFound)
            .map(to: Response.self) { user in
                return req
                    .redirect(to: AdminPanelRoutes.dashboard)
                    .flash(.success, "Logged in as \(user.name)")
            }
            .mapIfError { error in
                return req
                    .redirect(to: AdminPanelRoutes.login)
                    .flash(.error, "Invalid username and/or password")
            }
    }

    func renderLogin(_ req: Request) throws -> Future<View> {
        return Future
            .map(on: req) { () in
                return try req.make(LeafRenderer.self)
            }
            .flatMap(to: View.self) { leaf in
                return leaf.render(AdminPanelViews.User.login)
            }
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
