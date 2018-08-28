import Leaf
import Authentication
import Sugar

public final class HasRequiredRole<U: AdminPanelUserType>: TagRenderer {
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
        
        guard
            let userRole = container.user?.role
        else {
             return tag.future(.bool(false))
        }
        
        return tag.future(.bool(userRole >= requiredRole))
    }
}
