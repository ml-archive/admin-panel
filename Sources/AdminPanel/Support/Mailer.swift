import Vapor
import SMTP
import Transport

public class Mailer {
    public static func sendWelcomeMail(drop: Droplet, backendUser: BackendUser, password: String?) throws {
        guard let smtpUser = drop.config["mail", "user"]?.string,
            let smtpPassword = drop.config["mail", "password"]?.string,
            let fromName = drop.config["mail", "fromName"]?.string,
            let fromEmail = drop.config["mail", "fromEmail"]?.string,
            let smtpHost = drop.config["mail", "smtpHost"]?.string,
            let smtpPort = drop.config["mail", "smtpPort"]?.int
        else {
                return
        }
        
        let credentials = SMTPCredentials(
            user: smtpUser,
            pass: smtpPassword
        )
        
        let from = EmailAddress(name: fromName, address: fromEmail)
        
        // Generate HTML
        let html = try drop.view.make("Emails/welcome", [
            "name": Node(Configuration.shared?.name.string ?? "Project"),
            "backendUser": try backendUser.toBackendView(),
            "password": Node(password ?? ""),
            "randomPassword": password != nil ? true : false,
            "url": "https://google.com"
        ]).data.string()
        
        
        let email: SMTP.Email = Email(from: from,
                                      to: backendUser.email.value,
                                      subject: "Welcome to Admin Panel",
                                      body: EmailBody(type: .html, content: html))
        
        
        let client = try SMTPClient<TCPClientStream>(host: smtpHost, port: smtpPort, securityLayer: SecurityLayer.tls(nil))
        
        try client.send(email, using: credentials)
    }
}

