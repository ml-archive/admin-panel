import Fluent
import Foundation
import JWT
import Reset
import Sugar
import Vapor

extension AdminPanelUser: PasswordResettable {
    public typealias JWTPayload = ModelPayload<AdminPanelUser>

    public struct RequestReset: RequestCreatable, Decodable, HasReadableUsername {
        public static let readableUsernameKey = \RequestReset.email
        public let email: String
    }
    public struct ResetPassword: RequestCreatable, Decodable, HasReadablePassword {
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
