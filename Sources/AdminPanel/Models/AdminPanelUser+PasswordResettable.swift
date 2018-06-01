import Fluent
import Foundation
import JWT
import Reset
import Sugar
import Vapor

extension AdminPanelUser: PasswordResettable {
    public typealias JWTPayload = ModelPayload<AdminPanelUser>
    public typealias RequestLinkType = RequestLink
    public typealias ResetPasswordType = ResetPassword

    public struct RequestLink: Decodable, HasReadableUser {
        public let email: String

        public var username: String {
            return email
        }
    }
    public struct ResetPassword: Decodable, HasReadablePassword {
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
