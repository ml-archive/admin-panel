import Flash
import Leaf
import Vapor

public func handleValidationError(
    path: String,
    message: String = "Something went wrong while validating the form.",
    on req: Request
) -> (Error) throws -> Future<Response> {
    return { error in
        try req
            .privateContainer
            .flash(.error, message)
            .make(LeafRenderer.self)
            .render(path, [String: String]())
            .encode(for: req)
    }
}

public func handleValidationError<E: Encodable>(
    path: String,
    message: String = "Something went wrong while validating the form.",
    context: E? = nil,
    on req: Request
) -> (Error) throws -> Future<Response> {
    return { error in
        try req
            .privateContainer
            .flash(.error, message)
            .make(LeafRenderer.self)
            .render(path, context)
            .encode(for: req)
    }
}

public func handleValidationError<E: Encodable>(
    path: String,
    message: String = "Something went wrong while validating the form.",
    context: Future<E>,
    on req: Request
) -> (Error) throws -> Future<Response> {
    return { error in
        return context.flatMap(to: Response.self) { context in
            try req
                .privateContainer
                .flash(.error, message)
                .make(LeafRenderer.self)
                .render(path, context)
                .encode(for: req)
        }
    }
}
