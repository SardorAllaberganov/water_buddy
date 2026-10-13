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
    /// `+` in the log's header — Home has a *Today* heading of its own now.
    @MainActor
    func testTheTabBarSwitchesBetweenHomeAndHistory() throws {
        let app = XCUIApplication()
        app.launch()

        let getStarted = app.buttons["Get Started"]
        if getStarted.waitForExistence(timeout: 5) {
            getStarted.tap()
        }

        let vessel = app.otherElements["Today's hydration"]
        let logHeading = app.buttons["Add a serving"]

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
    /// published, windowed and correct. What an injected store cannot show is how the card arrives
    /// in VoiceOver. It was **one** element until the card became the day picker
    /// (`docs/superpowers/specs/2026-10-07-earlier-servings-design.md`), and this test asserted
    /// exactly that. The contract now is one summary stop plus **exactly one button per day** —
    /// never one per bar *and* one per weekday, the duplicated stop this codebase has shipped
    /// before and could see only in a real accessibility tree (`tasks/lessons.md`).
    ///
    /// Reachable through ordinary UI because today counts: one serving makes the published window
    /// non-empty, which is what draws the card. No seeded fixture and no launch argument — a test
    /// whose setup can silently no-op is worse than no test, because it is counted.
    @MainActor
    func testTheWeekCardIsOneSummaryAndOneButtonPerDay() throws {
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

        XCTAssertTrue(
            app.staticTexts["Last 7 days"].waitForExistence(timeout: 5),
            "the week card did not draw after a serving"
        )
        XCTAssertEqual(
            app.descendants(matching: .any).matching(identifier: "Last 7 days").count, 1,
            "the card's summary must resolve to exactly one element"
        )
        for name in Self.dayNames() {
            XCTAssertEqual(
                app.buttons.matching(identifier: name).count, 1,
                "\(name) must be exactly one button on the week card"
            )
        }
        XCTAssertTrue(app.buttons["Today"].isSelected, "the card opens on today")
    }

    /// The whole new path, from outside the process: pick yesterday on the week card, add a serving
    /// with the `+`, and find it under yesterday.
    ///
    /// `EarlierServingTests` pins the model's half. What it cannot see is the card's button, the
    /// sheet opening on the day it was asked for, and the screen following the serving there.
    /// Idempotent like the rest of this suite: it compares yesterday's total before and after rather
    /// than assuming an empty day, because the simulator keeps every serving an earlier run added.
    @MainActor
    func testAServingAddedToYesterdayShowsUnderYesterday() throws {
        let app = XCUIApplication()
        app.launch()

        let getStarted = app.buttons["Get Started"]
        if getStarted.waitForExistence(timeout: 5) {
            getStarted.tap()
        }

        // A serving today is what draws the week card, and with it yesterday's button.
        let glass = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass")).firstMatch
        XCTAssertTrue(glass.waitForExistence(timeout: 5), "the Home tab's quick-add row did not draw")
        glass.tap()

        app.buttons["History"].tap()

        let yesterday = app.buttons[Self.dayNames()[1]]
        XCTAssertTrue(yesterday.waitForExistence(timeout: 5), "the week card has no button for yesterday")
        yesterday.tap()
        XCTAssertTrue(yesterday.isSelected, "tapping a day did not select it")

        // The day's total, off its own button. **Not a count of rows**: a lazy list builds only
        // the rows on screen, so a count stopped moving once a day held more than the screen
        // shows — and with two cards above the servings that is one or two of them
        // (`docs/AI_CONTEXT.md`, known issue #62).
        let before = Self.millilitres(on: yesterday)
        XCTAssertGreaterThanOrEqual(before, 0, "a day's button did not carry its total")

        XCTAssertEqual(
            app.buttons.matching(identifier: "Add a serving").count, 1,
            "the + must resolve to exactly one element"
        )
        app.buttons["Add a serving"].tap()

        XCTAssertTrue(app.datePickers.firstMatch.waitForExistence(timeout: 5), "the sheet did not open on its wheel")
        app.buttons["Save"].tap()

        // Polled, because the figure is parsed out of a sentence and a predicate cannot do that.
        let deadline = Date().addingTimeInterval(5)
        while Self.millilitres(on: yesterday) <= before, Date() < deadline {
            Thread.sleep(forTimeInterval: 0.2)
        }
        XCTAssertGreaterThan(Self.millilitres(on: yesterday), before, "the new serving is not under yesterday")
        XCTAssertTrue(yesterday.isSelected, "the screen did not stay on the day the serving landed on")

        // And it is listed there, as one control. The bar's total comes off the week's figures
        // and would grow over an empty list; and a row is two whole layouts to choose from, which
        // must never both be in the tree — every serving read twice (rule `65-accessibility`).
        let row = app.buttons.matching(NSPredicate(format: "label ENDSWITH %@", " millilitres")).firstMatch
        bringIntoView(row, in: app)
        XCTAssertTrue(row.exists, "yesterday's total grew and no serving is listed under it")
        XCTAssertEqual(
            app.cells.containing(.button, identifier: row.label).firstMatch.buttons.count, 1,
            "a serving must resolve to exactly one button in its row"
        )
    }

    /// A serving row is a control, and all of it is one: the gap between the amount and the time is
    /// most of the row, and a tap there has to open the sheet as a tap on the text does.
    ///
    /// No unit test can see where a tap lands. This one exists because the row once stopped
    /// answering there: on iOS 26.5, drawn on Apple's glass, it took a tap on its text and ignored
    /// one on the bare glass between — while iOS 27.0 took both, so every run on the newer system
    /// passed (`tasks/lessons.md`, 2026-10-10).
    @MainActor
    func testAServingRowOpensItsSheetWhereverItIsTapped() throws {
        let app = XCUIApplication()
        app.launch()

        let getStarted = app.buttons["Get Started"]
        if getStarted.waitForExistence(timeout: 5) {
            getStarted.tap()
        }

        // A serving today is what gives History a row.
        let glass = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass")).firstMatch
        XCTAssertTrue(glass.waitForExistence(timeout: 5), "the Home tab's quick-add row did not draw")
        glass.tap()

        app.buttons["History"].tap()

        let row = app.buttons.matching(NSPredicate(format: "label ENDSWITH %@", " millilitres")).firstMatch
        bringIntoView(row, in: app)
        XCTAssertTrue(row.waitForExistence(timeout: 5), "History shows no serving for today")

        // The row's centre: past the amount, short of the time, on nothing but the pane.
        row.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        let title = app.staticTexts["Edit serving"]
        XCTAssertTrue(title.waitForExistence(timeout: 5), "a tap on the row's bare glass did not open the sheet")

        app.buttons["Cancel"].tap()
        XCTAssertTrue(title.waitForNonExistence(timeout: 5), "Cancel did not dismiss the sheet")
    }

    /// History is one list now, and its second card is new: a heading, exactly once, above the
    /// rows it describes — on a day that has servings to place.
    @MainActor
    func testTheStripIsOneHeadingOverADaysServings() throws {
        let app = launchedOnHome()
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass,")).firstMatch.tap()

        app.buttons["History"].tap()
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 5))

        XCTAssertTrue(app.staticTexts["When you drank"].waitForExistence(timeout: 5), "a day with a serving draws no strip")
        XCTAssertEqual(
            app.descendants(matching: .any).matching(identifier: "When you drank").count, 1,
            "the strip's heading must resolve to exactly one element"
        )
    }

    /// The sheet's three vessels, from outside the process: each is one button, the one whose
    /// amount the sheet shows is selected, and a tap on another moves the slider to its amount.
    ///
    /// Matched by name and compared by value, never by a literal amount: the vessels are the
    /// user's to edit, and this suite never resets the device. Nothing is saved.
    @MainActor
    func testTheSheetsVesselShortcutsSetTheAmount() throws {
        let app = launchedOnHome()
        app.buttons["History"].tap()
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 5))
        app.buttons["Add a serving"].tap()

        let slider = app.sliders["Serving amount"]
        XCTAssertTrue(slider.waitForExistence(timeout: 5), "the sheet did not open")

        for name in ["Cup", "Glass", "Bottle"] {
            XCTAssertEqual(
                app.buttons.matching(identifier: name).count, 1,
                "\(name) must be exactly one button in the sheet"
            )
        }

        // A new serving opens on the Glass's amount, so the Glass is the one selected.
        let glass = app.buttons["Glass"]
        // Unwrapped first: two values that are both missing are equal too.
        let opened = try XCTUnwrap(slider.value as? String, "the slider speaks no amount")
        XCTAssertEqual(opened, glass.value as? String, "the sheet did not open on the Glass's amount")
        XCTAssertTrue(glass.isSelected, "the shortcut whose amount is showing is not marked selected")

        // Low on the capsule and to one side: off its glyph and its figure, on nothing but the
        // control's own surface.
        let bottle = app.buttons["Bottle"]
        bottle.coordinate(withNormalizedOffset: CGVector(dx: 0.12, dy: 0.8)).tap()

        let moved = NSPredicate(format: "value == %@", bottle.value as? String ?? "")
        let set = XCTNSPredicateExpectation(predicate: moved, object: slider)
        XCTAssertEqual(XCTWaiter().wait(for: [set], timeout: 5), .completed, "a tap on the Bottle did not set its amount")
        XCTAssertTrue(bottle.isSelected, "the Bottle was tapped and is not marked selected")
        if glass.value as? String != bottle.value as? String {
            XCTAssertFalse(glass.isSelected, "two vessels of different amounts are both marked selected")
        }

        app.buttons["Cancel"].tap()
        XCTAssertTrue(slider.waitForNonExistence(timeout: 5), "Cancel did not dismiss the sheet")
    }

    /// At the largest text size a shortcut's glyph and its figure do not fit side by side, three
    /// to a row. Shrunk onto one line, the glyphs grew with the text and the figures were what
    /// went: a cup with no number at all, a mug and a *2*, a bottle and an ellipsis — and the
    /// figure is what the button sets.
    ///
    /// A cut-off text cannot be read from outside the process — its label is still the whole
    /// string — so what is asserted is its shape: a figure of three digits is wider than it is
    /// tall, and cut to one character it is not. The digits are counted from the button's own
    /// value, because the vessels are the user's to edit.
    @MainActor
    func testTheSheetsShortcutsDrawTheirAmountsWholeAtTheLargestTextSize() throws {
        // Setup first, at the ordinary size, so this does not depend on the order the suite ran in.
        launchedOnHome().terminate()

        let app = XCUIApplication()
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5), "the app did not open on Home")

        app.buttons["History"].tap()
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 5))
        app.buttons["Add a serving"].tap()
        XCTAssertTrue(app.sliders["Serving amount"].waitForExistence(timeout: 5), "the sheet did not open")

        for name in ["Cup", "Glass", "Bottle"] {
            let shortcut = app.buttons[name]
            XCTAssertTrue(shortcut.exists, "the sheet has no shortcut for \(name)")
            XCTAssertGreaterThanOrEqual(shortcut.frame.height, 44, "\(name) is shorter than a fingertip")

            let figure = shortcut.staticTexts.firstMatch
            XCTAssertTrue(figure.exists, "\(name) draws no figure at all")

            let digits = (shortcut.value as? String ?? "").prefix { $0.isNumber }.count
            XCTAssertGreaterThan(digits, 0, "\(name)'s value did not carry its amount")
            XCTAssertGreaterThanOrEqual(
                figure.frame.width, figure.frame.height * 0.4 * CGFloat(digits),
                "\(name)'s figure was cut short: \(figure.frame) for \(digits) digits"
            )
        }

        app.buttons["Cancel"].tap()
    }

    /// At the largest text size a serving's amount and its time do not fit on one line beside
    /// the glyph. Squeezed onto one, the amount lost its unit — *100…* for *100 ml* — in the one
    /// place a serving says how much it was. So the row draws the first of its layouts that fits
    /// at its own size, and its second puts the time under the amount.
    ///
    /// A cut-off text keeps its whole label, so what is asserted is what prevents it: the time is
    /// under the amount, or the amount is drawn at its own size. The time beside it is the
    /// yardstick for "its own size" — an amount is set a step larger than its time at every text
    /// size, and squeezed onto the time's line it was drawn at 60 % and came out the smaller of
    /// the two: 38 points tall beside 45.
    @MainActor
    func testAServingRowDrawsItsAmountWholeAtTheLargestTextSize() throws {
        // A serving first, at the ordinary size, where the Glass is on screen to be tapped.
        let setup = launchedOnHome()
        setup.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass,")).firstMatch.tap()
        XCTAssertTrue(setup.buttons["Undo"].waitForExistence(timeout: 5), "the Glass was not poured")
        setup.terminate()

        let app = XCUIApplication()
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5), "the app did not open on Home")

        app.buttons["History"].tap()
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 5))

        let row = app.buttons.matching(NSPredicate(format: "label ENDSWITH %@", " millilitres")).firstMatch
        bringIntoView(row, in: app)
        XCTAssertTrue(row.waitForExistence(timeout: 5), "History shows no serving for today")

        // The amount is the row's first text. The time is the one that reads as a time: the
        // vessel's name, when there is one, sits between them in the tree or after them.
        let amount = row.staticTexts.element(boundBy: 0)
        let time = row.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", ":")).firstMatch
        XCTAssertTrue(amount.exists && time.exists, "a row draws an amount and a time")

        let stacked = time.frame.minY >= amount.frame.maxY - 1
        let atItsOwnSize = amount.frame.height >= time.frame.height * 0.95
        XCTAssertTrue(
            stacked || atItsOwnSize,
            "the amount was squeezed onto the time's line: \(amount.frame) beside \(time.frame)"
        )
    }

    /// At the largest text sizes a past day's name and its date do not fit on one line beside
    /// the `+`. Squeezed onto one, the heading was cut — *Saturday, 10 O…*, and in Russian
    /// *Понедельник…*, the date gone altogether — on the one line that says which day is shown.
    ///
    /// A cut-off text keeps its whole label, so what is asserted is its size, against *Today*:
    /// a word that fits its line unshrunk at every size. Squeezed, a past day's heading was
    /// drawn at 60 % of it — 43 points tall beside 72. On a line of its own the longest weekday
    /// in English, *Wednesday*, is drawn at 81 % on a 402-point phone and by its width at about
    /// 73 % on a 375-point one, which is why the line is drawn at seven-tenths and not higher.
    ///
    /// And it stays one heading: the day and its total, once.
    @MainActor
    func testAPastDaysHeadingKeepsItsSizeAtTheLargestTextSize() throws {
        // A serving first, at the ordinary size: it is what draws the week card, and with it
        // yesterday's button.
        let setup = launchedOnHome()
        setup.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass,")).firstMatch.tap()
        XCTAssertTrue(setup.buttons["Undo"].waitForExistence(timeout: 5), "the Glass was not poured")
        setup.terminate()

        let app = XCUIApplication()
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5), "the app did not open on Home")

        app.buttons["History"].tap()
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 5))

        let today = app.staticTexts["Today"]
        XCTAssertTrue(today.exists, "History did not open on today")
        XCTAssertEqual(app.staticTexts.matching(identifier: "Today").count, 1, "History's heading must resolve to exactly one element")
        XCTAssertTrue((today.value as? String ?? "").hasSuffix(" millilitres"), "the heading does not carry the day's total")
        let itsOwnSize = today.frame.height

        let name = Self.dayNames()[1]
        let yesterday = app.buttons[name]
        XCTAssertTrue(yesterday.waitForExistence(timeout: 5), "the week card has no button for yesterday")
        yesterday.tap()
        XCTAssertTrue(yesterday.isSelected, "tapping a day did not select it")

        // The heading is spoken as the day spelled out, which opens with the weekday.
        let headings = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", name))
        let heading = headings.firstMatch
        if !heading.exists { app.swipeDown() }
        XCTAssertTrue(heading.waitForExistence(timeout: 5), "a past day has no heading")
        XCTAssertEqual(headings.count, 1, "a past day's heading must resolve to exactly one element")
        XCTAssertTrue((heading.value as? String ?? "").hasSuffix(" millilitres"), "the heading does not carry the day's total")

        XCTAssertGreaterThanOrEqual(
            heading.frame.height, itsOwnSize * 0.7,
            "the day's name was squeezed onto one line: \(heading.frame) against \(itsOwnSize) for Today"
        )
    }

    // MARK: - Home's header and Undo

    /// The vessel's value ends "… <total> of <goal> millilitres." — the one place a UI test can
    /// read today's total, and why that spoken string keeps its `%d` keys.
    private static func total(in app: XCUIApplication) -> Int {
        let words = (app.otherElements["Today's hydration"].value as? String ?? "").split(separator: " ")
        return words.count > 2 ? Int(words[2]) ?? -1 : -1
    }

    /// Waits until the vessel speaks `total`, and says whether it did.
    private static func waitForTotal(_ total: Int, in app: XCUIApplication) -> Bool {
        let spoken = NSPredicate(format: "value CONTAINS %@", " \(total) of ")
        let reached = XCTNSPredicateExpectation(predicate: spoken, object: app.otherElements["Today's hydration"])
        return XCTWaiter().wait(for: [reached], timeout: 5) == .completed
    }

    @MainActor
    private func launchedOnHome() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()

        let getStarted = app.buttons["Get Started"]
        if getStarted.waitForExistence(timeout: 5) {
            getStarted.tap()
        }
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5), "the app did not open on Home")
        return app
    }

    /// Home's heading is one element, not a date and a title read as two.
    @MainActor
    func testHomeIsHeadedTodayOnce() throws {
        let app = launchedOnHome()

        XCTAssertEqual(
            app.staticTexts.matching(identifier: "Today").count, 1,
            "Home's heading must resolve to exactly one element"
        )
    }

    /// On a screen with less height than the layout wants, the **vessel** gives way — never the
    /// text. The status line can shrink to fit a narrow *width* (`minimumScaleFactor`), and the
    /// column once read that as leave to squeeze it for *height* too: on an iPhone 16, 22 points
    /// shorter than an iPhone 17, the vessel kept its full size and the line under it was drawn
    /// at 72 %. Nothing in the unit suite lays a screen out, and on the taller phone it fitted.
    ///
    /// Compared with the title rather than with a number of points, so the check does not move
    /// with the text size: a 22-point line under a 34-point title is about 0.65 of its height,
    /// and squeezed it was 0.46.
    @MainActor
    func testTheStatusLineIsNeverSqueezedToMakeRoomForTheVessel() throws {
        let app = launchedOnHome()

        let title = app.staticTexts["Today"]
        let status = app.staticTexts.matching(
            NSPredicate(format: "label ENDSWITH %@ OR label == %@", "millilitres to go", "Goal reached")
        ).firstMatch
        XCTAssertTrue(status.waitForExistence(timeout: 5), "Home shows no status line")

        XCTAssertGreaterThanOrEqual(
            status.frame.height, title.frame.height * 0.6,
            "the status line was drawn smaller than its text style — the vessel took its room"
        )
    }

    /// The streak chip shares the title's line, and the title must not pay for it. It did: with
    /// a chip beside it *Today* was drawn at 72 % — 29 points tall where 41 is its style — and
    /// only on a day with a streak, which the suite had never produced on Home. The same squeeze
    /// as the status line's, one row up, and the check above cannot see it: a smaller title only
    /// makes that comparison easier to pass.
    ///
    /// A streak needs no yesterday: today counts once it reaches the goal. So this pours until
    /// the status says so, then compares the title with the status line under it — a 34-point
    /// title over a 22-point line is about 1.5 times its height; squeezed it was 1.1.
    @MainActor
    func testTheTitleKeepsItsSizeBesideTheStreak() throws {
        let app = launchedOnHome()

        let reached = app.staticTexts["Goal reached"]
        let bottle = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Bottle,")).firstMatch
        var pours = 0
        while !reached.exists && pours < 20 {
            bottle.tap()
            pours += 1
            _ = reached.waitForExistence(timeout: 1)
        }
        XCTAssertTrue(reached.exists, "the goal was not reached after \(pours) Bottles")

        let chip = app.descendants(matching: .any).matching(identifier: "Day streak").firstMatch
        XCTAssertTrue(chip.waitForExistence(timeout: 5), "a day that reached its goal shows no streak")
        XCTAssertEqual(
            app.descendants(matching: .any).matching(identifier: "Day streak").count, 1,
            "the streak must resolve to exactly one element"
        )

        let title = app.staticTexts["Today"]
        XCTAssertGreaterThanOrEqual(
            title.frame.height, reached.frame.height * 1.3,
            "the title was drawn smaller than its text style — the chip beside it took its room"
        )
    }

    /// The whole of Undo, from outside the process: a pour offers it, and taking it removes that
    /// pour and nothing else. Idempotent like the rest of this suite — it compares totals rather
    /// than assuming an empty day.
    @MainActor
    func testUndoTakesBackThePourJustMade() throws {
        let app = launchedOnHome()
        let before = Self.total(in: app)
        XCTAssertGreaterThanOrEqual(before, 0, "the vessel's value did not carry today's total")

        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass,")).firstMatch.tap()

        let undo = app.buttons["Undo"]
        XCTAssertTrue(undo.waitForExistence(timeout: 5), "a pour from Home did not offer Undo")
        XCTAssertEqual(app.buttons.matching(identifier: "Undo").count, 1, "Undo resolves to more than one element")
        XCTAssertGreaterThan(Self.total(in: app), before, "the pour did not reach today's total")

        undo.tap()

        XCTAssertTrue(Self.waitForTotal(before, in: app), "Undo did not take the pour back")
        XCTAssertTrue(undo.waitForNonExistence(timeout: 5), "the offer stood after it was taken")
    }

    /// Two pours, one Undo: only the second comes back, and the first pour's timer must not have
    /// cleared the second's offer.
    @MainActor
    func testUndoAfterTwoPoursTakesBackOnlyTheLast() throws {
        let app = launchedOnHome()
        let before = Self.total(in: app)

        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass,")).firstMatch.tap()
        XCTAssertTrue(app.buttons["Undo"].waitForExistence(timeout: 5))
        let afterGlass = Self.total(in: app)
        XCTAssertGreaterThan(afterGlass, before)

        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Cup,")).firstMatch.tap()
        let moved = NSPredicate(format: "NOT (value CONTAINS %@)", " \(afterGlass) of ")
        let poured = XCTNSPredicateExpectation(predicate: moved, object: app.otherElements["Today's hydration"])
        XCTAssertEqual(XCTWaiter().wait(for: [poured], timeout: 5), .completed, "the second pour did not land")

        app.buttons["Undo"].tap()

        XCTAssertTrue(Self.waitForTotal(afterGlass, in: app), "Undo took back something other than the last pour")
    }

    /// An offer lasts eight seconds. Nothing in the unit suite runs the view's timer.
    @MainActor
    func testAnUndoOfferExpires() throws {
        let app = launchedOnHome()

        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass,")).firstMatch.tap()
        let undo = app.buttons["Undo"]
        XCTAssertTrue(undo.waitForExistence(timeout: 5))

        XCTAssertTrue(undo.waitForNonExistence(timeout: 14), "the offer was still standing after its eight seconds")
    }

    /// Undo is for a pour made from this screen, while this screen is up.
    @MainActor
    func testAnUndoOfferDoesNotOutliveItsScreen() throws {
        let app = launchedOnHome()

        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass,")).firstMatch.tap()
        XCTAssertTrue(app.buttons["Undo"].waitForExistence(timeout: 5))

        app.buttons["History"].tap()
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 5))
        app.buttons["Home"].tap()
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5))

        XCTAssertFalse(app.buttons["Undo"].exists, "the offer came back with the tab")
    }

    /// Leaving the app ends the offer, as leaving the tab does. While VoiceOver runs an offer has
    /// no deadline (spec §5.2), and without this an offer made in the morning was still standing
    /// when the app was opened again in the afternoon — one double-tap from deleting a serving
    /// nobody had just poured.
    ///
    /// VoiceOver cannot be switched on from here, so this is told apart from the eight seconds by
    /// the clock: the app is away and back well inside them.
    @MainActor
    func testAnUndoOfferDoesNotOutliveTheAppLeavingTheScreen() throws {
        let app = launchedOnHome()

        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass,")).firstMatch.tap()
        let poured = Date()
        XCTAssertTrue(app.buttons["Undo"].waitForExistence(timeout: 5))

        XCUIDevice.shared.press(.home)
        XCTAssertTrue(app.wait(for: .runningBackground, timeout: 5), "the app did not leave the screen")
        app.activate()
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5))

        XCTAssertLessThan(
            Date().timeIntervalSince(poured), 6,
            "too slow to tell leaving the app from the offer's own eight seconds"
        )
        XCTAssertFalse(app.buttons["Undo"].exists, "the offer was still standing when the app came back")
    }

    /// An older pour's eight seconds must not end a newer pour's offer. The second pour is made
    /// four seconds into the first's timer, and the offer is looked for well after the first's
    /// has run out and well before the second's does. `testUndoAfterTwoPoursTakesBackOnlyTheLast`
    /// presses Undo two seconds in, before either timer has anything to say.
    @MainActor
    func testAnOlderPoursTimerDoesNotEndANewerOffer() throws {
        let app = launchedOnHome()

        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass,")).firstMatch.tap()
        let first = Date()
        XCTAssertTrue(app.buttons["Undo"].waitForExistence(timeout: 5))

        Thread.sleep(until: first.addingTimeInterval(4))
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Cup,")).firstMatch.tap()
        XCTAssertLessThan(
            Date().timeIntervalSince(first), 6.5,
            "too slow: the second pour did not land inside the first pour's eight seconds"
        )

        Thread.sleep(until: first.addingTimeInterval(9.5))
        XCTAssertTrue(app.buttons["Undo"].exists, "the first pour's timer ended the second pour's offer")
    }

    /// A disc answers anywhere on its glass, and so does Undo — not only on the glyph or the
    /// words. Every other test here taps a control at its centre, which is its glyph.
    ///
    /// **What this can see, and what it cannot.** It was seen to fail with the Cup's disc made to
    /// answer only at its foot. It does **not** fail when the pane's content shape is taken away
    /// on iOS 26.5 — the change that makes `testAServingRowOpensItsSheetWhereverItIsTapped` fail
    /// there — nor with the disc answering only on its middle 20 points: a finger's tolerance
    /// reaches the glyph from anywhere on a disc 68 points across. So this pins the outcome on
    /// Home; the row test is the one that pins the content shape.
    @MainActor
    func testADiscAndUndoAnswerOffTheirGlyphs() throws {
        let app = launchedOnHome()
        let before = Self.total(in: app)

        // High on the Cup's disc, clear of the glyph in its middle and inside its circle.
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Cup,")).firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.12)).tap()

        let undo = app.buttons["Undo"]
        XCTAssertTrue(undo.waitForExistence(timeout: 5), "a tap on a disc's bare glass poured nothing")
        XCTAssertGreaterThan(Self.total(in: app), before, "a tap on a disc's bare glass did not reach today's total")

        // At the capsule's leading end, before its first word.
        undo.coordinate(withNormalizedOffset: CGVector(dx: 0.04, dy: 0.5)).tap()

        XCTAssertTrue(Self.waitForTotal(before, in: app), "a tap on Undo's bare glass took nothing back")
    }

    /// At the largest text size *Added 250 ml* and *Undo* do not fit on one line. Shrunk until
    /// they did, the amount was cut short — *Added 25…* — and the amount is what makes the button
    /// safe to press. So the capsule draws the first of its forms that fits unshrunk, and its
    /// last is the two parts one above the other.
    ///
    /// A cut-off text cannot be read from outside the process — its label is still the whole
    /// string — so what is asserted is what prevents it: the amount is either above the word, or
    /// beside it at its own size. The title is the yardstick for "its own size": at this text
    /// size the amount's line is 0.8 of the title's, and squeezed onto one line it was 0.5.
    @MainActor
    func testUndoDrawsItsAmountWholeAtTheLargestTextSize() throws {
        // Setup first, at the ordinary size, so this does not depend on the order the suite ran in.
        launchedOnHome().terminate()

        let app = XCUIApplication()
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5), "the app did not open on Home")

        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass,")).firstMatch.tap()
        let undo = app.buttons["Undo"]
        XCTAssertTrue(undo.waitForExistence(timeout: 5), "a pour from Home did not offer Undo")

        let amount = undo.staticTexts.matching(NSPredicate(format: "label != %@", "Undo")).firstMatch
        let word = undo.staticTexts["Undo"]
        XCTAssertTrue(amount.exists && word.exists, "Undo does not draw both its amount and its word")

        let stacked = word.frame.minY >= amount.frame.maxY - 1
        let atItsOwnSize = amount.frame.height >= app.staticTexts["Today"].frame.height * 0.7
        XCTAssertTrue(
            stacked || atItsOwnSize,
            "the amount was squeezed onto the word's line: \(amount.frame) beside \(word.frame)"
        )

        // Taken back, so the day's total is left as this test found it.
        undo.tap()
    }

    /// The names VoiceOver gives the week card's seven days, today first: "Today", then the six days
    /// before it as full weekdays — formatted the way the app formats them while it follows the
    /// device's language, which is how this suite runs.
    private static func dayNames() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("EEEE")
        let calendar = Calendar.autoupdatingCurrent
        let past = (1...6).compactMap { calendar.date(byAdding: .day, value: -$0, to: Date()) }
        return ["Today"] + past.map(formatter.string(from:))
    }

    /// A day's total, off its button on the week card: the value reads "<n> millilitres".
    @MainActor
    private static func millilitres(on day: XCUIElement) -> Int {
        Int((day.value as? String ?? "").split(separator: " ").first ?? "") ?? -1
    }

    /// Brings a serving row clear of the tab bar. With two cards above the servings, a day's
    /// first row can start under the bar or below the screen, and a lazy list builds only what is
    /// on it.
    @MainActor
    private func bringIntoView(_ row: XCUIElement, in app: XCUIApplication) {
        // Given a moment to be built first: a swipe at a row that is only late scrolls a list
        // that needed no scrolling.
        _ = row.waitForExistence(timeout: 2)

        let bar = app.buttons["History"]
        var swipes = 0
        while swipes < 4, !(row.exists && row.frame.maxY < bar.frame.minY - 8) {
            app.swipeUp()
            swipes += 1
        }
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
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 5))
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
