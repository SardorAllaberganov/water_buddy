//
//  LanguageUITests.swift
//  WaterBuddyUITests
//

import XCTest

/// Settings' Language row and the sheet it opens from the bottom (spec
/// `2026-11-26-spanish-and-language-selector-design.md` §4), on DEBUG's fresh start, so a language chosen
/// here never outlives its test (rule `85-testing`). One launch per test: a fresh start clears its own suite.
final class LanguageUITests: XCTestCase {

    override func setUp() { continueAfterFailure = false }

    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-WaterBuddyFreshStart", "YES"]
        app.launch()
        completeWelcomeIfShown(app)
        return app
    }

    /// Brings a row on Settings clear of the tab bar (``scrollClearOfTheBar(_:in:)``), and taps it.
    @MainActor
    private func tap(_ row: XCUIElement, in app: XCUIApplication) {
        XCTAssertTrue(row.waitForExistence(timeout: 5), "\(row) is not on Settings")
        scrollClearOfTheBar(row, in: app)
        row.tap()
    }

    /// Settings carries one Language row, one element naming the language the app is in, and none of the
    /// languages themselves: they are the sheet's.
    @MainActor
    func testSettingsCarriesOneLanguageRow() {
        let app = launch()
        app.buttons["Settings"].firstMatch.tap()

        let row = app.buttons["Language"]
        XCTAssertTrue(row.waitForExistence(timeout: 5), "Settings carries no Language row")
        XCTAssertEqual(app.buttons.matching(identifier: "Language").count, 1, "the Language row is not one button")
        XCTAssertEqual(row.value as? String, "Follow device", "the row does not name the language the app is in")
        for name in ["English", "Русский", "O‘zbekcha", "Español"] {
            XCTAssertEqual(app.buttons.matching(identifier: name).count, 0, "\(name) still stands on Settings itself")
        }
    }

    /// The row opens the sheet, where each choice is one button. A tap on *Español* switches the app and
    /// closes the sheet; the row, in Spanish, opens it again, and *Follow device* brings English back.
    @MainActor
    func testTheSheetSwitchesTheAppAndCloses() {
        let app = launch()
        app.buttons["Settings"].firstMatch.tap()
        tap(app.buttons["Language"], in: app)

        let spanish = app.buttons["Español"]
        XCTAssertTrue(spanish.waitForExistence(timeout: 5), "the language sheet did not open")
        for name in ["Follow device", "English", "Русский", "O‘zbekcha", "Español"] {
            XCTAssertEqual(app.buttons.matching(identifier: name).count, 1, "\(name) is not one button in the sheet")
        }
        spanish.tap()

        let closed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: spanish)
        XCTAssertEqual(XCTWaiter().wait(for: [closed], timeout: 5), .completed, "choosing Español did not close the sheet")
        XCTAssertTrue(app.buttons["Configuración"].waitForExistence(timeout: 5), "choosing Español did not switch the app")

        let idioma = app.buttons["Idioma"]
        XCTAssertTrue(idioma.waitForExistence(timeout: 5), "the Language row is not in Spanish")
        XCTAssertEqual(idioma.value as? String, "Español", "the row does not name Español")
        tap(idioma, in: app)

        let follow = app.buttons["Como en el dispositivo"]
        XCTAssertTrue(follow.waitForExistence(timeout: 5), "the sheet did not open in Spanish")
        follow.tap()
        XCTAssertTrue(app.buttons["Settings"].waitForExistence(timeout: 5), "Follow device did not bring English back")
    }
}
