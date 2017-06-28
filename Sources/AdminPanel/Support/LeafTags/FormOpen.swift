import Foundation
import Leaf
import Node
import Vapor
import VaporForms

public class FormOpen: BasicTag {
    public init(){}
    public let name = "form:open"
    
    public func run(arguments: [Argument]) throws -> Node? {
        
        /*
         #form:open(url, method, fileupload)
         
         given input:
         #form:open('/admin/backend_users/edit/#(backendUser.id)', 'post', true)
         
         expected output:
         <form method="post" action="/admin/backend_users/edit/#(backendUser.id)" enctype="multipart/form-data">
            <input name="_token" type="hidden" value="..." />
         
         */
        
        guard arguments.count == 3,
            let url: String = arguments[0].value?.string,
            let method: String = arguments[1].value?.string
            else {
                throw Abort.serverError
        }
        
        let isFileupload = arguments[2].value?.bool ?? false
        
 
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
