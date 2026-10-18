//
//  AppStoreScreenshotUITests.swift
//  WaterBuddyUITests
//
//  Created by Sardor Allaberganov on 02/09/26.
//

import XCTest

/// A figure as the app speaks it on *Follow device*: grouped by the device's own region
/// (spec 2026-10-16 §6.3). The capture device is in `en_UZ`, which groups with a space, so a figure
/// written with a comma here would stop the run at its first figure assertion.
private func grouped(_ figure: Int) -> String {
    figure.formatted(.number)
}

/// A figure as the store set prints it: in `en_US`, which the store capture launches in, so the
/// listing reads *1,300* whatever region the capture device is in.
private func listed(_ figure: Int) -> String {
    figure.formatted(.number.locale(Locale(identifier: "en_US")))
}

/// The four iPhone screenshots App Store Connect is given, captured by driving the real app.
///
/// **This is not a test.** It asserts only what a wrong picture would get wrong and proves nothing
/// about the product; it is a capture harness that happens to need XCUITest's ability to tap. It
/// lives in this target because XCUITest is the only thing in the toolchain that can reach the app's
/// own controls — `simctl` can screenshot a simulator but cannot touch it.
///
/// ## Why it starts clean on its own
///
/// A capture must start from an empty install, or the figures on screen are whatever the last run
/// left behind — and the welcome, shot `04`, exists only until a goal is committed. Until
/// 2026-10-18 that meant an erased device and a script that refused a dirty one. It now launches
/// with `-WaterBuddyFreshStart`, as the welcome's own tests do (rule `85-testing`): a throwaway
/// suite cleared at launch and an in-memory store, with no widget, reminder or watch side effects.
/// Every run is a new install, on any simulator. The launch still resolves the App Group's suite
/// and runs its one-shot migration — `WaterBuddyApp.init()` does, before the fresh start's branch —
/// but the run's manager is built on the throwaway suite and the in-memory store, so none of the
/// device's servings, goal or total reaches a shot, and the run writes none there.
///
/// It also launches in `en_US` (`-AppleLanguages (en) -AppleLocale en_US`). A fresh start follows
/// the device, and every simulator on the capture Mac is in `en_UZ`, which would print *2 000* and a
/// 24-hour clock into an en-US listing.
///
/// ## Why it is excluded from the gate
///
/// It runs for minutes, and it is driven only by `Tools/CaptureScreenshots.sh`, which pins the
/// status bar and writes the four PNGs into `Screenshots/`. Rule `85-testing`'s gate carries
/// `-skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests` to keep it, and the census below,
/// out of the ordinary run.
///
/// ## Why History's sheet, and not Home's pours
///
/// A pour on Home is stamped *now*, so the 1.1 capture spaced five pours 65 s apart to give its
/// rows five different minutes — and its History still drew five minutes of drinking, and its week
/// one day. The set shows a lived-in week instead (roadmap item 1.2.8, approved 2026-10-17): today's
/// servings at set times through the sheet's wheel, and six earlier days through the week card. And
/// with nothing poured on Home, Home is shot with no *Undo* line, no slosh and no confetti, and no
/// rating request can start.
///
/// The wheel offers nothing later than now, and today's last serving is at 1:30 PM — so the run
/// refuses to start before 1:45 PM, and after 11:45 PM, where it would cross midnight and split the
/// week it is building.
///
/// ## Why one method and not four
///
/// The four screens are four *steps of one session*, not four independent cases. Home has to show
/// water, which means the servings have already been saved; History has to show those same
/// servings. Splitting them into separate `func test…`s would relaunch between each — and a fresh
/// start empties the store at every launch — and XCTest gives no ordering guarantee across methods.
///
/// ## Capture order is not display order
///
/// The welcome exists only until the first goal is committed, so its goal step is shot **first** and named
/// `04`. The names are the App Store ordering; the sequence below is the only one the app permits.
final class AppStoreScreenshotUITests: XCTestCase {

    /// Seconds between the census's quick-add taps.
    ///
    /// `HistoryView` renders a serving's time as `.dateTime.hour().minute()`, so five taps fired back
    /// to back produce five rows stamped with the same minute — which reads as fabricated in a
    /// screenshot. 65 s is the smallest gap that guarantees a distinct minute on every row. The store
    /// capture no longer pours on Home; it sets each time on History's wheel.
    private let tapSpacing: TimeInterval = 65

    /// The store set's today, in the order it is drunk: 1,300 ml, 65 % of the default 2,000 — short
    /// of the goal, so no confetti. Every time is before 1:45 PM, the earliest the run starts.
    private let today: [(vessel: String, hour: String, minute: String, period: String)] = [
        ("Glass", "7", "40", "AM"),
        ("Cup", "9", "15", "AM"),
        ("Bottle", "10", "50", "AM"),
        ("Glass", "12", "25", "PM"),
        ("Cup", "1", "30", "PM"),
    ]

    /// The six days before today, oldest first: 1,650 (short of the goal), then 2,000, 2,250,
    /// 2,150, 2,500 and 2,000 — five days met, so Home's chip reads *5 days*. Only the week card's
    /// bars show them, so each keeps the time of day the sheet opens on.
    private let earlierDays: [[String]] = [
        ["Bottle", "Bottle", "Bottle", "Cup"],
        ["Bottle", "Bottle", "Bottle", "Bottle"],
        ["Bottle", "Bottle", "Bottle", "Bottle", "Glass"],
        ["Bottle", "Bottle", "Bottle", "Bottle", "Cup"],
        ["Bottle", "Bottle", "Bottle", "Bottle", "Bottle"],
        ["Bottle", "Bottle", "Bottle", "Bottle"],
    ]

    /// The three vessels a fresh start offers, as the sheet's shortcuts set them.
    private let amounts = ["Cup": 150, "Glass": 250, "Bottle": 500]

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
        // Before anything launches: a run outside the window fails at its first wheel, minutes in.
        let clock = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let minutes = (clock.hour ?? 0) * 60 + (clock.minute ?? 0)
        guard (13 * 60 + 45)..<(23 * 60 + 45) ~= minutes else {
            XCTFail(
                "the store capture runs between 1:45 PM and 11:45 PM: today's last serving is at "
                    + "1:30 PM and the wheel offers nothing later than now, and a run across midnight "
                    + "would split the week it builds"
            )
            return
        }

        let app = XCUIApplication()
        app.launchArguments += [
            "-WaterBuddyFreshStart", "YES",
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US",
        ]
        app.launch()

        // ── 04 · the first-run screen ────────────────────────────────────────────────────────────
        // Shot before anything else, because committing a goal ends it. A fresh start always opens
        // on it, so its absence means the argument was not read — and the run would be on the
        // device's own data, whose figures are nobody's listing.
        let getStarted = app.buttons["Get Started"]
        XCTAssertTrue(
            getStarted.waitForExistence(timeout: 10),
            "the welcome is not showing — the fresh start did not take, so this run is not a new install"
        )
        // The shot is the goal step: the number the rest of the product is measured against.
        getStarted.tap()
        XCTAssertTrue(app.sliders["Daily water goal"].waitForExistence(timeout: 10), "the goal step did not appear")
        Thread.sleep(forTimeInterval: settle)
        capture("04-goal-setup")

        // On through the vessels and past reminders without asking, as a new user might.
        tapWhenReady(app.buttons["Continue"])
        tapWhenReady(app.buttons["Continue"])
        XCTAssertTrue(app.buttons["Not now"].waitForExistence(timeout: 10), "the welcome's last step did not appear")
        tapWhenReady(app.buttons["Not now"])

        let vessel = app.otherElements["Today's hydration"]
        XCTAssertTrue(vessel.waitForExistence(timeout: 10), "the root did not swap to HomeView")

        // ── the week, through History's sheet ────────────────────────────────────────────────────
        app.buttons["History"].tap()
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 10), "the History tab did not draw")

        // Today first: until a day carries water there is no week card, and no day to pick.
        let todayButton = app.buttons["Today"]
        var drunkToday = 0
        for serving in today {
            openSheet(in: app)
            setTime(hour: serving.hour, minute: serving.minute, period: serving.period, in: app)
            save(serving.vessel, in: app)
            drunkToday += amounts[serving.vessel] ?? 0
            waitForTotal(drunkToday, on: todayButton, named: "today")
        }

        let names = DateFormatter()
        names.locale = Locale(identifier: "en_US")
        names.setLocalizedDateFormatFromTemplate("EEEE")
        for (index, servings) in earlierDays.enumerated() {
            let offset = earlierDays.count - index
            let date = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -offset, to: Date()))
            let name = names.string(from: date)
            let day = app.buttons[name]
            XCTAssertTrue(day.waitForExistence(timeout: 5), "the week card has no button for \(name)")
            day.tap()
            XCTAssertTrue(day.isSelected, "tapping \(name) did not select it")

            var drunk = 0
            for serving in servings {
                openSheet(in: app)
                save(serving, in: app)
                drunk += amounts[serving] ?? 0
            }
            waitForTotal(drunk, on: day, named: name)
        }

        // ── 01 · Home, with water ────────────────────────────────────────────────────────────────
        app.buttons["Home"].tap()
        XCTAssertTrue(vessel.waitForExistence(timeout: 10), "Home did not draw")
        XCTAssertEqual(
            vessel.value as? String,
            "65 percent. \(listed(1_300)) of \(listed(2_000)) millilitres.",
            "Home does not show today's 1,300 ml"
        )
        let chip = app.descendants(matching: .any).matching(identifier: "Day streak").firstMatch
        XCTAssertTrue(chip.waitForExistence(timeout: 5), "Home shows no streak")
        XCTAssertEqual(chip.value as? String, "5 days", "the streak is not the five days met before today")
        Thread.sleep(forTimeInterval: settle)
        capture("01-home")

        // ── 02 · History, on today ───────────────────────────────────────────────────────────────
        // History opens on today whichever day it was left on.
        app.buttons["History"].tap()
        XCTAssertTrue(
            app.buttons["Add a serving"].waitForExistence(timeout: 10),
            "the History tab did not draw"
        )
        XCTAssertTrue(app.staticTexts["Last 7 days"].waitForExistence(timeout: 5), "the week card did not draw")
        XCTAssertTrue(todayButton.isSelected, "History did not open on today")
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

    // MARK: - History's sheet

    /// Opens the sheet on the day History shows, at its wheel.
    @MainActor
    private func openSheet(in app: XCUIApplication) {
        tapWhenReady(app.buttons["Add a serving"])
        XCTAssertTrue(app.datePickers.firstMatch.waitForExistence(timeout: 5), "the sheet did not open on its wheel")
    }

    /// Sets today's serving to a time of day, and reads it back off the wheel.
    ///
    /// The wheel offers nothing later than now, and a wheel stopped on a later time snaps back to
    /// now. So the spinning is done in the morning, where every time is earlier than now — the run
    /// starts after 1:45 PM: *AM* first, then the hour, then the minute, and the serving's own half
    /// of the day last, which lands on a time still earlier than now. Spun in the afternoon, at
    /// 2:42 PM on 2026-10-18, the hour was asked for 12 and read back 2 — that it passed a time
    /// later than now on the way and snapped back is inferred, and the morning order built on it
    /// has passed since. Read back, because a snapped wheel says nothing. The wheels are the date,
    /// the hour, the minute and the half of the day (a probe on 2026-10-17, in `en_US`), and they
    /// speak *7 o’clock* and *40 minutes*.
    @MainActor
    private func setTime(hour: String, minute: String, period: String, in app: XCUIApplication) {
        let wheels = app.datePickers.firstMatch.pickerWheels
        XCTAssertEqual(wheels.count, 4, "the sheet's wheel is not date, hour, minute and AM/PM")
        wheels.element(boundBy: 3).adjust(toPickerWheelValue: "AM")
        wheels.element(boundBy: 1).adjust(toPickerWheelValue: hour)
        wheels.element(boundBy: 2).adjust(toPickerWheelValue: minute)
        wheels.element(boundBy: 3).adjust(toPickerWheelValue: period)

        let read = (0..<4).map { wheels.element(boundBy: $0).value as? String ?? "" }
        XCTAssertEqual(read[0], "Today", "the serving is not on today")
        XCTAssertTrue(read[1].hasPrefix(hour + " "), "the hour reads \"\(read[1])\", not \(hour)")
        XCTAssertTrue(read[2].hasPrefix(minute + " "), "the minute reads \"\(read[2])\", not \(minute)")
        XCTAssertEqual(read[3], period, "the half of the day reads \"\(read[3])\", not \(period)")
    }

    /// Sets the serving's amount with a vessel's shortcut, and saves it.
    ///
    /// By the vessel's name, never its amount: the amount is what the shortcut sets, and the slider
    /// is waited on until it shows it.
    @MainActor
    private func save(_ vessel: String, in app: XCUIApplication) {
        let shortcut = app.buttons[vessel]
        XCTAssertTrue(shortcut.waitForExistence(timeout: 5), "the sheet has no \(vessel) shortcut")
        shortcut.tap()
        let amount = app.sliders["Serving amount"]
        let set = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", shortcut.value as? String ?? ""), object: amount)
        XCTAssertEqual(XCTWaiter().wait(for: [set], timeout: 5), .completed, "the \(vessel) did not set the amount")

        app.buttons["Save"].tap()
        XCTAssertTrue(app.datePickers.firstMatch.waitForNonExistence(timeout: 5), "the sheet did not close on Save")
    }

    /// Waits for a day's button on the week card to carry `expected` millilitres.
    ///
    /// Off the button, not by counting rows: a lazy list builds only the rows on screen
    /// (`docs/AI_CONTEXT.md`, known issue #62). Polled, because the figure is parsed out of a
    /// sentence — *1,300 millilitres* — and a predicate cannot do that.
    @MainActor
    private func waitForTotal(_ expected: Int, on day: XCUIElement, named name: String) {
        let total = { Int((day.value as? String ?? "").split(separator: " ").first?.filter(\.isNumber) ?? "") ?? -1 }
        let deadline = Date().addingTimeInterval(5)
        while total() != expected, Date() < deadline {
            Thread.sleep(forTimeInterval: 0.2)
        }
        XCTAssertEqual(total(), expected, "\(name) does not carry the water saved to it")
    }
}

// MARK: - The full census

/// Every screen, every state, every scroll position — 25 shots in one session.
///
/// Separate from `testCaptureAppStoreScreenshots` above. This one is filtered independently
/// (`-only-testing:…/testCaptureFullScreenCensus`) and, unlike its sibling since 2026-10-18, still
/// needs a device with no WaterBuddy container. Both are skipped by the gate at class level.
///
/// ## Why one method and not twenty-five
///
/// These are not independent cases; they are 25 steps of one session, and five of the steps are
/// **one-way doors**. XCTest gives no ordering guarantee across methods, so splitting them would
/// let a later state destroy an earlier one non-deterministically:
///
/// | Door | Closes forever |
/// |---|---|
/// | *Not now* tapped | the welcome — `Key.isGoalSet` is never unset |
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

        // ── 01–03 · the welcome's goal step, before the one-way door ─────────────────────────────
        let getStarted = app.buttons["Get Started"]
        XCTAssertTrue(
            getStarted.waitForExistence(timeout: 10),
            "the welcome is not showing — the device was not erased before this run"
        )
        getStarted.tap()
        XCTAssertTrue(goalSlider.waitForExistence(timeout: 10), "the goal step did not appear")
        XCTAssertEqual(goalSlider.value as? String, "\(grouped(2_000)) millilitres")
        Thread.sleep(forTimeInterval: settle)
        capture("01-goal-setup-default-2000")

        goalSlider.adjust(toNormalizedSliderPosition: 0.0)
        XCTAssertEqual(goalSlider.value as? String, "\(grouped(1_000)) millilitres")
        Thread.sleep(forTimeInterval: 1)
        capture("02-goal-setup-min-1000")

        goalSlider.adjust(toNormalizedSliderPosition: 1.0)
        XCTAssertEqual(goalSlider.value as? String, "\(grouped(4_000)) millilitres")
        Thread.sleep(forTimeInterval: 1)
        capture("03-goal-setup-max-4000")

        // Restore 2,000 before committing. Finishing the welcome saves whatever the slider shows,
        // and every percentage in the other 22 shots is computed against this number.
        goalSlider.adjust(toNormalizedSliderPosition: 0.333)
        XCTAssertEqual(goalSlider.value as? String, "\(grouped(2_000)) millilitres")

        // ── 04–05 · the two empty states, before any water ───────────────────────────────────────
        tapWhenReady(app.buttons["Continue"])
        tapWhenReady(app.buttons["Continue"])
        XCTAssertTrue(app.buttons["Not now"].waitForExistence(timeout: 10), "the welcome's last step did not appear")
        tapWhenReady(app.buttons["Not now"])
        XCTAssertTrue(vessel.waitForExistence(timeout: 10), "the root did not swap to HomeView")
        XCTAssertEqual(vessel.value as? String, "0 percent. 0 of \(grouped(2_000)) millilitres.")
        Thread.sleep(forTimeInterval: settle)
        capture("04-home-empty-0")

        app.buttons["History"].tap()
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 10))
        XCTAssertFalse(
            app.staticTexts["Last 7 days"].exists,
            "a week card in the empty state means the device was dirty"
        )
        Thread.sleep(forTimeInterval: settle)
        capture("05-history-empty")

        // ── 06–07 · water, ascending ─────────────────────────────────────────────────────────────
        app.buttons["Home"].tap()
        XCTAssertTrue(vessel.waitForExistence(timeout: 5))
        pour("Cup", in: app)
        Thread.sleep(forTimeInterval: settle)
        XCTAssertEqual(vessel.value as? String, "8 percent. 150 of \(grouped(2_000)) millilitres.")
        capture("06-home-sliver-8")

        for (index, name) in ["Bottle", "Glass", "Glass", "Cup"].enumerated() {
            Thread.sleep(forTimeInterval: tapSpacing)
            pour(name, in: app)
            _ = index
        }
        Thread.sleep(forTimeInterval: settle)
        XCTAssertEqual(vessel.value as? String, "65 percent. \(grouped(1_300)) of \(grouped(2_000)) millilitres.")
        capture("07-home-partial-65")

        // ── 08 · History, five rows, five distinct minutes ───────────────────────────────────────
        app.buttons["History"].tap()
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Last 7 days"].waitForExistence(timeout: 5))
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
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 5))

        // ── 12–13 · a list long enough to overflow, at both scroll positions ─────────────────────
        // Three more Cups: 1,750 ml stays under the 2,000 goal, so the confetti does not fire early.
        // No tap spacing — these three rows exist to overflow the viewport, and shots 12/13 are
        // marked as poor store assets anyway, so their timestamps needn't be distinct.
        app.buttons["Home"].tap()
        XCTAssertTrue(vessel.waitForExistence(timeout: 5))
        for _ in 0..<3 { pour("Cup", in: app); Thread.sleep(forTimeInterval: 1) }
        Thread.sleep(forTimeInterval: settle)
        XCTAssertEqual(vessel.value as? String, "88 percent. \(grouped(1_750)) of \(grouped(2_000)) millilitres.")

        app.buttons["History"].tap()
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 10))
        XCTAssertEqual(servingRows(in: app).count, 8)
        Thread.sleep(forTimeInterval: settle)
        capture("12-history-populated-8rows-top")

        scrollHistoryList(app, byPoints: 200)
        capture("13-history-populated-8rows-scrolled")
        returnToTop(of: "History", in: app, proof: app.buttons["Add a serving"])

        // ── 14–15 · Settings, at rest and at max scroll ──────────────────────────────────────────
        app.buttons["Settings"].tap()
        XCTAssertTrue(goalSlider.waitForExistence(timeout: 10))
        XCTAssertEqual(goalSlider.value as? String, "\(grouped(2_000)) millilitres")
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
        XCTAssertEqual(vessel.value as? String, "100 percent. \(grouped(2_000)) of \(grouped(2_000)) millilitres.")
        capture("17-home-at-goal-100")

        pour("Bottle", in: app)
        Thread.sleep(forTimeInterval: settle)
        XCTAssertEqual(vessel.value as? String, "125 percent. \(grouped(2_500)) of \(grouped(2_000)) millilitres.")
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
    /// `RootTabView` builds a page when its tab is shown and removes it when it has left, so the
    /// scroll container is rebuilt at offset 0. The sleep is not belt and braces — the pages
    /// slide for 0.45 s, and a shutter fired mid-slide catches half of each.
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
