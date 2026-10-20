//
//  WristPlan.swift
//  WaterBuddy
//
//  `ReminderPlan`'s twin (rule `80-notifications`'s "the plan decides, the applier only files and
//  unfiles" idiom, one layer over): this decides nothing about *whether* to sync, only *which*
//  water the watch counts as today's — its own outbox pours by the watch's day, and the phone's
//  mirrored total until the phone's own day ends (spec §17). Pure — `import Foundation` alone, no
//  `Date()` inside, the clock and calendar injected — so it is testable from the existing iOS gate
//  with no watch target and no `WatchConnectivity` import at all
//  (`docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md` §5, §11 step 4, §17).
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

    /// What the watch draws as today's water: the phone's mirrored total while the phone's own day is
    /// still running, plus the watch's own outbox pours for the watch's day.
    ///
    /// **The phone's total stops where the phone's day ends, not at the watch's midnight**
    /// (spec §17). `currentWater` is the phone's figure for `[phoneDayStart, phoneDayEnd)`, and a
    /// phone that slept through midnight sends nothing to say its day has turned — counting the
    /// figure regardless drew yesterday's water on the wrist every morning. Comparing *instants* is
    /// what keeps §5's guarantee under time-zone skew: compared on the watch's own calendar, a mirror
    /// composed a minute ago can look like yesterday's, and zeroing it would show nothing on the
    /// wrist while the phone reads its real total. Nothing is rolled over or stored — the same
    /// filter, applied on every read.
    ///
    /// Both watch surfaces read this — `WristModel.todaysTotal` and the complication — so the screen
    /// and the face cannot disagree.
    nonisolated static func todaysTotal(mirror: WristMirror?, outbox: [WristPour], now: Date, calendar: Calendar) -> Int {
        let phoneTotal = mirror.map { now < dayEnd(of: $0, calendar: calendar) ? $0.currentWater : 0 } ?? 0
        return phoneTotal + todaysTotal(from: outbox, now: now, calendar: calendar)
    }

    /// The instants after `now` at which ``todaysTotal(mirror:outbox:now:calendar:)`` changes with
    /// nothing new arriving: the phone's day end while it is still ahead, and the watch's own next
    /// midnight, where its outbox pours re-bucket. Ascending, and one instant where the two coincide —
    /// which they do whenever both devices share a time zone.
    ///
    /// The complication schedules a timeline entry at each: the watch's twin of the phone widget's
    /// midnight entry (rule `40-widget`), so the face turns over even if nothing wakes it.
    nonisolated static func dayBoundaries(after now: Date, mirror: WristMirror?, calendar: Calendar) -> [Date] {
        var boundaries: Set<Date> = [DataManager.nextDayBoundary(after: now, calendar: calendar)]
        if let mirror {
            let end = dayEnd(of: mirror, calendar: calendar)
            if end > now { boundaries.insert(end) }
        }
        return boundaries.sorted()
    }

    /// Where the phone's day ends: the mirror's own `phoneDayEnd`, or — for a mirror from a phone
    /// build that predates the field — the watch's first midnight after `phoneDayStart`, which is
    /// exact whenever the two devices share a time zone.
    private nonisolated static func dayEnd(of mirror: WristMirror, calendar: Calendar) -> Date {
        mirror.phoneDayEnd ?? DataManager.nextDayBoundary(after: mirror.phoneDayStart, calendar: calendar)
    }
}

// MARK: - The face

extension WristPlan {

    /// Today's figures as both watch surfaces draw them — the screen through `WristModel.face`, the
    /// complication through its entry — so the two cannot disagree (spec 2026-10-20 §3.5).
    ///
    /// **Nested here, not a file of its own:** a new file would grow two exception sets
    /// (rule `15-project`); `ReminderPlan.Slot` is the precedent. `nonisolated`, because this file
    /// compiles into the phone app, whose default isolation is the main actor, and the complication's
    /// provider reads it off the main actor.
    nonisolated struct Face: Equatable, Sendable {

        let total: Int
        let goal: Int

        /// How full the vessel is: the share of the goal, held to `0...1` — the water stops at the
        /// rim — and 0 for a goal of 0, which a corrupt mirror is the only way to carry.
        var progress: Double {
            guard goal > 0 else { return 0 }
            return min(1, max(0, Double(total) / Double(goal)))
        }

        /// The readout: the share in whole percent, rounded as the complication always rounded it,
        /// held to `0...999` so it fits a face in three digits. 0 for a goal of 0.
        var percentage: Int {
            guard goal > 0 else { return 0 }
            return min(999, max(0, Int((Double(total) / Double(goal) * 100).rounded())))
        }

        /// The vessel's own sentence — `WaterSnapshot.spokenFigures(in:locale:)`'s twin, the same key —
        /// so the screen and every face speak today alike.
        func spokenFigures(in strings: Bundle, locale: Locale) -> String {
            strings.localized("%1$d percent. %2$d of %3$d millilitres.", percentage, total, goal, locale: locale)
        }

        /// *1,240 of 2,000 ml* — the line under the vessel and the rectangle's middle line, the phone's
        /// own key, both figures grouped as `locale` groups them.
        func millilitreLine(in strings: Bundle, locale: Locale) -> String {
            strings.figure("%1$@ of %2$@ ml", total, goal, locale: locale)
        }

        /// What a face draws in the gallery and as its placeholder: 62%, the figure the circular face
        /// has always shown there.
        static let sample = Face(total: 1_240, goal: 2_000)
    }

    /// Today's face from the watch's store: ``todaysTotal(mirror:outbox:now:calendar:)`` against the
    /// phone's goal, or ``DataManager/defaultDailyGoal`` before the first sync — the fallback
    /// `WristModel.displayGoal` has always used.
    nonisolated static func face(mirror: WristMirror?, outbox: [WristPour], now: Date, calendar: Calendar) -> Face {
        Face(
            total: todaysTotal(mirror: mirror, outbox: outbox, now: now, calendar: calendar),
            goal: mirror?.dailyGoal ?? DataManager.defaultDailyGoal
        )
    }
}
