import Leaf
import Reset
import Submissions
import Sugar
import Vapor

internal final class ResetController
    <U: AdminPanelUserType>: ResetControllerType
{
    internal func renderResetPasswordRequestForm(_ req: Request) throws -> Future<Response> {
        let adminPanelConfig: AdminPanelConfig<U> = try req.make()
        try req.populateFields(U.RequestReset.self)
        return try req.privateContainer
            .make(LeafRenderer.self)
            .render(adminPanelConfig.views.login.requestResetPassword)
            .encode(for: req)
    }

    internal func resetPasswordRequest(_ req: Request) throws -> Future<Response> {
        let resetConfig: ResetConfig<U> = try req.make()
        let adminPanelConfig: AdminPanelConfig<U> = try req.make()
        let submission = try req.content.decode(U.RequestReset.Submission.self)

        return submission
            .createValid(on: req)
            .flatMap(to: U.RequestReset.self) { _ in
                try U.RequestReset.create(on: req)
            }
            .flatMap(to: U?.self) { try U.find(by: $0, on: req) }
            .flatTry { user -> Future<Void> in
                guard let user = user else {
                    // ignore case where user could not be found to prevent malicious attackers from
                    // finding out which accounts are available on the system
                    return .done(on: req)
                }
                return try resetConfig.reset(
                    user,
                    context: U.Context.requestResetPassword(),
                    on: req
                )
            }
            .map(to: Response.self) { _ in
                req
                    .redirect(to: "/admin/login")
                    .flash(.success, "Email with reset link sent.")
            }
            .catchFlatMap(handleValidationError(
                path: adminPanelConfig.views.login.requestResetPassword,
                on: req)
            )
    }

    internal func renderResetPasswordForm(_ req: Request) throws -> Future<Response> {
        let resetConfig: ResetConfig<U> = try req.make()
        let adminPanelConfig: AdminPanelConfig<U> = try req.make()
        try req.populateFields(U.ResetPassword.self)
        let payload = try resetConfig.extractVerifiedPayload(from: req.parameters.next())

        return try U
            .authenticate(using: payload, on: req)
            .unwrap(or: ResetError.userNotFound)
            .flatMap(to: Response.self) { user in
                guard user.passwordChangeCount == payload.passwordChangeCount else {
                    throw ResetError.tokenAlreadyUsed
                }
                return try req.privateContainer
                    .make(LeafRenderer.self)
                    .render(adminPanelConfig.views.login.resetPassword)
                    .encode(for: req)
            }
    }

    internal func resetPassword(_ req: Request) throws -> Future<Response> {
        let resetConfig: ResetConfig<U> = try req.make()
        let adminPanelConfig: AdminPanelConfig<U> = try req.make()
        let payload = try resetConfig.extractVerifiedPayload(from: req.parameters.next())
        let submission = try req.content.decode(U.ResetPassword.Submission.self)

        return submission
            .createValid(on: req)
            .flatMap(to: U?.self) { _ in
                return try U.authenticate(using: payload, on: req)
            }
            .unwrap(or: ResetError.userNotFound)
            .try { user in
                guard user.passwordChangeCount == payload.passwordChangeCount else {
                    throw ResetError.tokenAlreadyUsed
                }
            }
            .flatMap(to: U.self) { user in
                try U.ResetPassword.create(on: req)
                    .flatMap(to: U.self) { resetPassword in
                        var user = user
                        let password = resetPassword[keyPath: U.ResetPassword.readablePasswordKey]
                        user[keyPath: U.passwordKey] = try U.hashPassword(password)
                        user.passwordChangeCount += 1
                        return user.save(on: req)
                    }
            }
            .map(to: Response.self) { user in
                req
                    .redirect(to: "/admin/login")
                    .flash(.success, "Your password has been updated.")
            }
            .catchFlatMap(handleValidationError(
                path: adminPanelConfig.views.login.resetPassword,
                on: req)
            )
    }
}
