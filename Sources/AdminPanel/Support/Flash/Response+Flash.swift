import HTTP
import Node
import VaporForms

extension Response {
    public func flash(_ flashType: Helper.FlashType, _ message: String) -> Response{
        self.storage[Helper.flashKey] = Node([
            flashType.rawValue: Node(message)
        ])
        
        return self
    }
}
