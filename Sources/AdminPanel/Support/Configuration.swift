import Foundation
import Vapor
import HTTP

public struct Configuration {
    
    public static var shared: Configuration?
    
    public enum Field: String {
        case name                       = "adminpanel.name"
        case unauthorizedPath           = "adminpanel.unauthorizedPath"
        case loadRoutes                 = "adminpanel.loadRoutes"
        case profileImageFallbackUrl    = "adminpanel.profileImageFallbackUrl"
        case loginSuccessPath           = "adminpanel.loginSuccessPath"
        case welcomeMailViewPath        = "adminpanel.welcomeMailViewPath"
        case resetPasswordViewPath      = "adminpanel.resetPasswordViewPath"
        case autoLoginFirstUser         = "adminpanel.autoLoginFirstUser"
        
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
    public let profileImageFallbackUrl: String
    public let loginSuccessPath: String
    public let welcomeMailViewPath: String
    public let resetPasswordViewPath: String
    public let autoLoginFirstUser: Bool
    
    public init(drop: Droplet) throws {
        try self.init(config: drop.config)
    }
    
    public init(config: Config) throws {
        self.name                       = try Configuration.extract(field: .name, config: config)
        self.unauthorizedPath           = try Configuration.extract(field: .unauthorizedPath, config: config)
        self.loadRoutes                 = try Configuration.extract(field: .loadRoutes, config: config)
        self.profileImageFallbackUrl    = try Configuration.extract(field: .profileImageFallbackUrl, config: config)
        self.loginSuccessPath           = try Configuration.extract(field: .loginSuccessPath, config: config)
        self.welcomeMailViewPath        = try Configuration.extract(field: .welcomeMailViewPath, config: config)
        self.resetPasswordViewPath      = try Configuration.extract(field: .resetPasswordViewPath, config: config)
        self.autoLoginFirstUser         = try Configuration.extract(field: .autoLoginFirstUser, config: config)
    }
    
    public func makeNode() -> Node {
        return Node([
            "name"                      : Node(name),
            "unauthorizedPath"          : Node(unauthorizedPath),
            "loadRoutes"                : Node(loadRoutes),
            "profileImageFallbackUrl"   : Node(profileImageFallbackUrl),
            "loginSuccessPath"          : Node(loginSuccessPath),
            "welcomeMailViewPath"       : Node(welcomeMailViewPath),
            "resetPasswordViewPath"     : Node(resetPasswordViewPath)
        ])
    }
    
    private static func extract(field: Field, config: Config) throws -> String {
        guard let string = config[field.path]?.string else {
            throw field.error
        }
        
        return string
    }
    
    private static func extract(field: Field, config: Config) throws -> Bool {
        guard let bool = config[field.path]?.bool else {
            throw field.error
        }
        
        return bool
    }
}
