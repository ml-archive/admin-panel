import VaporForms
import HTTP
import Vapor

extension Request {
    public func authedBackendUser() throws -> BackendUser {
        
        guard let backendUser: BackendUser = try auth.user() as? BackendUser else {
            throw Abort.custom(status: .internalServerError, message: "The authed user is not a BackendUser")
        }
        
        return backendUser
    }
}
