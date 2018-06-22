import Vapor
import Leaf

public protocol DashboardControllerType {
    func renderDashboard(_ req: Request) throws -> Future<Response>
}

public final class DashboardController<U: AdminPanelUserType>: DashboardControllerType {
    public init() {}

    public func renderDashboard(_ req: Request) throws -> Future<Response> {
        let config = try req.make(AdminPanelConfig<U>.self)
        let path = config.dashboardPath ?? AdminPanelViews.Dashboard.index

        return try req.privateContainer
            .make(LeafRenderer.self)
            // TODO: Remove empty context when this gets fixed
            // https://github.com/vapor/template-kit/issues/17
            .render(path, [String: String]())
            .encode(for: req)
    }
}
