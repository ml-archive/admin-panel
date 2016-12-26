import Vapor
import SMTP
import Transport

public class Mailer {
    public static func sendWelcomeMail(drop: Droplet, backendUser: BackendUser, password: String?) throws {
        let credentials = SMTPCredentials(
            user: drop.config["mail", "user"]?.string ?? "",
            pass: drop.config["mail", "password"]?.string ?? ""
        )
        
        let from = EmailAddress(name: drop.config["mail", "fromName"]?.string ?? "Default name",
                                address: drop.config["mail", "fromEmail"]?.string ?? "Default email")
        
        let html = try drop.view.make("Emails/welcome", [
            "name": Node(Configuration.shared?.name.string ?? "Project"),
            "backendUser": try backendUser.toBackendView(),
            "password": Node(password ?? ""),
            "showPassword": password != nil ? true : false,
            "url": "https://google.com"
        ]).data.string()
        
        let email: SMTP.Email = Email(from: from,
                                      to: backendUser.email.value,
                                      subject: "Welcome to Admin Panel",
                                      body: EmailBody(type: .html, content: html))
        
        
        let client = try SMTPClient<TCPClientStream>(host: "smtp.mailgun.org", port: 465, securityLayer: SecurityLayer.tls(nil))
        
        try client.send(email, using: credentials)
    }
}

