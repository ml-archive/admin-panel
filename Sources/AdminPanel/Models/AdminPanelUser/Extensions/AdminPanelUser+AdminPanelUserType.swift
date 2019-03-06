import Reset
import Vapor

extension AdminPanelUser: AdminPanelUserType {
    public typealias Role = AdminPanelUserRole

    public static let usernameKey: WritableKeyPath<AdminPanelUser, String> = \.email
    public static let passwordKey: WritableKeyPath<AdminPanelUser, String> = \.password

    public func didCreate(on req: Request) throws -> Future<Void> {
        struct ShouldSpecifyPassword: Decodable {
            let shouldSpecifyPassword: Bool?
        }

        guard
            try req.content.syncDecode(ShouldSpecifyPassword.self).shouldSpecifyPassword == true
        else {
            let config: ResetConfig<AdminPanelUser> = try req.make()
            return try config.reset(self, context: .newUserWithoutPassword, on: req)
        }

        return req.future()
    }
}
