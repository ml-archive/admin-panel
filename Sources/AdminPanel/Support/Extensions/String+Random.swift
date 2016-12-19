import Foundation
import Random
extension String {
    public static func randomAlphaNumericString(_ length: Int = 64) -> String {
        return CryptoRandom.bytes(length).base64String
    }
}



