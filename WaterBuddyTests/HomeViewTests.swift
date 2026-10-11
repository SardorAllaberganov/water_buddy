//
//  HomeViewTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import Foundation
import SwiftData
import SwiftUI
import Testing
import UIKit
@testable import WaterBuddy

// MARK: - Fixtures

private func gregorian(in timeZone: String) -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: timeZone)!
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar
}

private let utcDay = gregorian(in: "UTC")

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
}

/// The same throwaway suite and in-memory store every other suite here builds, for the same two
/// reasons: `@Test` functions run in parallel inside one process, and no test may reach the real
/// App Group — the suite *or* the store file (rule `85-testing`).
@MainActor
private func withTempStore<T>(_ body: (DataManager, UserDefaults) throws -> T) throws -> T {
    let name = "test.waterbuddy.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    let container = try ModelContainer(
        for: WaterLog.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    let manager = DataManager(
        defaults: defaults,
        modelContainer: container,
        calendar: utcDay,
        now: { utc(2026, 8, 28) },
        reloadWidgets: {},
        // Not optional, and not decoration. The production default is
        // `DataManager.requestReminderReschedule`, which builds a real `UNUserNotificationCenter`
        // and reconciles against it — so a fixture that omits this makes every `addLog` below
        // remove real pending requests under `ReminderPlan.identifierPrefix`. Rule `85-testing`
        // forbids a test that constructs a real centre outright, and the same defaulted-dependency
        // trap already pointed all 74 tests at the live store once (`tasks/lessons.md`).
        rescheduleReminders: { _ in },
        // Same hazard, a second seam: the production default reaches a real `WCSession`.
        publishWrist: { _ in }
    )
    return try body(manager, defaults)
}

// MARK: - Tests

/// The quick-add row — the vessels `HomeView` puts under the thumb.
///
/// The amounts are **user data** now: they live on `DataManager`, and this suite asserts what the
/// row does with them. What is still fixed, and still asserted here, is the three slots' identity —
/// their names, their glyphs and their order — because that is the half the widget never reads and
/// the half nothing in the compiler notices when it moves.
@MainActor
struct HomeServingTests {

    /// The vessel that crosses the process boundary.
    ///
    /// This used to assert that the row *contained* `defaultServing`, because the widget compiled
    /// that constant in and the row had to keep offering it or the two front doors had drifted.
    /// The invariant did not disappear when the vessels became editable — it moved. The widget now
    /// reads the middle vessel out of the shared suite, so what has to hold is that
    /// `HomeView`'s middle slot and `WaterSnapshot.serving` are **the same number, whatever the
    /// user set it to**. Asserted against an edited value precisely so a re-introduced constant on
    /// either side would fail.
    @Test func theRowsMiddleVesselIsTheOneTheWidgetLogs() throws {
        try withTempStore { manager, defaults in
            manager.servings = [200, 330, 750]

            let row = HomeView.servings(amounts: manager.servings)
            let snapshot = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: { utc(2026, 8, 28) }())

            #expect(row[1].amount == 330)
            #expect(snapshot.serving == row[1].amount,
                    "the widget's button and the app's middle vessel are one value read twice")
        }
    }

    @Test func theDefaultRowIsTheStandardThreeVessels() throws {
        try withTempStore { manager, _ in
            #expect(HomeView.servings(amounts: manager.servings).map(\.amount) == [150, 250, 500])
            #expect(HomeView.servings(amounts: manager.servings).map(\.amount) == DataManager.defaultServings)
        }
    }

    /// A serving logged from the row has to be editable in the log without the slider rewriting it.
    ///
    /// This was a property of three compile-time constants; it is now a property of the **editor**,
    /// which offers exactly `HistoryView.servingRange` on `HistoryView.servingStep`. So it is
    /// asserted about the range the Settings card offers rather than about today's stored values —
    /// the store deliberately accepts anything positive, and a user who edited a vessel through
    /// some other path is not a case the row can fix.
    @Test func theEditorsOfferKeepsEveryVesselCorrectableInTheLog() {
        for amount in stride(from: HistoryView.servingRange.lowerBound,
                             through: HistoryView.servingRange.upperBound,
                             by: HistoryView.servingStep) {
            #expect(HistoryView.servingRange.contains(amount))
            #expect(amount % HistoryView.servingStep == 0,
                    "the editor's slider would snap this to a different figure")
        }
        #expect(DataManager.defaultServings.allSatisfy { HistoryView.servingRange.contains($0) },
                "the defaults must themselves be offerable, or a fresh install cannot edit its own row")
    }

    /// Replaces `theServingsAreDistinctAndAscending`, which asserted something the feature
    /// deliberately removed rather than something that broke.
    ///
    /// Ascent is **not** enforced any more, and that is a decision: making an edit to Cup push
    /// Glass out of its way would silently change what the *widget* logs, which is the
    /// bug-found-only-by-arithmetic the old constant existed to prevent. What must hold instead is
    /// that duplicates stay drawable — identity is the slot, so two vessels holding the same amount
    /// are two rows rather than one.
    @Test func vesselsMayDuplicateOrDescendAndStillDrawAsThreeRows() throws {
        try withTempStore { manager, _ in
            manager.servings = [500, 250, 250]

            let row = HomeView.servings(amounts: manager.servings)
            #expect(row.count == 3)
            #expect(Set(row.map(\.id)).count == 3, "a colliding id makes SwiftUI drop or merge a row")
            #expect(row.map(\.amount) == [500, 250, 250], "never re-sorted on the way out")
        }
    }

    /// An SF Symbol that does not resolve renders as **nothing at all** — no glyph, no warning, no
    /// failed build. Nothing else in the gate can see it, and a screenshot only catches it if
    /// somebody happens to take one.
    @Test(arguments: vesselSlots.map(\.symbol))
    func everyServingSymbolResolves(symbol: String) {
        #expect(UIImage(systemName: symbol) != nil,
                "an unresolved SF Symbol draws an empty button")
    }

    @Test func everySlotIsNamedAndDrawn() {
        #expect(vesselSlots.count == DataManager.defaultServings.count,
                "a slot without an amount, or an amount without a slot, silently truncates the row")
        for slot in vesselSlots {
            #expect(!slot.nameKey.isEmpty, "the key is the button's accessibility label")
            #expect(!slot.symbol.isEmpty)
        }
    }

    /// The whole row, tapped once each — through the real mutation path, asserted on the property
    /// *and* on the cache the widget reads.
    @Test func loggingEveryQuickAddServingAccumulatesAndWritesThrough() throws {
        try withTempStore { manager, defaults in
            manager.servings = [200, 330, 750]
            let row = HomeView.servings(amounts: manager.servings)

            for serving in row {
                manager.addLog(amount: serving.amount)
            }

            let total = row.reduce(0) { $0 + $1.amount }

            #expect(manager.currentWater == total)
            #expect(manager.todaysLogs.count == row.count,
                    "each tap is its own serving, with its own provenance")
            // A value that never reached the cache is invisible to the widget.
            #expect(defaults.integer(forKey: DataManager.Key.currentWater) == total)
        }
    }
}

// MARK: - Layout and Undo, as values

/// The parts of Home that are decisions rather than drawing, pinned without building a view.
/// Not `@MainActor`: everything read here is `nonisolated` on purpose (rule `43-concurrency`).
struct HomeLayoutTests {

    /// The Glass is ranked above Cup and Bottle (spec §5.2): it is the slot the widget, Siri, the
    /// Control Center control and the watch all log.
    @Test func onlyTheGlassIsRankedAboveTheOthers() {
        let row = HomeView.servings(amounts: [150, 250, 500])

        #expect(row.map(\.isUsual) == [false, true, false])
        #expect(row.first(where: \.isUsual)?.nameKey == vesselSlots[DataManager.usualSlot].nameKey)
    }

    @Test func theVesselIsHeldBetweenItsFloorAndItsCeiling() {
        #expect(HomeView.vesselRange(scaled: 300) == 200...300)
        #expect(HomeView.vesselRange(scaled: 600) == 200...HomeView.vesselCeiling)
        #expect(HomeView.vesselRange(scaled: 150) == 150...150, "the floor never rises above the ceiling")
    }

    /// Large text raises the vessel's ceiling and never its floor: the vessel gives way before
    /// the quick-add row does. A floor that rose with the text size — two thirds of the scaled
    /// size — was tried and drawn: on a 402 x 874 pt phone it put the vessels' names under the tab
    /// bar from the second accessibility size, and left 42 pt of each disc showing at the largest.
    @Test func largeTextRaisesTheCeilingAndNeverTheFloor() {
        for scaled in [380.0, 417, 445, 483, 510] as [CGFloat] {
            #expect(HomeView.vesselRange(scaled: scaled).lowerBound == HomeView.vesselFloor)
        }
        #expect(HomeView.vesselRange(scaled: 320).upperBound == 320)
        #expect(HomeView.vesselRange(scaled: 510).upperBound == HomeView.vesselCeiling)
    }

    /// The vessel takes what the header, the status and the row leave of the screen. The figures
    /// are the 375 x 667 pt phone's: 587 pt of visible height, 372.5 pt of everything else.
    @Test func theVesselTakesWhatTheRestOfTheColumnLeaves() {
        let range = HomeView.vesselRange(scaled: 300)

        #expect(HomeView.vesselDiameter(available: 587, others: 372.5, range: range) == 214.5)
        #expect(HomeView.vesselDiameter(available: 900, others: 372.5, range: range) == 300,
                "room to spare does not grow it past its design size")
        #expect(HomeView.vesselDiameter(available: 500, others: 372.5, range: range) == 200,
                "under its floor the vessel stops shrinking, and the screen scrolls instead")
    }

    @Test func aDiscIsNeverSmallerThanAFingerNorLargerThanItsCeiling() {
        #expect(HomeView.discDiameter(scaled: 30, ceiling: HomeView.sideDiscCeiling) == 44)
        #expect(HomeView.discDiameter(scaled: 68, ceiling: HomeView.sideDiscCeiling) == 68)
        #expect(HomeView.discDiameter(scaled: 400, ceiling: HomeView.sideDiscCeiling) == HomeView.sideDiscCeiling)
    }

    @Test func theGlassDiscOutgrowsItsNeighboursAllTheWayUp() {
        #expect(HomeView.glassDiscCeiling > HomeView.sideDiscCeiling)
        #expect(HomeView.sideDiscCeiling >= 44)
    }

    @Test func anUndoOfferStandsEightSecondsAndDoesNotExpireUnderVoiceOver() {
        #expect(UndoOffer.lifetime(voiceOverRunning: false) == .seconds(8))
        #expect(UndoOffer.lifetime(voiceOverRunning: true) == nil)
    }

    @Test func twoPoursOfOneAmountAreTwoOffers() {
        #expect(UndoOffer(id: UUID(), amount: 250) != UndoOffer(id: UUID(), amount: 250))
    }

    /// An SF Symbol that does not resolve draws nothing at all.
    @Test(arguments: HomeView.glyphs)
    func everyHomeGlyphResolves(symbol: String) {
        #expect(UIImage(systemName: symbol) != nil, "an unresolved SF Symbol draws an empty space")
    }
}
