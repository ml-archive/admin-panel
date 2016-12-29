import Foundation
import Leaf
import Node
import Vapor
import VaporForms

public class FormTextGroup: BasicTag {
    public init(){}
    public let name = "form:textgroup"
    
    public func run(arguments: [Argument]) throws -> Node? {
        
        /*
         #form:textgroup(key, value, fieldset)
         
         Arguments:
         [0] = The name of the input (the key that gets posted) *
         [1] = The value of the input (the value that gets posted) (defaults to empty string) *
         [2] = The VaporForms Fieldset of the entire model * **
         
         * - All the arguments are actually required. We need to throw exceptions at people if they don't supply all of them
         ** - It would be awesome if you could only post the exact Field of the Fieldset so we don't need to find it in this code (its gonna get repetetive)
         
         The <label> will get its value from the Fieldset
         
         If the Fieldset has the "errors" property the form-group will get the has-error css class and all errors will be added as help-block's to the form-group
        */
        
        // throw exception if arguments.count is < 3
        
        // Explicit set type as string - throw exception if not string
        let inputName = arguments[0].value?.string
        // Explicit set type as string - throw exception if not string
        let inputValue = arguments[1].value?.string ?? ""
        
        // Explicit set type as [String : Node] (???) - throw exception if not
        let fieldsetNode = arguments[2].value?.nodeObject
        let fieldset = fieldsetNode?[inputName!]
        
        // Explicit set type as string - throw exception if not string
        // throw exception if Fieldset Field does not have a label property or use the inputName (which is lowercase) by default?
        let label = fieldset?["label"]?.string
        
        // This is not a required property
        let errors = fieldset?["errors"]?.pathIndexableArray
        
        // Start constructing the template
        var template = [String]()

        template.append("<div class='form-group \(errors != nil ? "has-error" : "")'>")
        
        template.append("<label class='control-label'>\(label)</label>")
        
        template.append("<input class='form-control' type='text' name='\(inputName)' value='\(inputValue)' />")
      
        // If Fieldset has errors then loop through them and add help-blocks
        if(errors != nil) {
            for e in errors! {
                template.append("<span class='help-block'>\(e)</span>")
            }
        }
        
        template.append("</div>")
        
        // Return template
        return .bytes(template.joined().bytes)
    }
}
