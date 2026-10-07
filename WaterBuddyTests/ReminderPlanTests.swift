//
//  ReminderPlanTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 28/08/26.
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

private let utcDay = gregorian(in: "UTC")

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

private func slots(
    enabled: Bool = true,
    water: Int = 0,
    goal: Int = 2_000,
    lastDrink: Date? = nil,
    now: Date = utc(2026, 8, 28, 12),
    calendar: Calendar = utcDay,
    horizonDays: Int = ReminderPlan.horizonDays
) -> [ReminderPlan.Slot] {
    ReminderPlan.slots(
        enabled: enabled,
        currentWater: water,
        dailyGoal: goal,
        lastDrink: lastDrink,
        now: now,
        calendar: calendar,
        horizonDays: horizonDays
    )
}

// MARK: - Tests

/// The reminder schedule as a **pure value** — no `UserNotifications`, no clock, no actor.
///
/// This suite is deliberately **not** `@MainActor`, and it deliberately does not import
/// `UserNotifications`. That is the same load-bearing canary `WaterSnapshotTests` carries: if
/// ``ReminderPlan`` ever needs the main actor or the notification framework to decide *when* to
/// remind, this file stops compiling — and it should, because a plan that cannot be computed
/// without the system is a plan that cannot be tested without the system.
struct ReminderPlanTests {

    // MARK: The shape of a day

    @Test func aFullDayIsSevenSlotsTwoHoursApartFromNineToNine() {
        #expect(ReminderPlan.hours == [9, 11, 13, 15, 17, 19, 21])

        // 21:00 is inclusive — the literal reading of "every 2 hours between 9 AM and 9 PM".
        #expect(ReminderPlan.hours.first == 9)
        #expect(ReminderPlan.hours.last == 21)
        #expect(zip(ReminderPlan.hours, ReminderPlan.hours.dropFirst()).allSatisfy { $1 - $0 == 2 })
    }

    /// The property a rolling "two hours after your last log" timer cannot hold: a log at 20:50
    /// would fire at 22:50, outside the window the user asked for. A fixed grid makes that
    /// arithmetically impossible, and this is the test that says so.
    @Test func noSlotEverFallsOutsideTheWindow() {
        for slot in slots(now: utc(2026, 8, 28, 20, 50), horizonDays: 3) {
            #expect(ReminderPlan.hours.contains(slot.hour), "a slot at \(slot.hour):00 is outside 09–21")
        }
    }

    // MARK: Today

    @Test func todayKeepsOnlyTheSlotsStillAhead() {
        let today = slots(now: utc(2026, 8, 28, 12)).filter { $0.dayOrdinal == 20_260_828 }
        #expect(today.map(\.hour) == [13, 15, 17, 19, 21])
    }

    /// Strictly ahead: a slot at exactly `now` has already had its moment.
    @Test func aSlotExactlyAtNowIsNotScheduled() {
        let today = slots(now: utc(2026, 8, 28, 13)).filter { $0.dayOrdinal == 20_260_828 }
        #expect(today.map(\.hour) == [15, 17, 19, 21])
    }

    @Test func afterTheLastSlotTodayContributesNothing() {
        let today = slots(now: utc(2026, 8, 28, 22)).filter { $0.dayOrdinal == 20_260_828 }
        #expect(today.isEmpty)
    }

    // MARK: The "smart" half

    /// Reaching the goal silences the rest of today — and *only* today. There is no fire-time hook
    /// for a local notification, so this can only be done by not scheduling in the first place.
    @Test func reachingTheGoalSilencesTheRestOfTodayButNotTomorrow() {
        let planned = slots(water: 2_000, goal: 2_000, now: utc(2026, 8, 28, 12))

        #expect(planned.allSatisfy { $0.dayOrdinal != 20_260_828 }, "today must be silent")
        #expect(planned.contains { $0.dayOrdinal == 20_260_829 }, "tomorrow starts empty and must still remind")
    }

    @Test func overshootingTheGoalAlsoSilencesToday() {
        let planned = slots(water: 3_000, goal: 2_000, now: utc(2026, 8, 28, 12))
        #expect(planned.allSatisfy { $0.dayOrdinal != 20_260_828 })
    }

    @Test func fallingShortOfTheGoalKeepsTodaysRemainingSlots() {
        let planned = slots(water: 1_999, goal: 2_000, now: utc(2026, 8, 28, 12))
        #expect(planned.contains { $0.dayOrdinal == 20_260_828 })
    }

    @Test func disabledPlansNothingAtAll() {
        #expect(slots(enabled: false).isEmpty)
    }

    // MARK: A drink in the hour before a slot

    /// The complaint this answers, from a review of a competing app: "not prompt me to drink more
    /// when you know that I had a drink moments ago". 11:00 is 45 minutes after a 10:15 drink.
    @Test func aDrinkSilencesASlotDueWithinTheHour() {
        let today = slots(lastDrink: utc(2026, 8, 28, 10, 15), now: utc(2026, 8, 28, 10, 15))
            .filter { $0.dayOrdinal == 20_260_828 }
        #expect(today.map(\.hour) == [13, 15, 17, 19, 21])
    }

    /// Ninety minutes is not "moments ago" — the rhythm the user asked for still holds.
    @Test func aDrinkMoreThanAnHourBeforeASlotLeavesItPlanned() {
        let today = slots(lastDrink: utc(2026, 8, 28, 9, 30), now: utc(2026, 8, 28, 9, 30))
            .filter { $0.dayOrdinal == 20_260_828 }
        #expect(today.map(\.hour) == [11, 13, 15, 17, 19, 21])
    }

    /// Strictly under an hour: a drink at exactly 10:00 leaves 11:00 in place, and one a minute
    /// later does not. Any quiet longer than the hour fails the first half.
    @Test func theQuietHourEndsExactlyAnHourAfterTheDrink() {
        let atTen = slots(lastDrink: utc(2026, 8, 28, 10), now: utc(2026, 8, 28, 10))
        let aMinuteLater = slots(lastDrink: utc(2026, 8, 28, 10, 1), now: utc(2026, 8, 28, 10, 1))

        #expect(atTen.contains { $0.dayOrdinal == 20_260_828 && $0.hour == 11 })
        #expect(!aMinuteLater.contains { $0.dayOrdinal == 20_260_828 && $0.hour == 11 })
    }

    /// 09:00 has no slot before it, so only the drink's own distance from it can silence it.
    @Test func aDrinkBeforeNineSilencesTheFirstSlot() {
        let today = slots(lastDrink: utc(2026, 8, 28, 8, 30), now: utc(2026, 8, 28, 8, 30))
            .filter { $0.dayOrdinal == 20_260_828 }
        #expect(today.map(\.hour) == [11, 13, 15, 17, 19, 21])
    }

    /// A watch pour carries the watch's own clock, and `ingest(_:)` folds it in as stamped, so a
    /// drink can sit *ahead* of `now`. Unclamped, a pour stamped 20:00 and read at 10:15 would
    /// silence every slot until 21:00; clamped, it counts as a drink at 10:15.
    @Test func aDrinkStampedAheadOfTheClockSilencesOnlyTheNextHour() {
        let today = slots(lastDrink: utc(2026, 8, 28, 20), now: utc(2026, 8, 28, 10, 15))
            .filter { $0.dayOrdinal == 20_260_828 }
        #expect(today.map(\.hour) == [13, 15, 17, 19, 21])
    }

    /// The latest drink is one of today's rows, and tomorrow's first slot is hours past any of them.
    @Test func aLateDrinkLeavesTomorrowUntouched() {
        let planned = slots(lastDrink: utc(2026, 8, 28, 21, 30), now: utc(2026, 8, 28, 21, 30))
        #expect(planned.contains { $0.dayOrdinal == 20_260_829 && $0.hour == 9 })
    }

    /// The plan with a drink is the plan without one, minus at most one slot — dropped, never moved,
    /// so nothing can fire outside the window. Swept every five minutes across a day, with each drink
    /// logged at `now` and again stamped three hours ahead of it (a watch clock running fast).
    @Test func oneDrinkSilencesAtMostOneSlot() {
        var silencedAnything = false
        for step in 0..<(24 * 12) {
            let now = utc(2026, 8, 28, 0).addingTimeInterval(TimeInterval(step * 5 * 60))
            let unsilenced = Set(slots(now: now))
            for drink in [now, now.addingTimeInterval(3 * 60 * 60)] {
                let silenced = Set(slots(lastDrink: drink, now: now))
                let dropped = unsilenced.subtracting(silenced)

                #expect(silenced.isSubset(of: unsilenced), "a drink at \(drink) moved a slot")
                #expect(dropped.count <= 1, "a drink at \(drink) silenced \(dropped.count) slots")
                silencedAnything = silencedAnything || !dropped.isEmpty
            }
        }
        #expect(silencedAnything, "a sweep that never silences anything proves nothing")
    }

    // MARK: The horizon, and the cap that silently truncates

    /// A user who only ever taps the widget still gets reminded, so the plan runs ahead. The
    /// arithmetic is asserted rather than assumed because iOS caps an app at 64 pending requests
    /// and drops the excess **silently**.
    @Test func theHorizonStaysWellInsideTheSixtyFourRequestCap() {
        let planned = slots(now: utc(2026, 8, 28, 0, 1))

        #expect(planned.count == ReminderPlan.hours.count * (ReminderPlan.horizonDays + 1))
        #expect(planned.count <= ReminderPlan.maximumPendingRequests)
    }

    @Test func theHorizonCoversTheNextWholeDays() {
        let days = Set(slots(now: utc(2026, 8, 28, 12), horizonDays: 3).map(\.dayOrdinal))
        #expect(days == [20_260_828, 20_260_829, 20_260_830, 20_260_831])
    }

    // MARK: Identifiers

    /// Stability is what makes rescheduling safe: `add` **replaces** a request with the same
    /// identifier, so an unchanged slot is re-planted rather than duplicated — and a stale slot can
    /// be removed by name instead of by `removeAllPendingNotificationRequests()`, which from the
    /// widget process would clear the app's entire set.
    @Test func identifiersAreStableAcrossAReplan() {
        let first = slots(now: utc(2026, 8, 28, 12)).map(\.identifier)
        let second = slots(now: utc(2026, 8, 28, 12)).map(\.identifier)
        #expect(first == second)
        #expect(Set(first).count == first.count, "duplicate identifiers would collapse two slots into one")
    }

    @Test func identifiersAreNamespacedAndCarryTheDayAndHour() {
        let slot = try! #require(slots(now: utc(2026, 8, 28, 12)).first { $0.dayOrdinal == 20_260_828 })

        #expect(slot.identifier.hasPrefix(ReminderPlan.identifierPrefix))
        #expect(slot.identifier == "\(ReminderPlan.identifierPrefix)20260828.13")
    }

    // MARK: Time

    @Test func aSlotFiresAtItsHourInTheGivenCalendar() {
        let slot = try! #require(slots(now: utc(2026, 8, 28, 12)).first)
        let parts = utcDay.dateComponents([.year, .month, .day, .hour, .minute], from: slot.fireDate)

        #expect(parts.hour == 13)
        #expect(parts.minute == 0)
        #expect(parts.day == 28)
    }

    /// The rollover's own calendar decides when a day ends, here as everywhere else
    /// (rule `30-rollover`). A DST day is the case where a naive "add 86,400 seconds" horizon
    /// drifts an hour and starts reminding at 08:00 or 10:00.
    @Test func everySlotKeepsItsLocalHourAcrossADstTransition() {
        // 2026-03-08 is the US spring-forward.
        let newYork = gregorian(in: "America/New_York")
        let start = newYork.date(from: DateComponents(year: 2026, month: 3, day: 7, hour: 8))!

        for slot in slots(now: start, calendar: newYork, horizonDays: 3) {
            let hour = newYork.component(.hour, from: slot.fireDate)
            #expect(hour == slot.hour, "slot \(slot.identifier) drifted to \(hour):00 local")
        }
    }
}
