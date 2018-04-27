import Vapor
import Leaf

internal final class DashboardController {
    // MARK: Dashboard

    func renderDashboard(_ req: Request) throws -> Future<View> {
        return try req
            .make(LeafRenderer.self)
            .render(AdminPanelViews.Dashboard.index)
    }
}
