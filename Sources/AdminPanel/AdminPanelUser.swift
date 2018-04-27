import Authentication
import Sugar

public protocol AdminPanelUser:
    HasPassword,
    UserType,
    PasswordAuthenticatable,
    SessionAuthenticatable
{}
