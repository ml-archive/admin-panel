public typealias SidebarMenuPathGenerator<U: AdminPanelUserRoleType> = ((U?) -> String)

public extension AdminPanelUserRoleType {
    static var sidebarMenuPathGenerator: SidebarMenuPathGenerator<Self> {
        return { role in
            role?.menuPath ?? ""
        }
    }
}
