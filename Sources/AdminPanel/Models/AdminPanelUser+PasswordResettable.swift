import Fluent
import Foundation
import JWT
import Leaf
import Mailgun
import Reset
import Submissions
import Sugar
import Vapor

extension AdminPanelUser: PasswordResettable {
    public enum AdminPanelResetPasswordContext: HasRequestResetPasswordContext {
        case userRequestedToResetPassword
        case newUserWithoutPassword

        public static func requestResetPassword() -> AdminPanelResetPasswordContext {
            return .userRequestedToResetPassword
        }
    }

    public typealias JWTPayload = ModelPayload<AdminPanelUser>
    public typealias Context = AdminPanelResetPasswordContext

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
                // TODO: add password validator
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

    internal struct ResetPasswordEmail: Codable {
        let url: String
        let expire: Int
    }

    public func sendPasswordReset(
        url: String,
        token: String,
        expirationPeriod: TimeInterval,
        context: AdminPanelResetPasswordContext,
        on req: Request
    ) throws -> Future<Void> {
        guard let mailgun = try? req.make(Mailgun.self) else {
            print("WARNING (AdminPanel): Mailgun not setup - no emails will be sent.")
            return Future.transform(to: (), on: req)
        }

        let config = try req.make(AdminPanelConfig<AdminPanelUser>.self)
        var from: String
        var subject: String
        var view: String
        var expiration: Int

        switch context {
        case .userRequestedToResetPassword:
            from = config.resetPasswordEmail.fromEmail
            subject = config.resetPasswordEmail.subject
            view = config.views.reset.requestResetPasswordEmail
            expiration = Int(expirationPeriod / 60) // Minutes
        case .newUserWithoutPassword:
            from = config.specifyPasswordEmail.fromEmail
            subject = config.specifyPasswordEmail.subject
            view = config.views.reset.newUserResetPasswordEmail
            expiration = Int(expirationPeriod / 86400) // Days
        }

        let emailData = ResetPasswordEmail(url: url, expire: expiration)

        return try req
            .make(LeafRenderer.self)
            .render(view, emailData)
            .map(to: String.self) { view in
                String(bytes: view.data, encoding: .utf8) ?? ""
            }
            .map(to: Mailgun.Message.self) { html in
                Mailgun.Message(
                    from: from,
                    to: self.email,
                    subject: subject,
                    text: "Please turn on html to view this email.",
                    html: html
                )
            }
            .flatMap(to: Response.self) { message in
                try mailgun.send(message, on: req)
            }
            .transform(to: ())
    }

    public func signer(
        for context: AdminPanelResetPasswordContext,
        on container: Container
    ) throws -> ExpireableJWTSigner {
        let resetConfig: ResetConfig<AdminPanelUser> = try container.make()
        let adminPanelConfig: AdminPanelConfig<AdminPanelUser> = try container.make()

        switch context {
        case .userRequestedToResetPassword: return resetConfig.signer
        case .newUserWithoutPassword: return adminPanelConfig.newUserSetPasswordSigner
        }
    }
}
