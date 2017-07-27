import Vapor

public struct BackendUserForm {
    static let emptyUser = BackendUserForm()
    
    let name: String
    var nameErrors: [String]
    
    let email: String
    var emailErrors: [String]
    
    let role: String
    var roleErrors: [String]
    
    let password: String
    var passwordErrors: [String]
    
    let repeatPassword: String
    var repeatPasswordErrors: [String]
    
    let sendMail: Bool
    var randomPassword: Bool
    
    var shouldResetPassword: Bool

    init(
        name: String? = nil,
        email: String? = nil,
        role: String? = nil,
        password: String? = nil,
        repeatPassword: String? = nil,
        sendMail: Bool? = nil,
        randomPassword: Bool? = nil,
        shouldResetPassword: Bool? = nil,
        nameErrors: [String] = [],
        emailErrors: [String] = [],
        roleErrors: [String] = [],
        passwordErrors: [String] = [],
        repeatPasswordErrors: [String] = []
    ) {
        self.name = name ?? ""
        self.email = email ?? ""
        self.role = role ?? ""
        self.password = password ?? ""
        self.repeatPassword = repeatPassword ?? ""
        self.sendMail = sendMail ?? false
        self.randomPassword = randomPassword ?? false
        self.shouldResetPassword = shouldResetPassword ?? false
        self.nameErrors = nameErrors
        self.emailErrors = emailErrors
        self.roleErrors = roleErrors
        self.passwordErrors = passwordErrors
        self.repeatPasswordErrors = repeatPasswordErrors
    }

    static func validating(_ content: Content) -> (BackendUserForm, hasErrors: Bool) {
        let name = content["name"]?.string
        let email = content["email"]?.string
        let role = content["role"]?.string
        let shouldResetPassword = content["shouldResetPassword"]?.string != nil
        let sendEmail = content["sendEmail"]?.string != nil
        let password = content["password"]?.string
        let repeatPassword = content["passwordRepeat"]?.string
        
        return validate(
            name: name,
            email: email,
            role: role,
            shouldResetPassword: shouldResetPassword,
            sendEmail: sendEmail,
            password: password,
            repeatPassword: repeatPassword
        )
    }
    
    static func validate(
        name: String?,
        email: String?,
        role: String?,
        shouldResetPassword: Bool?,
        sendEmail: Bool?,
        password: String?,
        repeatPassword: String?
    ) -> (BackendUserForm, hasErrors: Bool) {
        var shouldResetPassword = shouldResetPassword
        var password = password
        var hasErrors = false
        
        var nameErrors: [String] = []
        var emailErrors: [String] = []
        var passwordErrors: [String] = []
        var repeatPasswordErrors: [String] = []
        var roleErrors: [String] = []
        
        let requiredFieldError = "Field is required"
        if name == nil {
            nameErrors.append(requiredFieldError)
            hasErrors = true
        }
        
        if email == nil {
            emailErrors.append(requiredFieldError)
            hasErrors = true
        }
        
        if role == nil {
            roleErrors.append(requiredFieldError)
            hasErrors = true
        }
        
        let nameCharactercount = name?.utf8.count ?? 0
        if nameCharactercount < 1 || nameCharactercount > 191 {
            nameErrors.append("Must be between 1 and 191 characters long")
            hasErrors = true
        }
        
        let emailCharactercount = email?.utf8.count ?? 0
        if emailCharactercount < 1 || emailCharactercount > 191 {
            emailErrors.append("Must be between 1 and 191 characters long")
            hasErrors = true
        }
        
        if (role?.utf8.count ?? 0) > 191 {
            nameErrors.append("Must be less than 191 characters long")
            hasErrors = true
        }

        if password != repeatPassword {
            repeatPasswordErrors.append("Passwords do not match")
            hasErrors = true
        }

        let randomPassword = (password?.isEmpty ?? true) && (repeatPassword?.isEmpty ?? true)
        if randomPassword {
            password = String.randomAlphaNumericString(10)
            shouldResetPassword = true
        } else {
            if let password = password {
                let passwordCharactercount = password.utf8.count
                if passwordCharactercount < 8 || passwordCharactercount > 191 {
                    passwordErrors.append("Must be between 8 and 191 characters long")
                    hasErrors = true
                }
            } else {
                passwordErrors.append(requiredFieldError)
                hasErrors = true
            }

            if let repeatPassword = repeatPassword {
                let passwordRepeatCharacterCount = repeatPassword.utf8.count
                if passwordRepeatCharacterCount < 8 || passwordRepeatCharacterCount > 191 {
                    repeatPasswordErrors.append("Must be between 8 and 191 characters long")
                    hasErrors = true
                }
            } else {
                repeatPasswordErrors.append(requiredFieldError)
                hasErrors = true
            }
        }

        let user = BackendUserForm(
            name: name,
            email: email,
            role: role,
            password: password,
            repeatPassword: repeatPassword,
            sendMail: sendEmail,
            randomPassword: randomPassword,
            shouldResetPassword: shouldResetPassword,
            nameErrors: nameErrors,
            emailErrors: emailErrors,
            roleErrors: roleErrors,
            passwordErrors: passwordErrors,
            repeatPasswordErrors: repeatPasswordErrors
        )

        return (user, hasErrors)
    }
}

extension BackendUserForm: NodeRepresentable {
    public func makeNode(in context: Context?) throws -> Node {
        var node = Node([:])
        
        var nameObj = try Node(node: [
            "label": "Name"
        ])
        if !name.isEmpty {
            try nameObj.set("value", name)
        }
        if !nameErrors.isEmpty {
            try nameObj.set("errors", nameErrors)
        }
        
        var emailObj = try Node(node: [
            "label": "Email",
        ])
        if !email.isEmpty {
            try emailObj.set("value", email)
        }
        if !emailErrors.isEmpty {
            try emailObj.set("errors", emailErrors)
        }
        
        var passwordObj = try Node(node: [
            "label": "Password",
        ])
        if !passwordErrors.isEmpty {
            try passwordObj.set("errors", passwordErrors)
        }

        var passwordRepeatObj = try Node(node: [
            "label": "Repeat password",
        ])
        if !repeatPasswordErrors.isEmpty {
            try passwordRepeatObj.set("errors", repeatPasswordErrors)
        }
        
        var roleObj = try Node(node: [
            "label": "Role",
        ])
        if !role.isEmpty {
            try roleObj.set("value", role)
        }
        if !roleErrors.isEmpty {
            try roleObj.set("errors", roleErrors)
        }

        let shouldResetObj = Node(node: [
            "label": "Should reset password",
            "value": .bool(shouldResetPassword)
        ])

        let sendMailObj = Node(node: [
            "label": "Send mail with info",
            "value": .bool(sendMail)
        ])
        
        try node.set("name", nameObj)
        try node.set("email", emailObj)
        try node.set("password", passwordObj)
        try node.set("role", roleObj)
        try node.set("passwordRepeat", passwordRepeatObj)
        try node.set("shouldResetPassword", shouldResetObj)
        try node.set("sendEmail", sendMailObj)
        
        return node
    }
}
