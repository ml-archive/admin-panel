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

    public typealias Context = AdminPanelResetPasswordContext
    public typealias JWTPayload = ModelPayload<AdminPanelUser>

    public struct RequestReset: HasReadableUsername, SelfCreatable, Submittable {
        public func makeSubmission() -> Submission {
            return Submission(email: email)
        }

        public struct Submission: Decodable, FieldsRepresentable, Reflectable {
            let email: String?

            public static func makeFields(for instance: Submission?) throws -> [Field] {
                return try [Field(
                    keyPath: \.email,
                    instance: instance,
                    label: "Email",
                    validators: [.email]
                )]
            }
        }

        public static let readableUsernameKey: KeyPath<RequestReset, String> = \.email
        public let email: String
    }

    public struct ResetPassword: HasReadablePassword, SelfCreatable, Submittable {
        public func makeSubmission() -> Submission {
            return Submission(password: password, passwordAgain: password)
        }

        public struct Submission: Decodable, FieldsRepresentable, Reflectable {
            let password: String?
            let passwordAgain: String?

            public static func makeFields(for instance: Submission?) throws -> [Field] {
                return try [
                    Field(
                        keyPath: \.password,
                        instance: instance,
                        label: "New password",
                        validators: [.count(8...), .strongPassword()]
                    ),
                    Field(
                        keyPath: \.passwordAgain,
                        instance: instance,
                        label: "New password again",
                        validators: [Validator("") {
                            guard $0 == instance?.password else {
                                throw BasicValidationError("Passwords do not match")
                            }
                        }]
                    )
                ]
            }
        }

        public static let readablePasswordKey: KeyPath<ResetPassword, String> = \.password
        public let password: String
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
            print("WARNING (AdminPanel): Mailgun not set up - no emails will be sent.")
            return req.future()
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
            .view()
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

    public static func expirationPeriod(
        for context: AdminPanelResetPasswordContext
    ) -> TimeInterval {
        switch context {
        case .userRequestedToResetPassword: return 1.hoursInSecs
        case .newUserWithoutPassword: return 30.daysInSecs
        }
    }
}
