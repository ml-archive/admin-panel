import Vapor
import Fluent
import Sugar

extension User: Seedable {
    private enum Keys {
        enum Options {
            static let email = "email"
            static let password = "password"
            static let name = "name"
        }
    }

    // default on CommandOption doesn't seem to work as expected, so defining defaults here
    private static var defaultEmail: String { return "admin@admin.com" }
    private static var defaultPassword: String { return "admin" }
    private static var defaultName: String { return "Test User" }

    public static var options: [CommandOption] {
        return [
            .value(name: Keys.Options.email, short: "e", default: User.defaultEmail, help: ["Change email"]),
            .value(name: Keys.Options.password, short: "p", default: User.defaultPassword, help: ["Change password"]),
            .value(name: Keys.Options.name, short: "n", default: User.defaultName, help: ["Change name"]),
        ]
    }

    public static var help: String {
        return "Seeds a test user with email 'admin@admin.com' and password 'admin'."
    }

    public convenience init(command: CommandContext) throws {
        let email = command.options[Keys.Options.email] ?? User.defaultEmail
        let password = command.options[Keys.Options.password] ?? User.defaultPassword
        let name = command.options[Keys.Options.name] ?? User.defaultName

        self.init(email: email, password: password, name: name)
    }
}
