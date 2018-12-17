import Vapor
import Fluent
import Sugar

extension AdminPanelUser: Seedable {
    private enum Keys {
        enum Options {
            static let email = "email"
            static let password = "password"
            static let name = "name"
        }
    }

    // default on CommandOption doesn't seem to work as expected, so defining defaults here
    private static var defaultEmail: String { return "admin@admin.com" }
    private static var defaultName: String { return "Test User" }

    public static var options: [CommandOption] {
        return [
            .value(
                name: Keys.Options.email,
                short: "e",
                default: AdminPanelUser.defaultEmail,
                help: ["Change email"]
            ),
            .value(
                name: Keys.Options.password,
                short: "p",
                help: ["Change password"]
            ),
            .value(
                name: Keys.Options.name,
                short: "n",
                default: AdminPanelUser.defaultName,
                help: ["Change name"]
            )
        ]
    }

    public static var help: String {
        return "Seeds a test user with email 'admin@admin.com' and the supplied password."
    }

    public convenience init(command: CommandContext) throws {
        let password = try command.requireOption(Keys.Options.password)
        let email = command.options[Keys.Options.email] ?? AdminPanelUser.defaultEmail
        let name = command.options[Keys.Options.name] ?? AdminPanelUser.defaultName

        try self.init(
            email: email,
            name: name,
            title: "Tester",
            role: .superAdmin,
            password: password
        )
    }
}
