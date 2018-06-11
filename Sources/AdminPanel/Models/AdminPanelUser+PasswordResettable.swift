import Fluent
import Foundation
import JWT
import Reset
import Sugar
import Vapor

extension AdminPanelUser: PasswordResettable {
    public typealias JWTPayload = ModelPayload<AdminPanelUser>

    public struct RequestLink: Decodable, HasReadableUsername {
        public static let readableUsernameKey = \RequestLink.email
        public let email: String
    }
    public struct ResetPassword: Decodable, HasReadablePassword {
        public static let readablePasswordKey = \ResetPassword.password
        public let password: String
    }

    public func sendPasswordReset(
        url: String,
        token: String,
        expirationPeriod: TimeInterval,
        on req: Request
    ) throws -> Future<Void> {
        print(link)
        return .done(on: req)
    }
}
