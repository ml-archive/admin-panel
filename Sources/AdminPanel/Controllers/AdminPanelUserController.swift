import Fluent
import Vapor
import Leaf

internal final class AdminPanelUserController {
    // MARK: List

    func renderList(_ req: Request) throws -> Future<View> {
        return AdminPanelUser.query(on: req).all()
            .flatMap(to: View.self) { users in
                return try req.privateContainer
                    .make(LeafRenderer.self)
                    .render(AdminPanelViews.AdminPanelUser.index, MultipleUsers(users: users))
        }
    }

    // MARK: Create user

    func renderCreate(_ req: Request) throws -> Future<Response> {
        try req.populateFields(AdminPanelUser.self)
        return try req.privateContainer
            .make(LeafRenderer.self)
            // TODO: Remove empty context when this gets fixed
            // https://github.com/vapor/template-kit/issues/17
            .render(AdminPanelViews.AdminPanelUser.editAndCreate, [String: String]())
            .encode(for: req)
    }

    func create(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(AdminPanelUser.Submission.self)
            .createValid(on: req)
            .save(on: req)
            .map(to: Response.self) { user in
                req
                    .redirect(to: "/admin/users")
                    .flash(
                        .success,
                        "The user with email '\(user.email)' got created successfully."
                    )
            }
            .catchFlatMap(handleValidationError(
                path: AdminPanelViews.AdminPanelUser.editAndCreate,
                on: req)
            )
    }

    // MARK: Edit user

    func renderEditMe(_ req: Request) throws -> Future<View> {
        let user = try req.requireAuthenticated(AdminPanelUser.self)
        return try renderEdit(req, user: Future.transform(to: user, on: req))
    }

    func renderEditUser(_ req: Request) throws -> Future<View> {
        let user = try req.parameters.next(AdminPanelUser.self)
        return try renderEdit(req, user: user)
    }

    private func renderEdit(_ req: Request, user: Future<AdminPanelUser>) throws -> Future<View> {
        return user
            .populateFields(on: req)
            .flatMap { user in
                try req.privateContainer
                    .make(LeafRenderer.self)
                    .render(AdminPanelViews.AdminPanelUser.editAndCreate, SingleUser(user: user))
            }
    }

    func editMe(_ req: Request) throws -> Future<Response> {
        let user = try req.requireAuthenticated(AdminPanelUser.self)
        return try edit(req, user: Future.transform(to: user, on: req))
    }

    func editUser(_ req: Request) throws -> Future<Response> {
        let user = try req.parameters.next(AdminPanelUser.self)
        return try edit(req, user: user)
    }

    private func edit(_ req: Request, user: Future<AdminPanelUser>) throws -> Future<Response> {
        return user
            .updateValid(on: req)
            .save(on: req)
            .map(to: Response.self) { user in
                req
                    .redirect(to: "/admin/users")
                    .flash(
                        .success,
                        "The user with email '\(user.email)' got updated successfully."
                    )
            }
            .catchFlatMap(handleValidationError(
                path: AdminPanelViews.AdminPanelUser.editAndCreate,
                context: user.map(to: SingleUser.self) { .init(user: $0) },
                on: req)
            )
    }

    // MARK: Delete user

    func delete(_ req: Request) throws -> Future<Response> {
        let auth = try req.requireAuthenticated(AdminPanelUser.self)
        let user = try req.parameters.next(AdminPanelUser.self)
        return user.delete(on: req)
            .map(to: Response.self) { user in
                guard auth.id != user.id else {
                    return req
                        .redirect(to: "/admin/login")
                        .flash(.success, "Your user has now been deleted.")

                }

                return req
                    .redirect(to: "/admin/users")
                    .flash(
                        .success,
                        "The user with email '\(user.email)' got deleted successfully."
                    )
            }
    }
}

private extension AdminPanelUserController {
    private struct SingleUser: Encodable {
        let user: AdminPanelUser?
    }

    private struct MultipleUsers: Encodable {
        let users: [AdminPanelUser]
    }
}
