import Vapor
import SMTP
import Transport
import Sockets

public class Mailer {
    public static func sendWelcomeMail(drop: Droplet, backendUser: BackendUser, password: String?) throws {
        guard let smtpUser = drop.config["mail", "user"]?.string,
            let smtpPassword = drop.config["mail", "password"]?.string,
            let fromEmail = drop.config["mail", "fromEmail"]?.string,
            let smtpHost = drop.config["mail", "smtpHost"]?.string,
            let smtpPort = drop.config["mail", "smtpPort"]?.int,
            let name = Configuration.shared?.name.string
        else {
            return
        }
        
        let credentials = SMTPCredentials(
            user: smtpUser,
            pass: smtpPassword
        )
        
        let from = EmailAddress(name: name, address: fromEmail)
        
        let url = drop.config["app", "url"]?.string ?? "missing url"
        
        // Generate HTML
        let html = try drop.view.make(Configuration.shared?.welcomeMailViewPath.string ?? "Emails/welcome", [
            "name": Node(Configuration.shared?.name.string ?? "Project"),
            "backendUser": try backendUser.toBackendView(),
            "password": Node(password ?? ""),
            "randomPassword": password != nil ? true : false,
            "url": url
        ]).data.makeString()
        
        
        let email: SMTP.Email = Email(from: from,
                                      to: backendUser.email,
                                      subject: "Welcome to Admin Panel",
                                      body: EmailBody(type: .html, content: html))
        
        let stream = try TCPInternetSocket(
            scheme: "smtps",
            hostname: smtpHost,
            port: Port(smtpPort)
        )

        let client = try SMTPClient(stream)
        
        try client.send(email, using: credentials)
    }
    
    public static func sendResetPasswordMail(drop: Droplet, backendUser: BackendUser, token: BackendUserResetPasswordToken) throws {
        guard let smtpUser = drop.config["mail", "user"]?.string,
            let smtpPassword = drop.config["mail", "password"]?.string,
            let fromEmail = drop.config["mail", "fromEmail"]?.string,
            let smtpHost = drop.config["mail", "smtpHost"]?.string,
            let smtpPort = drop.config["mail", "smtpPort"]?.int,
            let name = Configuration.shared?.name.string
            else {
                return
        }
        
        let credentials = SMTPCredentials(
            user: smtpUser,
            pass: smtpPassword
        )
        
        let from = EmailAddress(name: name, address: fromEmail)
        
        let url = drop.config["app", "url"]?.string ?? "missing url"
        
        // Generate HTML
        let html = try drop.view.make(Configuration.shared?.resetPasswordViewPath.string ?? "Emails/reset-password", [
            "name": Node(Configuration.shared?.name.string ?? "Project"),
            "backendUser": try backendUser.toBackendView(),
            "token": token.token,
            "expire": 60,
            "url": url
            ]).data.makeString()
        
        
        let email: SMTP.Email = Email(from: from,
                                      to: backendUser.email,
                                      subject: "Reset password",
                                      body: EmailBody(type: .html, content: html))
        
        let stream = try TCPInternetSocket(
            scheme: "smtps",
            hostname: smtpHost,
            port: Port(smtpPort)
        )
        let client = try SMTPClient(stream)
        
        try client.send(email, using: credentials)
    }
}

