import Vapor
import XCTest

@testable import AdminPanel

class BackendUserTests: XCTestCase {
    func testSendEmail() {
        let content = Content()
        content.append(Node(["sendEmail": "true"]))
        let (form, _) = BackendUserForm.validating(content)
        XCTAssertTrue(form.sendMail)
    }

    func testPasswordsMatch() {
        let (form, hasErrors) = BackendUserForm.validate(
            name: nil,
            email: nil,
            role: nil,
            shouldResetPassword: nil,
            sendEmail: false,
            password: "testtest",
            repeatPassword: "testtest"
        )
        XCTAssert(hasErrors)
        XCTAssertEqual(form.passwordErrors.count, 0)
    }

    func testErrorOnMissingPassword() {
        let (form, _) = BackendUserForm.validate(
            name: nil,
            email: nil,
            role: nil,
            shouldResetPassword: nil,
            sendEmail: nil,
            password: nil,
            repeatPassword: "testtest"
        )

        XCTAssertFalse(form.randomPassword)
        XCTAssertEqual(form.passwordErrors.count, 1)
        XCTAssertEqual(form.repeatPasswordErrors.count, 1)
        XCTAssert(form.password.isEmpty)
        XCTAssertEqual(form.repeatPassword, "testtest")
    }

    func testErrorOnMissingPasswordRepeat() {
        let (form, _) = BackendUserForm.validate(
            name: nil,
            email: nil,
            role: nil,
            shouldResetPassword: nil,
            sendEmail: nil,
            password: "testtest",
            repeatPassword: nil
        )

        XCTAssertFalse(form.randomPassword)
        XCTAssertEqual(form.passwordErrors.count, 0)
        XCTAssertEqual(form.repeatPasswordErrors.count, 2)
        XCTAssert(form.repeatPassword.isEmpty)
        XCTAssertEqual(form.password, "testtest")
    }

    func testPasswordsDoNotMatch() {
        let (form, _) = BackendUserForm.validate(
            name: nil,
            email: nil,
            role: nil,
            shouldResetPassword: nil,
            sendEmail: false,
            password: nil,
            repeatPassword: nil
        )

        XCTAssert(form.randomPassword)
        XCTAssert(form.shouldResetPassword)
        XCTAssertEqual(form.passwordErrors.count, 0)
        XCTAssertEqual(form.repeatPasswordErrors.count, 0)
        XCTAssertFalse(form.password.isEmpty)
    }
}
