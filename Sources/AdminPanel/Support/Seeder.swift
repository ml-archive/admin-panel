import Console
import TurnstileCrypto
import Vapor

public final class Seeder: Command {
    public let id = "admin-panel:seeder"
    
    public let help: [String] = [
        "Seeds the database"
    ]
    
    public let console: ConsoleProtocol
    public let drop: Droplet
    
    public init(drop: Droplet) {
        self.drop = drop
        self.console = drop.console
    }
    
    public func run(arguments: [String]) throws {
        
        console.info("Started the seeder");
        
        // BUG FIX WHILE WAITING FOR VAPOR UPDATE
        BackendUser.database = drop.database
        BackendUserRole.database = drop.database
        
        let backendUserRoles = [
            try BackendUserRole(node: [
                "title": "Super admin",
                "slug": "super-admin",
                "is_default": false,
                ]),
            try BackendUserRole(node: [
                "title": "Admin",
                "slug": "admin",
                "is_default": false,
                ]),
            try BackendUserRole(node: [
                "title": "User",
                "slug": "user",
                "is_default": true,
                ]),
            ]
        
        backendUserRoles.forEach({
            var backendUserRole = $0
            console.info("Looping \(backendUserRole.title)")
            do {
                try backendUserRole.save()
            } catch {
                console.error("Failed to store \(backendUserRole.title)")
                print(error)
            }
        })
        
        
        let backendUsers = [
            try BackendUser(node: [
                "name": "Admin",
                "email": "admin@admin.com",
                "password": BCrypt.hash(password: "admin"),
                "role": "super-admin",
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
