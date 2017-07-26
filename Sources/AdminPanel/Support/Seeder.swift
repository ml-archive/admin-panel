import Console
import Vapor
import Foundation
import Sugar


public final class Seeder: Command, ConfigInitializable {

    public let id = "admin-panel:seeder"
    
    public let help: [String] = [
        "Seeds the database for admin panel"
    ]
    
    public let console: ConsoleProtocol

    public init(config: Config) throws {
        self.console = try config.resolveConsole()
    }
    
    public func run(arguments: [String]) throws {
        console.info("Started the seeder")
        
        var node = Node.object([:])
        try node.set("name", "Admin")
        try node.set("email", "admin@admin.com")
        try node.set("password", BCryptHasher().make("admin").makeString())
        try node.set("role", "super-admin")
        try node.set("updatedAt", Date().toDateTimeString())
        try node.set("createdAt", Date().toDateTimeString())
        
        let backendUsers = [
            try BackendUser(node: node),
        ]
        
        backendUsers.forEach({
            let backendUser = $0
            console.info("Looping \(backendUser.name)")
            do {
                try backendUser.save()
            } catch {
                console.error("Failed to store \(backendUser.name)")
                print(error)
            }
        })
        
        console.info("Finished the seeder");
    }
}
