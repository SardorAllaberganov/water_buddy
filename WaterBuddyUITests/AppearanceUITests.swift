//
//  AppearanceUITests.swift
//  WaterBuddyUITests
//

import XCTest

/// Set C's controls, with Premium held through DEBUG's fresh start (rule `85-testing`; spec
/// `2026-11-22-set-c-design.md` §3.14). One launch per test: a fresh start clears its own suite.
final class AppearanceUITests: XCTestCase {

    override func setUp() { continueAfterFailure = false }

    @MainActor
    private func launch(_ extra: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-WaterBuddyFreshStart", "YES", "-WaterBuddyPremiumHeld", "YES", "-WaterBuddyPremium", "YES"] + extra
        app.launch()
        completeWelcomeIfShown(app)
        return app
    }

    /// A vessel added in the library and put in the middle becomes Home's middle button.
    @MainActor
    func testAVesselAddedAndPutInTheMiddleIsHomesMiddleButton() {
        let app = launch()
        app.buttons["Settings"].firstMatch.tap()
        let row = app.buttons["Your vessels"]
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.tap()

        app.buttons["Add a vessel"].tap()
        let name = app.textFields["Name"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.tap()
        name.typeText("Stanley\n")
        app.buttons["Add to your vessels"].tap()

        app.buttons["Stanley"].tap()
        app.buttons["In place of Glass"].tap()
        app.buttons["Done"].firstMatch.tap()   // the editor
        app.buttons["Done"].firstMatch.tap()   // the library

        app.buttons["Home"].firstMatch.tap()
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Stanley,")).firstMatch.waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass,")).count, 0)
    }

    /// Each vessel in the library is one button. XCUITest lists the screen beneath a sheet with the sheet, so the
    /// count is what the sheet adds (rule `65-accessibility`, the owner's ruling of 2026-10-24).
    @MainActor
    func testEachVesselIsOneButton() {
        let app = launch()
        app.buttons["Settings"].firstMatch.tap()
        let before = ["Cup", "Glass", "Bottle"].map { app.buttons.matching(identifier: $0).count }
        app.buttons["Your vessels"].tap()
        XCTAssertTrue(app.buttons["Add a vessel"].waitForExistence(timeout: 5))
        for (name, count) in zip(["Cup", "Glass", "Bottle"], before) {
            XCTAssertEqual(app.buttons.matching(identifier: name).count - count, 1, "\(name)")
        }
    }

    /// Each theme is one button, and a tap selects it.
    @MainActor
    func testEachThemeIsOneButtonAndATapSelectsIt() {
        let app = launch()
        app.buttons["Settings"].firstMatch.tap()
        let dusk = app.buttons["Dusk"]
        XCTAssertTrue(dusk.waitForExistence(timeout: 5))
        for name in ["Aurora", "Lagoon", "Dusk", "Midnight", "Bloom"] {
            XCTAssertEqual(app.buttons.matching(identifier: name).count, 1, name)
        }
        XCTAssertTrue(app.buttons["Aurora"].isSelected)
        dusk.tap()
        XCTAssertTrue(dusk.isSelected)
        XCTAssertFalse(app.buttons["Aurora"].isSelected)
    }
}
