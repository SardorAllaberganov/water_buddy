//
//  LiveActivityUITests.swift
//  WaterBuddyUITests
//

import XCTest

/// Settings' *Live Activity* switch (spec `2026-11-27-live-activity-design.md` §6), on DEBUG's fresh start, whose Live
/// Activity owner is built on a silent source: no activity starts, and the switch never outlives its test (rule
/// `85-testing`).
final class LiveActivityUITests: XCTestCase {

    override func setUp() { continueAfterFailure = false }

    /// One switch, off until it is turned on, and turned on and off again by a tap each.
    @MainActor
    func testSettingsCarriesOneLiveActivitySwitch() {
        let app = XCUIApplication()
        app.launchArguments = ["-WaterBuddyFreshStart", "YES"]
        app.launch()
        completeWelcomeIfShown(app)
        app.buttons["Settings"].firstMatch.tap()

        let toggle = app.switches["Live Activity"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5), "Settings carries no Live Activity switch")
        XCTAssertEqual(app.switches.matching(identifier: "Live Activity").count, 1,
                       "the Live Activity switch is not one element")
        scrollClearOfTheBar(toggle, in: app)
        XCTAssertEqual(toggle.value as? String, "0", "the switch is on before anyone turned it on")

        tapWhenReady(toggle)
        let on = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == '1'"), object: toggle)
        XCTAssertEqual(XCTWaiter().wait(for: [on], timeout: 5), .completed, "a tap did not turn the switch on")

        tapWhenReady(toggle)
        let off = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == '0'"), object: toggle)
        XCTAssertEqual(XCTWaiter().wait(for: [off], timeout: 5), .completed, "a second tap did not turn it off")
    }
}
