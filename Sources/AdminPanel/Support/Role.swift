import Vapor
public class Role{
    let title: String
    let slug: String
    let isDefault: Bool
    
    public init(name: String, slug: String, isDefault: Bool) {
        self.title = name
        self.slug = slug
        self.isDefault = isDefault
    }
    
    public init(node: Node) throws {
        title = try node.get("title")
        slug = try node.get("slug")
        isDefault = try node.get("is_default")
    }
    
    public convenience init(config: Config) throws {
        try self.init(node: config.makeNode(in: nil))
    }
    
    public func makeNode() -> Node {
        return Node([
            "title": Node(title),
            "slug": Node(slug),
            "isDefault": Node(isDefault)
        ])
    }
}
