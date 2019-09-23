import Fluent
import Submissions
import Sugar
import Validation
import Vapor

extension AdminPanelUser: Submittable {
    public static func makeAdditionalFields(
        for submission: Submission?,
        given user: AdminPanelUser?
    ) throws -> [Field] {
        return try [
            Field(
                keyPath: \.email,
                instance: submission,
                label: "Email",
                validators: [.email],
                asyncValidators: [{ req, _ in
                    guard let submission = submission else { return req.future([]) }
                    return validateThat(
                        only: user,
                        has: submission.email,
                        for: \.email,
                        on: req
                    )
                }]
            )
        ]
    }

    public func makeSubmission() -> Submission? {
        return Submission(
            email: email,
            name: name,
            title: title,
            role: role?.rawValue,
            oldPassword: role?.rawValue,
            password: nil,
            passwordAgain: nil,
            shouldResetPassword: shouldResetPassword,
            shouldSpecifyPassword: false
        )
    }

    public struct Submission:
        Decodable,
        Reflectable,
        FieldsRepresentable,
        HasUpdatableUsername,
        HasUpdatablePassword
    {
        public static let oldPasswordKey = \Update.oldPassword
        public static let updatablePasswordKey = \Update.password
        public static let updatableUsernameKey = \Update.email

        let email: String?
        let name: String?
        let title: String?
        let role: String?
        let oldPassword: String?
        let password: String?
        let passwordAgain: String?
        let shouldResetPassword: Bool?
        let shouldSpecifyPassword: Bool?

        public static func makeFields(for instance: Submission?) throws -> [Field] {
            let isPasswordRequired = instance?.shouldSpecifyPassword ?? false
            return try [
                Field(
                    keyPath: \.name,
                    instance: instance,
                    label: "Name",
                    validators: [.count(2...191)]
                ),
                Field(
                    keyPath: \.title,
                    instance: instance,
                    label: "Title",
                    validators: [.count(...191)]
                ),
                Field(
                    keyPath: \.role,
                    instance: instance,
                    label: "Role",
                    validators: [.count(...191)]
                ),
                Field(
                    keyPath: \.password,
                    instance: instance,
                    label: "Password",
                    validators: [.count(8...), .strongPassword()],
                    isRequired: isPasswordRequired,
                    isAbsentWhen: .equal(to: "")
                ),
                Field(
                    keyPath: \.passwordAgain,
                    instance: instance,
                    label: "Password again",
                    validators: [Validator("") {
                        guard $0 == instance?.password else {
                            throw BasicValidationError("Passwords do not match")
                        }
                    }],
                    isRequired: isPasswordRequired,
                    isAbsentWhen: .equal(to: "")
                ),
                Field(
                    keyPath: \.shouldResetPassword,
                    instance: instance,
                    label: "Should reset password"
                ),
                Field(
                    keyPath: \.shouldSpecifyPassword,
                    instance: instance,
                    label: "Specify password"
                )
            ]
        }
    }
}
