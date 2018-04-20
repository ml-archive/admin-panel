import Vapor

enum AdminPanelError: String, Error {
    case userNotFound
}

extension AdminPanelError: AbortError {
    var identifier: String {
        return rawValue
    }

    var reason: String {
        switch self {
        case .userNotFound: return "The user was not found."
        }
    }

    var status: HTTPResponseStatus {
        switch self {
        case .userNotFound: return .notFound
        }
    }
}
