import VaporForms
import HTTP
import Vapor

extension Response {
    public func withFieldset(_ fieldset: Fieldset) -> Response {
        do {
            self.storage["_fieldset"] = try fieldset.makeNode()
        } catch {
            print("AdminPanel.withFieldset: " + error.localizedDescription)
        }
        
        return self
    }
}
