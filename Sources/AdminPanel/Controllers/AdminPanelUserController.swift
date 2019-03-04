import Fluent
import Leaf
import Paginator
import Submissions
import Vapor

public protocol AdminPanelUserControllerType {
    func renderList(_ req: Request) throws -> Future<Response>
    func renderCreate(_ req: Request) throws -> Future<Response>
    func create(_ req: Request) throws -> Future<Response>
    func renderEditMe(_ req: Request) throws -> Future<Response>
    func editMe(_ req: Request) throws -> Future<Response>
    func renderEditUser(_ req: Request) throws -> Future<Response>
    func editUser(_ req: Request) throws -> Future<Response>
    func delete(_ req: Request) throws -> Future<Response>
}

public final class AdminPanelUserController
    <U: AdminPanelUserType>: AdminPanelUserControllerType
{
    public init() {}

    // MARK: List

    public func renderList(_ req: Request) throws -> Future<Response> {
        let config: AdminPanelConfig<U> = try req.make()
        return try U.query(on: req)
            .paginate(for: req)
            .flatMap(to: Response.self) { (paginator: OffsetPaginator) in
                try req
                    .view()
                    .render(
                        config.views.adminPanelUser.index,
                        MultipleUsers(users: paginator.data ?? []),
                        userInfo: try paginator.userInfo(),
                        on: req
                    )
                    .encode(for: req)
            }
    }

    // MARK: Create user

    public func renderCreate(_ req: Request) throws -> Future<Response> {
        let config: AdminPanelConfig<U> = try req.make()
        try req.addFields(forType: U.self)

        return try req
            .view()
            .render(config.views.adminPanelUser.editAndCreate, on: req)
            .encode(for: req)
    }

    public func create(_ req: Request) throws -> Future<Response> {
        let config: AdminPanelConfig<U> = try req.make()

        return U
            .create(on: req)
            .save(on: req)
            .flatTry { user in
                try user.didCreate(on: req)
            }
            .map { user in
                req.redirect(to: config.endpoints.adminPanelUserBasePath)
                    .flash(
                        .success,
                        "The user with email '\(user[keyPath: U.usernameKey])' " +
                        "was created successfully."
                    )
            }
            .catchFlatMap(handleValidationError(
                path: config.views.adminPanelUser.editAndCreate,
                on: req
            ))
    }

    // MARK: Edit user

    public func renderEditMe(_ req: Request) throws -> Future<Response> {
        return try renderEdit(req, user: try req.requireAuthenticated(U.self))
    }

    public func renderEditUser(_ req: Request) throws -> Future<Response> {
        return try req.parameters
            .next(U.self)
            .flatMap { user in
                try self.renderEdit(req, user: user)
            }
    }

    private func renderEdit(_ req: Request, user: U) throws -> Future<Response> {
        let adminPanelUser: U = try req.requireAuthenticated()
        try adminPanelUser.requireRole(user.role) // A user may not edit a user of a higher role

        try req.addFields(given: user)
        let config: AdminPanelConfig<U> = try req.make()

        return try req
            .view()
            .render(config.views.adminPanelUser.editAndCreate, SingleUser(user: user), on: req)
            .encode(for: req)
    }

    public func editMe(_ req: Request) throws -> Future<Response> {
        let user = try req.requireAuthenticated(U.self)
        return try edit(req, user: user)
    }

    public func editUser(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(U.self)
            .flatMap { user in
                try self.edit(req, user: user)
            }
    }

    private func edit(_ req: Request, user: U) throws -> Future<Response> {
        let config: AdminPanelConfig<U> = try req.make()

        return user
            .applyUpdate(on: req)
            .save(on: req)
            .map(to: Response.self) { user in
                req.redirect(to: config.endpoints.adminPanelUserBasePath)
                    .flash(
                        .success,
                        "The user with username '\(user[keyPath: U.usernameKey])' " +
                        "got updated successfully."
                    )
            }
            .catchFlatMap(handleValidationError(
                path: config.views.adminPanelUser.editAndCreate,
                context: SingleUser(user: user),
                on: req
            ))
    }

    // MARK: Delete user

    public func delete(_ req: Request) throws -> Future<Response> {
        let auth = try req.requireAuthenticated(U.self)
        let user = try req.parameters.next(U.self)
        let config: AdminPanelConfig<U> = try req.make()

        return user
            .delete(on: req)
            .map(to: Response.self) { user in
                guard auth[keyPath: U.usernameKey] != user[keyPath: U.usernameKey] else {
                    return req
                        .redirect(to: config.endpoints.adminPanelUserBasePath)
                        .flash(.success, "Your user has now been deleted.")
                }

                return req
                    .redirect(to: config.endpoints.adminPanelUserBasePath)
                    .flash(
                        .success,
                        "The user with username '\(user[keyPath: U.usernameKey])' " +
                        "got deleted successfully."
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
