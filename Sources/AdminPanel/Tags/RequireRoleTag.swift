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
            
            if requiredRole.weight == 0 {
                throw tag.error(reason: "Required role is at minimum. No requirement needed")
            }
            
            guard let userRole = container.user?.role else {
                throw tag.error(reason: "Invalid user role")
            }
            
            if userRole >= requiredRole {
                let parsedBody = String(data: body.data, encoding: .utf8) ?? ""
                return .string(parsedBody)
            } else {
                return TemplateData.string("")
            }
        }
    }
}
