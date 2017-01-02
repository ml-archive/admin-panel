import VaporForms
import HTTP
import Vapor

extension Form {
    public static func getFieldset(_ request: Request) throws -> Node {
        
        if let fieldSet: Node = request.storage["_fieldset"] as? Node {
            return fieldSet
        }
        
        return try self.fieldset.makeNode()
    }
}
