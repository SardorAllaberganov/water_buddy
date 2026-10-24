//
//  WeekInsightsTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 23/10/26.
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

private func on(_ calendar: Calendar, _ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
    calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

/// A day of October 2026, UTC.
private func october(_ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
    on(utcDay, 2026, 10, day, hour, minute)
}

private func log(_ amount: Int, at date: Date) -> WaterLog {
    WaterLog(amount: amount, timestamp: date)
}

/// `amount` at `hour`:`minute` on each of October's `days`.
private func days(_ days: [Int], _ amount: Int, at hour: Int = 12, _ minute: Int = 0) -> [WaterLog] {
    days.map { log(amount, at: october($0, hour, minute)) }
}

private let goal = 2_000

/// Thursday 22 October 2026, 14:00 UTC — *today* in this file. 1 October 2026 is a Thursday. With
/// Sunday first, the finished week is Sunday 11 to Saturday 17 — its weekend the 11th and the 17th —
/// and the week before Sunday 4 to Saturday 10; with Monday first, the 12th to the 18th and the 5th to
/// the 11th.
private let thursday22 = october(22, 14)

/// US English: Sunday first, Saturday and Sunday off.
private let sundayFirst = WeekInsights.Request(firstWeekday: 1, weekend: [1, 7])
/// Russian and Uzbek: Monday first.
private let mondayFirst = WeekInsights.Request(firstWeekday: 2, weekend: [1, 7])
/// Sunday first, Friday and Saturday off.
private let fridayAndSaturdayOff = WeekInsights.Request(firstWeekday: 1, weekend: [6, 7])

/// Long before both weeks, so every day of them counts.
private let longAgo = on(utcDay, 2026, 8, 1)

private func insights(
    _ rows: [WaterLog],
    request: WeekInsights.Request = sundayFirst,
    first: Date? = longAgo,
    goal: Int = goal,
    now: Date = thursday22,
    calendar: Calendar = utcDay
) -> WeekInsights? {
    WeekInsights.make(rows: rows, request: request, firstServing: first, goal: goal, now: now, calendar: calendar)
}

private let finishedWeek = Array(11...17)
private let weekBefore = Array(4...10)

// MARK: - The value

/// One week's insights, worked out with no store, no `DataManager` and no main actor (spec
/// `2026-10-23-insights-design.md` §3.1 to §3.3). Not `@MainActor`, on purpose: a canary for
/// ``WeekInsights`` staying a pure value (rule `43-concurrency`), as `MonthPatternsTests` is for
/// ``MonthPatterns``. Fix the declaration it reads, never this suite.
struct WeekInsightsTests {

    // MARK: Which week

    @Test func theWeekIsTheLastFinishedOneFromTheLocalesFirstDay() throws {
        let sunday = try #require(insights([], first: nil))
        #expect(sunday.firstDay == october(11, 0))
        #expect(sunday.lastDay == october(17, 0))
        #expect(sunday.nextWeek == october(25, 0))

        let monday = try #require(insights([], request: mondayFirst, first: nil))
        #expect(monday.firstDay == october(12, 0))
        #expect(monday.lastDay == october(18, 0))
        #expect(monday.nextWeek == october(26, 0))
    }

    @Test func theWeekTurnsAtMidnightOnTheLocalesFirstDay() throws {
        let saturdayNight = try #require(insights([], first: nil, now: october(17, 23, 59)))
        #expect(saturdayNight.firstDay == october(4, 0))

        let sundayMorning = try #require(insights([], first: nil, now: october(18, 0, 1)))
        #expect(sundayMorning.firstDay == october(11, 0))
    }

    /// Sunday 1 November 2026 is 25 hours long in New York: the week is still seven days, walked by
    /// the calendar and never by 86,400 seconds (rule `30-rollover`).
    @Test func aWeekAcrossTheEndOfDaylightSavingKeepsItsSevenDays() throws {
        let newYork = gregorian(in: "America/New_York")
        let rows = (1...7).map { log(2_000, at: on(newYork, 2026, 11, $0, 23, 30)) }
        let week = try #require(insights(rows, first: nil, now: on(newYork, 2026, 11, 12, 9), calendar: newYork))
        #expect(week.firstDay == on(newYork, 2026, 11, 1, 0))
        #expect(week.lastDay == on(newYork, 2026, 11, 7, 0))
        #expect(week.nextWeek == on(newYork, 2026, 11, 15, 0))

        let counted = try #require(insights(rows, first: on(newYork, 2026, 10, 1), now: on(newYork, 2026, 11, 12, 9), calendar: newYork))
        // Every serving at 23:30 lands on its own day: seven days, every one on goal.
        #expect(counted.content?.oneThing == .everyDayMet)
    }

    // MARK: When it appears

    @Test func aWeekWithFewerThanFourDaysOfWaterIsPending() throws {
        let three = try #require(insights(days([12, 13, 14], 2_000)))
        #expect(three.content == nil)

        let four = try #require(insights(days([12, 13, 14, 15], 2_000)))
        #expect(four.content != nil)
    }

    @Test func aUserWithNoServingIsPending() throws {
        let none = try #require(insights([], first: nil))
        #expect(none.content == nil)
    }

    /// The first week after an install counts from the first serving's day, as the month does.
    @Test func daysBeforeTheFirstServingDoNotCount() throws {
        let week = try #require(insights(days([14, 15, 16, 17], 2_000), first: october(14, 8)))
        let content = try #require(week.content)
        #expect(content.oneThing == .everyDayMet)
        #expect(content.detail == .average(2_000, goal: 2_000))
    }

    @Test func theWeekBeforeIsComparedOnlyWhenItQualifies() throws {
        let thisWeek = days(finishedWeek, 2_000)

        let thin = try #require(insights(thisWeek + days([5, 6, 7], 3_000))?.content)
        #expect(thin.working == nil)

        // Four days of 3,000 before: 4 on goal, an average of 1,714. Now 7 on goal.
        let full = try #require(insights(thisWeek + days([5, 6, 7, 8], 3_000))?.content)
        #expect(full.working == .moreDaysMet(7, before: 4))
    }

    // MARK: The one thing

    @Test func weekendsRunningLowerIsTheOneThing() throws {
        let rows = days([12, 13, 14, 15, 16], 2_500) + days([11, 17], 1_000)
        let content = try #require(insights(rows)?.content)
        #expect(content.oneThing == .weekendsLower(1_500))
        #expect(content.suggestion == WeekInsights.Suggestion(gap: 1_500, when: .weekendDays))
        #expect(content.detail == nil)
        #expect(content.working == .everyWeekdayMet)
    }

    @Test func weekdaysRunningLowerIsTheOneThing() throws {
        let rows = days([12, 13, 14, 15, 16], 1_500) + days([11, 17], 4_000)
        let content = try #require(insights(rows)?.content)
        #expect(content.oneThing == .weekdaysLower(2_500))
        #expect(content.suggestion == WeekInsights.Suggestion(gap: 2_500, when: .weekdays))
        #expect(content.working == .everyWeekendDayMet)
    }

    @Test func aShortfallNamesThePartOfTheDayThatHeldTheLeast() throws {
        let mornings = try #require(insights(days(finishedWeek, 1_500, at: 9))?.content)
        #expect(mornings.oneThing == .shortOfGoal(500))
        // Nothing in the afternoon or the evening: the tie goes to the earlier.
        #expect(mornings.suggestion == WeekInsights.Suggestion(gap: 500, when: .each(.afternoon)))

        let rows = days(finishedWeek, 1_000, at: 9) + days(finishedWeek, 500, at: 14)
        let evenings = try #require(insights(rows)?.content)
        #expect(evenings.suggestion == WeekInsights.Suggestion(gap: 500, when: .each(.evening)))
    }

    @Test func aDropOnTheWeekBeforeIsTheOneThingEvenWithTheGoalMet() throws {
        let rows = days(weekBefore, 3_000) + days(finishedWeek, 2_100)
        let content = try #require(insights(rows)?.content)
        #expect(content.oneThing == .lessThanBefore(900))
        // Every serving at noon, the afternoon's: the morning and the evening tie, and the earlier wins.
        #expect(content.suggestion == WeekInsights.Suggestion(gap: 900, when: .each(.morning)))
    }

    /// Weekdays exactly on goal and weekends 700 short: the weekends score 700 × 2 = 1,400, and an average
    /// of 1,800 is 200 short, 200 × 7 = 1,400 — a tie, and the earlier in the order is taken.
    @Test func aTieGoesToTheEarlierShortfall() throws {
        let rows = days([12, 13, 14, 15, 16], 2_000) + days([11, 17], 1_300)
        let content = try #require(insights(rows)?.content)
        #expect(content.oneThing == .weekendsLower(700))
    }

    /// Weekends 800 under weekdays but on goal themselves: not a shortfall — a suggestion to drink more on
    /// days that met the goal would sit beside *Your goal on every weekend day* (the final review's M7).
    @Test func aSideOnGoalIsNoShortfall() throws {
        let rows = days([12, 13, 14, 15, 16], 3_000) + days([11, 17], 2_200)
        let content = try #require(insights(rows)?.content)
        #expect(content.oneThing == .everyDayMet)
        #expect(content.suggestion == nil)
    }

    /// Short of the goal by 500 a day scores 3,500; down 1,500 on the week before, 10,500.
    @Test func theLargerShortfallWins() throws {
        let rows = days(weekBefore, 3_000) + days(finishedWeek, 1_500)
        let content = try #require(insights(rows)?.content)
        #expect(content.oneThing == .lessThanBefore(1_500))
    }

    /// A goal of 3,000 says nothing under 300: weekends 200 lower and an average 158 short.
    @Test func aDifferenceUnderATenthOfTheGoalIsNotSaid() throws {
        let rows = days([12, 13, 14, 15, 16], 2_900) + days([11, 17], 2_700)
        let content = try #require(insights(rows, goal: 3_000)?.content)
        #expect(content.oneThing == .average(2_850, goal: 3_000))
        #expect(content.suggestion == nil)
        #expect(content.detail == nil)
        #expect(content.working == nil)
    }

    @Test func theThresholdIsATenthOfTheGoalAndNeverUnderFiftyMillilitres() {
        #expect(WeekInsights.threshold(goal: 2_000) == 200)
        #expect(WeekInsights.threshold(goal: 300) == 50)
        #expect(WeekInsights.threshold(goal: 0) == 50)
    }

    @Test func figuresAreRoundedToFiftyMillilitresHalfUp() {
        #expect(WeekInsights.rounded(24) == 0)
        #expect(WeekInsights.rounded(25) == 50)
        #expect(WeekInsights.rounded(74) == 50)
        #expect(WeekInsights.rounded(75) == 100)
        #expect(WeekInsights.rounded(1_975) == 2_000)
    }

    @Test func everyDayOnGoalTakesTheAverageAsItsDetail() throws {
        let content = try #require(insights(days(finishedWeek, 2_200))?.content)
        #expect(content.oneThing == .everyDayMet)
        #expect(content.detail == .average(2_200, goal: 2_000))
        // Nothing weaker repeats it: not every weekday, not the count of days.
        #expect(content.working == nil)
    }

    // MARK: What is working

    @Test func everyWeekdayOnGoalNeedsThreeOfThem() throws {
        let first = october(14, 8)

        // Saturday and Sunday off: the 14th, 15th and 16th are weekdays, the 17th the weekend.
        let three = days([14, 15, 16], 2_000) + days([17], 1_500)
        let saturday = try #require(insights(three, first: first)?.content)
        #expect(saturday.oneThing == .weekendsLower(500))
        #expect(saturday.working == .everyWeekdayMet)

        // Friday and Saturday off: two weekdays, the 14th and 15th, are not enough.
        let two = days([14, 15, 16], 2_000) + days([17], 1_500)
        let friday = try #require(insights(two, request: fridayAndSaturdayOff, first: first)?.content)
        #expect(friday.oneThing == .weekendsLower(250))
        #expect(friday.working == .daysMet(3, of: 4))
    }

    /// *Goal met on 5 days, up from 3* is the one thing: *5 of 7 days on goal* would say it twice (the
    /// final review's I2). Both weeks average 2,014.
    @Test func theCountOfDaysOnGoalIsNotSaidTwice() throws {
        let before = days([4, 5, 6], 2_700) + days([7, 8, 9, 10], 1_500)
        let this = days([13, 14, 15, 16, 17], 2_100) + days([11, 12], 1_800)
        let content = try #require(insights(before + this)?.content)
        #expect(content.oneThing == .moreDaysMet(5, before: 3))
        #expect(content.working == nil)
    }

    @Test func aFirstDrinkHalfAnHourEarlierIsWorking() throws {
        let rows = days(weekBefore, 2_000, at: 8) + days(finishedWeek, 2_000, at: 7, 30)
        let content = try #require(insights(rows)?.content)
        #expect(content.oneThing == .everyDayMet)
        #expect(content.working == .earlierStart(minutes: 30))
    }

    @Test func aMoreGenerousWeekIsWorking() throws {
        let rows = days(weekBefore, 2_000) + days(finishedWeek, 2_300)
        let content = try #require(insights(rows)?.content)
        #expect(content.oneThing == .everyDayMet)
        #expect(content.working == .moreThanBefore(300))
    }

    // MARK: Worth knowing

    @Test func aFirstDrinkAnHourLaterIsWorthKnowing() throws {
        let rows = days(weekBefore, 2_000, at: 8) + days(finishedWeek, 2_000, at: 9)
        let content = try #require(insights(rows)?.content)
        #expect(content.worthKnowing == .laterStart(minutes: 60))
    }

    @Test func aFirstDrinkUnderHalfAnHourLaterIsNotSaid() throws {
        let rows = days(weekBefore, 2_000, at: 8) + days(finishedWeek, 2_000, at: 8, 25)
        let content = try #require(insights(rows)?.content)
        #expect(content.worthKnowing == .halfBy(october(11, 9)))
    }

    @Test func daysWithNothingLoggedComeFirst() throws {
        let rows = days(weekBefore, 2_000, at: 8) + days([12, 13, 14, 15, 16], 2_500, at: 10)
        let content = try #require(insights(rows)?.content)
        #expect(content.oneThing == .weekendsLower(2_500))
        #expect(content.worthKnowing == .emptyDays(2))
    }

    @Test func halfTheWaterIsInByTheNextWholeHour() throws {
        let rows = days(finishedWeek, 500, at: 8, 10) + days(finishedWeek, 500, at: 18)
        let content = try #require(insights(rows)?.content)
        #expect(content.worthKnowing == .halfBy(october(11, 9)))
    }

    @Test func theHalfWayHourIsHeldToFiveToMidnight() throws {
        let content = try #require(insights(days(finishedWeek, 2_000, at: 23, 30))?.content)
        #expect(content.worthKnowing == .halfBy(october(11, 23, 55)))
    }

    /// Half the water in at 23:57: *before 23:55* would be untrue, so it is not said (the final review's
    /// M4).
    @Test func aHalfWayAfterFiveToMidnightIsNotSaid() throws {
        let content = try #require(insights(days(finishedWeek, 2_000, at: 23, 57))?.content)
        #expect(content.worthKnowing == nil)
    }

    // MARK: Degrading

    @Test func aCorruptRowSaturatesRatherThanTraps() throws {
        let rows = days([12, 13, 14, 15], 2_000) + [log(.max, at: october(16))]
        let content = try #require(insights(rows)?.content)
        // The corrupt day stands at the ceiling, 100,000: the weekdays average 21,600 against an
        // empty weekend.
        #expect(content.oneThing == .weekendsLower(21_600))
    }

    /// A corrupt row near `Int.min` reads as nothing rather than trapping a score's multiplication (the
    /// final review's M5): weekdays 1,600 on average, an average day 1,142, 858 short.
    @Test func aNegativeRowIsReadAsNothing() throws {
        let rows = days([12, 13, 14, 15], 2_000) + [log(.min + 1, at: october(16))]
        let content = try #require(insights(rows)?.content)
        #expect(content.oneThing == .shortOfGoal(850))
    }

    // MARK: The suggestion

    @Test func theSuggestionTakesTheVesselNearestTheGap() {
        let vessels = [200, 400, 750]
        // 100 either side: the tie goes to the smaller.
        #expect(WeekInsights.Suggestion(gap: 300, when: .weekdays).vessel(in: vessels) == 0)
        #expect(WeekInsights.Suggestion(gap: 600, when: .weekdays).vessel(in: vessels) == 2)
        #expect(WeekInsights.Suggestion(gap: 5_000, when: .weekdays).vessel(in: vessels) == 2)
        #expect(WeekInsights.Suggestion(gap: 50, when: .weekdays).vessel(in: vessels) == 0)
        #expect(WeekInsights.Suggestion(gap: 300, when: .weekdays).vessel(in: []) == nil)
    }
}

// MARK: - Publishing

/// A `DataManager` over a throwaway suite and an in-memory store — or `container`, for the failed read —
/// with every side effect injected away (rule `85-testing`).
@MainActor
private func withInsightsStore<T>(
    now: @escaping () -> Date,
    container: ModelContainer? = nil,
    _ body: (DataManager, UserDefaults) throws -> T
) throws -> T {
    let name = "test.waterbuddy.insights.\(UUID().uuidString)"
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
    return try body(manager, defaults)
}

/// The week's insights as `DataManager` publishes them (spec §3.6): only while History has asked for
/// them, from every site that changes what they say, and never from a failed read.
@MainActor
struct InsightsPublishingTests {

    @Test func nothingIsPublishedUntilHistoryAsksForInsights() throws {
        try withInsightsStore(now: { thursday22 }) { manager, _ in
            for day in [12, 13, 14, 15] { manager.addLog(amount: 2_000, at: october(day)) }
            #expect(manager.insights == nil)
        }
    }

    @Test func askingPublishesTheFinishedWeekAndLettingGoClearsIt() throws {
        try withInsightsStore(now: { thursday22 }) { manager, _ in
            for day in [12, 13, 14, 15] { manager.addLog(amount: 2_000, at: october(day)) }

            manager.showInsights(sundayFirst)
            let shown = try #require(manager.insights)
            #expect(shown.firstDay == october(11, 0))
            #expect(shown.content != nil)

            manager.showInsights(nil)
            #expect(manager.insights == nil)
        }
    }

    @Test func aServingInTheWeekRepublishesThem() throws {
        try withInsightsStore(now: { thursday22 }) { manager, _ in
            for day in [12, 13, 14] { manager.addLog(amount: 2_000, at: october(day)) }
            manager.showInsights(sundayFirst)
            #expect(manager.insights?.content == nil)

            manager.addLog(amount: 2_000, at: october(15))
            #expect(manager.insights?.content != nil)
        }
    }

    @Test func theDayTurningMovesTheWeek() throws {
        var clock = october(17, 23)
        try withInsightsStore(now: { clock }) { manager, _ in
            manager.showInsights(sundayFirst)
            #expect(manager.insights?.firstDay == october(4, 0))

            clock = october(18, 0, 30)
            manager.dayDidTurn()
            #expect(manager.insights?.firstDay == october(11, 0))
        }
    }

    @Test func theGoalMovingRepublishesThem() throws {
        try withInsightsStore(now: { thursday22 }) { manager, _ in
            for day in finishedWeek { manager.addLog(amount: 2_000, at: october(day)) }
            manager.saveDailyGoal(ml: 2_000)
            manager.showInsights(sundayFirst)
            #expect(manager.insights?.content?.oneThing == .everyDayMet)

            manager.saveDailyGoal(ml: 3_000)
            #expect(manager.insights?.content?.oneThing == .shortOfGoal(1_000))
        }
    }

    /// A failed read is not an empty week (rule `20-state`).
    @Test func aFailedReadLeavesThemAsTheyStand() throws {
        let store = try UnreadableStore()
        defer { store.remove() }
        try withInsightsStore(now: { thursday22 }, container: store.container) { manager, _ in
            for day in [12, 13, 14, 15] { manager.addLog(amount: 2_000, at: october(day)) }
            manager.showInsights(sundayFirst)
            let before = try #require(manager.insights, "the store must be healthy before it is broken")

            try store.breakReads()
            #expect(!store.stillReads, "the store must be unreadable before anything is asserted about a failed read")
            manager.refresh()

            #expect(manager.insights == before)
        }
    }

    /// A read, not a mutation: asking writes neither store's keys.
    @Test func askingWritesNoKey() throws {
        try withInsightsStore(now: { thursday22 }) { manager, defaults in
            for day in [12, 13, 14, 15] { manager.addLog(amount: 2_000, at: october(day)) }
            let keys = { defaults.dictionaryRepresentation().filter { $0.key.hasPrefix("sardor.WaterBuddy.") } as NSDictionary }
            let before = keys()

            manager.showInsights(sundayFirst)
            manager.showInsights(nil)

            #expect(keys() == before)
        }
    }
}
