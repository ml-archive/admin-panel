import Fluent
import Foundation
import JWT
import Reset
import Submissions
import Sugar
import Vapor

extension AdminPanelUser: PasswordResettable {
    public typealias JWTPayload = ModelPayload<AdminPanelUser>

    public struct RequestReset: HasReadableUsername, RequestCreatable, Submittable {
        public struct Submission: SubmissionType {
            public func fieldEntries() throws -> [FieldEntry<RequestReset>] {
                return try [makeFieldEntry(keyPath: \.email, label: "Email", validators: [.email])]
            }

            public init(_ requestLink: RequestReset?) {
                self.email = requestLink?.email
            }

            let email: String?
        }

        public struct Create: Decodable {
            let email: String
        }

        public static let readableUsernameKey = \RequestReset.email
        public let email: String

        public init(_ create: Create) throws {
            self.email = create.email
        }
    }

    public struct ResetPassword: HasReadablePassword, RequestCreatable, Submittable {
        public struct Submission: SubmissionType {
            public func fieldEntries() throws -> [FieldEntry<ResetPassword>] {
                #warning("TODO: add password validator")
                return try [makeFieldEntry(keyPath: \.password, label: "Password")]
            }

            public init(_ resetPassword: ResetPassword?) {
                self.password = resetPassword?.password
            }

            let password: String?
        }

        public struct Create: Decodable {
            let password: String
        }

        public static let readablePasswordKey = \ResetPassword.password
        public let password: String

        public init(_ create: Create) throws {
            self.password = create.password
        }
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
