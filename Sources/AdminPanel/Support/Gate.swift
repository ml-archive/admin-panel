import Vapor
import HTTP

class Gate {
    
    public static let error = Abort(
        .forbidden,
        metadata: nil,
        reason: "User does not have access to this page"
    )
    
    /// Check if a backend_users.role is allowed to access
    ///
    /// - Parameters:
    ///   - backendUserRole: role from config
    ///   - role: role from config
    /// - Returns: bool
    public static func allow(_ backendUserRole: String, _ role: String) -> Bool {
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
    
    public static func disallow(_ backendUserRole: String, _ role: String) -> Bool {
        return !self.allow(backendUserRole, role)
    }
    
    public static func allowOrFail(_ backendUserRole: String, _ role: String) throws {
        if self.disallow(backendUserRole, role) {
            throw self.error
        }
    }
    
    // MARK : BackendUser
    public static func allow(_ backendUser: BackendUser?, _ role: String) -> Bool {
        return self.allow(backendUser?.role ?? "", role)
    }
    
    public static func disallow(_ backendUser: BackendUser?, _ role: String) -> Bool {
        return !self.allow(backendUser, role)
    }
    
    public static func allowOrFail(_ backendUser: BackendUser?, _ role: String) throws {
        if self.disallow(backendUser, role) {
            throw self.error
        }
    }
    
    // MARK: User
    public static func allow(_ request: Request, _ role: String) -> Bool {
        guard let backendUser = request.auth.authenticated(BackendUser.self) else {
            return false
        }
        return self.allow(backendUser.role, role)
    }
    
    public static func disallow(_ request: Request, _ role: String) -> Bool {
        return !self.allow(request, role)
    }
    
    public static func allowOrFail(_ request: Request, _ role: String) throws {
        if self.disallow(request, role) {
            throw self.error
        }
    }
}
