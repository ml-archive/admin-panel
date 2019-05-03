import Authentication
import Reset
import Submissions
import Sugar

public protocol AdminPanelUserType:
    Creatable,
    Loginable,
    Parameter,
    PasswordAuthenticatable,
    PasswordResettable,
    SessionAuthenticatable,
    Submittable,
    TemplateDataRepresentable,
    Updatable
where
    Self.Login: Decodable,
    Self.Update: Decodable,
    Self.ResolvedParameter == Future<Self>,
    Self.RequestReset: Submittable,
    Self.ResetPassword: Submittable
{
    associatedtype Role: AdminPanelUserRoleType

    var shouldResetPassword: Bool { get }
    var role: Role? { get }
    func didCreate(on req: Request) throws -> Future<Void>
}

extension AdminPanelUserType {
    public func didCreate(on req: Request) throws -> Future<Void> {
        return req.future()
    }
}

public extension AdminPanelUserType {
    func requireRole(_ role: Self.Role?) throws {
        guard
            let myRole = self.role,
            let requiredRole = role,
            myRole >= requiredRole
        else {
            throw Abort(.unauthorized)
        }
    }
}
