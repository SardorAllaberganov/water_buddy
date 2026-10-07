//
//  EarlierServingTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 07/10/26.
//

import Foundation
import Observation
import SwiftData
import Testing
@testable import WaterBuddy

// MARK: - Fixtures

private func gregorian(in timeZone: String) -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: timeZone)!
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar
}

/// A Gregorian/UTC day, so nothing here can flake on a machine sitting near local midnight.
private let utcDay = gregorian(in: "UTC")

/// For the two daylight-saving tests. In 2026 New York leaves daylight time on Sunday 1 November and
/// enters it on Sunday 8 March, when 02:00–03:00 does not exist.
private let newYorkDay = gregorian(in: "America/New_York")

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

private func newYork(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
    newYorkDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

/// What the manager rang while a test watched: the widget doorbell, the wrist publish and every
/// reminder plan it handed out, in order.
private final class Taps {
    var reloads = 0
    var publishes = 0
    var plans: [[ReminderPlan.Slot]] = []
}

/// `withObservationTracking`'s `onChange` is `@Sendable`, so the tally needs a reference box.
private final class Counter: @unchecked Sendable {
    var count = 0
}

/// One manager over a UUID-named throwaway suite **and** an in-memory store, every side effect
/// routed to ``Taps``.
///
/// `modelContainer:` and `rescheduleReminders:` are the two arguments that look optional and are
/// not: their production defaults are the live App Group store and a real
/// `UNUserNotificationCenter`, and `init` reschedules, so merely constructing a manager with either
/// left out reaches the owner's real data (rule `85-testing`).
/// `theEarlierServingFixtureRoutesTheReminderPlanToTheInjectedSeam` fails if the second goes missing.
@MainActor
private func withEarlierStore<T>(
    calendar: Calendar = utcDay,
    now: @escaping () -> Date,
    _ body: (DataManager, Taps, UserDefaults) throws -> T
) throws -> T {
    let name = "test.waterbuddy.earlier.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    let container = try ModelContainer(
        for: WaterLog.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    let taps = Taps()
    let manager = DataManager(
        defaults: defaults,
        modelContainer: container,
        calendar: calendar,
        now: now,
        reloadWidgets: { taps.reloads += 1 },
        rescheduleReminders: { taps.plans.append($0) },
        publishWrist: { _ in taps.publishes += 1 }
    )
    return try body(manager, taps, defaults)
}

/// Whether a plan still holds today's reminder at `hour`.
@MainActor
private func plan(_ slots: [ReminderPlan.Slot]?, holds hour: Int, on day: Int) -> Bool {
    (slots ?? []).contains { $0.dayOrdinal == day && $0.hour == hour }
}

// MARK: - The week's servings, published

/// ``DataManager/historyLogs`` — what History lists for a day that is not today.
///
/// Published from the fetch the bars already make, so the list under a bar and the bar itself are
/// one reading of the store.
@MainActor
struct HistoryLogsTests {

    @Test func theWindowsServingsArePublishedByDayNewestFirst() throws {
        try withEarlierStore(now: { utc(2026, 8, 30, 12) }) { manager, _, _ in
            manager.addLog(amount: 100, at: utc(2026, 8, 28, 9))
            manager.addLog(amount: 300, at: utc(2026, 8, 28, 18))
            manager.addLog(amount: 200, at: utc(2026, 8, 28, 12))
            // 23:30 UTC is already the next day east of Greenwich — so this row lands under the
            // 28th only if the rows are bucketed on the injected calendar, not the machine's.
            manager.addLog(amount: 50, at: utc(2026, 8, 28, 23, 30))
            manager.addLog(amount: 400, at: utc(2026, 8, 30, 8))

            #expect(manager.historyLogs[20260828]?.map(\.amount) == [50, 300, 200, 100])
            #expect(manager.historyLogs[20260830]?.map(\.amount) == [400])
            #expect(manager.historyLogs[20260829] == nil, "a day with no servings has no entry")
        }
    }

    @Test func servingsOutsideTheWindowAreNotPublished() throws {
        try withEarlierStore(now: { utc(2026, 8, 30, 12) }) { manager, _, _ in
            manager.addLog(amount: 111, at: utc(2026, 8, 23, 23, 59))
            manager.addLog(amount: 222, at: utc(2026, 8, 24, 0, 0))
            manager.addLog(amount: 333, at: utc(2026, 8, 31, 0, 1))

            #expect(manager.historyLogs[20260823] == nil, "the day before the window opens")
            #expect(manager.historyLogs[20260824]?.map(\.amount) == [222], "the window's first instant")
            #expect(manager.historyLogs[20260831] == nil, "tomorrow")
        }
    }

    /// The bars carry an equality guard and the rows must not. Moving a serving's time inside a past
    /// day changes no total — `history` compares equal and stays put — but the day's rows reorder.
    @Test func retimingAServingWithinAPastDayRepublishesItsRows() throws {
        try withEarlierStore(now: { utc(2026, 8, 30, 12) }) { manager, _, _ in
            manager.addLog(amount: 100, at: utc(2026, 8, 28, 9))
            manager.addLog(amount: 200, at: utc(2026, 8, 28, 15))
            let early = try #require(manager.allLogs().first { $0.amount == 100 })

            let counter = Counter()
            withObservationTracking { _ = manager.historyLogs } onChange: { counter.count += 1 }
            manager.updateLog(early, newAmount: 100, timestamp: utc(2026, 8, 28, 20))

            #expect(counter.count == 1, "no bar moved, and the rows still must")
            #expect(manager.historyLogs[20260828]?.map(\.amount) == [100, 200])
        }
    }
}

// MARK: - Editing a serving's time

/// ``DataManager/updateLog(_:newAmount:timestamp:)`` — the one call the sheet's *Save* makes.
@MainActor
struct RetimingTests {

    @Test func movingTodaysServingIntoYesterdayMovesItsWaterBetweenTheDays() throws {
        try withEarlierStore(now: { utc(2026, 8, 30, 12) }) { manager, _, defaults in
            manager.addLog(amount: 250, at: utc(2026, 8, 30, 0, 10))
            manager.addLog(amount: 400, at: utc(2026, 8, 30, 9))
            let lateNight = try #require(manager.allLogs().first { $0.amount == 250 })

            manager.updateLog(lateNight, newAmount: 250, timestamp: utc(2026, 8, 29, 23, 50))

            #expect(manager.currentWater == 400)
            #expect(defaults.integer(forKey: DataManager.Key.currentWater) == 400, "the widget reads the cache")
            #expect(manager.todaysLogs.map(\.amount) == [400])
            let bars = Dictionary(uniqueKeysWithValues: manager.history.map { ($0.dayOrdinal, $0.total) })
            #expect(bars[20260829] == 250)
            #expect(bars[20260830] == 400)
        }
    }

    @Test func movingYesterdaysServingIntoTodayRaisesTodaysTotal() throws {
        try withEarlierStore(now: { utc(2026, 8, 30, 12) }) { manager, _, _ in
            manager.addLog(amount: 300, at: utc(2026, 8, 29, 20))
            manager.addLog(amount: 200, at: utc(2026, 8, 30, 8))
            let yesterdays = try #require(manager.allLogs().first { $0.amount == 300 })

            manager.updateLog(yesterdays, newAmount: 300, timestamp: utc(2026, 8, 30, 7))

            #expect(manager.currentWater == 500)
            #expect(manager.todaysLogs.map(\.amount) == [200, 300])
        }
    }

    @Test func aMoveAcrossMidnightRingsTheWidgetDoorbellOnce() throws {
        try withEarlierStore(now: { utc(2026, 8, 30, 12) }) { manager, taps, _ in
            manager.addLog(amount: 250, at: utc(2026, 8, 30, 0, 10))
            let serving = try #require(manager.allLogs().first)
            let reloads = taps.reloads
            let publishes = taps.publishes

            manager.updateLog(serving, newAmount: 250, timestamp: utc(2026, 8, 29, 23, 50))

            #expect(taps.reloads - reloads == 1, "today's total moved, so the widget has news")
            #expect(taps.publishes - publishes == 1, "and so does the watch, which shows the same total")
        }
    }

    /// A drink less than an hour before a slot answers it (`ReminderPlan.quietAfterDrink`). Moved
    /// earlier, the drink stops answering the slot, and the slot has to come back.
    @Test func retimingWithinTodayRingsNoDoorbellButReplansTheReminders() throws {
        try withEarlierStore(now: { utc(2026, 8, 30, 14, 30) }) { manager, taps, _ in
            manager.remindersEnabled = true
            manager.addLog(amount: 250, at: utc(2026, 8, 30, 14, 20))
            let serving = try #require(manager.allLogs().first)
            #expect(!plan(taps.plans.last, holds: 15, on: 20260830), "the drink at 14:20 answers 15:00")
            let reloads = taps.reloads

            manager.updateLog(serving, newAmount: 250, timestamp: utc(2026, 8, 30, 9, 30))

            #expect(taps.reloads == reloads, "today's total did not move")
            #expect(plan(taps.plans.last, holds: 15, on: 20260830), "moved to 09:30, it no longer answers 15:00")
        }
    }

    @Test func oneEditChangesTheAmountAndTheTimeTogether() throws {
        try withEarlierStore(now: { utc(2026, 8, 30, 12) }) { manager, taps, _ in
            manager.addLog(amount: 250, at: utc(2026, 8, 30, 0, 10))
            let serving = try #require(manager.allLogs().first)
            let reloads = taps.reloads

            manager.updateLog(serving, newAmount: 500, timestamp: utc(2026, 8, 29, 23, 50))

            #expect(manager.currentWater == 0)
            let bars = Dictionary(uniqueKeysWithValues: manager.history.map { ($0.dayOrdinal, $0.total) })
            #expect(bars[20260829] == 500)
            #expect(taps.reloads - reloads == 1, "one edit, one doorbell")
        }
    }

    @Test func anEditThatChangesNothingDoesNothing() throws {
        try withEarlierStore(now: { utc(2026, 8, 30, 12) }) { manager, taps, _ in
            manager.addLog(amount: 250, at: utc(2026, 8, 30, 9))
            let serving = try #require(manager.allLogs().first)
            let plans = taps.plans.count
            let reloads = taps.reloads

            let counter = Counter()
            withObservationTracking { _ = manager.todaysLogs } onChange: { counter.count += 1 }
            manager.updateLog(serving, newAmount: 250, timestamp: utc(2026, 8, 30, 9))

            #expect(counter.count == 0, "nothing moved, so nothing redraws")
            #expect(taps.plans.count == plans, "nor re-plans")
            #expect(taps.reloads == reloads)
        }
    }

    @Test func aNonPositiveAmountIgnoresTheWholeEdit() throws {
        try withEarlierStore(now: { utc(2026, 8, 30, 12) }) { manager, _, _ in
            manager.addLog(amount: 250, at: utc(2026, 8, 30, 9))
            let serving = try #require(manager.allLogs().first)

            manager.updateLog(serving, newAmount: 0, timestamp: utc(2026, 8, 29, 9))

            #expect(serving.timestamp == utc(2026, 8, 30, 9), "a refused edit moves nothing")
            #expect(manager.currentWater == 250)
        }
    }

    @Test func omittingTheTimestampKeepsTheServingsTime() throws {
        try withEarlierStore(now: { utc(2026, 8, 30, 12) }) { manager, _, _ in
            manager.addLog(amount: 250, at: utc(2026, 8, 30, 9))
            let serving = try #require(manager.allLogs().first)

            manager.updateLog(serving, newAmount: 400)

            #expect(serving.timestamp == utc(2026, 8, 30, 9))
            #expect(manager.currentWater == 400)
        }
    }

    /// Adding to a past day changes no figure the widget draws, so it must not be woken for it.
    @Test func aServingBackdatedIntoYesterdayRingsNoWidgetDoorbell() throws {
        try withEarlierStore(now: { utc(2026, 8, 30, 12) }) { manager, taps, _ in
            manager.addLog(amount: 400, at: utc(2026, 8, 30, 9))
            let reloads = taps.reloads

            manager.addLog(amount: 250, at: utc(2026, 8, 29, 20))

            #expect(taps.reloads == reloads)
            #expect(manager.currentWater == 400)
            let bars = Dictionary(uniqueKeysWithValues: manager.history.map { ($0.dayOrdinal, $0.total) })
            #expect(bars[20260829] == 250)
        }
    }

    /// Nothing else can catch a fixture that reaches a real notification centre: a test may not read
    /// the source tree, and may not build a real centre to inspect it. Watching the seam fire is the
    /// only evidence available from inside the process (`WaterLogTests`' identical guard).
    @Test func theEarlierServingFixtureRoutesTheReminderPlanToTheInjectedSeam() throws {
        try withEarlierStore(now: { utc(2026, 8, 30, 12) }) { _, taps, _ in
            #expect(!taps.plans.isEmpty, "the fixture is reaching a real UNUserNotificationCenter")
        }
    }
}

// MARK: - Where the week starts

/// ``DataManager/historyWindowStart(endingOn:calendar:)``.
///
/// **Deliberately not `@MainActor`.** It is a `nonisolated static` the bars' fetch and the sheet's
/// wheel both call; if it ever reached for instance state, this suite would stop compiling
/// (rule `43-concurrency`).
struct HistoryWindowStartTests {

    @Test func theWindowOpensAtMidnightSixDaysBeforeToday() {
        #expect(DataManager.historyWindowStart(endingOn: utc(2026, 8, 30, 15), calendar: utcDay) == utc(2026, 8, 24, 0))
    }

    /// 1 November 2026 is 25 hours long in New York. Six days of 86,400 seconds back from 3 November's
    /// midnight lands at 01:00 on 28 October, not at its midnight (rule `30-rollover`).
    @Test func theWindowsOpeningWalksCalendarDaysAcrossTheEndOfDaylightTime() {
        let opening = DataManager.historyWindowStart(endingOn: newYork(2026, 11, 3, 12), calendar: newYorkDay)

        #expect(opening == newYork(2026, 10, 28, 0))
    }
}

/// What the sheet's wheel offers, and where it opens.
@MainActor
struct CorrectionRangeTests {

    @Test func theCorrectionRangeRunsFromTheWindowsOpeningToNow() throws {
        try withEarlierStore(now: { utc(2026, 8, 30, 15, 20) }) { manager, _, _ in
            let range = manager.correctionRange()

            #expect(range.lowerBound == utc(2026, 8, 24, 0))
            #expect(range.upperBound == utc(2026, 8, 30, 15, 20), "nothing later than now is offered")
        }
    }

    @Test func theSuggestedTimeKeepsTheTimeOfDayOnTheChosenDay() throws {
        try withEarlierStore(now: { utc(2026, 8, 30, 15, 20) }) { manager, _, _ in
            #expect(manager.suggestedTime(onDay: 20260828) == utc(2026, 8, 28, 15, 20))
        }
    }

    @Test func todaysSuggestedTimeIsNow() throws {
        try withEarlierStore(now: { utc(2026, 8, 30, 15, 20) }) { manager, _, _ in
            #expect(manager.suggestedTime(onDay: 20260830) == utc(2026, 8, 30, 15, 20))
        }
    }

    @Test func aDayOutsideTheWindowIsSuggestedNow() throws {
        try withEarlierStore(now: { utc(2026, 8, 30, 15, 20) }) { manager, _, _ in
            #expect(manager.suggestedTime(onDay: 20260823) == utc(2026, 8, 30, 15, 20))
        }
    }

    /// 02:30 does not exist on 8 March 2026 in New York. Whatever instant the calendar resolves it
    /// to, the suggestion must still be on the day the user chose.
    @Test func theSuggestionLandsOnTheChosenDayAcrossTheStartOfDaylightTime() throws {
        try withEarlierStore(calendar: newYorkDay, now: { newYork(2026, 3, 10, 2, 30) }) { manager, _, _ in
            let suggestion = manager.suggestedTime(onDay: 20260308)

            #expect(DataManager.dayOrdinal(for: suggestion, in: newYorkDay) == 20260308)
        }
    }
}

// MARK: - A watch pour, re-timed

/// Re-timing a row the watch authored must not reopen either hole `ingest(_:)`'s conjunction guard
/// closes. The applied ledger is keyed by the pour's **own** `at`, which a resend repeats; the
/// existence check finds the row by `id`, wherever its time moved.
@MainActor
struct RetimedPourTests {

    @Test func aRetimedWatchPourIsNotDuplicatedByAResend() throws {
        try withEarlierStore(now: { utc(2026, 8, 30, 12) }) { manager, _, _ in
            let pour = WristPour(id: UUID(), amount: 250, at: utc(2026, 8, 30, 9))
            #expect(manager.ingest([pour]) == 1)
            let row = try #require(manager.allLogs().first { $0.id == pour.id })

            manager.updateLog(row, newAmount: 250, timestamp: utc(2026, 8, 29, 9))

            #expect(manager.ingest([pour]) == 0)
            #expect(manager.allLogs().filter { $0.id == pour.id }.count == 1)
        }
    }

    @Test func aRetimedWatchPourStaysDeletedWhenTheWatchResendsIt() throws {
        try withEarlierStore(now: { utc(2026, 8, 30, 12) }) { manager, _, _ in
            let pour = WristPour(id: UUID(), amount: 250, at: utc(2026, 8, 30, 9))
            #expect(manager.ingest([pour]) == 1)
            let row = try #require(manager.allLogs().first { $0.id == pour.id })

            manager.updateLog(row, newAmount: 250, timestamp: utc(2026, 8, 29, 9))
            manager.deleteLog(row)

            #expect(manager.ingest([pour]) == 0, "a deleted serving must not resurrect")
            #expect(!manager.allLogs().contains { $0.id == pour.id })
        }
    }
}

// MARK: - The screen's selection

/// `HistoryView`'s two selection helpers, read with no store, no view and no main actor.
///
/// **Deliberately not `@MainActor`** — a `View`'s statics infer its isolation, and a non-isolated
/// suite is what proves these two are `nonisolated` (rule `43-concurrency`). The week comes from
/// `DaySummary.series`, so no summary is constructed by hand.
struct HistorySelectionTests {

    private let week = DaySummary.series(from: [], days: DataManager.historyWindow, endingOn: utc(2026, 8, 30), in: utcDay)

    @Test func nothingSelectedShowsToday() {
        #expect(HistoryView.shownDay(selected: nil, in: week)?.dayOrdinal == 20260830)
    }

    @Test func aSelectedDayInsideTheWindowIsShown() {
        #expect(HistoryView.shownDay(selected: 20260827, in: week)?.dayOrdinal == 20260827)
    }

    /// The app left open across midnight: the day the user picked a week ago has scrolled out.
    @Test func aSelectionTheWindowLeftBehindFallsBackToToday() {
        #expect(HistoryView.shownDay(selected: 20260823, in: week)?.dayOrdinal == 20260830)
    }

    /// `nil`, not today's ordinal, so the screen goes on following midnight by itself.
    @Test func savingToTodayClearsTheSelection() {
        #expect(HistoryView.selection(forDay: 20260830, in: week) == nil)
    }

    @Test func savingToAPastDaySelectsIt() {
        #expect(HistoryView.selection(forDay: 20260828, in: week) == 20260828)
    }
}
