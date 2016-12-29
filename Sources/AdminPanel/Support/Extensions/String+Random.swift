import Foundation
import Random
extension String {
    public static func randomAlphaNumericString(_ length: Int = 64) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        let max = len - 1
        var randomString = ""
        
        for _ in 0 ..< length {
            #if os(Linux)
                let rand = Int(random() % (max + 1))
            #else
                let rand = Int(arc4random_uniform(UInt32(max)))
            #endif
            
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    public static func random(_ length: Int = 64) -> String {
        return CryptoRandom.bytes(length).base64String
    }
}
