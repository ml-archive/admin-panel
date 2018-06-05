import Fluent
import Submissions
import Sugar
import Validation

extension AdminPanelUser: Submittable {
    public struct Submission: SubmissionType {
        let email: String?
        let name: String?
        let title: String?
        let password: String?
        let passwordAgain: String?

        public init(_ user: AdminPanelUser?) {
            email = user?.email
            name = user?.name
            title = user?.title
            password = nil
            passwordAgain = nil
        }

        public func fieldEntries() throws -> [FieldEntry<AdminPanelUser>] {
            return try [
                makeFieldEntry(
                    keyPath: \Submission.email,
                    label: "Email address",
                    asyncValidators: [{ value, context, submittable, req in
                        return try uniqueField(
                            keyPath: AdminPanelUser.usernameKey,
                            value: value,
                            context: context,
                            accept: submittable?.email,
                            exceptIn: [.create],
                            on: req
                        )
                    }]
                ),
                makeFieldEntry(
                    keyPath: \Submission.name,
                    label: "Name",
                    validators: [.count(5...191)]
                ),
                makeFieldEntry(
                    keyPath: \Submission.title,
                    label: "Title",
                    validators: [.count(5...191)],
                    isRequired: false
                ),
                makeFieldEntry(
                    keyPath: \Submission.password,
                    label: "Password",
                    validators: [.count(8...)],
                    isRequired: false
                ),
                makeFieldEntry(
                    keyPath: \Submission.passwordAgain,
                    label: "Password again",
                    validators: [.count(8...)],
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
    }

    public convenience init(_ create: Create) throws {
        let password: String
        if create.password.count > 0 {
            password = create.password
        } else {
            password = String.randomAlphaNumericString(12)
        }

        try self.init(
            email: create.email,
            name: create.name,
            title: create.title,
            password: AdminPanelUser.hashPassword(password)
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
        }
    }
}
