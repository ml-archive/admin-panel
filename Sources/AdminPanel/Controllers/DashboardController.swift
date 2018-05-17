import Vapor
import Leaf

internal final class DashboardController {
    // MARK: Dashboard

    func renderDashboard(_ req: Request) throws -> Future<View> {
        return try req.privateContainer
            .make(LeafRenderer.self)
            // TODO: Remove empty context when this gets fixed
            // https://github.com/vapor/template-kit/issues/17
            .render(AdminPanelViews.Dashboard.index, [String: String]())
    }
}
