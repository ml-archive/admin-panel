import Leaf
import TemplateKit

public final class AvatarURLTag: TagRenderer {
    public func render(tag: TagContext) throws -> Future<TemplateData> {
        var identifier = ""
        var url: String?

        for index in 0...1 {
            if
                let param = tag.parameters[safe: index]?.string,
                !param.isEmpty
            {
                switch index {
                case 0: identifier = param
                case 1: url = param
                default: ()
                }
            }
        }

        let avatarURL = url ?? "https://api.adorable.io/avatars/150/\(identifier).png"

        return tag.future(.string(avatarURL))
    }
}
