import Vapor

public class NotEmpty: ValidationSuite {
    public static func validate(input value: String) throws {
        try Count.min(1).validate(input: value)
    }
}
