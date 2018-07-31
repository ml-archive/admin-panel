import Authentication
import Reset
import Submissions
import Sugar

public protocol AdminPanelUserType:
    Parameter,
    PasswordAuthenticatable,
    PasswordResettable,
    SessionAuthenticatable,
    Submittable,
    UserType
where
    ID: LosslessStringConvertible,
    Self.ResolvedParameter == Future<Self>
{
    var shouldResetPassword: Bool { get }
    func didCreate(with: Submission, on req: Request) throws -> Future<Void>
}

extension AdminPanelUserType {
    func didCreate(with: Submission, on req: Request) throws -> Future<Void> {
        return Future.transform(to: (), on: req)
    }
}
