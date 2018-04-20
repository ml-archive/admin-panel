import Vapor
import Leaf

internal final class DashboardController {
    // MARK: Dashboard

    func renderDashboard(_ req: Request) throws -> Future<View> {
        return Future
            .map(on: req) { () in
                return try req.make(LeafRenderer.self)
            }
            .flatMap(to: View.self) { leaf in
                return leaf.render(AdminPanelViews.Dashboard.index)
            }
    }
}
