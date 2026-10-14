//
//  WelcomeUITests.swift
//  WaterBuddyUITests
//
//  Created by Sardor Allaberganov on 14/10/26.
//

import XCTest

/// Taps a button of the welcome's bar once its step has arrived.
///
/// The bar's buttons are disabled while a step turns (`WelcomeView`'s `turning`), so a tap made the
/// moment after another lands on nothing — which is the point for a person's double tap, and a
/// trap for a test that taps as fast as it can. XCUITest's own wait for the app to idle does not
/// cover the slide.
@MainActor
func tapWhenReady(_ element: XCUIElement, timeout: TimeInterval = 5) {
    let ready = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true AND enabled == true"), object: element)
    XCTAssertEqual(XCTWaiter().wait(for: [ready], timeout: timeout), .completed, "\(element) never became ready to tap")
    element.tap()
}

/// Walks the welcome to Home if it is showing, choosing *Not now*.
///
/// Every UI test but the welcome's own runs against the device as it is. A gate simulator finished
/// its welcome long ago, so this does nothing there; a fresh one is walked with the welcome's
/// defaults and asks for nothing, so no permission prompt appears in a run (rule `85-testing`). It
/// replaced eleven copies of a *Get Started* tap, one per test, when the welcome grew from one
/// screen to four.
@MainActor
func completeWelcomeIfShown(_ app: XCUIApplication) {
    let getStarted = app.buttons["Get Started"]
    guard getStarted.waitForExistence(timeout: 5) else { return }
    getStarted.tap()

    for _ in 0..<2 {
        let next = app.buttons["Continue"]
        XCTAssertTrue(next.waitForExistence(timeout: 5), "the welcome's Continue did not appear")
        tapWhenReady(next)
    }

    let notNow = app.buttons["Not now"]
    XCTAssertTrue(notNow.waitForExistence(timeout: 5), "the welcome's last step did not appear")
    tapWhenReady(notNow)
}

/// The welcome, from outside the process (spec 2026-10-14 §10).
///
/// **The only class that launches with the fresh start.** A DEBUG build given
/// `-WaterBuddyFreshStart` runs on a throwaway suite, cleared as it launches, and an in-memory store
/// (`WaterBuddyApp.freshStartManager(arguments:)`). Every test here sees a new install, and none of
/// them touches the device's own state. Nothing here taps *Turn on reminders*: on a simulator its
/// answer is whatever the device last gave, so the prompt is a device check.
final class WelcomeUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    /// A new install, on the welcome's first step.
    ///
    /// The flag is followed by a value: a `-key` argument takes the next one as its value, and
    /// alone it would swallow whatever argument came after it (decision P7).
    @MainActor
    private func launchedFresh(_ more: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-WaterBuddyFreshStart", "YES"] + more
        app.launch()
        XCTAssertTrue(
            app.buttons["Get Started"].waitForExistence(timeout: 10),
            "the fresh start did not open on the welcome"
        )
        return app
    }

    @MainActor
    private func step(_ number: Int, of app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)["Step \(number) of 4"]
    }

    /// Forward and back through every step, and *Not now* opens the app on Home.
    @MainActor
    func testTheWelcomeWalksForwardAndBack() throws {
        let app = launchedFresh()
        XCTAssertTrue(step(1, of: app).exists, "the dots do not say which step this is")

        tapWhenReady(app.buttons["Get Started"])
        XCTAssertTrue(app.sliders["Daily water goal"].waitForExistence(timeout: 5), "Get Started did not bring the goal step")
        XCTAssertTrue(step(2, of: app).exists)

        tapWhenReady(app.buttons["Back"])
        XCTAssertTrue(app.buttons["Get Started"].waitForExistence(timeout: 5), "Back did not return to the first step")
        XCTAssertFalse(app.buttons["Back"].exists, "the first step offers Back")

        tapWhenReady(app.buttons["Get Started"])
        tapWhenReady(app.buttons["Continue"])
        XCTAssertTrue(app.sliders["Bottle"].waitForExistence(timeout: 5), "Continue did not bring the vessels step")
        XCTAssertTrue(step(3, of: app).exists)

        tapWhenReady(app.buttons["Back"])
        XCTAssertTrue(app.sliders["Daily water goal"].waitForExistence(timeout: 5), "Back did not return to the goal step")

        tapWhenReady(app.buttons["Continue"])
        tapWhenReady(app.buttons["Continue"])
        XCTAssertTrue(app.buttons["Turn on reminders"].waitForExistence(timeout: 5), "the last step did not appear")
        XCTAssertTrue(app.buttons["Not now"].exists)
        XCTAssertTrue(step(4, of: app).exists)

        tapWhenReady(app.buttons["Not now"])
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5), "Not now did not open the app on Home")
        XCTAssertFalse(app.buttons["Get Started"].exists, "the welcome is still in the tree")
    }

    /// Each control is one element, by the label VoiceOver speaks, on every step — and a step that is
    /// not shown is not in the tree (rule `65-accessibility`, *Proving it*).
    @MainActor
    func testEveryWelcomeControlIsOneElement() throws {
        let app = launchedFresh()
        XCTAssertEqual(app.buttons.matching(identifier: "Get Started").count, 1)
        XCTAssertEqual(app.sliders.count, 0, "a step that is not shown is in the tree")

        tapWhenReady(app.buttons["Get Started"])
        XCTAssertTrue(app.sliders["Daily water goal"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.sliders.matching(identifier: "Daily water goal").count, 1)
        XCTAssertEqual(app.buttons.matching(identifier: "Continue").count, 1)
        XCTAssertEqual(app.buttons.matching(identifier: "Back").count, 1)
        XCTAssertEqual(app.buttons.matching(identifier: "Work it out for me").count, 1)
        app.buttons["Work it out for me"].tap()
        for name in ["Light, Mostly sitting", "Moderate, Exercise some days", "Active, Exercise most days", "kg", "lb"] {
            XCTAssertEqual(app.buttons.matching(identifier: name).count, 1, "\(name) is not one button")
        }
        XCTAssertEqual(app.pickerWheels.count, 1, "the weight wheel is not one element")

        tapWhenReady(app.buttons["Continue"])
        XCTAssertTrue(app.sliders["Bottle"].waitForExistence(timeout: 5))
        for name in ["Cup", "Glass", "Bottle"] {
            XCTAssertEqual(app.sliders.matching(identifier: name).count, 1, "\(name) is not one slider")
        }
        XCTAssertEqual(app.sliders.matching(identifier: "Daily water goal").count, 0, "the goal step is still in the tree")

        tapWhenReady(app.buttons["Continue"])
        XCTAssertTrue(app.buttons["Turn on reminders"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons.matching(identifier: "Turn on reminders").count, 1)
        XCTAssertEqual(app.buttons.matching(identifier: "Not now").count, 1)
        XCTAssertEqual(app.buttons.matching(identifier: "Back").count, 1)
    }

    /// At the largest text size every step can still be walked: the bar's controls answer a tap,
    /// and what a step asks can be scrolled to above the bar (Review Focus 3).
    @MainActor
    func testTheWelcomeIsWalkableAtTheLargestTextSize() throws {
        // The category's real name: an unknown one is ignored without a word (rule `65-accessibility`).
        let app = launchedFresh(["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"])
        XCTAssertTrue(app.buttons["Get Started"].isHittable)
        tapWhenReady(app.buttons["Get Started"])

        XCTAssertTrue(app.buttons["Continue"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Continue"].isHittable, "Continue is out of reach on the goal step")
        XCTAssertTrue(app.buttons["Back"].isHittable)
        tapWhenReady(app.buttons["Continue"])

        let bottle = app.sliders["Bottle"]
        XCTAssertTrue(bottle.waitForExistence(timeout: 5))
        for _ in 0..<4 where !bottle.isHittable { app.swipeUp() }
        XCTAssertTrue(bottle.isHittable, "the last vessel cannot be scrolled out from under the bar")
        tapWhenReady(app.buttons["Continue"])

        XCTAssertTrue(app.buttons["Turn on reminders"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Turn on reminders"].isHittable)
        XCTAssertTrue(app.buttons["Not now"].isHittable, "Not now is out of reach at the largest size")
        tapWhenReady(app.buttons["Not now"])
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5))
    }

    /// The walk every other test makes lands on Home.
    @MainActor
    func testTheWalkEveryOtherTestMakesLandsOnHome() throws {
        let app = launchedFresh()
        completeWelcomeIfShown(app)
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5), "the helper did not finish the welcome")
    }

    /// A vessel set in the welcome is the one Home pours.
    @MainActor
    func testAVesselSetInTheWelcomeIsTheOneHomePours() throws {
        let app = launchedFresh()
        tapWhenReady(app.buttons["Get Started"])
        tapWhenReady(app.buttons["Continue"])

        let bottle = app.sliders["Bottle"]
        XCTAssertTrue(bottle.waitForExistence(timeout: 5))
        bottle.adjust(toNormalizedSliderPosition: 1)
        XCTAssertEqual(bottle.value as? String, "1000 millilitres")

        tapWhenReady(app.buttons["Continue"])
        tapWhenReady(app.buttons["Not now"])
        XCTAssertTrue(
            app.buttons["Bottle, add 1000 millilitres"].waitForExistence(timeout: 5),
            "Home does not pour the bottle the welcome set"
        )
    }

    /// Settings' vessel rows still save as their slider is let go, now that they are
    /// `VesselSliders` (decision P8): a fresh start, so no gate device's own vessels change.
    @MainActor
    func testAVesselEditedInSettingsIsSavedAsBefore() throws {
        let app = launchedFresh()
        completeWelcomeIfShown(app)
        // Home first, for the reason `testAStepsTitleStandsWhereATabsTitleDoes` gives.
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5))
        app.buttons["Settings"].tap()

        let bottle = app.sliders["Bottle"]
        XCTAssertTrue(bottle.waitForExistence(timeout: 5), "Settings did not appear")
        for _ in 0..<3 where !bottle.isHittable { app.swipeUp() }
        bottle.adjust(toNormalizedSliderPosition: 1)
        XCTAssertEqual(bottle.value as? String, "1000 millilitres")

        app.buttons["Home"].tap()
        XCTAssertTrue(
            app.buttons["Bottle, add 1000 millilitres"].waitForExistence(timeout: 5),
            "a vessel edited in Settings was not saved"
        )
    }

    /// A step's title stands where a tab's does, read off the tree (`tasks/lessons.md`, 2026-10-11).
    @MainActor
    func testAStepsTitleStandsWhereATabsTitleDoes() throws {
        let app = launchedFresh()
        tapWhenReady(app.buttons["Get Started"])
        tapWhenReady(app.buttons["Continue"])
        let title = app.staticTexts["Quick-add vessels"].firstMatch
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        // Let the slide end before reading where it stands.
        Thread.sleep(forTimeInterval: 1)
        let welcome = title.frame

        tapWhenReady(app.buttons["Continue"])
        tapWhenReady(app.buttons["Not now"])
        // Home first: while the root cross-fades to the tabs, Apple's bar draws each item twice, and
        // a tap then finds two *Settings*.
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5))
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.sliders["Daily water goal"].waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 1)
        // The app's own bar draws a caption that also reads *Settings*; the heading is the higher
        // (`GoalSetupUITests.assertTheTitleHoldsItsPlace(in:)`).
        let settings = app.staticTexts.matching(identifier: "Settings").allElementsBoundByIndex
            .map(\.frame)
            .min { $0.minY < $1.minY } ?? .zero

        XCTAssertEqual(welcome.minX, settings.minX, accuracy: 0.5, "a step's title starts elsewhere: \(welcome) against \(settings)")
        XCTAssertEqual(welcome.minY, settings.minY, accuracy: 0.5, "a step's title stands at another height: \(welcome) against \(settings)")
    }

    /// A second tap during a page turn is not a tap on the step arriving: a double tap moves one
    /// step. From Vessels it once landed on the arriving *Not now* and finished the welcome before
    /// Reminders was seen (the final review, 2026-10-14).
    @MainActor
    func testADoubleTapMovesOneStep() throws {
        let app = launchedFresh()
        app.buttons["Get Started"].doubleTap()
        XCTAssertTrue(app.sliders["Daily water goal"].waitForExistence(timeout: 5), "a double tap on Get Started did not bring the goal step")
        Thread.sleep(forTimeInterval: 1)
        XCTAssertFalse(app.sliders["Bottle"].exists, "a double tap on Get Started skipped the goal step")

        tapWhenReady(app.buttons["Continue"])
        XCTAssertTrue(app.sliders["Bottle"].waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 1)
        app.buttons["Continue"].doubleTap()
        Thread.sleep(forTimeInterval: 1)
        XCTAssertFalse(app.otherElements["Today's hydration"].exists, "a double tap on the vessels' Continue finished the welcome")
        XCTAssertTrue(app.buttons["Turn on reminders"].exists, "a double tap on the vessels' Continue left the reminders step")
        XCTAssertTrue(app.buttons["Not now"].exists)
    }

    // MARK: The calculator

    /// On the goal step, the calculator open.
    @MainActor
    private func calculatorOpen() -> XCUIApplication {
        let app = launchedFresh()
        tapWhenReady(app.buttons["Get Started"])
        let row = app.buttons["Work it out for me"]
        XCTAssertTrue(row.waitForExistence(timeout: 5), "the goal step has no calculator")
        XCTAssertEqual(app.buttons.matching(identifier: "Work it out for me").count, 1)
        row.tap()
        return app
    }

    /// *Use* moves the goal to the suggestion, and then says so instead of offering it again. At
    /// the starting 70 kg or 155 lb and *Moderate*, both units suggest 2,500.
    @MainActor
    func testUseSetsTheGoalItSuggests() throws {
        let app = calculatorOpen()
        let use = app.buttons["Use 2500 millilitres"]
        XCTAssertTrue(use.waitForExistence(timeout: 5), "the calculator did not suggest 2,500 at its starting weight")
        XCTAssertEqual(app.sliders["Daily water goal"].value as? String, "2000 millilitres", "the goal moved before Use was tapped")

        use.tap()

        XCTAssertEqual(app.sliders["Daily water goal"].value as? String, "2500 millilitres")
        XCTAssertFalse(app.buttons["Use 2500 millilitres"].exists, "Use is still offered for the goal it already set")
    }

    /// The activity moves the suggestion, and nothing else (decision W1). Both units' starts agree
    /// at every level: 2,100 light, 2,800 active.
    @MainActor
    func testTheActivityMovesOnlyTheSuggestion() throws {
        let app = calculatorOpen()
        let moderate = app.buttons["Moderate, Exercise some days"]
        XCTAssertTrue(moderate.waitForExistence(timeout: 5))
        XCTAssertTrue(moderate.isSelected, "the calculator does not start at Moderate")

        app.buttons["Active, Exercise most days"].tap()
        XCTAssertTrue(app.buttons["Use 2800 millilitres"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Active, Exercise most days"].isSelected)

        app.buttons["Light, Mostly sitting"].tap()
        XCTAssertTrue(app.buttons["Use 2100 millilitres"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.sliders["Daily water goal"].value as? String, "2000 millilitres", "picking an activity moved the goal")
    }

    /// The unit switch converts the weight shown, whichever unit the region started in: kilograms
    /// give 70, pounds give 154 — and 154 lb at *Moderate* suggests 2,400.
    @MainActor
    func testTheUnitSwitchConvertsTheWeight() throws {
        let app = calculatorOpen()
        let wheel = app.pickerWheels.firstMatch
        XCTAssertTrue(wheel.waitForExistence(timeout: 5), "the calculator has no weight wheel")

        app.buttons["kg"].tap()
        XCTAssertEqual(wheel.value as? String, "70 kg")
        XCTAssertTrue(app.buttons["kg"].isSelected)

        app.buttons["lb"].tap()
        XCTAssertEqual(app.pickerWheels.firstMatch.value as? String, "154 lb")
        XCTAssertTrue(app.buttons["Use 2400 millilitres"].waitForExistence(timeout: 5))
    }

    /// Use, then the goal moved away: *Use* comes back with the same figure (Review Focus 1).
    @MainActor
    func testUseComesBackWhenTheGoalIsMovedAway() throws {
        let app = calculatorOpen()
        app.buttons["Use 2500 millilitres"].tap()
        XCTAssertFalse(app.buttons["Use 2500 millilitres"].exists)

        app.sliders["Daily water goal"].adjust(toNormalizedSliderPosition: 1)
        XCTAssertEqual(app.sliders["Daily water goal"].value as? String, "4000 millilitres")
        XCTAssertTrue(app.buttons["Use 2500 millilitres"].waitForExistence(timeout: 5), "Use did not come back")
    }

    /// Continue and Back keep a step as it was left: the panel open, the pick, the goal
    /// (Review Focus 2).
    @MainActor
    func testAStepIsAsItWasLeftWhenBackReturnsToIt() throws {
        let app = calculatorOpen()
        app.buttons["Active, Exercise most days"].tap()
        app.buttons["Use 2800 millilitres"].tap()

        tapWhenReady(app.buttons["Continue"])
        XCTAssertTrue(app.sliders["Bottle"].waitForExistence(timeout: 5))
        tapWhenReady(app.buttons["Back"])

        XCTAssertTrue(app.sliders["Daily water goal"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.sliders["Daily water goal"].value as? String, "2800 millilitres")
        XCTAssertTrue(app.buttons["Active, Exercise most days"].isSelected, "the pick was lost")
    }
}
