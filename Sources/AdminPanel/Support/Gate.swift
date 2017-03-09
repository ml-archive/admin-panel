import Vapor

class Gate {
    
    public let error = Abort.custom(status: .forbidden, message: "User does not have access to this page")
    
    /// Check if a backend_users.role is allowed to access
    ///
    /// - Parameters:
    ///   - backendUserRole: role from config
    ///   - role: role from config
    /// - Returns: bool
    public func allow(_ backendUserRole: String, _ role: String) -> Bool {
        guard let roles = Configuration.shared?.roles else {
            print("AdminPanel.Gate missing configuration")
            return false
        }
        
        // Find role
        var foundRoleOpt: Role?
        for roleObj in roles {
            
            if roleObj.slug.lowercased() == role.lowercased() {
                foundRoleOpt = roleObj
            }
        }
        
        // Unwrap
        guard let foundRole = foundRoleOpt else {
            print("AdminPanel.Gate role was not found")
            
            return false
        }
        
        // Not make a list of all roles allowed, which is all roles from found role and above in array
        var allowedRoles: [Role] = []
        for roleObj in roles {
            allowedRoles.append(roleObj)
            
            if roleObj.slug == foundRole.slug {
                break
            }
        }
        
        // Loop allowed routes and check if backendUser has one of them
        for roleObj in allowedRoles {
            if roleObj.slug == backendUserRole {
                return true
            }
        }
        
        
        return false
    }
    
    public func disallow(_ backendUserRole: String, _ role: String) -> Bool {
        return !allow(backendUserRole, role)
    }
    
    public func allowOrFail(_ backendUserRole: String, _ role: String) throws {
        if disallow(backendUserRole, role) {
            throw error
        }
    }
    
    public func allow(_ backendUser: BackendUser, _ role: String) -> Bool {
        return allow(backendUser.role, role)
    }
    
    public func disallow(_ backendUser: BackendUser, _ role: String) -> Bool {
        return !allow(backendUser.role, role)
    }
    
    public func allowOrFail(_ backendUser: BackendUser, _ role: String) throws {
        if disallow(backendUser, role) {
            throw error
        }
    }
}
