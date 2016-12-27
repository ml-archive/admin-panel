
public struct HasNumeric: ValidationSuite {
    private static let alphanumeric = "0123456789"
    private static let validCharacters = alphanumeric.characters
    
    public static func validate(input value: String) throws {
        let passed = value
            .lowercased()
            .characters
            .filter(validCharacters.contains)
            .count
        
        if passed == 0 {
            throw error(with: value)
        }
    }
}
