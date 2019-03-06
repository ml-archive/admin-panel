import Leaf
import Reset
import Submissions
import Sugar
import Vapor

final class ResetController<U: AdminPanelUserType>: Reset.ResetController<U> {

    override func resetPasswordRequest(_ req: Request) throws -> Future<Response> {
        let adminPanelConfig: AdminPanelConfig<U> = try req.make()
        return try super.resetPasswordRequest(req)
            .catchFlatMap(handleValidationError(
                path: adminPanelConfig.views.login.requestResetPassword,
                on: req
            ))
    }

    override func resetPassword(_ req: Request) throws -> Future<Response> {
        let adminPanelConfig: AdminPanelConfig<U> = try req.make()
        return try super.resetPassword(req)
            .catchFlatMap(handleValidationError(
                path: adminPanelConfig.views.login.resetPassword,
                on: req
            ))
    }
}
