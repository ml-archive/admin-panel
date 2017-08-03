import HTTP
import Vapor

extension Request {
    public func authedBackendUser() throws -> BackendUser {
        
        guard let backendUser: BackendUser = auth.authenticated(BackendUser.self) else {
            throw Abort(
                .internalServerError,
                reason: "The authed user is not a BackendUser"
            )
        }
        
        return backendUser
    }
}
