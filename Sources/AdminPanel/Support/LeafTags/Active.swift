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
        
        for argument in arguments.list {
            guard let check = argument.value(with: arguments.stem, in: arguments.context)?.string else {
                continue
            }
            
            if check.hasSuffix("*"), url.contains(check.replacingOccurrences(of: "*", with: "")) {
                return .string(key)
            }
            
            if check == url {
                return .string(key)   
            }
        }
        
        return nil
    }
}
