//
//  DrinksUITests.swift
//  WaterBuddyUITests
//

import XCTest

/// Home's row of drinks, and a drink named and changed in History (spec `2026-11-27-other-drinks-design.md`
/// §5, §6), on DEBUG's fresh start, so no serving poured here outlives its test (rule `85-testing`). One launch
/// per test: a fresh start clears its own suite and store.
final class DrinksUITests: XCTestCase {

    override func setUp() { continueAfterFailure = false }

    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-WaterBuddyFreshStart", "YES"]
        app.launch()
        completeWelcomeIfShown(app)
        return app
    }

    /// Five drinks on Home, each one button, and Water chosen when the app opens (R3).
    @MainActor
    func testHomesRowIsFiveDrinksStartingOnWater() {
        let app = launch()
        for name in ["Water", "Tea", "Coffee", "Juice", "Milk"] {
            let drink = app.buttons[name]
            XCTAssertTrue(drink.waitForExistence(timeout: 5), "Home has no \(name) button")
            XCTAssertEqual(app.buttons.matching(identifier: name).count, 1, "\(name) is not one button")
            XCTAssertEqual(drink.isSelected, name == "Water", "\(name) is the wrong way round: selected \(drink.isSelected)")
        }
    }

    /// Coffee chosen and the Glass poured twice: the choice holds across pours, History names both coffees,
    /// and a serving's sheet opens on its drink and changes it to tea.
    @MainActor
    func testACoffeeHoldsAcrossPoursIsNamedInHistoryAndChangedInItsSheet() {
        let app = launch()
        let coffee = app.buttons["Coffee"]
        XCTAssertTrue(coffee.waitForExistence(timeout: 5), "Home has no Coffee button")
        coffee.tap()
        XCTAssertTrue(app.buttons["Coffee"].isSelected, "Coffee did not become the chosen drink")

        let glass = app.buttons["Glass, add 250 millilitres"]
        XCTAssertTrue(glass.waitForExistence(timeout: 5), "Home has no Glass")
        glass.tap()
        glass.tap()
        XCTAssertTrue(app.buttons["Coffee"].isSelected, "a pour did not keep the chosen drink")

        app.buttons["History"].firstMatch.tap()
        let coffees = app.buttons.matching(identifier: "Coffee, 250 millilitres")
        XCTAssertTrue(coffees.firstMatch.waitForExistence(timeout: 5), "History does not name the coffee")
        XCTAssertEqual(coffees.count, 2, "History does not show both coffees")

        coffees.firstMatch.tap()
        let tea = app.buttons["Tea"]
        XCTAssertTrue(tea.waitForExistence(timeout: 5), "the serving's sheet has no drinks")
        XCTAssertTrue(app.buttons["Coffee"].isSelected, "the sheet did not open on the serving's drink")
        tea.tap()
        app.buttons["Save"].tap()

        XCTAssertTrue(app.buttons["Tea, 250 millilitres"].waitForExistence(timeout: 5), "the sheet did not change the drink")
        XCTAssertEqual(app.buttons.matching(identifier: "Coffee, 250 millilitres").count, 1, "the other coffee changed too")
    }

    /// The sheet's five stand inside its card. *Cancel* starts at the card's leading edge, and the sheet's
    /// margins are equal, so the trailing edge is as far in from the screen's; *Save*'s own frame takes in the
    /// primary surface's ring, 6 pt past the card, and cannot stand for it. On this iPhone the first row ran
    /// past the card to scroll, *Milk* over its rim (the walk, 2026-11-27).
    @MainActor
    func testTheSheetsDrinksStandInsideItsCard() {
        let app = launch()
        app.buttons["History"].firstMatch.tap()
        let add = app.buttons["Add a serving"]
        XCTAssertTrue(add.waitForExistence(timeout: 5), "History has no + button")
        add.tap()

        let cancel = app.buttons["Cancel"]
        XCTAssertTrue(cancel.waitForExistence(timeout: 5), "the sheet did not open")
        let leading = cancel.frame.minX
        let trailing = app.windows.firstMatch.frame.maxX - leading
        for name in ["Water", "Tea", "Coffee", "Juice", "Milk"] {
            let drink = app.buttons[name]
            XCTAssertTrue(drink.exists, "the sheet has no \(name)")
            XCTAssertGreaterThanOrEqual(drink.frame.minX, leading, "\(name) starts outside the card: \(drink.frame)")
            XCTAssertLessThanOrEqual(drink.frame.maxX, trailing, "\(name) runs past the card at \(trailing): \(drink.frame)")
        }
    }
}
