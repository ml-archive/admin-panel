import Leaf
import TemplateKit

public final class SidebarMenuItemTag: TagRenderer {
    public func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        
        let body = try tag.requireBody()

        var url = "#"
        var icon = ""
        //var paths: [String] = []

        for index in 0...1 {
            if
                let param = tag.parameters[safe: index]?.string,
                !param.isEmpty
            {
                switch index {
                case 0: url = param
                case 1: icon = "<span data-feather='\(param)'></span>"
                default: ()
                }
            }
        }

        //Home <span class="sr-only">(current)</span>

        return tag.serializer.serialize(ast: body).map(to: TemplateData.self) { body in
            let parsedBody = String(data: body.data, encoding: .utf8) ?? ""

            let item =
            """
            <li class="nav-item">
                <a class="nav-link" href="\(url)">
                    \(icon)
                    \(parsedBody)
                </a>
            </li>
            """

            return .string(item)
        }
    }
}

//private extension ArgumentList {
//    func extractPath() -> String? {
//        return context.get(path: ["request", "uri", "path"])?.string
//    }
//}
//
//private extension Request {
//    static func isActive(_ path: String?, _ defaultPath: String?, _ args: ArraySlice<Argument>, _ stem: Stem, _ context: LeafContext) -> Bool {
//        guard args.count > 0 else {
//            return path == defaultPath
//        }
//
//        for arg in args {
//            guard let searchPath = arg.value(with: stem, in: context)?.string else { continue }
//
//            if searchPath.hasSuffix("*"), path?.contains(searchPath.replacingOccurrences(of: "*", with: "")) ?? false {
//                return true
//            }
//
//            if searchPath == path {
//                return true
//            }
//        }
//
//        return false
//    }
//}
