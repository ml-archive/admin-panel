import Leaf
import Authentication
import Sugar

public final class RoleAllowsTag<U: AdminPanelUserType>: TagRenderer {
    public func render(tag: TagContext) throws -> Future<TemplateData> {
        try tag.requireParameterCount(1)

        let container = try tag.container.make(
            CurrentUserContainer<U>.self
        )

        guard
            let roleString: String = tag.parameters[0].string,
            let requiredRole = U.Role.init(roleString)
        else {
            throw tag.error(reason: "Invalid role requirement")
        }

        return tag.future()
            .map(to: TemplateData.self) { _ in
                // User is either not logged in or not allowed to see content
                guard
                    let userRole = container.user?.role
                else {
                    return TemplateData.bool(false)
                }

                return TemplateData.bool(userRole >= requiredRole)
        }
        
    }
}
