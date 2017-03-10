import Foundation
import Leaf
import Node
import Vapor
import VaporForms

public class FormSelectGroup: BasicTag {
    public init(){}
    public let name = "form:selectgroup"
    
    /*
    public static func argumentToHtmlAttributes(arguments: [Argument], from: Int) throws -> String{
        var dict: [String:String] = [:]
        var list: [String] = []
        
        var index = 0
        for argument in arguments {
            if index < from {
                index = index + 1
                continue
            }
            
            let isDict = argument.value?.string?.characters.index(of: ":")
            
            if(isDict != nil) {
                let attrArr = argument.value?.string?.components(separatedBy: ":")
                let key: String = attrArr![0] ?? ""
                let val: String = attrArr![1] ?? ""
                dict[key] = val
            } else {
                list.append(argument.value?.string ?? "")
            }
            
        }
        
        // Given:
        // [..., "class:foo bar baz", "disabled"]
        // Expected return value:
        // "class='foo baar baz' disabled"
        
        return ""
    }
    */
    public func run(arguments: [Argument]) throws -> Node? {
        
        /*
         #form:checkboxgroup(key, value, fieldset)
         
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
         
         #form:checkboxgroup("send_mail", send_mail, fieldset)
         
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
            let inputName: String = arguments[0].value?.string,
            let inputValues = arguments[1].value?.nodeObject,
            let fieldsetNode = arguments[2].value?.nodeObject
            else {
                throw Abort.custom(status: .internalServerError, message: "FormSelectGroup parse error, expecting: #form:selectgroup(\"name\", \"values\", fieldset), \"default\"")
        }

        let fieldset = fieldsetNode[inputName]
        
        let selectedValue = arguments.count > 3 ? arguments[3].value?.string : nil
        
        let label = fieldset?["label"]?.string ?? inputName
        
        // This is not a required property
        let errors = fieldset?["errors"]?.pathIndexableArray
        
        
       /*
        do {
            var htmlAttrs = try FormSelectGroup.argumentToHtmlAttributes(arguments: arguments, from: 5)
        } catch {
            var htmlAttrs = ""
        }
        */
        
        // Start constructing the template
        var template = [String]()
        
        // Wrapper
        template.append("<div class='form-group \(errors != nil ? "has-error" : "")'>")
        template.append("<label class='control-label'>\(label)</label>")
        
        template.append("<select class='form-control' id='\(inputName)' name='\(inputName)'>")
        
        // Placeholder
        if(arguments.count > 4 && arguments[3].value == nil) {
            template.append("<option value='' disabled selected>\(arguments[4].value?.string ?? "")</option>")
        }
        
        // Options
        for (key, value) in inputValues.array {
            if(key == selectedValue) {
                template.append("<option value='\(key)' selected>\(value.string ?? key)</option>")
            } else {
                template.append("<option value='\(key)'>\(value.string ?? key)</option>")
            }
        }
        
        template.append("</select>")
        
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
