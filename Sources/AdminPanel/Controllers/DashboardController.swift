import Vapor
import Leaf

internal final class DashboardController {
    func renderDashboard(_ req: Request) throws -> Future<View> {
        let config = try req.make(AdminPanelConfig.self)
        let path = config.dashboardPath ?? AdminPanelViews.Dashboard.index

        return try req.privateContainer
            .make(LeafRenderer.self)
            // TODO: Remove empty context when this gets fixed
            // https://github.com/vapor/template-kit/issues/17
            .render(path, [String: String]())
    }
}
