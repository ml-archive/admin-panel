import Foundation
import Leaf
import Node
import Vapor

public class FormOpen: BasicTag {
    public init(){}
    public let name = "form:open"
    
    public func run(arguments: ArgumentList) throws -> Node? {
        
        /*
         #form:open(url, method, fileupload)
         
         given input:
         #form:open('/admin/backend_users/edit/#(backendUser.id)', 'post', true)
         
         expected output:
         <form method="post" action="/admin/backend_users/edit/#(backendUser.id)" enctype="multipart/form-data">
            <input name="_token" type="hidden" value="..." />
         
         */
        
        guard arguments.count == 3,
            let url: String = arguments.list[0].value(with: arguments.stem, in: arguments.context)?.string,
            let method: String = arguments.list[1].value(with: arguments.stem, in: arguments.context)?.string
            else {
                throw Abort.serverError
        }
        
        let isFileupload = arguments.list[2].value(with: arguments.stem, in: arguments.context)?.bool ?? false
        
 
        // Start constructing the template
        var template = [String]()
        
        if isFileupload {
            template.append("<form method='\(method)' action='\(url)' enctype='multipart/form-data'>")
        } else {
            template.append("<form method='\(method)' action='\(url)'>")
        }
        
        // TODO: Enable this if we can... No idea how to find the CRSF token, but we should grab it automatically and not let it be up to the user
        //template.append("<input name='_token' type='hidden' value='FOOBAR' />")
        
        // Return template
        return .bytes(template.joined().bytes)
    }
}
