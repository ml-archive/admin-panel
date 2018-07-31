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
    associatedtype Role: AdminPanelUserRoleType

    var shouldResetPassword: Bool { get }
    var role: Role { get }
    func didCreate(with: Submission, on req: Request) throws -> Future<Void>
}

extension AdminPanelUserType {
    func didCreate(with: Submission, on req: Request) throws -> Future<Void> {
        return Future.transform(to: (), on: req)
    }
}

public protocol AdminPanelUserRoleType: CustomStringConvertible, Comparable, Codable {}

public extension AdminPanelUserType {
    public func requireRole(_ role: Self.Role) throws {
        guard self.role >= role else {
            throw Abort(.unauthorized)
        }
    }
}
