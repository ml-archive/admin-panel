public typealias SidebarMenuPathGenerator<U: AdminPanelUserRoleType> = ((U?) -> String)

public extension AdminPanelUserRoleType {
    public static var sidebarMenuPathGenerator: SidebarMenuPathGenerator<Self> {
        return { role in
            role?.menuPath ?? ""
        }
    }
}
