import Vapor
import HTTP

public final class Helper {
    public static let flashKey = "_flash"
    enum State: String {
        case new = "new"
        case old = "old"
    }
    
    public enum FlashType: String {
        case error = "error"
        case success = "success"
        case info = "info"
        case warning = "warning"
    }
    
    private let request: Request
    
    public init(request: Request) {
        self.request = request
    }
    
    public func add(_ type: FlashType, _ message: String) throws {
        try request.session().data[Helper.flashKey, State.new.rawValue, type.rawValue] = Node(message)
    }
    
    public func add(_ custom: String, _ message: String) throws {
        try request.session().data[Helper.flashKey, State.new.rawValue, custom] = Node(message)
    }
    
    public func refresh() throws {
        // Copy old node to new node
        try request.session().data[Helper.flashKey, State.new.rawValue] = try request.session().data[Helper.flashKey, State.old.rawValue] ?? Node([])
    }
    
    public func clear() throws {
        try request.session().data[Helper.flashKey] = nil
    }
    
    public static func handleRequest(_ request: Request) throws {
        // Init flash node
        let flash = try request.session().data[flashKey, State.new.rawValue] ?? Node([])
        
        // Copy new node to old node
        try request.session().data[flashKey, State.old.rawValue] = flash
        
        // Apply new node to request storage
        request.storage[flashKey] = flash
        
        // Clear new node
        try request.session().data[flashKey, State.new.rawValue] = nil
    }
    
    public static func handleResponse(_ response: Response, _ request: Request) throws {
        guard let flash: Node = response.storage[flashKey] as? Node else {
            return
        }
        
        // Change to swicth
        if let error: String = flash[FlashType.error.rawValue]?.string {
            try request.flash.add(.error, error)
        }
        
        if let success: String = flash[FlashType.success.rawValue]?.string {
            try request.flash.add(.success, success)
        }
        
        if let info: String = flash[FlashType.info.rawValue]?.string {
            try request.flash.add(.info, info)
        }
        
        if let warning: String = flash[FlashType.warning.rawValue]?.string {
            try request.flash.add(.warning, warning)
        }
    }
}
