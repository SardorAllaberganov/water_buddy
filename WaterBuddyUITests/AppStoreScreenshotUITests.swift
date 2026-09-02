//
//  AppStoreScreenshotUITests.swift
//  WaterBuddyUITests
//
//  Created by Sardor Allaberganov on 02/09/26.
//

import XCTest

/// The four iPhone screenshots App Store Connect is given, captured by driving the real app.
///
/// **This is not a test.** It asserts almost nothing and proves nothing about the product; it is a
/// capture harness that happens to need XCUITest's ability to tap. It lives in this target because
/// XCUITest is the only thing in the toolchain that can reach the app's own controls — `simctl` can
/// screenshot a simulator but cannot touch it.
///
/// ## Why it is excluded from the gate
///
/// It is **deliberately non-idempotent**, which is the exact opposite of `GoalSetupUITests`' stance
/// ("setup is a state that exists once per install, so a test that *required* it would pass once and
/// fail on every run after"). That is correct for a test and wrong for a screenshot: a capture run
/// must start from a known-empty device or the numbers on screen are whatever the last run left
/// behind, and `GoalSetupView` is unreachable the moment `saveDailyGoal(ml:)` flips `Key.isGoalSet`.
/// So this one *requires* the fresh state and fails loudly without it, and rule `85-testing`'s gate
/// carries `-skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests` to keep it out of the ordinary
/// run. Drive it through `Tools/CaptureScreenshots.sh`, which erases the device first.
///
/// ## Why one method and not four
///
/// The four screens are four *steps of one session*, not four independent cases. Home has to show
/// water, which means the pours have already happened; History has to show those same servings.
/// Splitting them into separate `func test…`s would relaunch between each, and XCTest gives no
/// ordering guarantee across methods — the History shot could be taken before anything was poured.
///
/// ## Capture order is not display order
///
/// `GoalSetupView` exists only until the first goal is committed, so it is shot **first** and named
/// `04`. The names are the App Store ordering; the sequence below is the only one the app permits.
final class AppStoreScreenshotUITests: XCTestCase {

    /// Seconds between quick-add taps.
    ///
    /// `HistoryView` renders a serving's time as `.dateTime.hour().minute()`, so five taps fired back
    /// to back produce five rows stamped with the same minute — which reads as fabricated in a store
    /// listing. 65 s is the smallest gap that guarantees a distinct minute on every row. It costs
    /// ~4m20s of wall clock; set it to 0 to trade the spread for the time.
    private let tapSpacing: TimeInterval = 65

    /// Seconds to let the vessel settle before the shutter.
    ///
    /// `WaterVessel`'s slosh decays as `exp(-elapsed * 1.5)`, the level animates `.smooth(duration:
    /// 0.9)` and the readout `.smooth(duration: 0.5)`. Three seconds leaves the surface at ~1% of the
    /// pour's amplitude with both value animations finished. A shutter fired early catches a
    /// half-drawn number, and that is invisible in a thumbnail.
    private let settle: TimeInterval = 3

    override func setUpWithError() throws {
        continueAfterFailure = false

        // A simulator remembers how it was last rotated, and the app permits landscape on iPhone
        // (`INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone` lists both landscape values). A
        // landscape capture comes out 2868x1320, which is a transposed size App Store Connect
        // rejects for the portrait slot. This is load-bearing here, not belt and braces.
        XCUIDevice.shared.orientation = .portrait
    }

    @MainActor
    func testCaptureAppStoreScreenshots() throws {
        let app = XCUIApplication()
        app.launch()

        // ── 04 · the first-run screen ────────────────────────────────────────────────────────────
        // Shot before anything else, because committing a goal destroys it for the life of the
        // install. Its absence means the device was not erased, and that invalidates every figure
        // in the three shots below — so this is an assertion rather than the `if` the idempotent
        // suite uses.
        let getStarted = app.buttons["Get Started"]
        XCTAssertTrue(
            getStarted.waitForExistence(timeout: 10),
            "GoalSetupView is not showing — the device was not erased before this run, so the "
                + "captured totals would be whatever the last run left behind"
        )
        Thread.sleep(forTimeInterval: settle)
        capture("04-goal-setup")

        getStarted.tap()

        // ── pour, so Home and History have something to show ─────────────────────────────────────
        // Matched on the vessel's *name*, never its amount: the quick-add amounts are user-editable
        // (`Key.servings`), so a label literal like "Glass, add 250 millilitres" would be falsified
        // by any edit — the same reasoning `GoalSetupUITests` records at its own call sites.
        //
        // Bottle + Glass + Cup + Glass + Cup = 500 + 250 + 150 + 250 + 150 = 1,300 ml of the 2,000 ml
        // default goal, i.e. 65%. Deliberately short of the goal: at or above it `HomeView` fires
        // `ConfettiOverlay`, and a screenshot of a celebration is a screenshot of a transient state.
        let vessel = app.otherElements["Today's hydration"]
        XCTAssertTrue(vessel.waitForExistence(timeout: 10), "the root did not swap to HomeView")

        let pours = ["Bottle", "Glass", "Cup", "Glass", "Cup"]
        for (index, name) in pours.enumerated() {
            let button = app.buttons
                .matching(NSPredicate(format: "label BEGINSWITH %@", name + ","))
                .firstMatch
            XCTAssertTrue(
                button.waitForExistence(timeout: 5),
                "the quick-add row is missing a button for \(name)"
            )
            button.tap()
            if index < pours.count - 1 {
                Thread.sleep(forTimeInterval: tapSpacing)
            }
        }

        // ── 01 · Home, with water ────────────────────────────────────────────────────────────────
        Thread.sleep(forTimeInterval: settle)
        capture("01-home")

        // ── 02 · History, populated ──────────────────────────────────────────────────────────────
        app.buttons["History"].tap()
        XCTAssertTrue(
            app.staticTexts["Today"].waitForExistence(timeout: 10),
            "the History tab did not draw"
        )
        // The week card is what makes this shot worth taking rather than a bare list; its absence
        // would mean the pours did not land.
        XCTAssertTrue(
            app.otherElements["Last 7 days"].waitForExistence(timeout: 5),
            "the week card did not draw, so the servings did not register"
        )
        Thread.sleep(forTimeInterval: settle)
        capture("02-history")

        // ── 03 · Settings ────────────────────────────────────────────────────────────────────────
        app.buttons["Settings"].tap()
        XCTAssertTrue(
            app.sliders["Daily water goal"].waitForExistence(timeout: 10),
            "the Settings tab did not draw"
        )
        // Captured at rest. Do not scroll first: a mid-scroll shot with a sliced card reads as
        // broken, and the reminders toggle must stay untouched — flipping it would raise the system
        // notification-authorization alert over the screen (rule `70-privacy`).
        Thread.sleep(forTimeInterval: settle)
        capture("03-settings")
    }

    /// Attaches a full-screen capture under a stable name.
    ///
    /// `XCUIScreen.main.screenshot()` rather than `app.screenshot()`: the App Store slot is the
    /// device's full pixel size (1320x2868 on a 6.9" iPhone) including the status bar, and the
    /// app-scoped variant returns only the application's own frame.
    ///
    /// `.keepAlways` is required — the default lifetime discards attachments from a *passing* test,
    /// which is every run this harness is supposed to have.
    @MainActor
    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

// MARK: - The full census

/// Every screen, every state, every scroll position — 25 shots in one session.
///
/// Separate from `testCaptureAppStoreScreenshots` above, which stays exactly as it is because it
/// produced the shipped v1.0 assets. This one is filtered independently
/// (`-only-testing:…/testCaptureFullScreenCensus`) and, like its sibling, needs a device with no
/// WaterBuddy container. Both are skipped by the gate at class level.
///
/// ## Why one method and not twenty-five
///
/// These are not independent cases; they are 25 steps of one session, and five of the steps are
/// **one-way doors**. XCTest gives no ordering guarantee across methods, so splitting them would
/// let a later state destroy an earlier one non-deterministically:
///
/// | Door | Closes forever |
/// |---|---|
/// | `Get Started` tapped | `GoalSetupView` — `Key.isGoalSet` is never unset |
/// | first pour | the two empty states (Home 0%, History with no week card) |
/// | goal crossed | every below-goal Home state; `hasReachedGoal` latches |
/// | a quick-add slider moved | every `"Glass, add 250 millilitres"` predicate |
/// | language switched | **every English predicate simultaneously**, with no relaunch |
///
/// Water also only goes up cheaply — coming back down means deleting a History row — so the water
/// states are shot in ascending order: 8% → 65% → 88% → 100% → 125%.
extension AppStoreScreenshotUITests {

    /// The unobscured bottom edge on a 440x956 pt device: screen height, less the home indicator,
    /// less the floating tab bar. An element whose `frame.maxY` exceeds this is behind the bar and
    /// is not fully visible however hittable it claims to be.
    private var unobscuredBottom: CGFloat { 956 - 34 - 60 }

    @MainActor
    func testCaptureFullScreenCensus() throws {
        let app = XCUIApplication()
        app.launch()

        let goalSlider = app.sliders["Daily water goal"]
        let vessel = app.otherElements["Today's hydration"]

        // ── 01–03 · GoalSetupView, before the one-way door ───────────────────────────────────────
        let getStarted = app.buttons["Get Started"]
        XCTAssertTrue(
            getStarted.waitForExistence(timeout: 10),
            "GoalSetupView is not showing — the device was not erased before this run"
        )
        XCTAssertEqual(goalSlider.value as? String, "2000 millilitres")
        Thread.sleep(forTimeInterval: settle)
        capture("01-goal-setup-default-2000")

        goalSlider.adjust(toNormalizedSliderPosition: 0.0)
        XCTAssertEqual(goalSlider.value as? String, "1000 millilitres")
        Thread.sleep(forTimeInterval: 1)
        capture("02-goal-setup-min-1000")

        goalSlider.adjust(toNormalizedSliderPosition: 1.0)
        XCTAssertEqual(goalSlider.value as? String, "4000 millilitres")
        Thread.sleep(forTimeInterval: 1)
        capture("03-goal-setup-max-4000")

        // Restore 2,000 before committing. `Get Started` saves whatever the slider shows, and every
        // percentage in the other 22 shots is computed against this number.
        goalSlider.adjust(toNormalizedSliderPosition: 0.333)
        XCTAssertEqual(goalSlider.value as? String, "2000 millilitres")

        // ── 04–05 · the two empty states, before any water ───────────────────────────────────────
        getStarted.tap()
        XCTAssertTrue(vessel.waitForExistence(timeout: 10), "the root did not swap to HomeView")
        XCTAssertEqual(vessel.value as? String, "0 percent. 0 of 2000 millilitres.")
        Thread.sleep(forTimeInterval: settle)
        capture("04-home-empty-0")

        app.buttons["History"].tap()
        XCTAssertTrue(app.staticTexts["Today"].waitForExistence(timeout: 10))
        XCTAssertFalse(
            app.otherElements["Last 7 days"].exists,
            "a week card in the empty state means the device was dirty"
        )
        Thread.sleep(forTimeInterval: settle)
        capture("05-history-empty")

        // ── 06–07 · water, ascending ─────────────────────────────────────────────────────────────
        app.buttons["Home"].tap()
        XCTAssertTrue(vessel.waitForExistence(timeout: 5))
        pour("Cup", in: app)
        Thread.sleep(forTimeInterval: settle)
        XCTAssertEqual(vessel.value as? String, "8 percent. 150 of 2000 millilitres.")
        capture("06-home-sliver-8")

        for (index, name) in ["Bottle", "Glass", "Glass", "Cup"].enumerated() {
            Thread.sleep(forTimeInterval: tapSpacing)
            pour(name, in: app)
            _ = index
        }
        Thread.sleep(forTimeInterval: settle)
        XCTAssertEqual(vessel.value as? String, "65 percent. 1300 of 2000 millilitres.")
        capture("07-home-partial-65")

        // ── 08 · History, five rows, five distinct minutes ───────────────────────────────────────
        app.buttons["History"].tap()
        XCTAssertTrue(app.staticTexts["Today"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.otherElements["Last 7 days"].waitForExistence(timeout: 5))
        XCTAssertEqual(servingRows(in: app).count, 5)
        Thread.sleep(forTimeInterval: settle)
        capture("08-history-populated-5rows-top")

        // ── 09 · the swipe action, revealed but NOT triggered ────────────────────────────────────
        // `allowsFullSwipe: true` (HistoryView.swift:159) means a long swipe DELETES outright, with
        // no confirmation anywhere in the project. `swipeLeft()` has no distance control and scales
        // with element width, so it can cross that threshold on a 440pt row. 40% of the width is a
        // reveal; anything more is a destruction.
        let firstRow = servingRows(in: app).firstMatch
        XCTAssertTrue(firstRow.waitForExistence(timeout: 5))
        revealDelete(on: firstRow)
        XCTAssertTrue(app.buttons["Delete"].waitForExistence(timeout: 3))
        Thread.sleep(forTimeInterval: 1)
        capture("09-history-row-swipe-delete-revealed")
        firstRow.swipeRight()
        Thread.sleep(forTimeInterval: 0.8)
        XCTAssertEqual(servingRows(in: app).count, 5, "a row was deleted by the reveal gesture")

        // ── 10–11 · the edit sheet, both detents ─────────────────────────────────────────────────
        servingRows(in: app).firstMatch.tap()
        let sheetTitle = app.staticTexts["Edit serving"]
        XCTAssertTrue(sheetTitle.waitForExistence(timeout: 5))
        XCTAssertTrue(app.sliders["Serving amount"].exists)
        Thread.sleep(forTimeInterval: settle)
        capture("10-history-edit-sheet-medium")

        // The .large detent. Dragging a sheet up is genuinely unreliable — the same gesture
        // sometimes dismisses instead of expanding — so this is attempted, verified, and SKIPPED
        // rather than retried blind. A half-expanded sheet is a worse artefact than a missing one.
        let grabber = sheetTitle
            .coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.0))
            .withOffset(CGVector(dx: 0, dy: -24))
        grabber.press(forDuration: 0.1,
                      thenDragTo: grabber.withOffset(CGVector(dx: 0, dy: -380)),
                      withVelocity: .slow,
                      thenHoldForDuration: 0.5)
        Thread.sleep(forTimeInterval: 1.5)
        if sheetTitle.exists && sheetTitle.frame.minY < 300 {
            capture("11-history-edit-sheet-large")
        } else {
            XCTContext.runActivity(named: "11 skipped — the .large detent was not reached") { _ in }
        }
        if app.buttons["Cancel"].exists { app.buttons["Cancel"].tap() }
        XCTAssertTrue(app.staticTexts["Today"].waitForExistence(timeout: 5))

        // ── 12–13 · a list long enough to overflow, at both scroll positions ─────────────────────
        // Three more Cups: 1,750 ml stays under the 2,000 goal, so the confetti does not fire early.
        // No tap spacing — these three rows exist to overflow the viewport, and shots 12/13 are
        // marked as poor store assets anyway, so their timestamps needn't be distinct.
        app.buttons["Home"].tap()
        XCTAssertTrue(vessel.waitForExistence(timeout: 5))
        for _ in 0..<3 { pour("Cup", in: app); Thread.sleep(forTimeInterval: 1) }
        Thread.sleep(forTimeInterval: settle)
        XCTAssertEqual(vessel.value as? String, "88 percent. 1750 of 2000 millilitres.")

        app.buttons["History"].tap()
        XCTAssertTrue(app.staticTexts["Today"].waitForExistence(timeout: 10))
        XCTAssertEqual(servingRows(in: app).count, 8)
        Thread.sleep(forTimeInterval: settle)
        capture("12-history-populated-8rows-top")

        scrollHistoryList(app, byPoints: 200)
        capture("13-history-populated-8rows-scrolled")
        returnToTop(of: "History", in: app, proof: app.staticTexts["Today"])

        // ── 14–15 · Settings, at rest and at max scroll ──────────────────────────────────────────
        app.buttons["Settings"].tap()
        XCTAssertTrue(goalSlider.waitForExistence(timeout: 10))
        XCTAssertEqual(goalSlider.value as? String, "2000 millilitres")
        Thread.sleep(forTimeInterval: settle)
        capture("14-settings-top-rest")

        scroll(app, from: settingsAnchor(app), until: app.buttons["O‘zbekcha"], step: 300, maxDrags: 3)
        capture("15-settings-scrolled-language")
        returnToTop(of: "Settings", in: app, proof: goalSlider)

        // ── 16–18 · the goal crossing, which is destructive to everything above ──────────────────
        app.buttons["Home"].tap()
        XCTAssertTrue(vessel.waitForExistence(timeout: 5))
        pour("Glass", in: app)
        // A blind shot: ConfettiOverlay is .accessibilityHidden(true) and .allowsHitTesting(false),
        // so there is nothing to wait on. 0.55 s is early in the burst, while the pieces are still
        // near the vessel and fully opaque.
        Thread.sleep(forTimeInterval: 0.55)
        capture("16-home-confetti-burst")

        Thread.sleep(forTimeInterval: settle)
        XCTAssertEqual(vessel.value as? String, "100 percent. 2000 of 2000 millilitres.")
        capture("17-home-at-goal-100")

        pour("Bottle", in: app)
        Thread.sleep(forTimeInterval: settle)
        XCTAssertEqual(vessel.value as? String, "125 percent. 2500 of 2000 millilitres.")
        capture("18-home-over-goal-125")

        // ── 19 · a quick-add vessel edited — after every Home shot, because it rewrites labels ───
        app.buttons["Settings"].tap()
        let glassSlider = app.sliders["Glass"]
        XCTAssertTrue(glassSlider.waitForExistence(timeout: 10))
        glassSlider.adjust(toNormalizedSliderPosition: 0.65)
        XCTAssertNotEqual(glassSlider.value as? String, "250 millilitres")
        Thread.sleep(forTimeInterval: settle)
        capture("19-settings-servings-edited")

        // ── 20–21 · the permission prompt and the denied state, both one-way ─────────────────────
        returnToTop(of: "Settings", in: app, proof: goalSlider)
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        app.switches["Smart reminders"].tap()
        if springboard.buttons["Allow"].waitForExistence(timeout: 8) {
            Thread.sleep(forTimeInterval: 1)
            capture("20-settings-notification-permission-alert")
            // Matched by PREFIX, not by literal. iOS labels this button "Don’t Allow" with a
            // TYPOGRAPHIC apostrophe (U+2019 RIGHT SINGLE QUOTATION MARK), not the ASCII U+0027 an
            // author naturally types — so `springboard.buttons["Don't Allow"]` finds nothing and the
            // run dies here with `No matches found`. Observed, not guessed: the failure printed the
            // real hierarchy as `Button, label: 'Don’t Allow'`. A prefix match is immune to which
            // apostrophe a future iOS ships, and to the localised forms too.
            let deny = springboard.buttons
                .matching(NSPredicate(format: "label BEGINSWITH %@", "Don"))
                .firstMatch
            XCTAssertTrue(deny.waitForExistence(timeout: 5), "no deny button on the permission alert")
            deny.tap()

            let openSettings = app.buttons["Open iOS Settings"]
            if openSettings.waitForExistence(timeout: 8) {
                // Do NOT tap it — it calls UIApplication.open and leaves the app under test.
                scroll(app, from: settingsAnchor(app), until: openSettings, step: 160, maxDrags: 3)
                capture("21-settings-reminders-blocked")
            } else {
                XCTContext.runActivity(named: "21 skipped — the denied card did not appear") { _ in }
            }
        } else {
            XCTContext.runActivity(named: "20/21 skipped — no permission alert appeared") { _ in }
        }

        // ── 22–25 · the Russian pass. Everything below is positional. ────────────────────────────
        // The tab bar's three slots are measured HERE, while their labels still resolve, and reused
        // as coordinates afterwards. Tapping by `element(boundBy:)` would be a lottery — the button
        // collection also holds the quick-add row and the language rows.
        let tabCentres = ["Home", "History", "Settings"].map { title -> CGVector in
            let frame = app.buttons[title].frame
            let size = app.frame.size
            return CGVector(dx: frame.midX / size.width, dy: frame.midY / size.height)
        }

        returnToTop(of: "Settings", in: app, proof: goalSlider)
        scroll(app, from: settingsAnchor(app), until: app.buttons["Русский"], step: 300, maxDrags: 3)
        app.buttons["Русский"].tap()
        Thread.sleep(forTimeInterval: 2)
        capture("22-settings-language-picker-ru-selected")

        tap(tabCentres[2], in: app)     // Settings
        Thread.sleep(forTimeInterval: settle)
        capture("23-settings-ru-top")

        tap(tabCentres[0], in: app)     // Home
        Thread.sleep(forTimeInterval: settle)
        capture("24-home-ru")

        tap(tabCentres[1], in: app)     // History
        Thread.sleep(forTimeInterval: settle)
        capture("25-history-ru")
    }

    // MARK: - Element helpers

    /// A logged serving row. The regex is **anchored** deliberately: `HomeView`'s quick-add buttons
    /// are labelled `"Glass, add 250 millilitres"` and would match an unanchored `millilitres`.
    @MainActor
    private func servingRows(in app: XCUIApplication) -> XCUIElementQuery {
        app.buttons.matching(NSPredicate(format: "label MATCHES %@", "^[0-9]+ millilitres$"))
    }

    /// Taps a quick-add vessel by NAME, never by amount — the amounts are user-editable, so
    /// `"Glass, add 250 millilitres"` is falsified by shot 19. The trailing comma is load-bearing:
    /// the label format is `"%1$@, add %2$d millilitres"`.
    @MainActor
    private func pour(_ vessel: String, in app: XCUIApplication) {
        let button = app.buttons
            .matching(NSPredicate(format: "label BEGINSWITH %@", vessel + ","))
            .firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 5), "no quick-add button for \(vessel)")
        button.tap()
    }

    @MainActor
    private func tap(_ normalized: CGVector, in app: XCUIApplication) {
        app.coordinate(withNormalizedOffset: normalized).tap()
    }

    // MARK: - Scrolling

    /// Drags content up by `points`, 1:1.
    ///
    /// `swipeUp()` is momentum-based — its travel depends on a velocity XCTest picks and does not
    /// document — so a shot after one lands wherever the fling stopped. A coordinate press-drag is
    /// 1:1. The terminal hold is the half people omit: without it even `.slow` imparts a fling and
    /// the content keeps moving after the touch lifts.
    ///
    /// `withOffset` takes POINTS; `coordinate(withNormalizedOffset:)` takes FRACTIONS.
    @MainActor
    private func scrollDown(from anchor: XCUIElement, byPoints points: CGFloat) {
        XCTAssertTrue(anchor.waitForExistence(timeout: 5), "no drag anchor on screen")
        let start = anchor.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        start.press(forDuration: 0.05,
                    thenDragTo: start.withOffset(CGVector(dx: 0, dy: -points)),
                    withVelocity: .slow,
                    thenHoldForDuration: 0.6)
        Thread.sleep(forTimeInterval: 0.8)
    }

    /// `SettingsView`'s only slider-free drag target.
    ///
    /// This screen carries **four** `Slider`s. A press-drag beginning on a thumb drags the *thumb*,
    /// silently rewriting the goal or a vessel mid-capture — and a bare `app.swipeUp()` starts at
    /// the window centre, which at rest sits within a few points of the servings sliders. Both
    /// non-denied reminders strings begin with this phrase, so the anchor survives the toggle.
    @MainActor
    private func settingsAnchor(_ app: XCUIApplication) -> XCUIElement {
        app.staticTexts
            .matching(NSPredicate(format: "label BEGINSWITH %@", "A nudge every two hours"))
            .firstMatch
    }

    /// Scrolls to a *condition*, not by a number — card heights depend on how many lines a sentence
    /// wraps to, which changes with the reminders state and with language.
    ///
    /// `isHittable` alone only proves the element's centre is reachable. For a screenshot the whole
    /// element must sit above the tab bar, hence the `maxY` test.
    @MainActor
    private func scroll(_ app: XCUIApplication,
                        from anchor: XCUIElement,
                        until target: XCUIElement,
                        step: CGFloat = 300,
                        maxDrags: Int = 5) {
        for _ in 0..<maxDrags {
            if target.exists, target.isHittable, target.frame.maxY < unobscuredBottom { return }
            scrollDown(from: anchor, byPoints: step)
        }
        XCTAssertTrue(target.exists && target.isHittable, "never brought the target fully on screen")
    }

    /// `HistoryView`'s list, anchored to a row: a vertical drag on a row pans the list rather than
    /// activating the button. The header and week card are *siblings* of the `List`, so they never
    /// move — shots 12 and 13 sharing identical chrome is the finding, not a defect.
    @MainActor
    private func scrollHistoryList(_ app: XCUIApplication, byPoints points: CGFloat) {
        scrollDown(from: servingRows(in: app).firstMatch, byPoints: points)
    }

    /// Bounces off another tab instead of dragging back.
    ///
    /// `RootTabView`'s body is a `switch tab` inside a `ZStack`, so each destination is a
    /// structurally different branch: identity does not survive the swap and the scroll container is
    /// rebuilt at offset 0. The sleep is not belt and braces — the swap cross-fades over 0.28 s and
    /// a shutter fired mid-fade catches both screens at partial opacity.
    @MainActor
    private func returnToTop(of tab: String, in app: XCUIApplication, proof: XCUIElement) {
        let bounce = (tab == "Home") ? "History" : "Home"
        app.buttons[bounce].tap()
        Thread.sleep(forTimeInterval: 0.6)
        app.buttons[tab].tap()
        XCTAssertTrue(proof.waitForExistence(timeout: 5), "\(tab) did not redraw at the top")
        Thread.sleep(forTimeInterval: 0.6)
    }

    /// Reveals the swipe action **without** tripping the full swipe, which would delete the serving
    /// outright — there is no confirmation anywhere in this project.
    @MainActor
    private func revealDelete(on row: XCUIElement) {
        let start = row.coordinate(withNormalizedOffset: CGVector(dx: 0.88, dy: 0.5))
        let end = row.coordinate(withNormalizedOffset: CGVector(dx: 0.48, dy: 0.5))
        start.press(forDuration: 0.05, thenDragTo: end,
                    withVelocity: .slow, thenHoldForDuration: 0.4)
    }
}
