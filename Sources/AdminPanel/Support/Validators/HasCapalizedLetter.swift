
public struct HasNumeric: ValidationSuite {
    private static let alphanumeric = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    private static let validCharacters = alphanumeric.characters
    
    public static func validate(input value: String) throws {
        let passed = value
            .characters
            .filter(validCharacters.contains)
            .count
        
        if passed == 0 {
            throw error(with: value)
        }
    }
}
