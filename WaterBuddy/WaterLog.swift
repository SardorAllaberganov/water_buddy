//
//  WaterLog.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import Foundation
import SwiftData

/// One serving of water, at the moment it was logged.
///
/// This is the **source of truth** for what the user drank. Today's running total is *derived*
/// from it — `DataManager.recomputeToday()` sums today's logs and writes the figure into the App
/// Group's `UserDefaults` as a cache, which is what the widget reads. Nothing reads a total out of
/// SwiftData directly, and the widget never opens the store at all (rule `40-widget`).
///
/// **Why a cache at all, rather than the widget querying SwiftData?** A `TimelineProvider` carries
/// no isolation, and a `ModelContext` is not `Sendable`. Reading through the cache is what keeps
/// `HydrationProvider` synchronous and `nonisolated` — the property rule `43-concurrency` exists
/// to preserve. The cache is never authoritative: it is recomputed from the logs after every
/// mutation, so the two cannot drift without the log side being wrong first.
///
/// ## The timestamp is a `Date`, and that is not a contradiction of rule `30-rollover`
///
/// That rule forbids storing *the day* as a `Date` — an instant re-read under a different time
/// zone moves, which is how a user flying west loses a day. It is still the correct type for *the
/// moment a serving happened*, which is a real instant and does not move.
///
/// The distinction is in how it is read: `fetchLogsForToday()` never compares instants to decide
/// which day something belongs to. It derives today's half-open bounds from
/// `Calendar.waterBuddyDay` — the same calendar the ordinal uses — and filters on those. The
/// `yyyyMMdd` ordinal remains the marker for *whether the day turned*.
@Model
final class WaterLog {

    /// Stable across edits, so a view can identify a row it is animating and the seed migration
    /// can be recognised if it ever needs to be.
    ///
    /// `@Attribute(.unique)` is deliberately **not** applied. Two processes insert into this store
    /// — the app and `AddWaterIntent` in the widget extension — and a unique constraint turns a
    /// benign collision into a failed save in whichever process lost the race.
    var id: UUID

    /// Millilitres. `Int`, like every other volume in this product; clamped by the caller on the
    /// way in, never negative and never zero (rule `20-state`).
    var amount: Int

    /// When the serving was logged.
    var timestamp: Date

    init(id: UUID = UUID(), amount: Int, timestamp: Date) {
        self.id = id
        self.amount = amount
        self.timestamp = timestamp
    }
}
