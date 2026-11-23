//
//  ThemeStoreTests.swift
//  WaterBuddyTests
//

import Foundation
import SwiftData
import Testing
@testable import WaterBuddy

private func withTempDefaults<T>(_ body: (UserDefaults) throws -> T) rethrows -> T {
    let name = "test.waterbuddy.theme.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    return try body(defaults)
}

private final class Counter: @unchecked Sendable {
    var count = 0
}

@MainActor
private func makeManager(
    _ defaults: UserDefaults,
    onReload: @escaping () -> Void = {},
    onReschedule: @escaping () -> Void = {},
    onPublish: @escaping () -> Void = {}
) -> DataManager {
    DataManager(
        defaults: defaults,
        modelContainer: try! ModelContainer(for: WaterLog.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)),
        calendar: .waterBuddyDay,
        now: { Date(timeIntervalSince1970: 1_795_000_000) },
        reloadWidgets: onReload,
        rescheduleReminders: { _ in onReschedule() },
        publishWrist: { _ in onPublish() }
    )
}

/// The theme in the store (spec `2026-11-22-set-c-design.md` §3.5).
@MainActor
struct ThemeStoreTests {

    @Test func aFreshInstallDrawsAurora() {
        withTempDefaults { defaults in
            #expect(makeManager(defaults).theme == .aurora)
            #expect(defaults.object(forKey: DataManager.Key.theme) == nil)
        }
    }

    @Test func choosingAThemeWritesItsCodeAndAuroraRemovesTheKey() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults)
            manager.theme = .dusk
            #expect(defaults.string(forKey: DataManager.Key.theme) == "dusk")
            manager.theme = .aurora
            #expect(defaults.object(forKey: DataManager.Key.theme) == nil, "the absence is the state")
        }
    }

    @Test func aThemeRingsTheWidgetsAndTheWristOnceAndPlansNothing() {
        withTempDefaults { defaults in
            let reloads = Counter(), reschedules = Counter(), publishes = Counter()
            let manager = makeManager(defaults, onReload: { reloads.count += 1 },
                                      onReschedule: { reschedules.count += 1 }, onPublish: { publishes.count += 1 })
            (reloads.count, reschedules.count, publishes.count) = (0, 0, 0)

            manager.theme = .lagoon
            manager.theme = .lagoon

            #expect(reloads.count == 1)
            #expect(publishes.count == 1)
            #expect(reschedules.count == 0, "a theme moves no reminder")
        }
    }

    /// Review Focus 5.
    @Test func anUnknownThemeReadsAsAuroraAndIsLeftAsItIs() {
        withTempDefaults { defaults in
            defaults.set("neon", forKey: DataManager.Key.theme)
            let manager = makeManager(defaults)
            #expect(manager.theme == .aurora)
            #expect(DataManager.snapshot(defaults: defaults).theme == .aurora)
            #expect(defaults.string(forKey: DataManager.Key.theme) == "neon", "a failed read is never written back")
        }
    }

    @Test func aSecondInstanceReadsTheNewThemeOnRefresh() {
        withTempDefaults { defaults in
            let app = makeManager(defaults)
            let other = makeManager(defaults)
            app.theme = .midnight
            other.refresh()
            #expect(other.theme == .midnight)
        }
    }

    @Test func theSnapshotAndTheMirrorCarryTheTheme() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults)
            manager.theme = .bloom
            #expect(DataManager.snapshot(defaults: defaults).theme == .bloom)
            #expect(DataManager.composeWristMirror(from: defaults, calendar: .waterBuddyDay, now: Date()).themeCode == "bloom")
            manager.theme = .aurora
            #expect(DataManager.composeWristMirror(from: defaults, calendar: .waterBuddyDay, now: Date()).themeCode == nil)
        }
    }
}
