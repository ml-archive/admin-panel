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
        title = try node.extract("title")
        slug = try node.extract("slug")
        isDefault = try node.extract("is_default")
    }
    
    public convenience init(config: Config) throws {
        try self.init(node: config.node)
    }
}
