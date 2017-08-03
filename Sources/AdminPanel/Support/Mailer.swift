import Vapor
import SMTP
import Transport
import Sockets

public class Mailer {
    public static func initMailer(_ drop: Droplet) throws -> (Mailgun, fromEmail: String, name: String)? {
        guard
            let apiKey = drop.config["mail", "apiKey"]?.string,
            let fromEmail = drop.config["mail", "fromEmail"]?.string,
            let name = Configuration.shared?.name.string
        else {
            return nil
        }

        let domain = drop.config["mail", "domain"]?.string ?? "mg.like.st"
        return try (Mailgun(domain: domain, apiKey: apiKey, EngineClient.factory), fromEmail, name)
    }

    public static func sendWelcomeMail(drop: Droplet, backendUser: BackendUser, password: String?) throws {
        let url = drop.config["app", "url"]?.string ?? "missing url"
        
        // Generate HTML
        let html = try drop.view.make(Configuration.shared?.welcomeMailViewPath.string ?? "Emails/welcome", [
            "name": Node(Configuration.shared?.name.string ?? "Project"),
            "backendUser": try backendUser.toBackendView(),
            "password": Node(password ?? ""),
            "randomPassword": password != nil ? true : false,
            "url": url
        ]).data.makeString()
        
        if let (mailer, fromEmail, name) = try initMailer(drop) {
            let from = EmailAddress(name: name, address: fromEmail)

            let email: SMTP.Email = Email(
                from: from,
                to: backendUser.email,
                subject: "Welcome to Admin Panel",
                body: EmailBody(type: .html, content: html)
            )

            try mailer.send(email)

        }
    }
    
    public static func sendResetPasswordMail(drop: Droplet, backendUser: BackendUser, token: BackendUserResetPasswordToken) throws {
        let url = drop.config["app", "url"]?.string ?? "missing url"
        
        // Generate HTML
        let html = try drop.view.make(Configuration.shared?.resetPasswordViewPath.string ?? "Emails/reset-password", [
            "name": Node(Configuration.shared?.name.string ?? "Project"),
            "backendUser": try backendUser.toBackendView(),
            "token": token.token,
            "expire": 60,
            "url": url
        ]).data.makeString()
        
        if let (mailer, fromEmail, name) = try initMailer(drop) {
            let from = EmailAddress(name: name, address: fromEmail)

            let email: SMTP.Email = Email(
                from: from,
                to: backendUser.email,
                subject: "Reset password",
                body: EmailBody(type: .html, content: html)
            )

            try mailer.send(email)

        }
    }
}

