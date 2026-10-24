//
//  PremiumUITests.swift
//  WaterBuddyUITests
//
//  Created by Sardor Allaberganov on 21/10/26.
//

import XCTest

/// Premium's card and sheet (spec `2026-10-21-premium-foundation-design.md` §6). The only class that
/// launches with `-WaterBuddyPremium` (rule `85-testing`). It asserts nothing that needs a product to
/// load: a gate run has no StoreKit configuration, so the plans read as unavailable.
final class PremiumUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    /// One element by its label, whether SwiftUI exposes it as a button or a link.
    private func count(_ label: String, in app: XCUIApplication) -> Int {
        app.buttons.matching(identifier: label).count + app.links.matching(identifier: label).count
    }

    @MainActor
    func testAnOrdinaryRunHasNoPremiumCard() throws {
        let app = XCUIApplication()
        app.launch()
        completeWelcomeIfShown(app)

        app.buttons["Settings"].tap()
        XCTAssertTrue(app.sliders["Daily water goal"].waitForExistence(timeout: 5))
        // The card waits for the first StoreKit read; give it the time it would take to come.
        XCTAssertFalse(app.buttons["See Premium"].waitForExistence(timeout: 3),
                       "the card showed in a run not launched to offer it")
    }

    @MainActor
    func testTheCardLeadsSettingsAndOpensThePaywall() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-WaterBuddyPremium", "YES"]
        app.launch()
        completeWelcomeIfShown(app)

        app.buttons["Settings"].tap()
        let see = app.buttons["See Premium"]
        XCTAssertTrue(see.waitForExistence(timeout: 10), "no Premium card")
        XCTAssertEqual(app.buttons.matching(identifier: "See Premium").count, 1)
        let goal = app.sliders["Daily water goal"]
        XCTAssertTrue(goal.waitForExistence(timeout: 5))
        XCTAssertLessThan(see.frame.minY, goal.frame.minY, "the Premium card is not first")
        tapWhenReady(see)

        XCTAssertTrue(app.staticTexts["See how you really drink, and what would help."].waitForExistence(timeout: 5),
                      "no paywall")
        XCTAssertTrue(app.staticTexts["Logging water is free, always."].exists)
        // Each row is one element carrying its title and its line. Counted by the whole row's label:
        // XCUITest also lists the row's own title beneath it, which VoiceOver does not stop on
        // (`tasks/lessons.md`, 2026-10-17; the owner's ruling, 2026-10-22).
        for title in ["Month view and full history", "Your patterns", "Personal insights", "A monthly recap"] {
            let row = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH %@", title + ", "))
            XCTAssertEqual(row.count, 1, "\(title) is not one element")
        }
        for label in ["Restore Purchases", "Terms of Use", "Privacy Policy", "Not now"] {
            XCTAssertEqual(count(label, in: app), 1, "\(label) is not one element")
        }

        app.buttons["Not now"].tap()
        XCTAssertTrue(see.waitForExistence(timeout: 5), "Not now did not close the paywall")
    }

    /// Step 2 (spec `2026-10-22-month-view-design.md` §6, plan M1): an ordinary run's History has no
    /// *Week · Month* switch.
    @MainActor
    func testAnOrdinaryRunsHistoryHasNoMonthSwitch() throws {
        let app = XCUIApplication()
        app.launch()
        completeWelcomeIfShown(app)

        app.buttons["History"].tap()
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 5))
        // The switch waits for the first StoreKit read; give it the time it would take to come.
        XCTAssertFalse(app.buttons["Month"].waitForExistence(timeout: 3),
                       "the switch showed in a run not launched to offer it")
    }

    /// A free user's Month is the locked month: *See Premium* opens the paywall and *Back to this week*
    /// returns to the week. A holder's month has no UI test (spec §6): holding Premium here would take
    /// a StoreKit testing purchase.
    @MainActor
    func testAFreeUsersMonthIsLockedAndOpensThePaywall() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-WaterBuddyPremium", "YES"]
        app.launch()
        completeWelcomeIfShown(app)

        app.buttons["History"].tap()
        let week = app.buttons["Week"]
        let month = app.buttons["Month"]
        XCTAssertTrue(month.waitForExistence(timeout: 10), "no Week · Month switch")
        XCTAssertEqual(app.buttons.matching(identifier: "Week").count, 1)
        XCTAssertEqual(app.buttons.matching(identifier: "Month").count, 1)
        XCTAssertEqual(month.value as? String, "Premium")
        XCTAssertTrue(week.isSelected)
        tapWhenReady(month)

        let locked = app.staticTexts["Your whole month at a glance"]
        XCTAssertTrue(locked.waitForExistence(timeout: 5), "no locked month")
        XCTAssertTrue(month.isSelected)
        XCTAssertEqual(count("See Premium", in: app), 1, "See Premium is not one element")
        XCTAssertEqual(count("Back to this week", in: app), 1, "Back to this week is not one element")
        tapWhenReady(app.buttons["See Premium"])

        let paywall = app.staticTexts["See how you really drink, and what would help."]
        XCTAssertTrue(paywall.waitForExistence(timeout: 5), "See Premium opened no paywall")
        app.buttons["Not now"].tap()
        XCTAssertTrue(paywall.waitForNonExistence(timeout: 5), "Not now did not close the paywall")

        tapWhenReady(app.buttons["Back to this week"])
        XCTAssertTrue(locked.waitForNonExistence(timeout: 5), "Back to this week left the locked month up")
        XCTAssertTrue(week.isSelected)
    }

    /// Step 4 (spec `2026-10-23-insights-design.md` §3.4, §3.11): the switch's third segment, and a free
    /// user's Insights locked as Month is — *See Premium* opens the paywall, *Back to this week* returns.
    /// A holder's Insights has no UI test, for the month's reason.
    @MainActor
    func testAFreeUsersInsightsAreLockedAndOpenThePaywall() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-WaterBuddyPremium", "YES"]
        app.launch()
        completeWelcomeIfShown(app)

        // The first match: run first in the class, straight after the welcome closed, the tap found two
        // *History* buttons for a moment, and passed alone (the gate of 2026-10-24). The tab bar is not
        // what this test is for.
        app.buttons["History"].firstMatch.tap()
        let week = app.buttons["Week"]
        let insights = app.buttons["Insights"]
        XCTAssertTrue(insights.waitForExistence(timeout: 10), "no Insights segment")
        XCTAssertEqual(app.buttons.matching(identifier: "Insights").count, 1)
        XCTAssertEqual(insights.value as? String, "Premium")
        tapWhenReady(insights)

        let locked = app.staticTexts["A few lines each week on how you drank"]
        XCTAssertTrue(locked.waitForExistence(timeout: 5), "no locked Insights")
        XCTAssertTrue(insights.isSelected)
        XCTAssertEqual(count("See Premium", in: app), 1, "See Premium is not one element")
        tapWhenReady(app.buttons["See Premium"])

        let paywall = app.staticTexts["See how you really drink, and what would help."]
        XCTAssertTrue(paywall.waitForExistence(timeout: 5), "See Premium opened no paywall")
        app.buttons["Not now"].tap()
        XCTAssertTrue(paywall.waitForNonExistence(timeout: 5), "Not now did not close the paywall")

        tapWhenReady(app.buttons["Back to this week"])
        XCTAssertTrue(locked.waitForNonExistence(timeout: 5), "Back to this week left the locked Insights up")
        XCTAssertTrue(week.isSelected)
    }
}
