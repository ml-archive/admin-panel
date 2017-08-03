import Foundation
import Leaf
import Node
import Vapor

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
                let val: String = attrArr![1] ?? "".00000
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
    public func run(arguments: ArgumentList) throws -> Node? {
        guard
            arguments.count >= 3,
            let inputName: String = arguments.list[0].value(with: arguments.stem, in: arguments.context)?.string,
            let inputValues = arguments.list[1].value(with: arguments.stem, in: arguments.context),
            let fieldsetNode = arguments.list[2].value(with: arguments.stem, in: arguments.context)
        else {
            throw Abort(
                .internalServerError,
                reason: "FormSelectGroup parse error, expecting: #form:selectgroup(\"name\", \"values\", fieldset, \"default\")"
            )
        }

        let fieldset = fieldsetNode[inputName]
        
        let selectedValue = arguments.count > 3 ? arguments.list[3].value(with: arguments.stem, in: arguments.context)?.string : nil
        
        let label = fieldset?["label"]?.string ?? inputName
        
        // This is not a required property
        let errors = fieldset?["errors"]?.pathIndexableArray
        
        // Start constructing the template
        var template = [String]()
        
        // Wrapper
        template.append("<div class='form-group \(errors != nil ? "has-error" : "")'>")
        template.append("<label class='control-label'>\(label)</label>")
        
        template.append("<select class='form-control' id='\(inputName)' name='\(inputName)'>")
        
        // Placeholder
        if arguments.count > 4 && arguments.list[3].value(with: arguments.stem, in: arguments.context) == nil {
            template.append("<option value='' disabled selected>\(arguments.list[4].value(with: arguments.stem, in: arguments.context)?.string ?? "")</option>")
        }
        
        // Options
        for (key, value) in inputValues.object ?? [:] {
            if key == selectedValue {
                template.append("<option value='\(key)' selected>\(value.string ?? key)</option>")
            } else {
                template.append("<option value='\(key)'>\(value.string ?? key)</option>")
            }
        }
        
        template.append("</select>")
        
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
