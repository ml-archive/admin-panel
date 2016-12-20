import Console
import Admin
import TurnstileCrypto

public final class Seeder: Command {
public let id = "seeder"

public let help: [String] = [
"Seeds the database"
]

public let console: ConsoleProtocol

public init(console: ConsoleProtocol) {
self.console = console
}

public func run(arguments: [String]) throws {

console.info("Started the seeder");

let backendUserRoles = [
try Admin.BackendUserRole(node: [
"title": "Super admin",
"slug": "super-admin",
"is_default": false,
]),
try Admin.BackendUserRole(node: [
"title": "Admin",
"slug": "admin",
"is_default": false,
]),
try Admin.BackendUserRole(node: [
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
try Admin.BackendUser(node: [
"name": "Admin",
"email": "tech@nodes.dk",
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
