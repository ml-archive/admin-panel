import HTTP
import Vapor

public protocol SSOProtocol {
    init(droplet: Droplet)
    
    func auth(_ request: Request) throws -> Response
    func callback(_ request: Request) throws -> Response
}
