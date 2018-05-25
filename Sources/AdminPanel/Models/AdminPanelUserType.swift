import Authentication
import Reset
import Sugar

public protocol AdminPanelUserType:
    UserType,
    PasswordAuthenticatable,
    PasswordResettable,
    SessionAuthenticatable
{}
