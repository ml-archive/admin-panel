import XCTest
@testable import AdminPanelTests

class AdminPanelTests: XCTestCase {
    func test() {
        XCTAssertTrue(true)
    }


    static var allTests : [(String, (AdminPanelTests) -> () throws -> Void)] {
        return [
            ("test", test),
        ]
    }
}
