class Gate {
    public func allow(_ backendUser: BackendUser, _ role: String) -> Bool {
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
            if roleObj.slug == backendUser.role {
                return true
            }
        }
        
        
        return false
    }
}
