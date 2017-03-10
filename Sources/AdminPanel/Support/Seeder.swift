import Console
import TurnstileCrypto
import Vapor
import Foundation
import Sugar


public final class Seeder: Command {

    public let id = "admin-panel:seeder"
    
    public let help: [String] = [
        "Seeds the database for admin panel"
    ]
    
    public let console: ConsoleProtocol
    public let dropet: Droplet
    
    public init(dropet: Droplet) {
        self.dropet = dropet
        self.console = dropet.console
    }
    
    public func run(arguments: [String]) throws {
        
        console.info("Started the seeder");
        
        // BUG FIX WHILE WAITING FOR VAPOR UPDATE
        BackendUser.database = dropet.database
        
        let backendUsers = [
            try BackendUser(node: [
                "name": "Admin",
                "email": "admin@admin.com",
                "password": BCrypt.hash(password: "admin"),
                "role": "super-admin",
                "updated_at": Date().toDateTimeString(),
                "created_at": Date().toDateTimeString()
                ]),
            ]
        
        backendUsers.forEach({
            var backendUser = $0
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
