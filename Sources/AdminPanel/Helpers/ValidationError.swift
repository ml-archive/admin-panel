import Flash
import Leaf
import Submissions
import Vapor

func handleValidationError(
    path: String,
    message: String = "Something went wrong while validating the form.",
    on req: Request
) -> (Error) throws -> Future<Response> {
    return { error in
        guard error is SubmissionValidationError else {
            throw error
        }
        return try req
            .flash(.error, message)
            .view()
            .render(path, on: req)
            .encode(for: req)
    }
}

func handleValidationError<E: Encodable>(
    path: String,
    message: String = "Something went wrong while validating the form.",
    context: E,
    on req: Request
) -> (Error) throws -> Future<Response> {
    return { error in
        guard error is SubmissionValidationError else {
            throw error
        }
        return try req
            .flash(.error, message)
            .view()
            .render(path, context, on: req)
            .encode(for: req)
    }
}
