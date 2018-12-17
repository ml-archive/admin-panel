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
            .flash(.error, message)
            .view()
            .render(path, on: req)
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
            .flash(.error, message)
            .view()
            .render(path, context, on: req)
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
                .flash(.error, message)
                .view()
                .render(path, context, on: req)
                .encode(for: req)
        }
    }
}
