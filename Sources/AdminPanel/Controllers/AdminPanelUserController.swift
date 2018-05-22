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
}
