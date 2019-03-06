public protocol AdminPanelUserRoleType: LosslessStringConvertible, Comparable, Codable {
    var menuPath: String { get }
}
