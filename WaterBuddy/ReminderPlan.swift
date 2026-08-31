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
/// re-decided on every change to today's total.
///
/// ## Why a fixed grid rather than a rolling timer
///
/// "Remind me two hours after my last serving" is the obvious reading of the feature and it is
/// wrong: a serving logged at 20:50 fires at 22:50, outside the window the user asked for. On a
/// fixed grid that is not a bug to guard against, it is arithmetically unreachable —
/// `noSlotEverFallsOutsideTheWindow` is the test that keeps it that way.
enum ReminderPlan {

    /// Every two hours from 09:00 to 21:00, inclusive at both ends — seven a day.
    nonisolated static let hours = [9, 11, 13, 15, 17, 19, 21]

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

    /// The reminders that should be pending, given the state of the day.
    ///
    /// - Parameters:
    ///   - enabled: The user's toggle. `false` yields an empty plan rather than skipping the call,
    ///     so switching reminders off *clears* the schedule instead of stranding it.
    ///   - currentWater: Today's total. Reaching ``dailyGoal`` silences the rest of today.
    ///   - dailyGoal: Today's target.
    ///   - now: Injected, like every clock in this product.
    ///   - calendar: ``Calendar/waterBuddyDay``. The same calendar the rollover uses, so the log and
    ///     the reminders can never disagree about where a day ends (rule `30-rollover`).
    nonisolated static func slots(
        enabled: Bool,
        currentWater: Int,
        dailyGoal: Int,
        now: Date,
        calendar: Calendar,
        horizonDays: Int = ReminderPlan.horizonDays
    ) -> [Slot] {
        guard enabled else { return [] }

        let startOfToday = calendar.startOfDay(for: now)
        let goalReached = currentWater >= dailyGoal
        var planned: [Slot] = []

        for offset in 0...max(0, horizonDays) {
            // Today falls silent once the goal is met — and only today. Tomorrow starts at zero,
            // so it is planned regardless.
            if offset == 0, goalReached { continue }

            guard let day = calendar.date(byAdding: .day, value: offset, to: startOfToday) else { continue }
            let ordinal = DataManager.dayOrdinal(for: day, in: calendar)

            for hour in hours {
                // `date(bySettingHour:…)` resolves through the calendar, so a DST day still puts
                // 09:00 at 09:00 local. Adding 86,400 seconds would drift it by an hour.
                guard let fire = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day) else { continue }

                // Strictly ahead: a slot at exactly `now` has already had its moment.
                if offset == 0, fire <= now { continue }

                planned.append(Slot(dayOrdinal: ordinal, hour: hour, fireDate: fire))
            }
        }

        return planned
    }
}
