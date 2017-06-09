import Foundation
import Leaf
import Node
import Vapor

public enum Error: Swift.Error {
    case parse
}

public class FormCheckboxGroup: BasicTag {
    public init(){}
    public let name = "form:checkboxgroup"
    
    public func run(arguments: ArgumentList) throws -> Node? {
        
        /*
         #form:checkboxgroup(key, value, fieldset, attr1, attr2 etc)
         
         Arguments:
         [0] = The name of the input (the key that gets posted) *
         [1] = The value of the input (the value that gets posted) (defaults to empty string) *
         [2] = The VaporForms Fieldset of the entire model * **
         
         * - All the arguments are actually required. We need to throw exceptions at people if they don't supply all of them
         ** - It would be awesome if you could only post the exact Field of the Fieldset so we don't need to find it in this code (its gonna get repetetive)
         
         The <label> will get its value from the Fieldset
         
         If the Fieldset has the "errors" property the form-group will get the has-error css class and all errors will be added as help-block's to the form-group
         
         given input:
         
         let fieldset = Fieldset([
            "send_mail": BoolField(
                label: "Send E-mail"
            )
         ], requiring: ["send_mail"])
         
         expected output if fieldset is valid and value resolves to true:
         <div class="form-group">
            <div class="checkbox">
                <label>
                    <input type="checkbox" name="send_mail" value="send_email" checked/>
                    Send E-mail
                </label>
            </div>
         </div>
         
         expected output if fieldset is valid and value resolves to false:
         <div class="form-group">
            <div class="checkbox">
                <label>
                    <input type="checkbox" name="send_mail" value="send_email"/>
                    Send E-mail
                </label>
            </div>
         </div>
         
         expected output if fieldset is invalid (value does not matter):
         <div class="form-group has-error">
            <div class="checkbox">
                <label>
                    <input type="checkbox" name="send_mail" value="send_email"/>
                    Send E-mail
                </label>
            </div>
         </div>
         */
        
        guard arguments.count >= 3,
            let inputName: String = arguments.list[0].value(with: arguments.stem, in: arguments.context)?.string,
            let fieldsetNode = arguments.list[2].value(with: arguments.stem, in: arguments.context)
            else {
                throw Abort(
                    .internalServerError,
                    metadata: nil,
                    reason: "FormTextGroup parse error, expecting: #form:textgroup(\"name\", \"default\", fieldset)"
                )
        }
        
        // Retrieve field set for name
        let fieldset = fieldsetNode[inputName]
        
        // Retrieve input value, value from fieldset else passed default value
        let inputValue = fieldset?["value"]?.bool ?? arguments.list[1].value(with: arguments.stem, in: arguments.context)?.bool ?? false
        
        let label = fieldset?["label"]?.string ?? inputName
        
        // This is not a required property
        let errors = fieldset?["errors"]?.pathIndexableArray
        
        // This is not a required property
        // Preparing for optional array of attributes for input field
        // var attributes = [String]()
        //var argAttriutes = arguments[3].value?.nodeArray
        
        // Start constructing the template
        var template = [String]()
        
        template.append("<div class='form-group \(errors != nil ? "has-error" : "")'>")
        
        template.append("<div class='checkbox'>")
 
        template.append("<label>")
        
        if(inputValue == true) {
            template.append("<input type='checkbox' id='\(inputName)' name='\(inputName)' value='\(inputName)' checked")
        } else {
            template.append("<input type='checkbox' id='\(inputName)' name='\(inputName)' value='\(inputName)'")
        }
        
        // Add custom attributes
        if arguments.count > 3 {
            let max = arguments.count - 1
            for index in 3 ... max {
                if let argument = arguments.list[index].value(with: arguments.stem, in: arguments.context)?.string {
                    template.append(" " + argument)
                }
            }
        }
        
        template.append("/>")
        
        template.append("\(label)")
        
        template.append("</label>")
        
        template.append("</div>")
        
        // If Fieldset has errors then loop through them and add help-blocks
        if(errors != nil) {
            for e in errors! {
                
                guard let errorString = e.string else {
                    continue
                }
                
                template.append("<span class='help-block'>\(errorString)</span>")
            }
        }
        
        template.append("</div>")
        
        // Return template
        return .bytes(template.joined().bytes)
    }
}
