//
//  MonthPatternsTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 23/10/26.
//

import Foundation
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
private func servings(_ days: ClosedRange<Int>, _ amount: Int, at hour: Int = 12, _ minute: Int = 0) -> [WaterLog] {
    days.map { log(amount, at: october($0, hour, minute)) }
}

private let goal = 3_000

/// Thursday 22 October 2026, 14:00 UTC — *today* in this file. 1 October 2026 is a Thursday, so the
/// finished days, the 1st to the 21st, hold three Saturdays (3, 10, 17) and three Sundays (4, 11, 18).
private let thursday22 = october(22, 14)

private let saturdayAndSunday: Set<Int> = [1, 7]
private let fridayAndSaturday: Set<Int> = [6, 7]

private func patterns(
    _ rows: [WaterLog],
    month: Int = 20261001,
    first: Date? = on(utcDay, 2026, 8, 1),
    goal: Int = goal,
    now: Date = thursday22,
    calendar: Calendar = utcDay
) -> MonthPatterns? {
    MonthPatterns.make(
        rows: rows,
        days: MonthHistory.days(of: month, in: calendar),
        firstServing: first,
        goal: goal,
        now: now,
        calendar: calendar
    )
}

private func minutes(_ hour: Int, _ minute: Int) -> Int {
    hour * 60 + minute
}

// MARK: - The value

/// A month's patterns, worked out with no store, no `DataManager` and no main actor (spec
/// `2026-10-23-patterns-design.md` §3). Not `@MainActor`, on purpose: a canary for ``MonthPatterns``
/// staying a pure value (rule `43-concurrency`), as `MonthHistoryTests` is for ``MonthHistory``. Fix
/// the declaration it reads, never this suite.
struct MonthPatternsTests {

    // MARK: Which days count (§3.1)

    @Test func onlyAFinishedDayJoinsThePatterns() throws {
        let rows = servings(1...7, 250, at: 9)
            + [log(1_000, at: october(22, 10))]   // today: not over yet
            + [log(500, at: october(23, 8))]      // stamped after today — a watch clock ahead of the phone's
        let found = try #require(patterns(rows))
        #expect(found.hourly[9] == 1_750)
        #expect(found.hourly[10] == 0, "today joins at midnight")
        #expect(found.hourly[8] == 0, "a day that has not happened counts in nothing")
        #expect(found.daysWithWater == 7)
        #expect(found.hourly.count == 24)
    }

    @Test func sixDaysOfWaterAreNotYetAPattern() {
        #expect(MonthPatterns.minimumDays == 7)
        #expect(patterns(servings(1...6, 500)) == nil)
        #expect(patterns(servings(1...6, 500) + [log(500, at: october(22, 9))]) == nil, "today is not a seventh day")
        #expect(patterns(servings(1...7, 500)) != nil)
    }

    @Test func aMonthWithNoFirstServingHasNoPatterns() {
        #expect(patterns(servings(1...10, 500), first: nil) == nil)
    }

    @Test func daysBeforeTheFirstServingCountInNoWeekday() throws {
        let found = try #require(patterns(servings(10...21, 2_000), first: october(10, 12)))
        #expect(found.weekdays.count == 7)
        #expect(found.weekdays.map(\.days).reduce(0, +) == 12, "the 10th to the 21st")
        let split = found.split(weekend: saturdayAndSunday)
        #expect(split.weekdays?.average == 2_000)
        #expect(split.weekends?.average == 2_000)
    }

    @Test func aPastMonthCountsEveryDayAfterTheFirstServing() throws {
        let september = (1...7).map { log(500, at: on(utcDay, 2026, 9, $0)) }
        let found = try #require(patterns(september, month: 20260901))
        #expect(found.weekdays.map(\.days).reduce(0, +) == 30, "all of September is over")
        #expect(found.daysWithWater == 7)
    }

    // MARK: When you drink (§3.3)

    @Test func eachHourHoldsItsOwnWater() throws {
        let rows = servings(1...7, 100)
            + [log(250, at: october(2, 7, 10)), log(500, at: october(3, 7, 50))]
            + [log(250, at: october(4, 23, 59)), log(100, at: october(5, 0, 5))]
        let found = try #require(patterns(rows))
        #expect(found.hourly[12] == 700)
        #expect(found.hourly[7] == 750)
        #expect(found.hourly[23] == 250)
        #expect(found.hourly[0] == 100)
        #expect(found.hourly.reduce(0, +) == 1_800)
    }

    @Test func theBusiestHourHoldsTheMostWater() throws {
        let rows = servings(1...7, 250, at: 8) + servings(1...7, 500, at: 13) + servings(1...3, 250, at: 19)
        #expect(try #require(patterns(rows)).busiestHour == 13)
    }

    @Test func aTieForTheBusiestHourGoesToTheEarlier() throws {
        let rows = servings(1...7, 500, at: 16) + servings(1...7, 500, at: 9)
        #expect(try #require(patterns(rows)).busiestHour == 9)
    }

    @Test func aCorruptRowSaturatesRatherThanTraps() throws {
        let rows = servings(1...7, 250, at: 10) + [log(Int.max, at: october(8, 10, 30))]
        let found = try #require(patterns(rows))
        #expect(found.hourly[10] == Int.max)
        #expect(found.busiestHour == 10)
    }

    // MARK: Weekdays and weekends (§3.4)

    /// Every weekday 3,000 but Monday the 5th, empty; every weekend day 2,000 but Sunday the 11th, empty.
    private var aWeekOfEachKind: [WaterLog] {
        (1...21).compactMap { day -> WaterLog? in
            let weekday = utcDay.component(.weekday, from: october(day))
            let isWeekend = weekday == 1 || weekday == 7
            if day == 5 || day == 11 { return nil }
            return log(isWeekend ? 2_000 : 3_000, at: october(day))
        }
    }

    @Test func eachKindOfDayIsAveragedOverItsOwnDaysEmptyOnesIncluded() throws {
        let split = try #require(patterns(aWeekOfEachKind)).split(weekend: saturdayAndSunday)
        // Fifteen weekdays, fourteen with water; six weekend days, five with water.
        #expect(split.weekdays?.average == 14 * 3_000 / 15)
        #expect(split.weekends?.average == 5 * 2_000 / 6)
    }

    @Test func theWeekendIsTheOneHandedIn() throws {
        let split = try #require(patterns(aWeekOfEachKind)).split(weekend: fridayAndSaturday)
        // Fridays 2, 9, 16 at 3,000 and Saturdays 3, 10, 17 at 2,000.
        #expect(split.weekends?.average == (3 * 3_000 + 3 * 2_000) / 6)
        // Sundays 4 and 18 at 2,000, the 11th empty; twelve Monday-to-Thursdays, eleven at 3,000
        // and the 5th empty.
        #expect(split.weekdays?.average == (2 * 2_000 + 11 * 3_000) / 15)
    }

    @Test func aSideIsJudgedAgainstTheGoalAndItsBarClamped() throws {
        let rows = (1...21).map { day -> WaterLog in
            let weekday = utcDay.component(.weekday, from: october(day))
            return log(weekday == 1 || weekday == 7 ? 4_000 : 1_500, at: october(day))
        }
        let found = try #require(patterns(rows))
        #expect(found.goal == goal)
        let split = found.split(weekend: saturdayAndSunday)
        let weekends = try #require(split.weekends)
        let weekdays = try #require(split.weekdays)
        #expect(weekends.isMet)
        #expect(weekends.fraction == 1, "clamped at the goal")
        #expect(!weekdays.isMet)
        #expect(weekdays.fraction == 0.5)
    }

    @Test func aSideWithNoDayIsNothing() throws {
        let found = try #require(patterns(servings(1...7, 500)))
        #expect(found.split(weekend: []).weekends == nil)
        #expect(found.split(weekend: Set(1...7)).weekdays == nil)
    }

    // MARK: First and last drink, usually (§3.5)

    /// A serving on October's `day`, `after` minutes past midnight.
    private func serving(on day: Int, after minute: Int) -> WaterLog {
        log(250, at: october(day, minute / 60, minute % 60))
    }

    @Test func theUsualTimesAreTheMediansOfTheDays() throws {
        // Firsts 7:00, 7:10, …, 8:00; a noon serving between; lasts 20:00, 20:05, …, 20:30.
        let rows = (1...7).flatMap { day in
            [
                serving(on: day, after: minutes(7, 0) + (day - 1) * 10),
                serving(on: day, after: minutes(12, 0)),
                serving(on: day, after: minutes(20, 0) + (day - 1) * 5),
            ]
        }
        let found = try #require(patterns(rows))
        #expect(found.firstDrink == minutes(7, 30))
        #expect(found.lastDrink == minutes(20, 15))
    }

    /// The days' times out of order, so a median taken without sorting — the middle day's, or a mean —
    /// names a different time (the final review's M3).
    @Test func theUsualTimeIsTheMedianWhateverOrderTheDaysCameIn() throws {
        // By day: 9:00, 7:00, 8:30, 6:50, 9:40, 7:20, 8:00 — sorted, the fourth is 8:00.
        let firsts = [minutes(9, 0), minutes(7, 0), minutes(8, 30), minutes(6, 50), minutes(9, 40), minutes(7, 20), minutes(8, 0)]
        let rows = firsts.enumerated().map { serving(on: $0.offset + 1, after: $0.element) }
        #expect(try #require(patterns(rows)).firstDrink == minutes(8, 0))
    }

    @Test func anEvenCountTakesTheEarlierOfTheTwoMiddleDays() throws {
        // 7:00, 7:10, …, 8:10 — the middle two are 7:30 and 7:40.
        let rows = (1...8).map { serving(on: $0, after: minutes(7, 0) + ($0 - 1) * 10) }
        #expect(try #require(patterns(rows)).firstDrink == minutes(7, 30))
    }

    @Test func aDayWithOneServingIsItsOwnFirstAndLast() throws {
        let found = try #require(patterns(servings(1...7, 500, at: 9, 25)))
        #expect(found.firstDrink == minutes(9, 25))
        #expect(found.lastDrink == minutes(9, 25))
    }

    @Test func theUsualTimesRoundToTheNearestFiveMinutes() throws {
        let rows = servings(1...7, 250, at: 7, 42) + servings(1...7, 250, at: 21, 13)
        let found = try #require(patterns(rows))
        #expect(found.firstDrink == minutes(7, 40))
        #expect(found.lastDrink == minutes(21, 15))
    }

    @Test func theLastDrinkStaysInsideTheDay() throws {
        let found = try #require(patterns(servings(1...7, 250, at: 23, 58)))
        #expect(found.lastDrink == minutes(23, 55), "never 00:00, which is the next day's")
    }

    // MARK: The clock, the zone and the calendar (rule `30-rollover`)

    /// 2 November 2025 in New York is 25 hours long: 01:30 happens twice and the day's last minute is
    /// 24h59m after its midnight.
    @Test func aDaylightSavingDayKeepsItsWallClock() throws {
        let newYork = gregorian(in: "America/New_York")
        let midnight = on(newYork, 2025, 11, 2, 0)
        let early = midnight.addingTimeInterval(30 * 60)                  // 00:30 EDT
        let firstOneThirty = midnight.addingTimeInterval(90 * 60)         // 01:30 EDT
        let secondOneThirty = midnight.addingTimeInterval(150 * 60)       // 01:30 EST
        let last = midnight.addingTimeInterval(24 * 3_600 + 59 * 60)      // 23:59 EST

        #expect(MonthPatterns.minuteOfDay(secondOneThirty, in: newYork) == minutes(1, 30))
        #expect(MonthPatterns.minuteOfDay(last, in: newYork) == minutes(23, 59), "never 24:59")

        let rows = [log(100, at: early), log(200, at: firstOneThirty), log(300, at: secondOneThirty), log(400, at: last)]
            + (3...8).map { log(250, at: on(newYork, 2025, 11, $0)) }
        let found = try #require(patterns(
            rows, month: 20251101, first: early, now: on(newYork, 2025, 12, 5), calendar: newYork
        ))
        #expect(found.hourly[0] == 100)
        #expect(found.hourly[1] == 500, "both 01:30s fall in hour 1")
        #expect(found.hourly[23] == 400)
        #expect(found.hourly[12] == 1_500)
    }

    @Test func theSameServingsRegroupIntoTheNewZonesHours() throws {
        let rows = (5...11).map { log(500, at: on(utcDay, 2026, 1, $0, 12)) }
        let now = on(utcDay, 2026, 2, 1)
        let first = on(utcDay, 2026, 1, 5)
        let london = try #require(patterns(rows, month: 20260101, first: first, now: now, calendar: gregorian(in: "Europe/London")))
        let paris = try #require(patterns(rows, month: 20260101, first: first, now: now, calendar: gregorian(in: "Europe/Paris")))
        #expect(london.busiestHour == 12)
        #expect(paris.busiestHour == 13, "the same instants, an hour later on Paris's clock")
        #expect(paris.hourly[12] == 0)
    }

    @Test func theDrawnInstantsStandOnTheMonthsFirstAtTheTimesTheyName() throws {
        let rows = servings(1...7, 500, at: 7, 40) + servings(1...7, 250, at: 21, 10)
        let found = try #require(patterns(rows))
        let first = utcDay.dateComponents([.day, .hour, .minute], from: found.firstDrinkAt)
        let last = utcDay.dateComponents([.day, .hour, .minute], from: found.lastDrinkAt)
        let busiest = utcDay.dateComponents([.day, .hour, .minute], from: found.busiestHourAt)
        #expect(first.day == 1 && first.hour == 7 && first.minute == 40)
        #expect(last.day == 1 && last.hour == 21 && last.minute == 10)
        #expect(busiest.day == 1 && busiest.hour == 7 && busiest.minute == 0)
    }
}
