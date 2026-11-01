//
//  ExportUITests.swift
//  WaterBuddyUITests
//
//  Created by Sardor Allaberganov on 01/11/26.
//

import XCTest

/// The export card for a Premium holder (spec `2026-11-01-export-design.md`): the DEBUG fresh start, cleared at
/// every launch, with `-WaterBuddyPremiumHeld`'s lifetime purchase from no store (rule `85-testing`). A failed read
/// has no route from here; `ServingsExportTests` holds it. Save to Files is proved by hand.
final class ExportUITests: XCTestCase {

    private static let heading = "Export your servings"
    private static let share = "Share as a CSV file"

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    /// A holder's fresh start, past the welcome, on Home.
    @MainActor
    private func launch(_ arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-WaterBuddyFreshStart", "YES", "-WaterBuddyPremiumHeld", "YES"] + arguments
        app.launch()
        completeWelcomeIfShown(app)
        return app
    }

    @MainActor
    private func openTab(_ name: String, in app: XCUIApplication) {
        // Straight after the welcome a tab's button can be listed twice; the first match is the bar's.
        let tab = app.buttons[name].firstMatch
        XCTAssertTrue(tab.waitForExistence(timeout: 5))
        tapWhenReady(tab)
    }

    /// The name, never the amount: the amounts are the user's. The comma is load-bearing.
    @MainActor
    private func pourAGlass(in app: XCUIApplication) {
        let button = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass,")).firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 5), "no Glass on Home")
        tapWhenReady(button)
    }

    /// The card, scrolled clear of the floating bar's whole frame (`docs/AI_CONTEXT.md` #209).
    @MainActor
    private func card(in app: XCUIApplication) -> XCUIElement {
        let card = app.buttons[Self.heading]
        XCTAssertTrue(card.waitForExistence(timeout: 10), "no export card")
        let bar = app.tabBars.firstMatch
        for _ in 0..<6 where !card.isHittable || (bar.exists && card.frame.maxY > bar.frame.minY) {
            app.swipeUp()
        }
        return card
    }

    /// The sheet's one action, which says whether it is open: XCUITest lists the text inside a button, so the
    /// card's own title reads as the heading.
    @MainActor
    private func shareButton(in app: XCUIApplication) -> XCUIElement {
        app.buttons[Self.share]
    }

    @MainActor
    private func shareSheet(in app: XCUIApplication) -> XCUIElement {
        app.otherElements["ActivityListView"]
    }

    @MainActor
    func testAHolderWithNoServingsIsToldSoUntilTheyPour() throws {
        let app = launch()
        openTab("Settings", in: app)
        let row = card(in: app)
        XCTAssertEqual(app.buttons.matching(identifier: Self.heading).count, 1)
        tapWhenReady(row)

        let told = NSPredicate(format: "value == %@", "Nothing to export yet.")
        expectation(for: told, evaluatedWith: row)
        waitForExpectations(timeout: 5)
        XCTAssertFalse(shareButton(in: app).exists, "a sheet opened on nothing")

        // Leaving the tab clears it: a pour elsewhere must not leave it standing.
        openTab("Home", in: app)
        pourAGlass(in: app)
        openTab("Settings", in: app)
        let again = card(in: app)
        XCTAssertNotEqual(again.value as? String, "Nothing to export yet.", "the line outlived the pour")
        tapWhenReady(again)
        XCTAssertTrue(shareButton(in: app).waitForExistence(timeout: 5), "the pour was not found")
    }

    @MainActor
    func testAHoldersExportShowsItsSummaryAndOffersTheShareSheet() throws {
        let app = launch()
        pourAGlass(in: app)
        openTab("Settings", in: app)
        let row = card(in: app)
        // The card's own title is listed as text too, so the count is of what the sheet adds (rule `65-accessibility`).
        let headings = app.staticTexts.matching(identifier: Self.heading)
        let headingsBefore = headings.count
        tapWhenReady(row)

        let share = shareButton(in: app)
        XCTAssertTrue(share.waitForExistence(timeout: 5), "the sheet did not open")
        XCTAssertEqual(headings.count, headingsBefore + 1, "the sheet's heading is not one element")
        // The card is one element, so the count is of the label that joins what it says.
        let summary = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label BEGINSWITH %@ AND label CONTAINS %@ AND label CONTAINS %@",
                                  "1 serving,", "WaterBuddy-", "nothing else"))
        XCTAssertEqual(summary.count, 1, "the summary is not one element")
        XCTAssertEqual(app.buttons.matching(identifier: "Done").count, 1, "no single close button")
        XCTAssertEqual(app.buttons.matching(identifier: Self.share).count, 1)
        tapWhenReady(share)
        XCTAssertTrue(shareSheet(in: app).waitForExistence(timeout: 10), "iOS's share sheet did not open")
    }

    @MainActor
    func testTheShareButtonIsReachableAtTheLargestTextSize() throws {
        let app = launch(["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"])
        pourAGlass(in: app)
        openTab("Settings", in: app)
        tapWhenReady(card(in: app))

        let share = shareButton(in: app)
        XCTAssertTrue(share.waitForExistence(timeout: 5), "the sheet did not open")
        for _ in 0..<5 where !share.isHittable { app.swipeUp() }
        XCTAssertTrue(share.isHittable, "the largest text pushed Share out of reach")
    }
}
