import HTTP
import Node

extension Request {
    public var flash: Helper {
        let key = "flash-helper"
        
        guard let helper = storage[key] as? Helper else {
            let helper = Helper(request: self)
            storage[key] = helper
            return helper
        }
        
        return helper
    }
}
