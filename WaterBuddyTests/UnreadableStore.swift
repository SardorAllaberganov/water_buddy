//
//  UnreadableStore.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 10/10/26.
//

import Foundation
import SQLite3
import SwiftData
@testable import WaterBuddy

/// A file-backed store whose reads can be made to fail on demand, for the tests that pin what the
/// model does when it cannot read (rule `20-state`: a failed read is never written back).
///
/// **It fails the same way every time, which the older technique does not.** `WristSyncTests`
/// overwrites the store file with random bytes and deletes its `-wal` and `-shm` while the context
/// holds them open. SQLite notices an unlinked file from a background queue ("vnode unlinked while
/// in use … invalidated open fd"), so whether the next fetch fails is a race, and a second test
/// doing the same thing in the same process moves it: with three such tests in the target, the
/// old one failed once in four full runs and a new one once in six.
///
/// Here nothing is unlinked. The servings' table is renamed away through a second, ordinary
/// SQLite connection, and committed; every other connection sees the new schema at its next
/// statement and fails with "no such table". A throwaway file in a temporary directory, never the
/// App Group's (rule `85-testing`).
struct UnreadableStore {

    let container: ModelContainer

    private let directory: URL
    private let storeURL: URL

    init() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        storeURL = directory.appendingPathComponent("unreadable.store")

        let schema = Schema([WaterLog.self])
        container = try ModelContainer(for: schema, configurations: ModelConfiguration(schema: schema, url: storeURL))
    }

    /// Makes every later read of the servings fail. Throws if the table could not be renamed, so
    /// a test cannot go on to pass against a store that still reads.
    func breakReads() throws {
        var connection: OpaquePointer?
        defer { sqlite3_close(connection) }

        guard sqlite3_open_v2(storeURL.path, &connection, SQLITE_OPEN_READWRITE, nil) == SQLITE_OK,
              sqlite3_exec(connection, "ALTER TABLE ZWATERLOG RENAME TO ZWATERLOG_HIDDEN", nil, nil, nil) == SQLITE_OK
        else {
            throw Failure.couldNotHideTheTable(String(cString: sqlite3_errmsg(connection)))
        }
    }

    /// Puts the table back, so a test can look at what a failed read left behind: a row the model
    /// marked for deletion while it could not read is gone from the next fetch, and one it left
    /// alone is still there.
    func restoreReads() throws {
        var connection: OpaquePointer?
        defer { sqlite3_close(connection) }

        guard sqlite3_open_v2(storeURL.path, &connection, SQLITE_OPEN_READWRITE, nil) == SQLITE_OK,
              sqlite3_exec(connection, "ALTER TABLE ZWATERLOG_HIDDEN RENAME TO ZWATERLOG", nil, nil, nil) == SQLITE_OK
        else {
            throw Failure.couldNotRestoreTheTable(String(cString: sqlite3_errmsg(connection)))
        }
    }

    /// Whether a fresh context can still read the servings. A test proves this is `false` before
    /// it asserts anything about a failed read.
    var stillReads: Bool {
        (try? ModelContext(container).fetch(FetchDescriptor<WaterLog>())) != nil
    }

    /// Deletes the throwaway directory. Called last, from a `defer`, after every assertion — the
    /// one unlink this fixture makes, and nothing reads the store after it.
    func remove() {
        try? FileManager.default.removeItem(at: directory)
    }

    enum Failure: Error {
        case couldNotHideTheTable(String)
        case couldNotRestoreTheTable(String)
    }
}
