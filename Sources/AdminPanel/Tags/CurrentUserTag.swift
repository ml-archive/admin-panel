import Authentication
import Leaf
import Sugar
import TemplateKit

public final class UserTag: TagRenderer {
    public func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        try tag.requireParameterCount(1)
        let container = try tag.container.make(CurrentUserContainer<AdminPanelUser>.self)

        return Future.map(on: tag) {
            try container.user?.viewData(for: tag.parameters[0], tag: tag) ?? .null
        }

    }
}

private extension AdminPanelUser {
    enum Keys: String {
        case id
        case email
        case name
        case title
        case avatarUrl
    }

    func viewData(for data: TemplateData, tag: TagContext) throws -> TemplateData {
        guard let key = data.string else {
            throw tag.error(reason: "Wrong type given (expected a string): \(type(of: data))")
        }

        guard let parsedKey = Keys(rawValue: key) else {
            throw tag.error(reason: "Wrong argument given: \(key)")
        }

        switch parsedKey {
        case .id:
            return id == nil ? .null : .int(id!)
        case .email:
            return .string(email)
        case .name:
            return .string(name)
        case .title:
            return title == nil ? .null: .string(title!)
        case .avatarUrl:
            return avatarUrl == nil ? .null: .string(avatarUrl!)
        }
    }
}
