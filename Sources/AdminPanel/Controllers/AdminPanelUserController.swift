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
                    .render(AdminPanelViews.AdminPanelUser.index, ["users": users])
        }
    }

    // MARK: Create user

    func renderCreate(_ req: Request) throws -> Future<View> {
        return try req.privateContainer
            .make(LeafRenderer.self)
            // TODO: Remove empty context when this gets fixed
            // https://github.com/vapor/template-kit/issues/17
            .render(AdminPanelViews.AdminPanelUser.create, [String: String]())
    }

    func create(_ req: Request) throws -> Future<Response> {
        return try AdminPanelUser.register(on: req)
            .map(to: Response.self) { registration in
                req
                    .redirect(to: "/admin/users")
                    .flash(.success, "The user with email '\(registration.email)' got created successfully.")
            }
    }

    // MARK: Edit user

    func renderEdit(_ req: Request) throws -> Future<View> {
        let user = try req.parameters.next(AdminPanelUser.self)
        return try req.privateContainer
            .make(LeafRenderer.self)
            // TODO: Remove empty context when this gets fixed
            // https://github.com/vapor/template-kit/issues/17
            .render(AdminPanelViews.AdminPanelUser.create, ["user": user])
    }

    func edit(_ req: Request) throws -> Future<Response> {
        return try AdminPanelUser.update(on: req)
            .map(to: Response.self) { update in
                req
                    .redirect(to: "/admin/users")
                    .flash(.success, "The user with email '\(update.email)' got updated successfully.")
            }
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
                    .flash(.success, "The user with email '\(user.email)' got deleted successfully.")
            }
    }
}
