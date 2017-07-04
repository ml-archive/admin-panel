import Vapor

public struct BackendUserForm {
    let name: String
    let email: String
    let role: String
    let password: String
    let sendMail: Bool
    var randomPassword = false
    var repeatPassword = false
    var shouldResetPassword: Bool? = nil

    init(
        name: String,
        email: String,
        role: String,
        password: String,
        sendMail: Bool,
        randomPassword: Bool = false,
        repeatPassword: Bool = false,
        shouldResetPassword: Bool? = nil
    ) {
        self.name = name
        self.email = email
        self.role = role
        self.password = password
        self.sendMail = sendMail
        self.randomPassword = randomPassword
        self.repeatPassword = repeatPassword
        self.shouldResetPassword = shouldResetPassword
    }
    
    static func validating(_ json: JSON) -> (BackendUserForm?, errors: [String]?) {
        return (nil, nil)
    }
    
    static func validating(_ content: Content) -> (BackendUserForm?, errors: [String]?) {
        
        
        return (nil, nil)
    }
    
    static func validate(
        name: String?,
        email: String?,
        role: String?,
        shouldResetPassword: Bool?,
        sendEmail: Bool?,
        password: String?,
        randomPassword: Bool?,
        repeatPassword: Bool?
    ) -> (BackendUserForm?, errors: [String]?) {
        var errors: [String] = []
        
        if name == nil { errors.append("Missing field: `name`") }
        if email == nil { errors.append("Missing field: `email`") }
        if role == nil { errors.append("Missing field: `role`") }
        if shouldResetPassword == nil { errors.append("Missing field: `shouldResetPassword`") }
        if sendEmail == nil { errors.append("Missing field: `sendEmail`") }
        if password == nil { errors.append("Missing field: `password`") }
        if randomPassword == nil { errors.append("Missing field: `randomPassword`") }
        if repeatPassword == nil { errors.append("Missing field: `repeatPassword`") }
        
        guard errors.count == 0 else {
            return (nil, errors)
        }
        
        // TODO: validation
        
        let user = BackendUserForm(
            name: name!,
            email: email!,
            role: role!,
            password: password!,
            sendMail: sendEmail!,
            randomPassword: randomPassword!,
            repeatPassword: repeatPassword!,
            shouldResetPassword: shouldResetPassword!
    )
        
        return (user, nil)
    }
}
