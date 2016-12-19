import Foundation
import Vapor
import HTTP

public struct Configuration {
    public enum Field: String {
        case name                 = "adminpanel.name"
        case unauthorizedPath     = "adminpanel.unauthorizedPath"
        case loadRoutes           = "adminpanel.loadRoutes"
        
        var path: [String] {
            return rawValue.components(separatedBy: ".")
        }
        
        var error: Abort {
            return .custom(status: .internalServerError,
                           message: "Admin panel error - \(rawValue) config is missing.")
        }
    }
    
    public let name: String
    public let unauthorizedPath: String
    public let loadRoutes: Bool
    
    public init(drop: Droplet) throws {
        self.name                = try Configuration.extract(field: .name, drop: drop)
        self.unauthorizedPath    = try Configuration.extract(field: .unauthorizedPath, drop: drop)
        self.loadRoutes          = try Configuration.extract(field: .loadRoutes, drop: drop)
    }
    
    public func makeNode() -> Node {
        return Node([
            "name": Node(name),
            "unauthorizedPath": Node(unauthorizedPath),
            "loadRoutes": Node(loadRoutes)
        ])
    }
    
    private static func extract(field: Field , drop: Droplet) throws -> String {
        guard let string = drop.config[field.path]?.string else {
            throw field.error
        }
        
        return string
    }
    
    private static func extract(field: Field , drop: Droplet) throws -> Bool {
        guard let bool = drop.config[field.path]?.bool else {
            throw field.error
        }
        
        return bool
    }
}

