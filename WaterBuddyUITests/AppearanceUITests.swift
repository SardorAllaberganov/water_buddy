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
        let names = ["Cup", "Glass", "Bottle"]
        // A second button under the row — the `Button` surfaced again with its drawn words, "Cup, 150 ml" — is a
        // second VoiceOver stop (`tasks/lessons.md`, 2026-08-28), and an exact label never matches it.
        let surfaced = { (name: String) in app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", name + ", ")).count }
        let before = names.map { app.buttons.matching(identifier: $0).count }
        let surfacedBefore = names.map(surfaced)
        app.buttons["Your vessels"].tap()
        XCTAssertTrue(app.buttons["Add a vessel"].waitForExistence(timeout: 5))
        for (name, count) in zip(names, before) {
            XCTAssertEqual(app.buttons.matching(identifier: name).count - count, 1, "\(name)")
        }
        for (name, count) in zip(names, surfacedBefore) {
            XCTAssertEqual(surfaced(name) - count, 0, "\(name)'s row is surfaced as a second button")
        }
    }

    /// At the largest text size a vessel's name stays whole (the final review's Minor 5, re-graded by the walk): beside
    /// its glyph and its amount, a row's name had a third of the row, and "Bottle" broke into "Bot-tle" — its text two
    /// lines tall where "Cup"'s is one (rule `65-accessibility`, *Dynamic Type*).
    @MainActor
    func testTheLibrarysNamesStayWholeAtTheLargestSize() {
        let app = launch(["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"])
        app.buttons["Settings"].firstMatch.tap()
        let row = app.buttons["Your vessels"]
        let clear = { (e: XCUIElement) in e.exists && e.isHittable && e.frame.maxY < app.windows.firstMatch.frame.maxY - 160 }
        for _ in 0..<10 where !clear(row) { app.swipeUp() }
        tapWhenReady(row)
        XCTAssertTrue(app.buttons["Add a vessel"].waitForExistence(timeout: 5))
        // The drawn name under each row's button: XCUITest lists it there, though VoiceOver reads the button alone.
        let cup = app.buttons["Cup"].staticTexts["Cup"].firstMatch
        let bottle = app.buttons["Bottle"].staticTexts["Bottle"].firstMatch
        XCTAssertTrue(cup.exists && bottle.exists, "the rows' names are not listed")
        XCTAssertLessThan(bottle.frame.height, cup.frame.height * 1.4,
                          "Bottle's name is \(bottle.frame.height) pt tall, Cup's \(cup.frame.height): it broke across lines")
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

    /// Each icon is one button; choosing one passes iOS's own alert and selects it.
    @MainActor
    func testEachIconIsOneButtonAndAChoiceSelectsIt() {
        let app = launch()
        app.buttons["Settings"].firstMatch.tap()
        let lagoon = app.buttons["Lagoon icon"]
        XCTAssertTrue(lagoon.waitForExistence(timeout: 5))
        for name in ["Aurora", "Lagoon", "Dusk", "Midnight", "Bloom"] {
            XCTAssertEqual(app.buttons.matching(identifier: "\(name) icon").count, 1, name)
        }
        lagoon.tap()
        acceptIconAlert(app)
        // The card marks the icon once iOS's change completes, which is after its alert: wait for it.
        XCTAssertTrue(waitUntilSelected(app.buttons["Lagoon icon"]))
        app.buttons["Aurora icon"].tap()   // leave the simulator on the primary icon
        acceptIconAlert(app)
        XCTAssertTrue(waitUntilSelected(app.buttons["Aurora icon"]))
    }

    /// iOS's own alert after an icon change, dismissed — looked for in the app's tree and in SpringBoard's, since a
    /// system may draw it in either.
    @MainActor
    private func acceptIconAlert(_ app: XCUIApplication) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for alerts in [app.alerts, springboard.alerts] {
            let ok = alerts.buttons.firstMatch
            if ok.waitForExistence(timeout: 5) {
                ok.tap()
                return
            }
        }
    }

    @MainActor
    private func waitUntilSelected(_ element: XCUIElement) -> Bool {
        let selected = XCTNSPredicateExpectation(predicate: NSPredicate(format: "isSelected == true"), object: element)
        return XCTWaiter().wait(for: [selected], timeout: 5) == .completed
    }
}
