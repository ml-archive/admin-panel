import XCTest

@testable import AdminPanel

class BackendUserTests: XCTestCase {
    func testSendEmail() {
        let (form, _) = BackendUserForm.validating(["sendEmail": "true"])
        XCTAssertTrue(form.sendMail)
    }

    func testPasswordsMatch() {
        let (form, hasErrors) = BackendUserForm.validate(
            name: nil,
            email: nil,
            role: nil,
            shouldResetPassword: nil,
            sendEmail: false,
            password: "test",
            repeatPassword: "test"
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
            repeatPassword: "test"
        )

        XCTAssertFalse(form.randomPassword)
        XCTAssertEqual(form.passwordErrors.count, 1)
        XCTAssertEqual(form.repeatPasswordErrors.count, 1)
        XCTAssert(form.password.isEmpty)
        XCTAssertEqual(form.repeatPassword, "test")
    }

    func testErrorOnMissingPasswordRepeat() {
        let (form, _) = BackendUserForm.validate(
            name: nil,
            email: nil,
            role: nil,
            shouldResetPassword: nil,
            sendEmail: nil,
            password: "test",
            repeatPassword: nil
        )

        XCTAssertFalse(form.randomPassword)
        XCTAssertEqual(form.passwordErrors.count, 0)
        XCTAssertEqual(form.repeatPasswordErrors.count, 2)
        XCTAssert(form.repeatPassword.isEmpty)
        XCTAssertEqual(form.password, "test")
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
