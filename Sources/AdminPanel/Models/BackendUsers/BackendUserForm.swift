import Vapor

public struct BackendUserForm {
    let name: String
    let email: String
    let role: String
    let password: String
    let sendMail: Bool
    var randomPassword = false
    var shouldResetPassword: Bool? = nil

    public let fielset: [String:Any] = [
        "name": "",
        "email": "",
        "role": "",
        "should_reset_password": true,
        "send_mail": true,
        "password": "",
        "passwordRepeat": ""
    ]

    /*
    public static let fieldset = Fieldset([
        "name": StringField(
            label: "Name",
            String.MinimumLengthValidator(characters: 1),
            String.MaximumLengthValidator(characters: 191)
        ),
        "email": StringField(
            label: "Email",
            String.EmailValidator(),
            String.MinimumLengthValidator(characters: 1),
            String.MaximumLengthValidator(characters: 191)
        ),
        "role": StringField(
            label: "Role",
            String.MaximumLengthValidator(characters: 191)
            //
        ),
        "should_reset_password": BoolField(
            label: "Should reset password"
        ),
        "send_mail": BoolField(
            label: "Send mail with info"
        ),
        "password": StringField(
            label: "Password",
            String.MinimumLengthValidator(characters: 8),
            String.MaximumLengthValidator(characters: 191)
            //TODO check repeat
        ),
        "passwordRepeat": StringField(
            label: "Repeat password",
            String.MinimumLengthValidator(characters: 8),
            String.MaximumLengthValidator(characters: 191)
        ),
        ], requiring: ["name", "email", "role"])
    */
    public init(validatedData: [String: Node]) throws {
        
        guard let name = validatedData["name"]?.string,
        let email = validatedData["email"]?.string,
        let role = validatedData["role"]?.string
        else {
            throw FormError.validationFailed(fieldset: BackendUserForm.fieldset)
        }
        
        self.name = name
        self.email = email
        self.role = role
        
        self.sendMail = validatedData["send_mail"] != nil
    
        if let password = validatedData["password"]?.string {
            self.password = password
        } else {
            password = String.randomAlphaNumericString(8)
            randomPassword = true
        }
        
        if randomPassword {
            shouldResetPassword = true
        } else if validatedData["should_reset_password"] != nil {
            shouldResetPassword = true
        } else if validatedData["password"]?.string != nil {
            shouldResetPassword = false
        }
    }
}
