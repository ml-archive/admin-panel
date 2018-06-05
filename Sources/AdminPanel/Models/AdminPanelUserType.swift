import Authentication
import Reset
import Submissions
import Sugar

public protocol AdminPanelUserType:
    UserType,
    PasswordAuthenticatable,
    PasswordResettable,
    SessionAuthenticatable
{}
