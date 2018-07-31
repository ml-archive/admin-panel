import Fluent
import Reset
import Submissions
import Sugar
import Validation
import Vapor

extension AdminPanelUser: Submittable {
    public struct Submission: SubmissionType {
        let email: String?
        let name: String?
        let title: String?
        let password: String?
        let passwordAgain: String?
        let shouldResetPassword: Bool?
        let shouldSpecifyPassword: Bool?

        public init(_ user: AdminPanelUser?) {
            email = user?.email
            name = user?.name
            title = user?.title
            password = nil
            passwordAgain = nil
            shouldResetPassword = user?.shouldResetPassword
            shouldSpecifyPassword = true
        }

        public func fieldEntries() throws -> [FieldEntry<AdminPanelUser>] {
            return try [
                makeFieldEntry(
                    keyPath: \Submission.email,
                    label: "Email address",
                    asyncValidators: [{ email, _, adminPanelUser, req in
                        validateThat(
                            only: adminPanelUser,
                            has: email,
                            for: \AdminPanelUser.email,
                            on: req
                        )
                    }]
                ),
                makeFieldEntry(
                    keyPath: \.name,
                    label: "Name",
                    validators: [.count(2...191)]
                ),
                makeFieldEntry(
                    keyPath: \.title,
                    label: "Title",
                    validators: [.count(...191)],
                    isRequired: false
                ),
                makeFieldEntry(
                    keyPath: \.password,
                    label: "Password",
                    validators: [.count(8...)],
                    isRequired: false
                ),
                makeFieldEntry(
                    keyPath: \.passwordAgain,
                    label: "Password again",
                    validators: [.count(8...)],
                    isRequired: false
                ),
                makeFieldEntry(
                    keyPath: \.shouldResetPassword,
                    label: "Should reset password",
                    isRequired: false
                ),
                makeFieldEntry(
                    keyPath: \.shouldSpecifyPassword,
                    label: "Specify password",
                    isRequired: false
                )
            ]
        }
    }

    public struct Create: Decodable {
        let email: String
        let name: String
        let title: String?
        let password: String
        let shouldResetPassword: Bool?
        let shouldSpecifyPassword: Bool?
    }

    public convenience init(_ create: Create) throws {
        let password: String
        if create.shouldSpecifyPassword == true {
            password = create.password
        } else {
            password = String.randomAlphaNumericString(12)
        }

        try self.init(
            email: create.email,
            name: create.name,
            title: create.title,
            password: AdminPanelUser.hashPassword(password),
            shouldResetPassword: create.shouldResetPassword ?? false
        )
    }

    public func update(_ submission: Submission) throws {
        if let email = submission.email, !email.isEmpty {
            self.email = email
        }

        if let name = submission.name, !name.isEmpty{
            self.name = name
        }

        self.title = submission.title

        if let password = submission.password, !password.isEmpty {
            self.password = try AdminPanelUser.hashPassword(password)
            self.shouldResetPassword = false
        }
    }
}
