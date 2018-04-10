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
    }

    public var name: String = ""
    public var baseUrl: String = ""

    init(name: String, baseUrl: String) {
        self.name = name
        self.baseUrl = baseUrl
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
        }
    }
}
