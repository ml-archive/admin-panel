import Authentication
import Reset
import Submissions
import Sugar

public typealias SidebarMenuPathGenerator<U: AdminPanelUserRoleType> = ((U) -> String)

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

public protocol AdminPanelUserRoleType: LosslessStringConvertible, Comparable, Codable {
    var menuPath: String { get }
    var weight : UInt { get }
}

public extension AdminPanelUserType {
    public func requireRole(_ role: Self.Role) throws {
        guard self.role >= role else {
            throw Abort(.unauthorized)
        }
    }
}

public extension AdminPanelUserRoleType {
    public static var sidebarMenuPathGenerator: SidebarMenuPathGenerator<Self> {
        return { role in
            role.menuPath
        }
    }
}
