//
//  MonthHistoryTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 22/10/26.
//

import Foundation
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

/// A Gregorian/UTC day, so no test can flake near local midnight or across a DST change.
private let utcDay = gregorian(in: "UTC")

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

/// A serving at an instant, with no store behind it.
private func log(_ amount: Int, at date: Date) -> WaterLog {
    WaterLog(amount: amount, timestamp: date)
}

/// `amount` at noon on each of `days` of October 2026.
private func october(_ days: ClosedRange<Int>, _ amount: Int) -> [WaterLog] {
    days.map { log(amount, at: utc(2026, 10, $0)) }
}

private let goal = 3_000

/// Thursday 22 October 2026, 14:00 UTC — *today* in this file.
private let thursday22 = utc(2026, 10, 22, 14)

private func make(
    _ rows: [WaterLog],
    month: Int = 20261001,
    first: Date? = utc(2026, 8, 1),
    goal: Int = goal,
    now: Date = thursday22,
    calendar: Calendar = utcDay
) -> MonthHistory? {
    MonthHistory.make(rows: rows, month: month, firstServing: first, goal: goal, now: now, calendar: calendar)
}

// MARK: - The value

/// One month, worked out with no store, no `DataManager` and no main actor (spec
/// `2026-10-22-month-view-design.md` §3.5). Not `@MainActor`, on purpose: a canary for
/// ``MonthHistory`` staying a pure value (rule `43-concurrency`), as `DaySummaryTests` is for
/// ``DaySummary``. Fix the declaration it reads, never this suite.
struct MonthHistoryTests {

    // MARK: Naming a month

    @Test func aMonthIsNamedByItsFirstDay() {
        #expect(MonthHistory.firstDay(ofMonthHolding: thursday22, in: utcDay) == 20261001)
        #expect(MonthHistory.firstDay(of: 20261001, movedBy: -1, in: utcDay) == 20260901)
        #expect(MonthHistory.firstDay(of: 20261001, movedBy: 3, in: utcDay) == 20270101)
        #expect(MonthHistory.firstDay(of: 20260101, movedBy: -1, in: utcDay) == 20251201)
    }

    @Test func anOrdinalThatNamesNoMonthIsNothing() {
        #expect(MonthHistory.interval(of: 20261301, in: utcDay) == nil)
        #expect(MonthHistory.days(of: 20260001, in: utcDay).isEmpty)
        #expect(make([], month: 20261301) == nil)
    }

    @Test func aMonthHasItsOwnNumberOfDays() {
        #expect(MonthHistory.days(of: 20261001, in: utcDay).count == 31)
        #expect(MonthHistory.days(of: 20260901, in: utcDay).count == 30)
        #expect(MonthHistory.days(of: 20270201, in: utcDay).count == 28)
        #expect(MonthHistory.days(of: 20280201, in: utcDay).count == 29, "a leap February")
        #expect(MonthHistory.days(of: 20261001, in: utcDay).map(\.ordinal) == Array(20261001...20261031))
    }

    /// November 2025 in New York holds the 25-hour fall-back day: still thirty days, each once, and two
    /// servings on it 24h29m apart are one day (rule `30-rollover`).
    @Test func aDaylightSavingMonthKeepsEveryDay() throws {
        let newYork = gregorian(in: "America/New_York")
        #expect(MonthHistory.days(of: 20251101, in: newYork).map(\.ordinal) == Array(20251101...20251130))

        let early = newYork.date(from: DateComponents(year: 2025, month: 11, day: 2, hour: 0, minute: 30))!
        let late = newYork.date(from: DateComponents(year: 2025, month: 11, day: 2, hour: 23, minute: 59))!
        let now = newYork.date(from: DateComponents(year: 2025, month: 12, day: 5, hour: 12))!
        let month = try #require(make([log(500, at: early), log(250, at: late)], month: 20251101, first: early, now: now, calendar: newYork))
        #expect(month.days.first { $0.summary.dayOrdinal == 20251102 }?.summary.total == 750)
        #expect(month.days.filter { $0.summary.total > 0 }.count == 1)
    }

    @Test func aMonthKnowsTheWeekdayItsFirstFallsOn() throws {
        #expect(try #require(make([])).weekdayOfFirst == 5, "1 October 2026 is a Thursday")
        #expect(try #require(make([], month: 20260801)).weekdayOfFirst == 7, "1 August 2026 is a Saturday")
    }

    // MARK: Which days count

    @Test func aPastMonthCountsEveryDay() throws {
        let month = try #require(make([], month: 20260901))
        #expect(month.daysCounted == 30)
        #expect(month.days.allSatisfy { $0.isCounted && $0.canOpen })
        #expect(month.average == 0, "an empty day is a day the user drank nothing")
    }

    @Test func thisMonthCountsTodayOnlyOnceItHasReachedTheGoal() throws {
        let past = october(1...21, 3_000)
        let morning = try #require(make(past + [log(1_000, at: utc(2026, 10, 22, 9))]))
        #expect(morning.daysCounted == 21)
        #expect(morning.daysMet == 21)
        #expect(morning.days.first { $0.isToday }?.canOpen == true, "today opens before it counts")

        let met = try #require(make(past + [log(3_000, at: utc(2026, 10, 22, 9))]))
        #expect(met.daysCounted == 22)
        #expect(met.daysMet == 22)
    }

    @Test func daysStillToComeAreNeitherCountedNorOpened() throws {
        let ahead = try #require(make([])).days.filter { $0.summary.dayOrdinal > 20261022 }
        #expect(ahead.count == 9)
        #expect(ahead.allSatisfy { !$0.isCounted && !$0.canOpen })
    }

    @Test func theFirstMonthCountsFromTheFirstServing() throws {
        let month = try #require(make(october(15...21, 2_100), first: utc(2026, 10, 15, 9)))
        #expect(month.daysCounted == 7)
        #expect(month.average == 2_100, "averaged over the seven days since the first serving, not twenty-one")
        #expect(month.days.prefix(14).allSatisfy { !$0.canOpen && !$0.isCounted })
        #expect(month.earlier == nil, "nothing was logged before this month")
    }

    @Test func aMonthBeforeAnythingWasLoggedCountsNothing() throws {
        let month = try #require(make([], first: nil))
        #expect(month.daysCounted == 0)
        #expect(month.average == nil)
        #expect(month.change == nil)
        #expect(month.days.allSatisfy { !$0.canOpen })
        #expect(month.earlier == nil)
    }

    // MARK: The figures

    @Test func daysOnGoalAndTheBestRun() throws {
        // Met on every day from the 1st to the 21st but the 3rd, 13th, 15th and 19th: runs of 2, 9, 1, 3, 2.
        let short = [3, 13, 15, 19]
        let month = try #require(make((1...21).map { log(short.contains($0) ? 1_500 : 3_200, at: utc(2026, 10, $0)) }))
        #expect(month.daysMet == 17)
        #expect(month.daysCounted == 21)
        #expect(month.bestRun == 9)
    }

    @Test func aRunDoesNotCarryOverFromTheMonthBefore() throws {
        let rows = (25...30).map { log(3_000, at: utc(2026, 9, $0)) } + october(1...3, 3_000) + [log(500, at: utc(2026, 10, 4))]
        #expect(try #require(make(rows)).bestRun == 3)
    }

    @Test func theAverageCountsTheEmptyDays() throws {
        let month = try #require(make((1...15).map { log(3_000, at: utc(2026, 9, $0)) }, month: 20260901))
        #expect(month.average == 1_500)
        #expect(month.total == 45_000)
    }

    @Test func theTotalCountsTodaysWaterAndSaturates() throws {
        let month = try #require(make([log(Int.max, at: utc(2026, 10, 2)), log(250, at: utc(2026, 10, 22, 9))]))
        #expect(month.days[1].summary.total == DataManager.maximumDailyIntake, "a corrupt row is one full day, never a trap")
        #expect(month.total == DataManager.maximumDailyIntake + 250, "today's water is in the total before today counts")
    }

    /// Review Focus 1, plan M5: a pour stamped ahead of the phone's clock lands on a day still to come,
    /// and counts nowhere until that day comes.
    @Test func aServingStampedAfterTodayCountsNowhere() throws {
        let month = try #require(make([log(500, at: utc(2026, 10, 25))]))
        #expect(month.total == 0)
        #expect(month.days.first { $0.summary.dayOrdinal == 20261025 }?.canOpen == false)
    }

    @Test func theChangeComparesTheAverageWithTheMonthBefore() throws {
        let september = (1...30).map { log(2_000, at: utc(2026, 9, $0)) }
        #expect(try #require(make(september + october(1...21, 2_240))).change == 240)
        #expect(try #require(make(september + october(1...21, 1_900))).change == -100)
        #expect(try #require(make(september + october(1...21, 2_000))).change == 0)
    }

    @Test func thereIsNoChangeWithoutAMonthBefore() throws {
        #expect(try #require(make(october(1...21, 2_000), first: utc(2026, 10, 1))).change == nil)
    }

    @Test func raisingTheGoalRejudgesEveryDay() throws {
        let rows = october(1...21, 2_500)
        #expect(try #require(make(rows, goal: 2_000)).daysMet == 21)
        #expect(try #require(make(rows, goal: 3_000)).daysMet == 0)
    }

    @Test func aDayTellsItsRingWhatToDraw() throws {
        let month = try #require(make([log(1_500, at: utc(2026, 10, 5)), log(4_500, at: utc(2026, 10, 6))]))
        #expect(month.days[4].fraction == 0.5)
        #expect(!month.days[4].isMet)
        #expect(month.days[5].fraction == 1, "the arc closes at the goal and goes no further")
        #expect(month.days[5].isMet)
        #expect(month.days[21].isToday)
        #expect(month.days.filter(\.isToday).count == 1)
    }

    // MARK: The neighbours

    @Test func theArrowsStopAtTheFirstServingAndAtThisMonth() throws {
        let first = utc(2026, 8, 10)
        let october = try #require(make([], first: first))
        #expect(october.earlier?.firstDay == 20260901)
        #expect(october.later == nil)

        let august = try #require(make([], month: 20260801, first: first))
        #expect(august.earlier == nil)
        #expect(august.later?.firstDay == 20260901)
        #expect(august.later?.start == utc(2026, 9, 1, 0))
    }

    // MARK: The calendar's edges

    @Test func theLastMinuteAndTheFirstFallInTheirOwnMonths() throws {
        let rows = [log(400, at: utc(2026, 10, 31, 23, 59)), log(600, at: utc(2026, 11, 1, 0, 1))]
        let now = utc(2026, 11, 5)
        #expect(try #require(make(rows, now: now)).total == 400)
        #expect(try #require(make(rows, month: 20261101, now: now)).total == 600)
    }

    /// Review Focus 4: 00:30 on 1 October in Paris is 23:30 on 30 September in London. A serving
    /// follows its instant into whichever month the zone puts it in — the cost of recording an instant
    /// and not a day (`theSameInstantsRegroupUnderAWestwardTimeZone`, rule `30-rollover`).
    @Test func aServingAtTheMonthsEdgeRegroupsWithTheZone() throws {
        let paris = gregorian(in: "Europe/Paris")
        let london = gregorian(in: "Europe/London")
        let instant = paris.date(from: DateComponents(year: 2026, month: 10, day: 1, hour: 0, minute: 30))!
        let rows = [log(500, at: instant)]
        let now = utc(2026, 10, 22)

        #expect(try #require(make(rows, first: instant, now: now, calendar: paris)).total == 500)
        #expect(try #require(make(rows, first: instant, now: now, calendar: london)).total == 0)
        #expect(try #require(make(rows, month: 20260901, first: instant, now: now, calendar: london)).total == 500)
    }

    // MARK: Its patterns (spec `2026-10-23-patterns-design.md` §3.6)

    /// The month carries its patterns from its own rows: a September of water beside six October days
    /// is no October pattern, and a seventh October day is.
    @Test func aMonthCarriesThePatternsOfItsOwnRows() throws {
        let september = (1...30).map { log(500, at: utc(2026, 9, $0)) }

        let six = try #require(make(september + october(1...6, 500)))
        #expect(six.patterns == nil, "the month before's rows never reach this month's patterns")

        let seven = try #require(make(september + october(1...7, 500)))
        let patterns = try #require(seven.patterns)
        #expect(patterns.daysWithWater == 7)
        #expect(patterns.hourly[12] == 3_500)
        #expect(patterns.goal == goal)
    }
}

// MARK: - Publishing

private final class Counter: @unchecked Sendable {
    var count = 0
}

/// Every change to what `read` reads, counted: `withObservationTracking` fires once and lets go, so
/// the tally arms it again from inside each `onChange` — which runs synchronously, on the main actor,
/// within the mutation itself.
@MainActor
private final class ChangeTally {
    private(set) var count = 0
    private let read: @MainActor () -> Void

    init(_ read: @escaping @MainActor () -> Void) {
        self.read = read
        arm()
    }

    private func arm() {
        withObservationTracking { read() } onChange: { [weak self] in
            MainActor.assumeIsolated {
                self?.count += 1
                self?.arm()
            }
        }
    }
}

/// A `DataManager` over a throwaway suite and an in-memory store — or `container`, for the failed read —
/// with every side effect injected away (rule `85-testing`).
@MainActor
private func withMonthStore<T>(
    now: @escaping () -> Date,
    container: ModelContainer? = nil,
    _ body: (DataManager) throws -> T
) throws -> T {
    let name = "test.waterbuddy.month.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    let manager = DataManager(
        defaults: defaults,
        modelContainer: try container ?? ModelContainer(
            for: WaterLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ),
        calendar: utcDay,
        now: now,
        reloadWidgets: {},
        rescheduleReminders: { _ in },
        publishWrist: { _ in }
    )
    return try body(manager)
}

/// One suite and one store two managers share — the app and `AddWaterIntent`'s instance.
@MainActor
private func withSharedMonthStore<T>(_ body: (UserDefaults, ModelContainer) throws -> T) throws -> T {
    let name = "test.waterbuddy.month.shared.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    let container = try ModelContainer(for: WaterLog.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    return try body(defaults, container)
}

@MainActor
private func makeMonthManager(_ defaults: UserDefaults, container: ModelContainer, now: @escaping () -> Date) -> DataManager {
    DataManager(
        defaults: defaults,
        modelContainer: container,
        calendar: utcDay,
        now: now,
        reloadWidgets: {},
        rescheduleReminders: { _ in },
        publishWrist: { _ in }
    )
}

/// The month as `DataManager` publishes it (spec §3.7): only while History has asked for one, from
/// every site that changes what it draws, and never from a failed read.
@MainActor
struct MonthPublishingTests {

    @Test func nothingIsPublishedUntilHistoryAsksForAMonth() throws {
        try withMonthStore(now: { thursday22 }) { manager in
            manager.addLog(amount: 500, at: utc(2026, 10, 5))
            #expect(manager.month == nil)
            #expect(manager.monthLogs.isEmpty)
        }
    }

    @Test func askingForAMonthPublishesItAndItsRows() throws {
        try withMonthStore(now: { thursday22 }) { manager in
            manager.addLog(amount: 500, at: utc(2026, 10, 5, 9))
            manager.addLog(amount: 250, at: utc(2026, 10, 5, 15))
            manager.addLog(amount: 750, at: utc(2026, 9, 30))

            manager.showMonth(manager.thisMonth)

            let month = try #require(manager.month)
            #expect(month.firstDay == 20261001)
            #expect(month.days[4].summary.total == 750)
            #expect(manager.monthLogs[20261005]?.map(\.amount) == [250, 500], "newest first")
            #expect(manager.monthLogs[20260930] == nil, "the month before is read for the change, never published")
        }
    }

    @Test func askingForNoMonthClearsBoth() throws {
        try withMonthStore(now: { thursday22 }) { manager in
            manager.addLog(amount: 500, at: utc(2026, 10, 5))
            manager.showMonth(manager.thisMonth)

            manager.showMonth(nil)

            #expect(manager.month == nil)
            #expect(manager.monthLogs.isEmpty)
        }
    }

    /// Review Focus 5.
    @Test func aMonthThatNamesNoMonthPublishesNothing() throws {
        try withMonthStore(now: { thursday22 }) { manager in
            manager.addLog(amount: 500, at: utc(2026, 10, 5))
            manager.showMonth(20261301)
            #expect(manager.month == nil)
            #expect(manager.monthLogs.isEmpty)
        }
    }

    @Test func aPourWhileAMonthIsShownRepublishesIt() throws {
        try withMonthStore(now: { thursday22 }) { manager in
            manager.showMonth(manager.thisMonth)
            let counter = Counter()
            withObservationTracking { _ = manager.month } onChange: { counter.count += 1 }

            manager.addLog(amount: 3_000)

            #expect(counter.count == 1, "a month that never redraws is the whole hazard")
            #expect(manager.month?.days[21].summary.total == 3_000)
            #expect(manager.monthLogs[20261022]?.count == 1)
        }
    }

    /// The owner's ruling of 2026-10-22: a pour reads the shown month once — after its write — not
    /// in its leading re-read as well, which cost 7 ms at 500 days where once is 3.5. `monthLogs` is
    /// republished unguarded on every read, so its changes count the reads.
    @Test func aPourReadsTheShownMonthOnce() throws {
        try withMonthStore(now: { thursday22 }) { manager in
            manager.showMonth(manager.thisMonth)
            let reads = ChangeTally { _ = manager.monthLogs }

            manager.addLog(amount: 250)

            #expect(reads.count == 1)
            #expect(manager.monthLogs[20261022]?.count == 1, "the one read is the one after the write")
        }
    }

    @Test func aRemovalReadsTheShownMonthOnce() throws {
        try withMonthStore(now: { thursday22 }) { manager in
            manager.addLog(amount: 500)
            manager.showMonth(manager.thisMonth)
            let reads = ChangeTally { _ = manager.monthLogs }

            manager.removeWater(amount: 200)

            #expect(reads.count == 1)
            #expect(manager.month?.days[21].summary.total == 300, "the one read is the one after the write")
        }
    }

    /// A refresh on its own still reads the month — it is how a serving another process logged reaches
    /// a month on screen.
    @Test func aRefreshStillReadsTheShownMonth() throws {
        try withMonthStore(now: { thursday22 }) { manager in
            manager.showMonth(manager.thisMonth)
            let reads = ChangeTally { _ = manager.monthLogs }

            manager.refresh()

            #expect(reads.count == 1)
        }
    }

    /// `month` is a value, so it may carry `history`'s equality guard; `refresh()` runs on every
    /// foreground, and an unguarded republish would redraw the month for nothing.
    @Test func aRefreshThatChangesNothingDoesNotChurnTheMonth() throws {
        try withMonthStore(now: { thursday22 }) { manager in
            manager.addLog(amount: 250)
            manager.showMonth(manager.thisMonth)
            let counter = Counter()
            withObservationTracking { _ = manager.month } onChange: { counter.count += 1 }

            manager.refresh()

            #expect(counter.count == 0, "nothing moved, so nothing should redraw")
        }
    }

    /// A failed read is not an empty month (rule `20-state`).
    @Test func aFailedReadLeavesTheMonthAsItStands() throws {
        let store = try UnreadableStore()
        defer { store.remove() }
        try withMonthStore(now: { thursday22 }, container: store.container) { manager in
            manager.addLog(amount: 500, at: utc(2026, 10, 5))
            manager.showMonth(manager.thisMonth)
            let before = try #require(manager.month, "the store must be healthy before it is broken")

            try store.breakReads()
            #expect(!store.stillReads, "the store must be unreadable before anything is asserted about a failed read")
            manager.refresh()

            #expect(manager.month == before)
            #expect(manager.monthLogs[20261005]?.count == 1)
        }
    }

    /// Review Focus 3.
    @Test func aMonthEndingOnScreenStaysShownAndBecomesPast() throws {
        var clock = utc(2026, 10, 31, 22)
        try withMonthStore(now: { clock }) { manager in
            manager.addLog(amount: 500, at: utc(2026, 10, 1))
            manager.showMonth(manager.thisMonth)
            #expect(manager.month?.later == nil)

            clock = utc(2026, 11, 1, 0, 30)
            manager.dayDidTurn()

            let month = try #require(manager.month)
            #expect(month.firstDay == 20261001)
            #expect(month.later?.firstDay == 20261101)
            #expect(month.daysCounted == 31)
            #expect(!month.days.contains { $0.isToday })
        }
    }

    @Test func aGoalChangeRejudgesTheShownMonth() throws {
        try withMonthStore(now: { thursday22 }) { manager in
            manager.addLog(amount: 2_500, at: utc(2026, 10, 5))
            manager.dailyGoal = 3_000
            manager.showMonth(manager.thisMonth)
            #expect(manager.month?.daysMet == 0)

            manager.dailyGoal = 2_000

            #expect(manager.month?.daysMet == 1)
        }
    }

    /// Today joins the patterns at midnight (spec `2026-10-23-patterns-design.md` §3.1): six finished
    /// days and today's water are no pattern until the day turns, and then they are.
    @Test func theDayTurningAddsYesterdayToThePatterns() throws {
        var clock = utc(2026, 10, 7, 20)
        try withMonthStore(now: { clock }) { manager in
            for day in 1...7 { manager.addLog(amount: 500, at: utc(2026, 10, day, 9)) }
            manager.showMonth(manager.thisMonth)
            #expect(manager.month != nil)
            #expect(manager.month?.patterns == nil, "the 7th is today, and not over")

            clock = utc(2026, 10, 8, 0, 30)
            manager.dayDidTurn()

            #expect(manager.month?.patterns?.daysWithWater == 7)
        }
    }

    @Test func aSecondInstancesServingIsPickedUpByARefresh() throws {
        try withSharedMonthStore { defaults, container in
            let app = makeMonthManager(defaults, container: container, now: { thursday22 })
            let widget = makeMonthManager(defaults, container: container, now: { thursday22 })
            app.showMonth(app.thisMonth)

            widget.addLog(amount: 250)
            app.refresh()

            #expect(app.month?.days[21].summary.total == 250)
        }
    }

    @Test func thisMonthFollowsTheClock() throws {
        var clock = thursday22
        try withMonthStore(now: { clock }) { manager in
            #expect(manager.thisMonth == 20261001)
            clock = utc(2027, 1, 3)
            #expect(manager.thisMonth == 20270101)
        }
    }

    /// Review Focus 2.
    @Test func deletingTheFirstServingMovesTheEarliestBound() throws {
        try withMonthStore(now: { thursday22 }) { manager in
            manager.addLog(amount: 500, at: utc(2026, 9, 10))
            manager.addLog(amount: 500, at: utc(2026, 10, 5))
            manager.showMonth(manager.thisMonth)
            #expect(manager.month?.earlier?.firstDay == 20260901)

            // `allLogs()` is newest first: its last row is September's.
            manager.deleteLog(try #require(manager.allLogs().last))

            #expect(manager.month?.earlier == nil)
            #expect(manager.month?.days[4].isCounted == true, "the 5th is the first serving now")
            #expect(manager.month?.days[3].canOpen == false)
        }
    }
}
