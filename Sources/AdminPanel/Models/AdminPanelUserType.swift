import Authentication
import Reset
import Submissions
import Sugar

public typealias SidebarMenuPathGenerator<U: AdminPanelUserRoleType> = ((U?) -> String)

public protocol AdminPanelUserType:
    Creatable,
    Loginnable,
    Parameter,
    PasswordAuthenticatable,
    PasswordResettable,
    SessionAuthenticatable,
    Submittable,
    TemplateDataRepresentable,
    Updatable
where
    ID: LosslessStringConvertible,
    Self.Create: Decodable,
    Self.Login: SelfCreatable,
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
    func didCreate(with: Submission, on req: Request) throws -> Future<Void> {
        return req.future()
    }
}

public protocol AdminPanelUserRoleType: LosslessStringConvertible, Comparable, Codable {
    var menuPath: String { get }
}

public extension AdminPanelUserType {
    public func requireRole(_ role: Self.Role?) throws {
        guard
            let myRole = self.role,
            let requiredRole = role,
            myRole >= requiredRole
        else {
            throw Abort(.unauthorized)
        }
    }
}

public extension AdminPanelUserRoleType {
    public static var sidebarMenuPathGenerator: SidebarMenuPathGenerator<Self> {
        return { role in
            role?.menuPath ?? ""
        }
    }
}
