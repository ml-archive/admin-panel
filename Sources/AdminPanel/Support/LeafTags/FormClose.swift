import Foundation
import Leaf
import Node
import Vapor

public class FormClose: BasicTag {
    public init(){}
    public let name = "form:close"
    
    public func run(arguments: ArgumentList) throws -> Node? {
        /*
         #form:close()
         
         given input:
         #form:close()
         
         expected output:
         </form>
         
         */
        
        // Return template
        return .bytes("</form>".bytes)
    }
}
