import XCTest
@testable import AdminPanel

class AdminPanelTests: XCTestCase {
    func testRandomString() {
        let length = 10
        let randomString = String.randomAlphaNumericString(length)
        XCTAssertEqual(randomString.characters.count, length)
    }
    
    static var allTests : [(String, (AdminPanelTests) -> () throws -> Void)] {
        return [
            ("testRandomString", testRandomString),
        ]
    }
}
