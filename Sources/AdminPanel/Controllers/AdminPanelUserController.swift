import Fluent
import Submissions
import Vapor
import Leaf

public protocol AdminPanelUserControllerType {
    func renderList(_ req: Request) throws -> Future<View>
    func renderCreate(_ req: Request) throws -> Future<Response>
    func create(_ req: Request) throws -> Future<Response>
    func renderEditMe(_ req: Request) throws -> Future<View>
    func editMe(_ req: Request) throws -> Future<Response>
    func renderEditUser(_ req: Request) throws -> Future<View>
    func editUser(_ req: Request) throws -> Future<Response>
    func delete(_ req: Request) throws -> Future<Response>
}

public final class AdminPanelUserController
    <U: AdminPanelUserType>: AdminPanelUserControllerType
{
    public init() {}

    // MARK: List

    public func renderList(_ req: Request) throws -> Future<View> {
        let config: AdminPanelConfig<U> = try req.make()
        return U.query(on: req).all()
            .flatMap(to: View.self) { users in
                return try req.privateContainer
                    .make(LeafRenderer.self)
                    .render(config.views.adminPanelUser.index, MultipleUsers(users: users))
        }
    }

    // MARK: Create user

    public func renderCreate(_ req: Request) throws -> Future<Response> {
        let config: AdminPanelConfig<U> = try req.make()
        try req.populateFields(U.self)
        return try req.privateContainer
            .make(LeafRenderer.self)
            // TODO: Remove empty context when this gets fixed
            // https://github.com/vapor/template-kit/issues/17
            .render(config.views.adminPanelUser.editAndCreate, [String: String]())
            .encode(for: req)
    }

    public func create(_ req: Request) throws -> Future<Response> {
        let config: AdminPanelConfig<U> = try req.make()
        let submission = try req.content.decode(U.Submission.self)

        return submission
            .createValid(on: req)
            .save(on: req)
            .flatTry { user in
                return submission.flatTry { submission in
                    return try user.didCreate(with: submission, on: req)
                }
                .transform(to: ())
            }
            .map(to: Response.self) { user in
                req
                    .redirect(to: "/admin/users")
                    .flash(
                        .success,
                        """
                        The user with email '\(user[keyPath: U.usernameKey])'
                        was created successfully.
                        """
                    )
            }
            .catchFlatMap(handleValidationError(
                path: config.views.adminPanelUser.editAndCreate,
                on: req)
            )
    }

    // MARK: Edit user

    public func renderEditMe(_ req: Request) throws -> Future<View> {
        let user = try req.requireAuthenticated(U.self)
        return try renderEdit(req, user: Future.transform(to: user, on: req))
    }

    public func renderEditUser(_ req: Request) throws -> Future<View> {
        let user = try req.parameters.next(U.self)
        return try renderEdit(req, user: user)
    }

    private func renderEdit(_ req: Request, user: Future<U>) throws -> Future<View> {
        let adminPanelUser: U = try req.requireAuthenticated()

        let config: AdminPanelConfig<U> = try req.make()
        return user
            .try { user in
                try adminPanelUser.requireRole(user.role) // A user cannot edit another user of a higher role
            }
            .populateFields(on: req)
            .flatMap { user in
                try req.privateContainer
                    .make(LeafRenderer.self)
                    .render(config.views.adminPanelUser.editAndCreate, SingleUser(user: user))
            }
    }

    public func editMe(_ req: Request) throws -> Future<Response> {
        let user = try req.requireAuthenticated(U.self)
        return try edit(req, user: Future.transform(to: user, on: req))
    }

    public func editUser(_ req: Request) throws -> Future<Response> {
        let user = try req.parameters.next(U.self)
        return try edit(req, user: user)
    }

    private func edit(_ req: Request, user: Future<U>) throws -> Future<Response> {
        let config: AdminPanelConfig<U> = try req.make()
        return user
            .updateValid(on: req)
            .save(on: req)
            .map(to: Response.self) { user in
                req
                    .redirect(to: "/admin/users")
                    .flash(
                        .success,
                        """
                        The user with username '\(user[keyPath: U.usernameKey])'
                         got updated successfully.
                        """
                    )
            }
            .catchFlatMap(handleValidationError(
                path: config.views.adminPanelUser.editAndCreate,
                context: user.map(to: SingleUser.self) { .init(user: $0) },
                on: req)
            )
    }

    // MARK: Delete user

    public func delete(_ req: Request) throws -> Future<Response> {
        let auth = try req.requireAuthenticated(U.self)
        let user = try req.parameters.next(U.self)
        return user.delete(on: req)
            .map(to: Response.self) { user in
                guard auth[keyPath: U.usernameKey] != user[keyPath: U.usernameKey] else {
                    return req
                        .redirect(to: "/admin/login")
                        .flash(.success, "Your user has now been deleted.")

                }

                return req
                    .redirect(to: "/admin/users")
                    .flash(
                        .success,
                        """
                        The user with username '\(user[keyPath: U.usernameKey])'
                         got deleted successfully.
                        """
                    )
            }
    }
}

private extension AdminPanelUserController {
    private struct SingleUser: Encodable {
        let user: U?
    }

    private struct MultipleUsers: Encodable {
        let users: [U]
    }
}
