import Foundation
import Random
extension String {
    public static func randomAlphaNumericString(_ length: Int = 64) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        for _ in 0 ..< length {
            let rand = Int.random(min: 0, max: Int(len - 1))
            
            
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    public static func random(_ length: Int = 64) -> String {
        return CryptoRandom.bytes(length).base64String
    }
}
