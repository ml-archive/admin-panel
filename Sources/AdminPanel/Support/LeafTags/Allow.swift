import Leaf

public final class Allow: Tag {
    public let name = "allow"
    
    public enum Error: Swift.Error {
        case expetedTwoArguments(have: ArgumentList)
    }
    /*
    #allow(request, "admin")
    [0] = request
    [1] = role slug string
     */
    public func run(
        tagTemplate: TagTemplate,
        arguments: ArgumentList) throws -> Node? {
        guard arguments.count == 2 else { throw Error.expetedTwoArguments(have: arguments) }
        return nil
    }
    
    public func shouldRender(
        tagTemplate: TagTemplate,
        arguments: ArgumentList,
        value: Node?) -> Bool {
        guard let request = arguments.first else { return false }
        guard let backendUserRole = request["storage", "authedBackendUser", "role"]?.string else { return false }
        guard let role = arguments.list[1].value(with: arguments.stem, in: arguments.context)?.string else { return false }
        
        return Gate.allow(backendUserRole, role)
    }
}
