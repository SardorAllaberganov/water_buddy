//
//  GoalSetupUITests.swift
//  WaterBuddyUITests
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import XCTest

/// The one seam the unit suite structurally cannot reach: that tapping *Get Started* actually
/// swaps the app's root from `GoalSetupView` to `HomeView`.
///
/// `DailyGoalSetupTests` already proves the model half — that `saveDailyGoal(ml:)` flips
/// `isGoalSet` and invalidates its observers. What no injected `UserDefaults` can show is whether
/// SwiftUI re-evaluates `RootView` off that invalidation and renders the other branch. That needs
/// the real app, which is what this target is for (rule `85-testing`).
///
/// Deliberately idempotent rather than assuming a fresh install: setup is a state that exists once
/// per install, so a test that *required* it would pass once and fail on every run after. It
/// completes setup if it is showing, and either way asserts the app proper is on screen.
final class GoalSetupUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false

        // A simulator remembers how it was last rotated, and these cases tap a tab bar that sits
        // off-screen in landscape — a probe once failed with a frame origin of x = 428 on a 393pt
        // canvas for exactly this reason (`tasks/lessons.md`, 2026-08-29). The iPhone is
        // portrait-only now, so this is belt and braces rather than the fix; the suite must not
        // depend on how somebody last left the device.
        XCUIDevice.shared.orientation = .portrait
    }

    @MainActor
    func testCompletingSetupRevealsTheApp() throws {
        let app = XCUIApplication()
        app.launch()

        let getStarted = app.buttons["Get Started"]
        if getStarted.waitForExistence(timeout: 5) {
            // The slider is bound to the default, so this commits 2,000 ml — the amount the
            // screen was already showing.
            getStarted.tap()
        }

        // A quick-add button from `HomeView`'s row, addressed by the accessibility label a bare
        // glyph cannot supply. Its presence is the proof that the root actually swapped and drew.
        //
        // **Matched on the vessel's name, not on its amount.** The amounts are user-editable now,
        // so `"Glass, add 250 millilitres"` was a literal that any edit would falsify — and this
        // suite is deliberately idempotent and never resets the device, so once someone changed
        // that vessel the assertion would have failed on every run afterwards, for ever. The name
        // is fixed; the number is not.
        let glass = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass")).firstMatch
        XCTAssertTrue(
            glass.waitForExistence(timeout: 5),
            "the root did not swap to HomeView after setup was completed"
        )
    }

    /// The quick-add row, from outside the process.
    ///
    /// The unit suite pins the *menu* — the amounts, their symbols, that they are editable in the
    /// log. What it structurally cannot see is the **accessibility tree**: whether each vessel
    /// surfaces as one button carrying the label VoiceOver will read. That has already gone wrong
    /// once here, when a wrapper meant to group a row instead added a second element and every
    /// serving was announced twice (`tasks/lessons.md`).
    @MainActor
    func testTheQuickAddRowOffersEveryVessel() throws {
        let app = XCUIApplication()
        app.launch()

        let getStarted = app.buttons["Get Started"]
        if getStarted.waitForExistence(timeout: 5) {
            getStarted.tap()
        }

        // The three vessel *names*, which are fixed — never their amounts, which the user edits.
        // Each label reads "<Name>, add <n> millilitres", so a prefix match survives any edit while
        // still proving the button is the one it claims to be.
        for name in ["Cup", "Glass", "Bottle"] {
            let matching = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", name + ","))
            XCTAssertTrue(
                matching.firstMatch.waitForExistence(timeout: 5),
                "the quick-add row is missing a button for \(name)"
            )
            // Exactly one element per vessel. Two means a wrapper is surfacing alongside the
            // control it was meant to replace, which is inaudible in a screenshot and doubles
            // every announcement.
            XCTAssertEqual(
                matching.count, 1,
                "\(name) resolves to more than one accessibility element"
            )
        }
    }

    /// The tab bar, which is the only route to the log now that `HomeView`'s sheet is gone.
    ///
    /// The unit suite pins the tab *menu* — the set, the order, that every symbol resolves. What it
    /// cannot see is whether tapping one actually swaps the content, which is the entire feature.
    /// Each destination is identified by something only that screen draws: the vessel on Home, the
    /// *Today* heading in the log.
    @MainActor
    func testTheTabBarSwitchesBetweenHomeAndHistory() throws {
        let app = XCUIApplication()
        app.launch()

        let getStarted = app.buttons["Get Started"]
        if getStarted.waitForExistence(timeout: 5) {
            getStarted.tap()
        }

        let vessel = app.otherElements["Today's hydration"]
        let logHeading = app.staticTexts["Today"]

        // The app opens on Home.
        XCTAssertTrue(vessel.waitForExistence(timeout: 5), "the app did not open on the Home tab")

        app.buttons["History"].tap()
        XCTAssertTrue(logHeading.waitForExistence(timeout: 5), "the History tab did not show the log")

        app.buttons["Home"].tap()
        XCTAssertTrue(vessel.waitForExistence(timeout: 5), "the Home tab did not come back")
    }

    /// The week card, and the one thing about it no unit test can see: its shape in the
    /// accessibility tree.
    ///
    /// `HistoryWindowTests` already proves the model half — that `DataManager.history` is
    /// published, windowed and correct. What an injected store cannot show is whether the card
    /// arrives as **one** VoiceOver stop or as one per bar plus one per weekday. This codebase has
    /// shipped a duplicated stop before, and it was visible only in a real accessibility tree
    /// (`tasks/lessons.md`).
    ///
    /// Reachable through ordinary UI because today counts: one serving makes the published window
    /// non-empty, which is what draws the card. No seeded fixture and no launch argument — a test
    /// whose setup can silently no-op is worse than no test, because it is counted.
    @MainActor
    func testLoggingAServingRevealsTheWeekCardAsOneElement() throws {
        let app = XCUIApplication()
        app.launch()

        let getStarted = app.buttons["Get Started"]
        if getStarted.waitForExistence(timeout: 5) {
            getStarted.tap()
        }

        // Addressed by the label the quick-add row supplies, because the control is a bare glyph —
        // and by the vessel's *name* only, since its amount is user-editable.
        let glass = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass")).firstMatch
        XCTAssertTrue(glass.waitForExistence(timeout: 5), "the Home tab's quick-add row did not draw")
        glass.tap()

        app.buttons["History"].tap()

        let card = app.otherElements["Last 7 days"]
        XCTAssertTrue(card.waitForExistence(timeout: 5), "the week card did not draw after a serving")
        XCTAssertEqual(
            app.otherElements.matching(identifier: "Last 7 days").count, 1,
            "the card must resolve to exactly one element, not one per bar"
        )
    }

    /// `HomeView`'s *Today's log* button and its sheet were removed when the log became a tab.
    /// Two routes to one destination is the thing the tab bar was meant to replace, not to join.
    @MainActor
    func testHomeNoLongerCarriesTheOldSheetButton() throws {
        let app = XCUIApplication()
        app.launch()

        let getStarted = app.buttons["Get Started"]
        if getStarted.waitForExistence(timeout: 5) {
            getStarted.tap()
        }

        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5))
        XCTAssertFalse(
            app.buttons["Today's log"].exists,
            "the sheet button survived the move to a tab, so the log has two front doors"
        )
    }

    /// Settings became the bar's third destination, and this is the seam no unit test can reach:
    /// `AppTabTests` pins the *menu* — three cases, in order, each with a resolving symbol — while
    /// what actually matters is that tapping the slot swaps the content, and that it is reachable
    /// from **Home**. It used to be a sheet presented from a gear in `HistoryView`'s header, so
    /// before the move there was no route to it from Home at all.
    @MainActor
    func testSettingsIsReachableFromHomeAsATab() throws {
        let app = XCUIApplication()
        app.launch()

        let getStarted = app.buttons["Get Started"]
        if getStarted.waitForExistence(timeout: 5) {
            getStarted.tap()
        }

        XCTAssertTrue(
            app.otherElements["Today's hydration"].waitForExistence(timeout: 5),
            "the app did not open on Home"
        )

        let settings = app.buttons["Settings"]
        XCTAssertTrue(
            settings.waitForExistence(timeout: 5),
            "Settings is not reachable from Home, so it is still the log's sheet"
        )

        settings.tap()
        // The goal slider is drawn only by `SettingsView`, so its presence is the proof the tab
        // swapped the content rather than merely highlighting a slot.
        XCTAssertTrue(
            app.sliders["Daily water goal"].waitForExistence(timeout: 5),
            "the Settings tab did not show the settings screen"
        )

        // And the log's header must not keep its own entry point beside the tab. Two routes to one
        // destination is exactly what the tab bar replaced, not something it joins.
        app.buttons["History"].tap()
        XCTAssertTrue(app.staticTexts["Today"].waitForExistence(timeout: 5))
        XCTAssertEqual(
            app.buttons.matching(identifier: "Settings").count, 1,
            "two controls labelled Settings — the tab, and the log's old gear"
        )
    }

    /// Guards the extraction of `AuroraBackground` and `PressStyle` out of `HomeView.swift`:
    /// the vessel is a single accessibility element, and it is the thing that would go missing
    /// if the view tree came apart.
    @MainActor
    func testTheAppShowsTheHydrationVessel() throws {
        let app = XCUIApplication()
        app.launch()

        let getStarted = app.buttons["Get Started"]
        if getStarted.waitForExistence(timeout: 5) {
            getStarted.tap()
        }

        XCTAssertTrue(
            app.otherElements["Today's hydration"].waitForExistence(timeout: 5),
            "HomeView's vessel is missing"
        )
    }
}
