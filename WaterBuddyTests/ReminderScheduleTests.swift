//
//  ReminderScheduleTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 30/10/26.
//

import Foundation
import Testing
@testable import WaterBuddy

/// Set B's schedule as a pure value (spec `2026-10-30-coaching-design.md` §3.4, D5, D6). Deliberately
/// **not** `@MainActor`: the widget extension plans from it, so it must be readable from off the main actor —
/// this suite stops compiling if it ever is not (rule `43-concurrency`).
struct ReminderScheduleTests {

    private typealias Schedule = ReminderPlan.Schedule

    @Test func theStandardScheduleIsTheGridRemindersAlwaysFollowed() {
        #expect(Schedule.standard.hours == [9, 11, 13, 15, 17, 19, 21])
        #expect(Schedule.standard.quietWeekdays.isEmpty)
        #expect(ReminderPlan.hours == Schedule.standard.hours, "the welcome's bells read the standard grid")
    }

    @Test func aScheduleIsAcceptedAtEachEdgeOfTheDay() {
        #expect(Schedule(first: 5, last: 23, every: 1) != nil)
        #expect(Schedule(first: 5, last: 23, every: 2) != nil)
        #expect(Schedule(first: 5, last: 23, every: 3) != nil)
        #expect(Schedule(first: 22, last: 23, every: 1) != nil)
        #expect(Schedule(first: 9, last: 21, every: 2, quietWeekdays: [1, 2, 3, 4, 5, 6]) != nil, "six quiet days leave one")
    }

    @Test func aScheduleOutsideTheDayOrOffItsGridIsRefused() {
        #expect(Schedule(first: 4, last: 22, every: 2) == nil, "before 05:00")
        #expect(Schedule(first: 9, last: 24, every: 1) == nil, "after 23:00")
        #expect(Schedule(first: 9, last: 9, every: 1) == nil, "one reminder is no schedule")
        #expect(Schedule(first: 21, last: 9, every: 2) == nil, "backwards")
        #expect(Schedule(first: 9, last: 20, every: 2) == nil, "the last off the grid")
        #expect(Schedule(first: 9, last: 21, every: 4) == nil, "an interval the menu never offers")
        #expect(Schedule(first: 9, last: 21, every: 0) == nil)
        #expect(Schedule(first: 9, last: 21, every: 2, quietWeekdays: Set(1...7)) == nil, "every day quiet")
        #expect(Schedule(first: 9, last: 21, every: 2, quietWeekdays: [0]) == nil)
        #expect(Schedule(first: 9, last: 21, every: 2, quietWeekdays: [8]) == nil)
    }

    @Test func aScheduleIsTheHoursOnItsGrid() throws {
        #expect(try #require(Schedule(first: 7, last: 22, every: 3)).hours == [7, 10, 13, 16, 19, 22])
        #expect(try #require(Schedule(first: 5, last: 23, every: 1)).hours.count == 19)
    }

    @Test func aStoredScheduleRoundTrips() throws {
        #expect(Schedule.standard.stored == [9, 21, 2, 0])
        let weekend = try #require(Schedule(first: 8, last: 20, every: 3, quietWeekdays: [7, 1]))
        #expect(weekend.stored == [8, 20, 3, 65], "Sunday is bit 0, Saturday bit 6")
        for schedule in [Schedule.standard, weekend] {
            #expect(Schedule(stored: schedule.stored) == schedule)
        }
    }

    @Test func anyStoredAnomalyIsNoScheduleAtAll() {
        for stored in [[], [9, 21, 2], [9, 21, 2, 0, 0], [9, 21, 2, 127], [9, 21, 2, -1], [9, 21, 2, 128],
                       [9, 20, 2, 0], [21, 9, 2, 0], [4, 22, 2, 0], [9, 21, 5, 0]] {
            #expect(Schedule(stored: stored) == nil, "\(stored) read as a schedule")
        }
    }

    /// Every move the sheet makes returns a schedule the plan accepts — the last snapped **down** to the new
    /// grid, never past what the user chose.
    @Test func changingTheIntervalSnapsTheLastReminderDownToTheGrid() throws {
        #expect(Schedule.standard.with(every: 3).hours == [9, 12, 15, 18, 21])
        #expect(Schedule.standard.with(every: 1).last == 21)
        let early = try #require(Schedule(first: 6, last: 22, every: 2))
        #expect(early.with(every: 3).last == 21, "22 is off a 6-o'clock, three-hour grid")
    }

    @Test func movingTheFirstReminderKeepsOneIntervalBeforeTheLast() throws {
        #expect(Schedule.standard.with(first: 10).last == 20)
        let late = Schedule.standard.with(first: 22)
        #expect(late.first == 21 && late.last == 23, "a two-hour interval cannot start after 21:00")
        let hourly = try #require(Schedule(first: 9, last: 21, every: 1))
        #expect(hourly.with(first: 22).hours == [22, 23])
    }

    @Test func movingTheLastReminderStaysOnTheGrid() {
        #expect(Schedule.standard.with(last: 18).last == 17)
        #expect(Schedule.standard.with(last: 9).last == 11, "never fewer than two reminders")
        #expect(Schedule.standard.with(last: 30).last == 23)
    }

    @Test func theLastDayKeepingRemindersCannotBeTurnedQuiet() throws {
        let sixQuiet = try #require(Schedule(first: 9, last: 21, every: 2, quietWeekdays: [1, 2, 3, 4, 5, 6]))
        #expect(sixQuiet.toggling(weekday: 7) == sixQuiet)
        #expect(sixQuiet.toggling(weekday: 1).quietWeekdays == [2, 3, 4, 5, 6])
        #expect(Schedule.standard.toggling(weekday: 7).quietWeekdays == [7])
        #expect(Schedule.standard.toggling(weekday: 9) == .standard, "not a weekday")
    }

    /// D6: iOS keeps 64 pending requests and drops the rest silently. Every schedule `Schedule` accepts — not
    /// a sample — keeps today and at least two more days inside it.
    @Test func everyScheduleKeepsThePlanInsideTheCap() {
        var checked = 0
        for every in Schedule.intervals {
            for first in Schedule.earliest...Schedule.latest {
                for last in stride(from: first + every, through: Schedule.latest, by: every) {
                    guard let schedule = Schedule(first: first, last: last, every: every) else {
                        Issue.record("\(first)–\(last) every \(every) refused")
                        continue
                    }
                    #expect(schedule.hours.count * (schedule.horizonDays + 1) <= ReminderPlan.maximumPendingRequests)
                    #expect(schedule.horizonDays >= 2, "\(schedule.stored) plans under three days")
                    #expect(schedule.horizonDays <= ReminderPlan.horizonDays)
                    checked += 1
                }
            }
        }
        #expect(checked > 100, "a sweep that checks nothing proves nothing")
        #expect(Schedule.standard.horizonDays == ReminderPlan.horizonDays)
    }
}
