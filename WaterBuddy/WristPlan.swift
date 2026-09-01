//
//  WristPlan.swift
//  WaterBuddy
//
//  `ReminderPlan`'s twin (rule `80-notifications`'s "the plan decides, the applier only files and
//  unfiles" idiom, one layer over): this decides nothing about *whether* to sync, only *which* of
//  the watch's own outbox pours belong to today. Pure — `import Foundation` alone, no `Date()`
//  inside, the clock and calendar injected — so it is testable from the existing iOS gate with no
//  watch target and no `WatchConnectivity` import at all
//  (`docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md` §5, §11 step 4).
//
//  Physically lives in `WaterBuddy/` rather than `WaterBuddyWatch/`, alongside the other files a
//  second target reaches through an exception set — not because the phone calls it (it doesn't),
//  but because this is where the existing test gate can prove it correct before any watch target
//  exists to run it on. It reaches the watch target through the exception set Task 9 adds.
//

import Foundation

enum WristPlan {

    /// The sum of `pours` whose `at` falls within `now`'s day, in `calendar`.
    ///
    /// **Never rolls anything over** — there is no marker to stamp, and no cache to reset. This
    /// simply filters, on every call, from each pour's own instant. A pour carries no stored day of
    /// its own (`WristPour` has none, deliberately): a stamp made in one time zone and re-read in
    /// another would name a day the watch may no longer be in.
    nonisolated static func todaysTotal(from pours: [WristPour], now: Date, calendar: Calendar) -> Int {
        let startOfToday = calendar.startOfDay(for: now)
        guard let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday) else {
            return 0
        }
        return pours
            .filter { $0.at >= startOfToday && $0.at < startOfTomorrow }
            .reduce(0) { $0 + $1.amount }
    }
}
