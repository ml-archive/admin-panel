import Leaf
import Sugar
import TemplateKit

public final class SidebarMenuItemTag: TagRenderer {
    public func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        let body = try tag.requireBody()

        var url = "#"
        var icon = ""
        var activeLink = ""
        var activeTitle = ""

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

        if tag.parameters.count > 2 {
            let currentPath = try tag.container.make(CurrentUrlContainer.self).path
            let activeUrlPatterns = tag.parameters.dropFirst(2)

            if isActive(currentPath: currentPath, pathPatterns: activeUrlPatterns) {
                activeLink = " active"
                activeTitle = " <span class='sr-only'>(current)</span>"
            }
        }

        return tag.serializer.serialize(ast: body).map(to: TemplateData.self) { body in
            let parsedBody = String(data: body.data, encoding: .utf8) ?? ""

            let item =
            """
            <li class="nav-item">
                <a class="nav-link\(activeLink)" href="\(url)">
                    \(icon)
                    \(parsedBody)\(activeTitle)
                </a>
            </li>
            """

            return .string(item)
        }
    }
}


private extension SidebarMenuItemTag {
    func isActive(currentPath: String, pathPatterns: ArraySlice<TemplateData>) -> Bool {
        for arg in pathPatterns {
            let searchPath = arg.string ?? ""

            if
                searchPath.hasSuffix("*"),
                currentPath.contains(searchPath.replacingOccurrences(of: "*", with: ""))
            {
                return true
            }

            if searchPath == currentPath {
                return true
            }
        }

        return false
    }
}
