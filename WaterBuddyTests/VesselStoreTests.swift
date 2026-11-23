//
//  VesselStoreTests.swift
//  WaterBuddyTests
//

import Foundation
import SwiftData
import Testing
@testable import WaterBuddy

private let utcDay: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar
}()

private func withTempDefaults<T>(_ body: (UserDefaults) throws -> T) rethrows -> T {
    let name = "test.waterbuddy.vessels.\(UUID().uuidString)"
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
    onReschedule: @escaping () -> Void = {}
) -> DataManager {
    DataManager(
        defaults: defaults,
        modelContainer: try! ModelContainer(for: WaterLog.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)),
        calendar: utcDay,
        now: { utcDay.date(from: DateComponents(year: 2026, month: 11, day: 22, hour: 12))! },
        reloadWidgets: onReload,
        rescheduleReminders: { _ in onReschedule() },
        publishWrist: { _ in }
    )
}

/// The library in the store (spec `2026-11-22-set-c-design.md` §3.6, D11).
@MainActor
struct VesselStoreTests {

    @Test func aFreshInstallHasNoLibraryAndShowsTheStandardThree() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults)
            #expect(manager.vessels == VesselLibrary.standard(amounts: [150, 250, 500]))
            #expect(defaults.data(forKey: DataManager.Key.vessels) == nil, "absence means never made")
        }
    }

    @Test func nothingIsWrittenForAChangeThatChangesNothing() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults)
            manager.useStandardVessels()
            manager.putOnHome(id: "glass", slot: 1)
            #expect(defaults.data(forKey: DataManager.Key.vessels) == nil)
        }
    }

    @Test func theFirstChangeMakesTheLibraryFromHomesThree() throws {
        try withTempDefaults { defaults in
            let manager = makeManager(defaults)
            manager.servings = [200, 330, 750]
            let id = try #require(manager.addVessel(glyph: .flask, name: "Office", amount: 400))

            let stored = try #require(DataManager.resolveVessels(in: defaults))
            #expect(stored.amounts == [200, 330, 750], "Home's three keep the amounts they had")
            #expect(stored.more.map(\.id) == [id])
            #expect(manager.vessels == stored)
        }
    }

    @Test func puttingAVesselInTheMiddleIsWhatEveryDoorLogs() throws {
        try withTempDefaults { defaults in
            let manager = makeManager(defaults)
            let id = try #require(manager.addVessel(glyph: .bottle, name: "Stanley", amount: 1_180))
            manager.putOnHome(id: id, slot: DataManager.usualSlot)

            #expect(DataManager.usualServing(in: defaults) == 1_180, "the widget, Siri, the control and the reminder read this")
            #expect(defaults.array(forKey: DataManager.Key.servings) as? [Int] == [150, 1_180, 500])
            #expect(manager.servings == [150, 1_180, 500])
        }
    }

    /// Review Focus 1: an extension's long-lived instance must log the new middle vessel after a pick.
    @Test func aSecondInstanceReadsTheNewMiddleVessel() throws {
        try withTempDefaults { defaults in
            let app = makeManager(defaults)
            let other = makeManager(defaults)
            let id = try #require(app.addVessel(glyph: .bottle, name: "Stanley", amount: 1_180))
            app.putOnHome(id: id, slot: DataManager.usualSlot)

            other.refresh()
            #expect(other.servings[DataManager.usualSlot] == 1_180)
            #expect(other.vessels == app.vessels)
        }
    }

    @Test func aChangeOfTheMiddleGlyphReschedulesAndANameChangeDoesNot() throws {
        try withTempDefaults { defaults in
            let reschedules = Counter()
            let manager = makeManager(defaults, onReschedule: { reschedules.count += 1 })
            let id = try #require(manager.addVessel(glyph: .flask, name: "Office", amount: 400))
            reschedules.count = 0

            manager.putOnHome(id: id, slot: DataManager.usualSlot)
            #expect(reschedules.count == 1, "the reminder's button wears the middle glyph")

            manager.updateVessel(id: id, glyph: .flask, name: "Desk", amount: 400)
            #expect(reschedules.count == 1, "a name moves no slot and no icon")
        }
    }

    @Test func everyChangeRingsTheWidgetsOnce() throws {
        try withTempDefaults { defaults in
            let reloads = Counter()
            let manager = makeManager(defaults, onReload: { reloads.count += 1 })
            reloads.count = 0
            _ = try #require(manager.addVessel(glyph: .flask, name: "Office", amount: 400))
            #expect(reloads.count == 1)
        }
    }

    @Test func editingHomesAmountsWithALibraryWritesThemIntoIt() throws {
        try withTempDefaults { defaults in
            let manager = makeManager(defaults)
            let id = try #require(manager.addVessel(glyph: .flask, name: "Office", amount: 400))
            manager.putOnHome(id: id, slot: 0)

            manager.servings = [450, 250, 500]

            let stored = try #require(DataManager.resolveVessels(in: defaults))
            #expect(stored.home[0] == Vessel(id: id, glyph: .flask, name: "Office", amount: 450))
            #expect(defaults.array(forKey: DataManager.Key.servings) as? [Int] == [450, 250, 500])
        }
    }

    @Test func aCorruptLibraryReadsAsNoneAndIsLeftAsItIs() {
        withTempDefaults { defaults in
            let garbage = Data("{\"home\":[],\"more\":[]}".utf8)
            defaults.set(garbage, forKey: DataManager.Key.vessels)
            let manager = makeManager(defaults)
            #expect(manager.vessels == VesselLibrary.standard(amounts: manager.servings))
            #expect(defaults.data(forKey: DataManager.Key.vessels) == garbage, "a failed read is never written back")
        }
    }

    /// Review Focus 2, the pure half: only the app's role heals, and only when the two disagree.
    @Test func theHealIsTheAppsAlone() {
        let library = VesselLibrary.standard(amounts: [100, 200, 300])
        #expect(DataManager.healedServings(library: library, servings: [150, 250, 500], role: .phoneApp) == [100, 200, 300])
        for role in [DataManager.Role.phoneExtension, .watchApp, .watchExtension] {
            #expect(DataManager.healedServings(library: library, servings: [150, 250, 500], role: role) == nil, "\(role)")
        }
        #expect(DataManager.healedServings(library: library, servings: [100, 200, 300], role: .phoneApp) == nil)
        #expect(DataManager.healedServings(library: nil, servings: [150, 250, 500], role: .phoneApp) == nil)
    }

    /// Review Focus 2, the whole: a crash left the two apart, and the app's launch puts them back together.
    @Test func aLibraryAndServingsLeftApartAreHealedAtLaunch() throws {
        try withTempDefaults { defaults in
            let library = VesselLibrary.standard(amounts: [100, 200, 300])
            defaults.set(try JSONEncoder().encode(library), forKey: DataManager.Key.vessels)
            defaults.set([150, 250, 500], forKey: DataManager.Key.servings)

            let manager = makeManager(defaults)   // the test host is the app: `.phoneApp`
            #expect(manager.servings == [100, 200, 300])
            #expect(defaults.array(forKey: DataManager.Key.servings) as? [Int] == [100, 200, 300])
        }
    }

    /// Review Focus 4.
    @Test func useStandardVesselsKeepsEveryVesselStored() throws {
        try withTempDefaults { defaults in
            let manager = makeManager(defaults)
            let id = try #require(manager.addVessel(glyph: .bottle, name: "Stanley", amount: 1_180))
            manager.putOnHome(id: id, slot: DataManager.usualSlot)

            manager.useStandardVessels()

            #expect(manager.vessels.isStandardOnHome)
            #expect(manager.vessels.vessel(id: id) != nil, "nothing is deleted")
            #expect(DataManager.usualServing(in: defaults) == 250)
        }
    }

    @Test func aStandardOrAHomeVesselCannotBeDeleted() throws {
        try withTempDefaults { defaults in
            let manager = makeManager(defaults)
            let id = try #require(manager.addVessel(glyph: .flask, name: "Office", amount: 400))
            manager.putOnHome(id: id, slot: 2)
            manager.deleteVessel(id: id)
            manager.deleteVessel(id: "cup")
            #expect(manager.vessels.vessel(id: id) != nil)
            #expect(manager.vessels.vessel(id: "cup") != nil)
        }
    }
}
