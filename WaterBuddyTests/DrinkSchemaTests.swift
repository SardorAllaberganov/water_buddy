//
//  DrinkSchemaTests.swift
//  WaterBuddyTests
//

import CoreData
import Foundation
import SwiftData
import Testing
@testable import WaterBuddy

/// The store's two versions (spec `2026-11-27-other-drinks-design.md` §3.2): today's `WaterLog`, frozen as
/// version 1, and the drink added in version 2 through one lightweight stage. Each test writes its own store
/// file in a temporary folder of its own, never the App Group's (rule `85-testing`), and keeps each container
/// for as long as its context is used.
@MainActor
struct DrinkSchemaTests {

    /// Today's `WaterLog`, as every build up to 1.4.3 stored it: read off a store file by a probe test on
    /// 2026-11-27, then deleted (§3.2, step 1).
    private static let shippedHash = "7TIyxKKBgV1ejdPFXrftQ5Rgvy6R/JOcsllCl4qedBA="

    private struct Folder {
        let url: URL

        init() throws {
            url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }

        var store: URL { url.appendingPathComponent("drinks.store") }

        func remove() { try? FileManager.default.removeItem(at: url) }
    }

    /// Writes a store as a build up to 1.4.3 would have, through the frozen version 1.
    private func writeVersionOne(at url: URL, rows: [(id: UUID, amount: Int, at: Date)]) throws {
        let schema = Schema(versionedSchema: WaterBuddySchemaV1.self)
        let container = try ModelContainer(for: schema, configurations: ModelConfiguration(schema: schema, url: url))
        let context = ModelContext(container)
        for row in rows {
            context.insert(WaterBuddySchemaV1.WaterLog(id: row.id, amount: row.amount, timestamp: row.at))
        }
        try context.save()
    }

    @Test func theFrozenVersionOneIsTheShapeThatShipped() throws {
        let folder = try Folder()
        defer { folder.remove() }
        try writeVersionOne(at: folder.store, rows: [(UUID(), 250, Date(timeIntervalSince1970: 0))])

        let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(type: .sqlite, at: folder.store)
        let hashes = try #require(metadata[NSStoreModelVersionHashesKey] as? [String: Data])
        #expect(hashes["WaterLog"]?.base64EncodedString() == Self.shippedHash)
    }

    /// The migration a phone runs on its first launch of 1.5: every serving still there, each water.
    @Test func aStoreVersionOneWroteOpensWithEveryServingIntactAndWater() throws {
        let folder = try Folder()
        defer { folder.remove() }
        let rows: [(id: UUID, amount: Int, at: Date)] = [
            (UUID(), 150, Date(timeIntervalSince1970: 1_000)),
            (UUID(), 250, Date(timeIntervalSince1970: 2_000)),
            (UUID(), 500, Date(timeIntervalSince1970: 3_000)),
        ]
        try writeVersionOne(at: folder.store, rows: rows)

        let container = try WaterBuddyMigrationPlan.container(at: folder.store)
        let read = try ModelContext(container).fetch(FetchDescriptor<WaterLog>(sortBy: [SortDescriptor(\.timestamp)]))
        #expect(read.map(\.id) == rows.map { $0.id })
        #expect(read.map(\.amount) == [150, 250, 500])
        #expect(read.map(\.timestamp) == rows.map { $0.at })
        #expect(read.allSatisfy { $0.drink == .water && $0.drinkCode == nil })
    }

    @Test func aDrinkSurvivesAReopen() throws {
        let folder = try Folder()
        defer { folder.remove() }
        let id = UUID()
        do {
            let container = try WaterBuddyMigrationPlan.container(at: folder.store)
            let context = ModelContext(container)
            context.insert(WaterLog(id: id, amount: 150, timestamp: Date(timeIntervalSince1970: 0), drink: .coffee))
            try context.save()
        }

        let container = try WaterBuddyMigrationPlan.container(at: folder.store)
        let read = try ModelContext(container).fetch(FetchDescriptor<WaterLog>())
        #expect(read.map(\.id) == [id])
        #expect(read.first?.drink == .coffee)
        #expect(read.first?.drinkCode == "coffee")
    }

    /// Every container opens the plan's last version. Left on the frozen one, a container would open with the
    /// frozen class while the code saves the live one (§3.2, step 5).
    @Test func everyContainerOpensThePlansLastVersion() throws {
        let last = try #require(WaterBuddyMigrationPlan.schemas.last)
        #expect(ObjectIdentifier(WaterBuddyMigrationPlan.current) == ObjectIdentifier(last))
        #expect(WaterBuddyMigrationPlan.current.versionIdentifier == Schema.Version(2, 0, 0))
        #expect(WaterBuddyMigrationPlan.stages.count == WaterBuddyMigrationPlan.schemas.count - 1)
    }
}
