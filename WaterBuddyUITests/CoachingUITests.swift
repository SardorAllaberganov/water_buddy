//
//  CoachingUITests.swift
//  WaterBuddyUITests
//
//  Created by Sardor Allaberganov on 30/10/26.
//

import XCTest

/// Set B's controls for a Premium holder (spec `2026-10-30-coaching-design.md` D13): the DEBUG fresh start,
/// cleared at every launch, with `-WaterBuddyPremiumHeld`'s lifetime purchase from no store (rule
/// `85-testing`) — and for a lapsed holder, with `-WaterBuddyCoachingSeed`'s settings left behind and
/// `-WaterBuddyPremium`'s offer (spec `2026-10-31-finish-set-b-design.md` D8). Only `testThePaceLineIsPremiums`
/// needs the clock; the pace's arithmetic is pinned by unit tests.
final class CoachingUITests: XCTestCase {

    /// The paywall's headline: it is open while this is on screen.
    private static let paywallHeadline = "See how you really drink, and what would help."

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    /// A fresh start with `arguments` beside it, past the welcome, on Settings or left on Home.
    @MainActor
    private func launch(_ arguments: [String], toSettings: Bool = true) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-WaterBuddyFreshStart", "YES"] + arguments
        app.launch()
        completeWelcomeIfShown(app)
        guard toSettings else { return app }
        // Straight after the welcome the tab's button can be listed twice while the step leaves; the first
        // match is the bar's (set A's step 4 met this on History, `docs/AI_CONTEXT.md`).
        let settings = app.buttons["Settings"].firstMatch
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
        tapWhenReady(settings)
        return app
    }

    @MainActor
    private func launchHoldingPremium() -> XCUIApplication {
        launch(["-WaterBuddyPremiumHeld", "YES"])
    }

    /// The pace line, by its label, whatever type XCUITest gives the element.
    @MainActor
    private func paceLine(in app: XCUIApplication) -> XCUIElementQuery {
        app.descendants(matching: .any).matching(identifier: "Pace")
    }

    @MainActor
    private func scheduleRow(in app: XCUIApplication) -> XCUIElement {
        let row = app.buttons["Schedule"]
        XCTAssertTrue(row.waitForExistence(timeout: 10), "no Schedule row")
        for _ in 0..<5 where !row.isHittable { app.swipeUp() }
        return row
    }

    /// *Only when behind*, scrolled clear of the tab bar's whole frame. The bar floats over the page's foot, and
    /// XCUITest taps a switch at its control: a run left the switch at y 781–809 under a bar from y 791, read it as
    /// hittable — no scroll — and the touch at (328.5, 795.3), in the corner of the bar's frame, went to the bar
    /// (`docs/AI_CONTEXT.md` #209). Without a bar, `isHittable` alone decides.
    @MainActor
    private func behindSwitch(in app: XCUIApplication) -> XCUIElement {
        let behind = app.switches["Only when behind"]
        XCTAssertTrue(behind.waitForExistence(timeout: 5))
        let bar = app.tabBars.firstMatch
        for _ in 0..<5 where !behind.isHittable || (bar.exists && behind.frame.maxY > bar.frame.minY) {
            app.swipeUp()
        }
        return behind
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
        // Named in full, as the sheet's discs speak it (spec `2026-10-31-finish-set-b-design.md` D5).
        XCTAssertTrue((row.value as? String ?? "").contains("Not on Saturday"), "the row says \(row.value ?? "nothing")")
    }

    /// The last day keeping its reminders cannot be turned off, and says so: dimmed, still selected (D6).
    @MainActor
    func testTheLastDayKeepingRemindersCannotBeTurnedOff() throws {
        let app = launchHoldingPremium()
        tapWhenReady(scheduleRow(in: app))
        XCTAssertTrue(app.buttons["Sunday"].waitForExistence(timeout: 5), "no schedule sheet")

        XCTAssertTrue(app.buttons["Saturday"].isEnabled, "a day was dimmed while six kept their reminders")
        for day in ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"] {
            tapWhenReady(app.buttons[day])
            XCTAssertFalse(app.buttons[day].isSelected, "\(day) kept its reminders")
        }
        let last = app.buttons["Saturday"]
        XCTAssertTrue(last.isSelected, "the last day lost its reminders")
        XCTAssertFalse(last.isEnabled, "the last day keeping reminders can still be tapped")
        XCTAssertTrue(app.buttons["Friday"].isEnabled, "a quiet day cannot come back")
    }

    /// A lapsed holder (D2, D8): what was set keeps working and is spoken as locked; the switch turns off for
    /// free and on only through the paywall; the standard schedule is a free way back.
    @MainActor
    func testALapsedHoldersSettingsKeepWorkingAndTurnOffForFree() throws {
        let app = launch(["-WaterBuddyCoachingSeed", "YES", "-WaterBuddyPremium", "YES"])

        let value = scheduleRow(in: app).value as? String ?? ""
        XCTAssertTrue(value.contains("every 2 hours"), "the row says \(value)")
        XCTAssertTrue(value.contains("Not on Saturday"), "the lapse lost the quiet day: \(value)")
        XCTAssertTrue(value.contains("Premium"), "the lock is not spoken: \(value)")
        XCTAssertEqual(app.buttons.matching(identifier: "Use the standard schedule").count, 1)

        let behind = behindSwitch(in: app)
        XCTAssertEqual(behind.value as? String, "1", "the lapse lost what was set")
        tapWhenReady(behind)
        XCTAssertFalse(app.staticTexts[Self.paywallHeadline].waitForExistence(timeout: 2),
                       "turning the switch off opened the paywall")
        XCTAssertEqual(app.switches["Only when behind"].value as? String, "0", "turning it off is not free")
        tapWhenReady(app.switches["Only when behind"])
        XCTAssertTrue(app.staticTexts[Self.paywallHeadline].waitForExistence(timeout: 5),
                      "turning it back on did not open the paywall")
        app.buttons["Not now"].tap()
        XCTAssertEqual(app.switches["Only when behind"].value as? String, "0", "a lapsed holder's switch turned on")

        tapWhenReady(app.buttons["Use the standard schedule"])
        XCTAssertTrue(app.buttons["Use the standard schedule"].waitForNonExistence(timeout: 3),
                      "the way back stayed after it was taken")
        let standard = scheduleRow(in: app).value as? String ?? ""
        XCTAssertFalse(standard.contains("Not on"), "the standard schedule kept a quiet day: \(standard)")
        // 9 AM and 9 PM, in either clock the device writes; the seed's 5 and 23 carry no "9:00".
        XCTAssertFalse(value.contains("9:00"), "the seed's row already named the standard hours: \(value)")
        XCTAssertTrue(standard.contains("9:00"), "the row still says the seed's hours: \(standard)")
    }

    /// The pace line is Premium's (D4): drawn for a holder, absent for a lapsed one on the same settings.
    /// Only inside the seed's window: before 05:00 nothing is due and from 23:00 every share is, and either
    /// way the line is absent by design (W1) — an absence then would prove nothing.
    @MainActor
    func testThePaceLineIsPremiums() throws {
        let hour = Calendar.current.component(.hour, from: Date())
        try XCTSkipUnless((5..<23).contains(hour),
                          "the seed's pace runs from 05:00 to 23:00, and it is \(hour):00")

        let holder = launch(["-WaterBuddyCoachingSeed", "YES", "-WaterBuddyPremiumHeld", "YES"], toSettings: false)
        XCTAssertTrue(paceLine(in: holder).firstMatch.waitForExistence(timeout: 5), "a holder has no pace line")
        XCTAssertEqual(paceLine(in: holder).count, 1, "the pace line is not one element")
        holder.terminate()

        let lapsed = launch(["-WaterBuddyCoachingSeed", "YES", "-WaterBuddyPremium", "YES"], toSettings: false)
        XCTAssertTrue(lapsed.buttons["Settings"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertFalse(paceLine(in: lapsed).firstMatch.waitForExistence(timeout: 3), "a lapsed holder has a pace line")
    }
}
