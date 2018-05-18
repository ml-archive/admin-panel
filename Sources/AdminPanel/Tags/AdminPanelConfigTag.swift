import Async
import Leaf
import TemplateKit

public final class AdminPanelConfigTag: TagRenderer {
    public func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        try tag.requireParameterCount(1)
        let config = try tag.container.make(AdminPanelConfigTagData.self)
        return Future.map(on: tag) { try config.viewData(for: tag.parameters[0], tag: tag) }
    }

    public init() {}
}

public final class AdminPanelConfigTagData: Service {
    enum Keys: String {
        case name = "name"
        case baseUrl = "baseUrl"
        case userMenuPath = "userMenuPath"
        case adminMenuPath = "adminMenuPath"
        case superAdminMenuPath = "superAdminMenuPath"
        case dashboardPath = "dashboardPath"
    }

    public var name = ""
    public var baseUrl = ""
    public var userMenuPath: String?
    public var adminMenuPath: String?
    public var superAdminMenuPath: String?
    public var dashboardPath: String?

    init(
        name: String,
        baseUrl: String,
        userMenuPath: String? = nil,
        adminMenuPath: String? = nil,
        superAdminMenuPath: String? = nil,
        dashboardPath: String? = nil
    ) {
        self.name = name
        self.baseUrl = baseUrl
        self.userMenuPath = userMenuPath
        self.adminMenuPath = adminMenuPath
        self.superAdminMenuPath = superAdminMenuPath
        self.dashboardPath = dashboardPath
    }

    func viewData(for data: TemplateData, tag: TagContext) throws -> TemplateData {
        guard let key = data.string else {
            throw tag.error(reason: "Wrong type given (expected a string): \(type(of: data))")
        }

        guard let parsedKey = Keys(rawValue: key) else {
            throw tag.error(reason: "Wrong argument given: \(key)")
        }

        switch parsedKey {
        case .name:
            return .string(name)
        case .baseUrl:
            return .string(baseUrl)
        case .userMenuPath:
            return userMenuPath == nil ? .null: .string(userMenuPath!)
        case .adminMenuPath:
            return adminMenuPath == nil ? .null: .string(adminMenuPath!)
        case .superAdminMenuPath:
            return superAdminMenuPath == nil ? .null: .string(superAdminMenuPath!)
        case .dashboardPath:
            return dashboardPath == nil ? .null: .string(dashboardPath!)
        }
    }
}
