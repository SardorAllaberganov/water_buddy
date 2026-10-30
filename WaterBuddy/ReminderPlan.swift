//
//  ReminderPlan.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import Foundation

/// When the app should nudge the user, as a **pure value**.
///
/// Deliberately free of `UserNotifications`, of `Date()`, and of any actor isolation. Everything
/// that decides *whether* and *when* to remind lives here, so it can be reasoned about and tested
/// without a notification centre, an authorization prompt, or a device — and
/// ``NotificationManager`` is left with nothing to decide, only something to apply.
///
/// ## Why a plan computed in advance, rather than a decision at delivery
///
/// **There is no fire-time hook for a local notification.** `UNNotificationServiceExtension` exists
/// only for *push*; nothing in the system asks the app "should this one fire?" as the moment
/// arrives. So "don't nag me, I've already hit my goal" cannot be a filter — it can only be an
/// absence. Everything smart about these reminders is therefore decided here, ahead of time, and
/// re-decided on every change to today's logs.
///
/// ## Why a fixed grid rather than a rolling timer
///
/// "Remind me two hours after my last serving" is the obvious reading of the feature and it is
/// wrong: a serving logged at 20:50 fires at 22:50, outside the window the user asked for. On a
/// fixed grid that is not a bug to guard against, it is arithmetically unreachable —
/// `noSlotEverFallsOutsideTheWindow` is the test that keeps it that way.
///
/// ## Why a drink drops a slot rather than moving it
///
/// "Don't remind me right after I drank" is the same reading coming back in a second form, and
/// moving the next reminder to an hour after the drink would be the rolling timer again, with the
/// same 22:50 failure. So a drink less than ``quietAfterDrink`` before a slot answers that slot in
/// advance — it is dropped, and the one after it fires on the grid as planned. A plan with a drink
/// is always the plan without one, minus at most one slot; `oneDrinkSilencesAtMostOneSlot` sweeps
/// a whole day to keep it that way.
enum ReminderPlan {

    /// Every two hours from 09:00 to 21:00, inclusive at both ends — seven a day. The standard schedule's
    /// hours, spelled here too because the welcome's bells and their test read this name.
    nonisolated static let hours = Schedule.standard.hours

    /// How long a drink keeps the next slot quiet: a slot due less than this after the latest
    /// serving is dropped from the plan.
    ///
    /// An hour, and it is half the grid's interval that makes an hour safe. Long enough that no
    /// reminder lands moments after a drink — the complaint this exists for. Short enough that one
    /// drink can drop at most one slot, so a single serving quietens the day for under three hours:
    /// one missed interval, never two. `theQuietHourEndsExactlyAnHourAfterTheDrink` pins the hour;
    /// `oneDrinkSilencesAtMostOneSlot` pins the one-slot bound, which holds only while this stays
    /// within the grid's interval.
    nonisolated static let quietAfterDrink: TimeInterval = 60 * 60

    /// Namespaced like every other identifier this product owns, and for the same reason: the
    /// notification centre an extension resolves is the **containing app's**, so these ids share a
    /// space with anything the app ever schedules.
    nonisolated static let identifierPrefix = "sardor.WaterBuddy.reminder."

    /// How many whole days beyond today are planted.
    ///
    /// Not zero, because the product's whole arc is *log again without opening the app*: a user who
    /// only ever taps the widget would otherwise get one day of reminders and then silence. Three
    /// is a compromise with the cap below — see ``maximumPendingRequests``.
    nonisolated static let horizonDays = 3

    /// iOS keeps at most this many pending requests per app and **drops the excess silently**.
    ///
    /// `7 × (3 + 1) = 28`, comfortably inside it. The number is written down because a silent
    /// truncation is indistinguishable from a scheduling bug, and because raising ``horizonDays``
    /// is exactly the edit that would walk into it.
    nonisolated static let maximumPendingRequests = 64

    /// One reminder: a day, an hour, and the instant they resolve to.
    struct Slot: Equatable, Hashable, Sendable, Identifiable {

        /// A `yyyyMMdd` ordinal, the same shape the rollover uses (rule `30-rollover`).
        let dayOrdinal: Int
        let hour: Int
        let fireDate: Date

        /// Stable for a given day and hour, which is what makes rescheduling safe: adding a request
        /// under an existing identifier **replaces** it, so an unchanged slot is re-planted rather
        /// than duplicated, and a slot that has dropped out can be removed *by name*.
        ///
        /// Removing by name is not a stylistic choice. `removeAllPendingNotificationRequests()`
        /// called from the widget process would clear the **app's** entire set, because the
        /// extension has no notification identity of its own.
        var identifier: String { "\(ReminderPlan.identifierPrefix)\(dayOrdinal).\(String(format: "%02d", hour))" }

        var id: String { identifier }
    }

    /// The hours a day's reminders fall on: the standard grid, or one the user set — set B (spec
    /// `2026-10-30-coaching-design.md` §3.4, D5).
    ///
    /// **Whole hours, on a grid**: a first and a last reminder, `every` hours apart. The slot's identifier
    /// keeps its `dayOrdinal.HH` shape, and the plan stays a grid a drink only ever drops from. No interval
    /// is shorter than ``quietAfterDrink``, so one drink still drops at most one slot.
    ///
    /// **Validated whole, never repaired** — `DataManager.resolveServings(in:)`'s reason: a schedule nobody
    /// chose is worse than the standard one. Every move the sheet makes (`with(first:)`, `with(last:)`,
    /// `with(every:)`, `toggling(weekday:)`) returns one this accepts.
    nonisolated struct Schedule: Equatable, Hashable, Sendable, Identifiable {

        let first: Int
        let last: Int
        let every: Int
        /// Gregorian weekdays, 1 = Sunday, on which nothing is planted. Never all seven.
        let quietWeekdays: Set<Int>

        /// Every two hours from 09:00 to 21:00, every day — what reminders followed before set B, and what
        /// they follow while nothing else is stored.
        static let standard = Schedule(checkedFirst: 9, last: 21, every: 2, quietWeekdays: [])

        /// No reminder before 05:00 or after 23:00 (D5); no schedule crosses midnight.
        static let earliest = 5
        static let latest = 23

        /// The intervals the sheet offers, in hours. None shorter than ``ReminderPlan/quietAfterDrink``.
        static let intervals = [1, 2, 3]

        init?(first: Int, last: Int, every: Int, quietWeekdays: Set<Int> = []) {
            guard Self.intervals.contains(every),
                  first >= Self.earliest, last <= Self.latest, last > first,
                  (last - first).isMultiple(of: every),
                  quietWeekdays.allSatisfy({ (1...7).contains($0) }), quietWeekdays.count < 7
            else { return nil }
            self.init(checkedFirst: first, last: last, every: every, quietWeekdays: quietWeekdays)
        }

        /// `Key.reminderSchedule`'s form: `[first, last, every, quietMask]`, the mask's bit `n − 1` for weekday
        /// `n`. `nil` for any other shape — the wrong count, a mask with all seven days or more, or a schedule
        /// `init?(first:last:every:quietWeekdays:)` refuses.
        init?(stored: [Int]) {
            guard stored.count == 4, (0..<127).contains(stored[3]) else { return nil }
            let quiet = Set((1...7).filter { stored[3] & (1 << ($0 - 1)) != 0 })
            self.init(first: stored[0], last: stored[1], every: stored[2], quietWeekdays: quiet)
        }

        private init(checkedFirst first: Int, last: Int, every: Int, quietWeekdays: Set<Int>) {
            self.first = first
            self.last = last
            self.every = every
            self.quietWeekdays = quietWeekdays
        }

        var stored: [Int] {
            [first, last, every, quietWeekdays.reduce(0) { $0 | 1 << ($1 - 1) }]
        }

        /// What `.sheet(item:)` tells one opening from another (rule `50-views`).
        var id: [Int] { stored }

        var hours: [Int] {
            Array(stride(from: first, through: last, by: every))
        }

        /// How many reminder days beyond today are planted: ``ReminderPlan/horizonDays``, shortened so the plan
        /// stays inside iOS's 64 pending requests (D6). A quiet day plants nothing and counts for none of them,
        /// so the bound holds for the fullest week. `everyScheduleKeepsThePlanInsideTheCap` sweeps every schedule this type accepts.
        var horizonDays: Int {
            min(ReminderPlan.horizonDays, ReminderPlan.maximumPendingRequests / hours.count - 1)
        }

        func with(first: Int) -> Schedule {
            .snapped(first: first, last: last, every: every, quietWeekdays: quietWeekdays)
        }

        func with(last: Int) -> Schedule {
            .snapped(first: first, last: last, every: every, quietWeekdays: quietWeekdays)
        }

        func with(every: Int) -> Schedule {
            .snapped(first: first, last: last, every: every, quietWeekdays: quietWeekdays)
        }

        /// The day turned quiet, or back. The last day keeping reminders stays: a week with none is the
        /// reminders switch's job, not the schedule's.
        func toggling(weekday: Int) -> Schedule {
            var quiet = quietWeekdays
            if quiet.contains(weekday) {
                quiet.remove(weekday)
            } else if (1...7).contains(weekday), quiet.count < 6 {
                quiet.insert(weekday)
            }
            return Schedule(checkedFirst: first, last: last, every: every, quietWeekdays: quiet)
        }

        /// The nearest valid schedule: the interval one the menu offers, the first early enough to leave one
        /// interval before 23:00, and the last snapped **down** to the grid — never past what was chosen — and
        /// never fewer than two reminders.
        private static func snapped(first: Int, last: Int, every: Int, quietWeekdays: Set<Int>) -> Schedule {
            let every = intervals.contains(every) ? every : standard.every
            let first = min(max(first, earliest), latest - every)
            let steps = max(1, (last - first) / every)
            let last = min(first + steps * every, first + (latest - first) / every * every)
            return Schedule(checkedFirst: first, last: last, every: every, quietWeekdays: quietWeekdays)
        }
    }

    /// The reminders that should be pending, given the state of the day.
    ///
    /// - Parameters:
    ///   - enabled: The user's toggle. `false` yields an empty plan rather than skipping the call,
    ///     so switching reminders off *clears* the schedule instead of stranding it.
    ///   - currentWater: Today's total. Reaching ``dailyGoal`` silences the rest of today.
    ///   - dailyGoal: Today's target.
    ///   - lastDrink: The latest serving's instant, or `nil` before the first. A slot due less than
    ///     ``quietAfterDrink`` after it is dropped. Clamped to `now`: a watch pour carries the
    ///     watch's own clock, and one stamped ahead of this one would otherwise silence every slot
    ///     up to an hour past it.
    ///   - now: Injected, like every clock in this product.
    ///   - calendar: ``Calendar/waterBuddyDay``. The same calendar the rollover uses, so the log and
    ///     the reminders can never disagree about where a day ends (rule `30-rollover`).
    ///   - schedule: The hours and the quiet weekdays — ``Schedule/standard`` unless the user set their own.
    ///   - onlyWhenBehind: Set B's switch. Today, a slot whose share (``due(goal:schedule:at:calendar:)``) is
    ///     already drunk is dropped — a third reason beside the goal and a drink, and still never a move.
    ///   - horizonDays: How many reminder days beyond today — a quiet day counts for none; the schedule's
    ///     own (``Schedule/horizonDays``) unless given. `DataManager.nextReminder` passes 0.
    nonisolated static func slots(
        enabled: Bool,
        currentWater: Int,
        dailyGoal: Int,
        lastDrink: Date?,
        now: Date,
        calendar: Calendar,
        schedule: Schedule = .standard,
        onlyWhenBehind: Bool = false,
        horizonDays: Int? = nil
    ) -> [Slot] {
        guard enabled else { return [] }

        let startOfToday = calendar.startOfDay(for: now)
        let goalReached = currentWater >= dailyGoal
        let horizon = max(0, horizonDays ?? schedule.horizonDays)
        var planned: [Slot] = []
        var daysAhead = 0

        // The horizon counts **reminder days** beyond today: a quiet day uses none of it, so a user who chose
        // quiet days to need the app less still has the days after them filed (the final review's Important 1).
        // A week holds at least one day that is not quiet, so `7 × horizon` days ahead always find them; and
        // since a quiet day plants nothing, the cap holds as it does for the fullest week.
        for offset in 0...(7 * horizon) {
            if offset > 0, daysAhead == horizon { break }

            // Today falls silent once the goal is met — and only today. Tomorrow starts at zero,
            // so it is planned regardless.
            if offset == 0, goalReached { continue }

            guard let day = calendar.date(byAdding: .day, value: offset, to: startOfToday) else { continue }

            // A quiet weekday plants nothing — read on the plan's own calendar, so the day it silences is
            // the day the rollover calls it (rule `30-rollover`).
            if schedule.quietWeekdays.contains(calendar.component(.weekday, from: day)) { continue }
            if offset > 0 { daysAhead += 1 }

            let ordinal = DataManager.dayOrdinal(for: day, in: calendar)

            for hour in schedule.hours {
                // `date(bySettingHour:…)` resolves through the calendar, so a DST day still puts
                // 09:00 at 09:00 local. Adding 86,400 seconds would drift it by an hour.
                guard let fire = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day) else { continue }

                // Strictly ahead: a slot at exactly `now` has already had its moment.
                if offset == 0, fire <= now { continue }

                // A drink in the hour before a slot answers it in advance — dropped, never moved.
                if let lastDrink, fire.timeIntervalSince(min(lastDrink, now)) < quietAfterDrink { continue }

                // *Only when behind*: a slot whose share is already drunk has nothing to ask. Today only —
                // tomorrow starts at zero — and since `due` never falls through a day, what this drops is
                // always a run at the front of today's slots.
                if offset == 0, onlyWhenBehind,
                   currentWater >= due(goal: dailyGoal, schedule: schedule, at: fire, calendar: calendar) { continue }

                planned.append(Slot(dayOrdinal: ordinal, hour: hour, fireDate: fire))
            }
        }

        return planned
    }

    /// How much should be drunk by `instant` — set B's pace (spec `2026-10-30-coaching-design.md` D3).
    ///
    /// **A share per reminder**: each of the schedule's `n` hours asks for `goal ÷ n`, and by an instant the
    /// shares of every hour already reached are due — rounded to the nearest millilitre, in `Int`, and exactly
    /// the goal at the last hour. *Only when behind* asks this at each slot's fire and Home asks it now, so
    /// the two can never disagree. Quiet weekdays are not consulted: they silence reminders, not the goal.
    nonisolated static func due(goal: Int, schedule: Schedule, at instant: Date, calendar: Calendar) -> Int {
        let hours = schedule.hours
        let day = calendar.startOfDay(for: instant)
        let reached = hours.filter { hour in
            guard let fire = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day) else { return false }
            return fire <= instant
        }.count
        guard reached > 0, goal > 0 else { return 0 }
        return (goal * reached + hours.count / 2) / hours.count
    }

    /// Where today's water stands against ``due(goal:schedule:at:calendar:)``.
    nonisolated enum Pace: Equatable, Sendable {
        case onTrack
        /// Millilitres short of what is due.
        case behind(Int)
    }

    /// Home's pace line: `nil` while nothing is due yet, once the goal is met, and once every share is due —
    /// from the last reminder hour on, *behind* is exactly the *to go* Home's status already says (the walk,
    /// W1) — otherwise on track, or how far behind.
    nonisolated static func pace(water: Int, goal: Int, schedule: Schedule, now: Date, calendar: Calendar) -> Pace? {
        guard water < goal else { return nil }
        let due = due(goal: goal, schedule: schedule, at: now, calendar: calendar)
        guard due > 0, due < goal else { return nil }
        return water >= due ? .onTrack : .behind(due - water)
    }
}
