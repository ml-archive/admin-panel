import MySQL
import Vapor

public enum AdminPanelUserRole: String {
    case superAdmin
    case admin
    case user

    public var weight: UInt {
        switch self {
        case .superAdmin: return 3
        case .admin: return 2
        case .user: return 1
        }
    }

    public typealias RawValue = String

    public init?(rawValue: String?) {
        switch rawValue {
        case AdminPanelUserRole.superAdmin.rawValue: self = .superAdmin
        case AdminPanelUserRole.admin.rawValue: self = .admin
        case AdminPanelUserRole.user.rawValue: self = .user
        default: return nil
        }
    }
}

extension AdminPanelUserRole: ReflectionDecodable {
    public static func reflectDecoded() throws -> (AdminPanelUserRole, AdminPanelUserRole) {
        return (.superAdmin, .admin)
    }
}

extension AdminPanelUserRole: AdminPanelUserRoleType {
    public var menuPath: String {
        switch self {
        case .superAdmin:
            return "AdminPanel/Layout/Partials/Sidebars/superadmin"
        case .admin:
            return "AdminPanel/Layout/Partials/Sidebars/admin"
        case .user:
            return "AdminPanel/Layout/Partials/Sidebars/user"
        }
    }

    public init?(_ description: String) {
        guard let role = AdminPanelUserRole(rawValue: description) else {
            return nil
        }

        self = role
    }

    public var description: String {
        return self.rawValue
    }

    public static func < (lhs: AdminPanelUserRole, rhs: AdminPanelUserRole) -> Bool {
        return lhs.weight < rhs.weight
    }

    public static func == (lhs: AdminPanelUserRole, rhs: AdminPanelUserRole) -> Bool {
        return lhs.weight == rhs.weight
    }
}

extension AdminPanelUserRole: MySQLDataConvertible {
    public func convertToMySQLData() -> MySQLData {
        return MySQLData(string: self.rawValue)
    }

    public static func convertFromMySQLData(_ mysqlData: MySQLData) throws -> AdminPanelUserRole {
        guard let role = AdminPanelUserRole(rawValue: mysqlData.string()) else {
            throw Abort(.internalServerError, reason: "Could not convert MySQLData to AdminPanelUserRole")
        }
        return role
    }
}

extension AdminPanelUserRole: CaseIterable {}
