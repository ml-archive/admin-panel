import Fluent
import Submissions
import Vapor

public func validateThat<U: Model, T: Encodable & Equatable & CustomDebugStringConvertible>(
    only entity: U?,
    has value: T?,
    for keyPath: KeyPath<U, T>,
    on db: DatabaseConnectable
) -> Future<[ValidationError]> {
    guard let value = value else {
        return db.future([])
    }

    var query = U.query(on: db)
        .filter(keyPath == value)

    if let entity = entity {
        query = query.filter(U.idKey != entity[keyPath: U.idKey])
    }

    return query
        .count()
        .map { count in
            guard count == 0 else {
                let reason = """
                    A model of type \"\(U.self)\" with value \(value.debugDescription)
                    already exists.
                """
                return [BasicValidationError(reason)]
            }
            return []
        }
}
