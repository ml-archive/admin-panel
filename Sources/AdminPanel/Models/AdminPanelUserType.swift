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
}
