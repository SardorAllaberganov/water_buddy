//
//  CoachingUITests.swift
//  WaterBuddyUITests
//
//  Created by Sardor Allaberganov on 30/10/26.
//

import XCTest

/// Set B's controls for a Premium holder (spec `2026-10-30-coaching-design.md` D13): the DEBUG fresh start,
/// cleared at every launch, with `-WaterBuddyPremiumHeld`'s lifetime purchase from no store (rule
/// `85-testing`). Nothing here needs the clock: the pace line is pinned by unit tests.
final class CoachingUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    @MainActor
    private func launchHoldingPremium() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-WaterBuddyFreshStart", "YES", "-WaterBuddyPremiumHeld", "YES"]
        app.launch()
        completeWelcomeIfShown(app)
        // Straight after the welcome the tab's button can be listed twice while the step leaves; the first
        // match is the bar's (set A's step 4 met this on History, `docs/AI_CONTEXT.md`).
        let settings = app.buttons["Settings"].firstMatch
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
        tapWhenReady(settings)
        return app
    }

    @MainActor
    private func scheduleRow(in app: XCUIApplication) -> XCUIElement {
        let row = app.buttons["Schedule"]
        XCTAssertTrue(row.waitForExistence(timeout: 10), "no Schedule row")
        for _ in 0..<5 where !row.isHittable { app.swipeUp() }
        return row
    }

    @MainActor
    func testTheScheduleSheetsControlsAreOneElementEach() throws {
        let app = launchHoldingPremium()
        XCTAssertEqual(app.buttons.matching(identifier: "Schedule").count, 1)
        XCTAssertEqual(app.switches.matching(identifier: "Only when behind").count, 1)
        tapWhenReady(scheduleRow(in: app))

        XCTAssertTrue(app.buttons["Every 2 hours"].waitForExistence(timeout: 5), "no schedule sheet")
        // A `Menu` is listed as a button on iOS 27. Should XCUITest type it otherwise on a runtime, count it by
        // that type — never narrow the query to make one pass (rule `65-accessibility`).
        for label in ["First reminder", "Last reminder", "Every hour", "Every 2 hours", "Every 3 hours"] {
            XCTAssertEqual(app.buttons.matching(identifier: label).count, 1, "\(label) is not one element")
        }
        XCTAssertFalse(app.buttons["Standard schedule"].exists, "the standard schedule offers itself")
        for day in ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"] {
            XCTAssertEqual(app.buttons.matching(identifier: day).count, 1, "\(day) is not one element")
            XCTAssertTrue(app.buttons[day].isSelected, "\(day) does not keep its reminders")
        }
        XCTAssertTrue(app.buttons["Every 2 hours"].isSelected)
        XCTAssertEqual(app.buttons.matching(identifier: "Done").count, 1)
    }

    @MainActor
    func testAChangeInTheSheetShowsInTheRow() throws {
        let app = launchHoldingPremium()
        tapWhenReady(scheduleRow(in: app))

        tapWhenReady(app.buttons["Every 3 hours"])
        XCTAssertTrue(app.buttons["Every 3 hours"].isSelected)
        tapWhenReady(app.buttons["Saturday"])
        XCTAssertFalse(app.buttons["Saturday"].isSelected, "Saturday kept its reminders")
        XCTAssertTrue(app.buttons["Standard schedule"].waitForExistence(timeout: 3))
        app.buttons["Done"].tap()

        let row = scheduleRow(in: app)
        XCTAssertTrue((row.value as? String ?? "").contains("every 3 hours"), "the row says \(row.value ?? "nothing")")
        XCTAssertTrue((row.value as? String ?? "").contains("Sat"), "the quiet day is not in the row")
    }
}
