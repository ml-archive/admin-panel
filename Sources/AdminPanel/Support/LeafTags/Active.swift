import Foundation
import Leaf
import Node
import Vapor

public class Active: BasicTag {
    public init(){}
    public let name = "active"
    private let key = "active"
    
    public func run(arguments: ArgumentList) throws -> Node? {
        guard
            arguments.count >= 2,
            let url = arguments.list[0].value(with: arguments.stem, in: arguments.context)?["uri", "path"]?.string
            else {
                return nil
        }
        
        var checks: [String] = []        
        for argument in arguments.list {
            guard let check = argument.value(with: arguments.stem, in: arguments.context)?.string else {
                continue
            }
            
            checks.append(check)
        }
                
        for check in checks {
            guard let checkStr: String = check.string else {
                continue
            }
            
            if(checkStr.characters.last == "*") {
                let checkStr = checkStr.replacingOccurrences(of: "*", with: "")
                
                if(url.range(of: checkStr) != nil) {
                    return Node(key)
                }
            }
            
            if(checkStr == url) {
                return Node(key)
            }
        }
        
        return nil
    }
}
