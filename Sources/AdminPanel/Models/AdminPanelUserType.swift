import Authentication
import Sugar

public protocol AdminPanelUserType:
    HasPassword,
    UserType,
    PasswordAuthenticatable,
    SessionAuthenticatable
{}
