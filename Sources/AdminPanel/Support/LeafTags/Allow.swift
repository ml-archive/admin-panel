import Leaf

public final class Allow: Tag {
    public let name = "allow"
    
    public enum Error: Swift.Error {
        case expetedTwoArguments(have: [Argument])
    }
    /*
    #allow(request, "admin")
    [0] = request
    [1] = role slug string
     */
    public func run(
        stem: Stem,
        context: Context,
        tagTemplate: TagTemplate,
        arguments: [Argument]) throws -> Node? {
        guard arguments.count == 2 else { throw Error.expetedTwoArguments(have: arguments) }
        return nil
    }
    
    public func shouldRender(
        stem: Stem,
        context: Context,
        tagTemplate: TagTemplate,
        arguments: [Argument],
        value: Node?) -> Bool {
        guard let request = arguments.first?.value else { return false }
        guard let backendUserRole = request["storage", "authedBackendUser", "role"]?.string else { return false }
        guard let role = arguments[1].value?.string else { return false }
        
        return Gate.allow(backendUserRole, role)
    }
}
