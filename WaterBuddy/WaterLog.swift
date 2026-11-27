//
//  WaterLog.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import Foundation
import SwiftData

/// One serving — water, or since 1.5 another ``Drink`` — at the moment it was logged.
///
/// This is the **source of truth** for what the user drank. Every drink counts in full toward the day (spec
/// `2026-11-27-other-drinks-design.md` R2), so a total is still a plain sum of ``amount``. Today's running total is *derived*
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

    /// What was drunk: a ``Drink``'s code, and **absent for water** — so every serving logged before 1.5 is
    /// water with nothing rewritten, and the store's version 2 adds a column no existing row has to fill
    /// (spec `2026-11-27-other-drinks-design.md` §3.1, D1). Read and written through ``drink``, never directly
    /// by a caller.
    var drinkCode: String?

    init(id: UUID = UUID(), amount: Int, timestamp: Date, drink: Drink = .water) {
        self.id = id
        self.amount = amount
        self.timestamp = timestamp
        self.drinkCode = drink.code
    }

    /// The serving's drink. A missing code, or one this build does not know, reads as water: every drink
    /// counts in full (R2), so a code from a later build still counts, as water. Setting water removes the
    /// code. Computed, so the store keeps one column for it.
    var drink: Drink {
        get { Drink(code: drinkCode) }
        set { drinkCode = newValue.code }
    }
}

/// What a serving was: water, or one of the roadmap's four other drinks (spec
/// `2026-11-27-other-drinks-design.md` R1). Every drink counts in full toward the day (R2), so nothing that
/// sums servings reads this; History, Home's row and the export do.
///
/// `nonisolated`, as `AppTheme` is: the export and a test that is not `@MainActor` read it (rule
/// `43-concurrency`). The cases are in the row's order, and their raw values are the stored codes and the
/// words the export writes, fixed English in every language (R6).
nonisolated enum Drink: String, CaseIterable, Sendable {
    case water, tea, coffee, juice, milk

    /// The code ``WaterLog/drinkCode`` stores: `nil` for water, whose absence is the default.
    var code: String? { self == .water ? nil : rawValue }

    /// Reads a stored code. `nil` is water; so is a code this build does not know, which says so in DEBUG
    /// (rule `75-diagnostics`) and names no value.
    init(code: String?) {
        guard let code else {
            self = .water
            return
        }
        if let drink = Drink(rawValue: code) {
            self = drink
        } else {
            #if DEBUG
            print("[WaterBuddy] A serving's drink is not one this build knows; it is read as water.")
            #endif
            self = .water
        }
    }

    /// The name's key in the app's catalogue. A name stands alone, as a label, and is never inflected into a
    /// sentence (D8).
    var nameKey: String {
        switch self {
        case .water: "Water"
        case .tea: "Tea"
        case .coffee: "Coffee"
        case .juice: "Juice"
        case .milk: "Milk"
        }
    }
}

// MARK: - The store's versions

/// Version 1: `WaterLog` as every build up to 1.4.3 stored it — `id`, `amount`, `timestamp` — **frozen**.
///
/// A nested copy, field for field, so the store a phone holds before 1.5 can be named exactly and migrated.
/// Never edited: `DrinkSchemaTests.theFrozenVersionOneIsTheShapeThatShipped` checks its model hash against the
/// one a probe read off a real store on 2026-11-27 (spec `2026-11-27-other-drinks-design.md` §3.2).
nonisolated enum WaterBuddySchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] { [WaterLog.self] }

    @Model
    final class WaterLog {
        var id: UUID
        var amount: Int
        var timestamp: Date

        init(id: UUID = UUID(), amount: Int, timestamp: Date) {
            self.id = id
            self.amount = amount
            self.timestamp = timestamp
        }
    }
}

/// Version 2, the live one: the app's own ``WaterLog``, which adds ``WaterLog/drinkCode``.
nonisolated enum WaterBuddySchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] { [WaterLog.self] }
}

/// The store's history, and **the one way a container is opened** — by the app's ladder in
/// `DataManager.sharedModelContainer` and by the tests alike, so a test that opens a store version 1 wrote
/// runs the migration a phone runs.
///
/// Every container opens ``current``, the last of ``schemas``, through the plan. Left on a frozen version, a
/// container would open with the frozen class while the code saves the live one, and the first save would fail
/// (the shared schema procedure's lesson, from Glazzy; `DrinkSchemaTests.everyContainerOpensThePlansLastVersion`).
/// Each new version gets a frozen copy of the one before it and one more stage.
nonisolated enum WaterBuddyMigrationPlan: SchemaMigrationPlan {
    /// The version every container opens.
    static var current: any VersionedSchema.Type { WaterBuddySchemaV2.self }

    static var schemas: [any VersionedSchema.Type] { [WaterBuddySchemaV1.self, WaterBuddySchemaV2.self] }

    /// 1 to 2 adds an optional column, so it is lightweight: no row is read or rewritten.
    static var stages: [MigrationStage] {
        [.lightweight(fromVersion: WaterBuddySchemaV1.self, toVersion: WaterBuddySchemaV2.self)]
    }

    /// The store at `url`, or the process's default location when `nil`, opened at ``current`` and migrated
    /// to it if an earlier version wrote it.
    static func container(at url: URL?) throws -> ModelContainer {
        let schema = Schema(versionedSchema: current)
        let configuration = url.map { ModelConfiguration(schema: schema, url: $0) } ?? ModelConfiguration(schema: schema)
        return try ModelContainer(for: schema, migrationPlan: Self.self, configurations: configuration)
    }

    /// A store in memory, at ``current``: the last rung of the app's ladder.
    static func inMemoryContainer() throws -> ModelContainer {
        let schema = Schema(versionedSchema: current)
        return try ModelContainer(
            for: schema,
            migrationPlan: Self.self,
            configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        )
    }
}
