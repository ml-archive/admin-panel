import Leaf
import Reset
import Submissions
import Sugar
import Vapor

internal final class ResetController<U: AdminPanelUserType>: ResetControllerType {

    internal func renderResetPasswordRequestForm(_ req: Request) throws -> Future<Response> {
        let adminPanelConfig: AdminPanelConfig<U> = try req.make()
        try req.addFields(forType: U.self)

        return try req
            .view()
            .render(adminPanelConfig.views.login.requestResetPassword, on: req)
            .encode(for: req)
    }

    internal func resetPasswordRequest(_ req: Request) throws -> Future<Response> {
        let resetConfig: ResetConfig<U> = try req.make()
        let adminPanelConfig: AdminPanelConfig<U> = try req.make()

        return U.RequestReset.create(on: req)
            .flatMap { try U.find(by: $0, on: req) }
            .flatTry { (user: U?) -> Future<Void> in
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
            .map { _ in
                req
                    .redirect(to: "/admin/login")
                    .flash(.success, "Email with reset link sent.")
            }
            .catchFlatMap(handleValidationError(
                path: adminPanelConfig.views.login.requestResetPassword,
                on: req
            ))
    }

    internal func renderResetPasswordForm(_ req: Request) throws -> Future<Response> {
        let resetConfig: ResetConfig<U> = try req.make()
        let adminPanelConfig: AdminPanelConfig<U> = try req.make()
        try req.addFields(forType: U.self)

        let payload = try resetConfig.extractVerifiedPayload(from: req.parameters.next())

        return try U
            .authenticate(using: payload, on: req)
            .unwrap(or: ResetError.userNotFound)
            .flatMap { user in
                guard user.passwordChangeCount == payload.passwordChangeCount else {
                    throw ResetError.tokenAlreadyUsed
                }
                return try req
                    .view()
                    .render(adminPanelConfig.views.login.resetPassword, on: req)
                    .encode(for: req)
            }
    }

    internal func resetPassword(_ req: Request) throws -> Future<Response> {
        let resetConfig: ResetConfig<U> = try req.make()
        let adminPanelConfig: AdminPanelConfig<U> = try req.make()
        let payload = try resetConfig.extractVerifiedPayload(from: req.parameters.next())

        return try U
            .authenticate(using: payload, on: req)
            .unwrap(or: ResetError.userNotFound)
            .try { user in
                guard user.passwordChangeCount == payload.passwordChangeCount else {
                    throw ResetError.tokenAlreadyUsed
                }
            }
            .and(U.ResetPassword.create(on: req))
            .flatMap(to: U.self) { user, resetPassword in
                var user = user
                let password = resetPassword[keyPath: U.ResetPassword.readablePasswordKey]
                user[keyPath: U.passwordKey] = try U.hashPassword(password)
                user.passwordChangeCount += 1
                return user.save(on: req)
            }
            .map { _ in
                req
                    .redirect(to: "/admin/login")
                    .flash(.success, "Your password has been updated.")
            }
            .catchFlatMap(handleValidationError(
                path: adminPanelConfig.views.login.resetPassword,
                on: req
            ))
    }
}
