import Authentication
import Leaf
import Sugar
import TemplateKit

public final class CurrentUserTag<U: AdminPanelUserType>: TagRenderer {
    public func render(tag: TagContext) throws -> Future<TemplateData> {
        try tag.requireParameterCount(1)
        let request = try tag.requireRequest()
        let container = try request.privateContainer.make(CurrentUserContainer<U>.self)

        guard
            let user = container.user,
            let data = try user.convertToTemplateData().dictionary,
            let key = tag.parameters[0].string,
            let value = data[key]
        else {
            throw tag.error(reason: "No user is logged in or the key doesn't exist.")
        }

        return tag.future(value)
    }
}
