import Foundation
import Leaf
import Node
import Vapor

public class Active: BasicTag {
    public init(){}
    public let name = "active"
    private let key = "active"
    
    public func run(arguments: [Argument]) throws -> Node? {
        guard
            arguments.count >= 2,
            let url = arguments[0].value?.node["uri", "path"]?.string
            else {
                return nil
        }
        
        var checks: [String] = []        
        for argument in arguments {
            guard let check = argument.value?.string else {
                continue
            }
            
            checks.append(check)
        }
                
        for check in checks {
            guard let checkStr = check.string else {
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
