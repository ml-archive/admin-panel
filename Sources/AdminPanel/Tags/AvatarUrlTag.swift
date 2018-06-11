import Leaf
import TemplateKit

public final class AvatarUrlTag: TagRenderer {
    public func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
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

        let avatarUrl = url ?? "https://api.adorable.io/avatars/150/\(identifier).png"

        return Future.map(on: tag) { return .string(avatarUrl) }
    }
}
