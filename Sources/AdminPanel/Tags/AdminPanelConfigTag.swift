import Async
import Leaf
import Sugar
import TemplateKit

public final class AdminPanelConfigTag<U: AdminPanelUserType>: TagRenderer {
    public func render(tag: TagContext) throws -> Future<TemplateData> {
        try tag.requireParameterCount(1)
        let config = try tag.container.make(AdminPanelConfigTagData<U>.self)
        let container = try tag.container.make(CurrentUserContainer<U>.self)

        return Future.map(on: tag) {
            try config.viewData(
                for: tag.parameters[0],
                user: container.user,
                tag: tag
            )
        }
    }

    public init() {}
}

public final class AdminPanelConfigTagData<U: AdminPanelUserType>: Service {
    enum Keys: String {
        case name = "name"
        case baseURL = "baseURL"
        case sidebarMenuPath = "sidebarMenuPath"
        case dashboardPath = "dashboardPath"
        case environment = "environment"
    }

    public var name = ""
    public var baseURL = ""
    public var dashboardPath: String?
    public var sidebarMenuPathGenerator: SidebarMenuPathGenerator<U.Role>
    public var environment: Environment

    init(
        name: String,
        baseURL: String,
        sidebarMenuPathGenerator: @escaping SidebarMenuPathGenerator<U.Role>,
        dashboardPath: String? = nil,
        environment: Environment
    ) {
        self.name = name
        self.baseURL = baseURL
        self.sidebarMenuPathGenerator = sidebarMenuPathGenerator
        self.dashboardPath = dashboardPath
        self.environment = environment
    }

    func viewData(for data: TemplateData, user: U?, tag: TagContext) throws -> TemplateData {
        guard let key = data.string else {
            throw tag.error(reason: "Wrong type given (expected a string): \(type(of: data))")
        }

        guard let parsedKey = Keys(rawValue: key) else {
            throw tag.error(reason: "Wrong argument given: \(key)")
        }

        switch parsedKey {
        case .name:
            return .string(name)
        case .baseURL:
            return .string(baseURL)
        case .sidebarMenuPath:
            return user.map {
                .string(self.sidebarMenuPathGenerator($0.role))
            } ?? .null
        case .dashboardPath:
            return dashboardPath.map { .string($0) } ?? .null
        case .environment:
            return .string(environment.name)
        }
    }
}
