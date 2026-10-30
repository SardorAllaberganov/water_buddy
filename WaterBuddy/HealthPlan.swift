//
//  HealthPlan.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 29/10/26.
//

import Foundation

/// What Apple Health should be told, worked out from the log and from what WaterBuddy already wrote there —
/// ``ReminderPlan``'s position for Health (spec `2026-10-29-apple-health-design.md` §3.3).
///
/// **Pure.** Foundation alone, no HealthKit and no clock: ``HealthMirror`` reads the rows and the samples
/// and carries the answer out. App-only, in no exception set; its suite is not `@MainActor`.
///
/// **Health is a copy of the log** (the owner's D6): a serving with no sample is saved; a sample with no
/// serving is deleted when the log was seen to hold that serving, and kept when it never was — an earlier
/// install's, or another iPhone's; a sample that differs is saved again one version above itself, which HealthKit takes
/// as a replacement because the sync identifier — the serving's id — matches. A sample with no sync
/// identifier is not one WaterBuddy wrote, and is never WaterBuddy's to judge.
nonisolated enum HealthPlan {

    /// A serving as Health needs it.
    nonisolated struct Serving: Sendable, Equatable {
        let id: UUID
        let amount: Int
        let at: Date
    }

    /// A sample WaterBuddy wrote, read back.
    nonisolated struct Sample: Sendable, Equatable {
        /// Health's own id for the sample — what a deletion names.
        let object: UUID
        /// The sync identifier read back as a serving's id; `nil` when the sample carries none.
        let serving: UUID?
        /// Whole millilitres, rounded by the writer on the way in.
        let amount: Int
        let at: Date
        let version: Int
    }

    /// One serving to write, at the version that makes HealthKit keep it.
    nonisolated struct Save: Sendable, Equatable {
        let serving: Serving
        let version: Int
    }

    /// One pass's answer.
    nonisolated struct Changes: Sendable, Equatable {
        var saves: [Save] = []
        var deletions: Set<UUID> = []

        var isEmpty: Bool { saves.isEmpty && deletions.isEmpty }
    }

    /// How far back a pass reaches.
    nonisolated enum Scope: Sendable, Equatable {
        /// Every serving ever logged — when the switch turns on.
        case all
        /// The last ``HealthPlan/recentDays`` days, today among them — every other pass.
        case recent

        /// The wider of the two, for a pass asked for while another waits.
        func widened(by other: Scope) -> Scope {
            self == .all || other == .all ? .all : .recent
        }

        /// The half-open interval a pass reads, `nil` for every day. Days are stepped on the calendar,
        /// never in seconds (rule `30-rollover`). A calendar that cannot step back answers `nil` too: a
        /// wider pass costs time, never a wrong deletion.
        func interval(endingAt now: Date, calendar: Calendar) -> DateInterval? {
            guard self == .recent,
                  let start = calendar.date(
                      byAdding: .day, value: -(HealthPlan.recentDays - 1), to: calendar.startOfDay(for: now))
            else { return nil }
            return DateInterval(start: start, end: DataManager.nextDayBoundary(after: now, calendar: calendar))
        }
    }

    /// The latest a serving can still arrive or change: the span the phone keeps a watch pour's day in its
    /// applied ledger. History's own edits reach only its week, well inside it. By name, so the two cannot
    /// drift.
    static let recentDays = DataManager.appliedLedgerRetentionDays

    /// What Health should be told, from servings and samples read over the same interval — `nil` for every
    /// day. Both sides are cut to that half-open interval here, whatever either read returned around its
    /// edges.
    ///
    /// A sample whose serving is not in the log is deleted only when its serving is among `deletable` — the
    /// servings this log was seen to hold. A second sample of a serving the log holds goes either way.
    ///
    /// **Why only those.** HealthKit reads back every sample from WaterBuddy's own source, and that includes
    /// samples this log never held: an earlier install's, kept in Health when the app was deleted (rule
    /// `70-privacy`'s *Turning it off deletes nothing*, and the policy's promise), and those of WaterBuddy on
    /// another iPhone sharing Health through iCloud. Deleting every sample without a serving would erase them
    /// the moment the switch turned on over a new log, or a store fell back to an empty one. A serving deleted
    /// in the app was in the log before it went, so it was seen; a serving this log never held was not.
    static func changes(
        servings: [Serving], samples: [Sample], within interval: DateInterval?, deletable: Set<UUID>
    ) -> Changes {
        func inside(_ instant: Date) -> Bool {
            guard let interval else { return true }
            return interval.start <= instant && instant < interval.end
        }

        var written: [UUID: [Sample]] = [:]
        for sample in samples where inside(sample.at) {
            guard let id = sample.serving else { continue }
            written[id, default: []].append(sample)
        }

        var changes = Changes()
        var seen = Set<UUID>()
        for serving in servings where inside(serving.at) {
            seen.insert(serving.id)
            let copies = (written[serving.id] ?? []).sorted { $0.version > $1.version }
            guard let kept = copies.first else {
                changes.saves.append(Save(serving: serving, version: 1))
                continue
            }
            changes.deletions.formUnion(copies.dropFirst().map(\.object))
            if kept.amount != serving.amount || !sameInstant(kept.at, serving.at) {
                changes.saves.append(Save(serving: serving, version: kept.version + 1))
            }
        }
        for (id, copies) in written where !seen.contains(id) && deletable.contains(id) {
            changes.deletions.formUnion(copies.map(\.object))
        }
        return changes
    }

    /// Instants compared to the millisecond: an instant HealthKit hands back a hair different must not be
    /// written again on every pass, its version climbing forever. Task 0 measured no drift on iOS 27.0
    /// (spec §4a, f); the comparison stays as the guard.
    private static func sameInstant(_ a: Date, _ b: Date) -> Bool {
        (a.timeIntervalSinceReferenceDate * 1_000).rounded() == (b.timeIntervalSinceReferenceDate * 1_000).rounded()
    }
}
