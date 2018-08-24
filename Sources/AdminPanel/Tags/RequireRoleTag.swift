import Leaf
import Authentication
import Sugar

public final class RequireRoleTag<U: AdminPanelUserType>: TagRenderer {
    public func render(tag: TagContext) throws -> Future<TemplateData> {
        try tag.requireParameterCount(1)

        let container = try tag.container.make(
            CurrentUserContainer<U>.self
        )

        let body = try tag.requireBody()

        return tag.serializer.serialize(ast: body).map(to: TemplateData.self) { body in
            guard
                let roleString: String = tag.parameters[0].string,
                let requiredRole = U.Role.init(roleString)
            else {
                throw tag.error(reason: "Invalid role requirement")
            }

            // User is either not logged in or not allowed to see content
            guard
                let userRole = container.user?.role,
                userRole >= requiredRole
            else {
                return TemplateData.string("")
            }

            let parsedBody = String(data: body.data, encoding: .utf8) ?? ""
            return .string(parsedBody)
        }
    }
}
