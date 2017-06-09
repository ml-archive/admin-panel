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
    public let droplet: Droplet

    public init(config: Config) throws {
        self.console = try config.resolveConsole()
    }

    public init(droplet: Droplet) {
        self.droplet = droplet
        self.console = droplet.console
    }
    
    public func run(arguments: [String]) throws {
        
        console.info("Started the seeder");
        
        // BUG FIX WHILE WAITING FOR VAPOR UPDATE
        BackendUser.database = droplet.database
        
        let backendUsers = [
            try BackendUser(node: [
                "name": "Admin",
                "email": "admin@admin.com",
                "password": BCryptHasher().make("admin"),
                "role": "super-admin",
                "updated_at": Date().toDateTimeString(),
                "created_at": Date().toDateTimeString()
                ]),
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
