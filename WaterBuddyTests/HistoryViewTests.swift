//
//  HistoryViewTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import Foundation
import SwiftData
import SwiftUI
import Testing
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
/// App Group (rule `85-testing`).
@MainActor
private func withTempStore<T>(
    onReschedule: @escaping ([ReminderPlan.Slot]) -> Void = { _ in },
    _ body: (DataManager, UserDefaults) throws -> T
) throws -> T {
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
        // Not decoration. `DataManager.init` ends in `rescheduleRemindersNow()`, and the production
        // default builds a real `UNUserNotificationCenter` — so without this, constructing the
        // fixture reconciles against the user's actual reminders. This suite only reads a range,
        // which is exactly why it went unnoticed (rule `85-testing`).
        rescheduleReminders: onReschedule
    )
    return try body(manager, defaults)
}

// MARK: - Tests

/// The serving editor's **offer**, which is deliberately narrower than what the store accepts —
/// the same split `DailyGoalSetupTests` pins for `GoalSetupView.goalRange`.
///
/// `DataManager` clamps a serving only by rejecting anything non-positive, because that is a floor
/// against corruption rather than a menu. These numbers are the menu, and nothing in the compiler
/// notices when one of them moves.
@MainActor
struct HistoryServingTests {

    @Test func theStandardServingIsInsideTheOfferAndLandsOnAStep() {
        #expect(HistoryView.servingRange.contains(DataManager.defaultServing))
        #expect(DataManager.defaultServing % HistoryView.servingStep == 0)
    }

    @Test func theOfferedRangeIsAWholeNumberOfSteps() {
        let span = HistoryView.servingRange.upperBound - HistoryView.servingRange.lowerBound
        #expect(span % HistoryView.servingStep == 0, "the top of the slider would be unreachable")
    }

    /// Neither end may be rewritten on the way into the store, or the editor would offer an amount
    /// it cannot actually save.
    @Test func bothEndsOfTheOfferedRangeSurviveUpdateLog() throws {
        try withTempStore { manager, defaults in
            manager.addLog(amount: DataManager.defaultServing)
            let target = try #require(manager.todaysLogs.first)

            for end in [HistoryView.servingRange.lowerBound, HistoryView.servingRange.upperBound] {
                manager.updateLog(target, newAmount: end)

                #expect(manager.todaysLogs.first?.amount == end)
                // The cache is what the widget reads; an edit that never reached it is invisible
                // to the other process.
                #expect(defaults.integer(forKey: DataManager.Key.currentWater) == end)
            }
        }
    }

    /// The seed migration inserts a **single** log carrying a whole day's cached total, which can
    /// be far larger than the editor offers. Clamping the slider's initial value would silently
    /// show a different figure from the row the user tapped, so the bounds widen to contain it.
    @Test(arguments: [1, 50, 250, 1_000, 1_150, 4_000, DataManager.maximumDailyIntake])
    func theSliderBoundsAlwaysContainTheServingBeingEdited(amount: Int) {
        let bounds = HistoryView.sliderBounds(forAmount: amount)

        #expect(bounds.contains(amount))
        #expect(bounds.lowerBound <= HistoryView.servingRange.lowerBound)
        #expect(bounds.upperBound >= HistoryView.servingRange.upperBound)
        #expect(bounds.lowerBound >= 1, "a zero-width or non-positive offer cannot be edited")
    }

    // MARK: The fixture itself

    /// The twin of ``WaterLogStoreTests/theStoreFixtureRoutesTheReminderPlanToTheInjectedSeam()``,
    /// for this file's own `withTempStore`.
    ///
    /// This suite reads a *range* and looks harmless, which is exactly why it went unnoticed:
    /// `DataManager.init` reschedules, so constructing the fixture was enough to reach the real
    /// notification centre even in a test that never logs water (rule `85-testing`).
    @Test func theServingEditorFixtureRoutesTheReminderPlanToTheInjectedSeam() throws {
        var plans = 0
        try withTempStore(onReschedule: { _ in plans += 1 }) { manager, _ in
            manager.addLog(amount: 250)
        }

        #expect(plans > 0, "the fixture is reaching a real UNUserNotificationCenter")
    }
}
