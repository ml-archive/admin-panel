import Fluent
import Submissions
import Vapor

public func uniqueField<U: Model>(
    keyPath: WritableKeyPath<U, String>,
    value: String?,
    context: ValidationContext,
    accept: String? = nil,
    exceptIn contexts: [ValidationContext] = [],
    on db: DatabaseConnectable
) throws -> Future<[ValidationError]> where U.Database: QuerySupporting{
    return try U.query(on: db)
        .filter(keyPath == value)
        .first()
        .map(to: [ValidationError].self) { model in
            let value = model?[keyPath: keyPath]
            guard model == nil || (value == accept && !contexts.contains(context)) else {
                return [BasicValidationError("\(value ?? "") already exists")]
            }
            return []
        }
}
