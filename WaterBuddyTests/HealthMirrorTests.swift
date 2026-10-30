//
//  HealthMirrorTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 29/10/26.
//

import Foundation
import SwiftData
import Testing
@testable import WaterBuddy

// MARK: - Fixtures

private let utcDay: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar
}()

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
}

/// The tests' clock: 29 October 2026, 15:00 UTC.
private let today: () -> Date = { utc(2026, 10, 29, 15) }

/// A suite, a store and a manager of their own, torn down after — never the real App Group (rule
/// `85-testing`): `@Test` functions run in parallel in one process.
@MainActor
private final class Bench {
    let name = "test.waterbuddy.health.\(UUID().uuidString)"
    let defaults: UserDefaults
    let container: ModelContainer
    let manager: DataManager

    init(container: ModelContainer? = nil) throws {
        defaults = try #require(UserDefaults(suiteName: name))
        self.container = try container
            ?? ModelContainer(for: WaterLog.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        manager = Self.manager(defaults: defaults, container: self.container)
    }

    /// A second manager over the same suite and store — another process's, as the widget extension's is.
    static func manager(defaults: UserDefaults, container: ModelContainer) -> DataManager {
        DataManager(
            defaults: defaults, modelContainer: container, calendar: utcDay, now: today,
            reloadWidgets: {}, rescheduleReminders: { _ in }, publishWrist: { _ in }
        )
    }

    func tearDown() {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
}

/// Counts a notification's arrivals — rule `85-testing`'s `@unchecked Sendable` box.
nonisolated private final class Arrivals: @unchecked Sendable {
    var count = 0
}

// MARK: - DataManager's Health surface

@MainActor
struct HealthSurfaceTests {

    @Test func theSwitchIsOffUntilTheUserTurnsItOn() throws {
        let bench = try Bench()
        defer { bench.tearDown() }

        #expect(!bench.manager.healthEnabled)
        #expect(bench.defaults.object(forKey: DataManager.Key.healthEnabled) == nil, "absent, never materialised")
    }

    @Test func theSwitchWritesItsOwnKeyAndNothingElse() throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let before = bench.defaults.dictionaryRepresentation().filter { $0.key.hasPrefix("sardor.WaterBuddy.") }

        bench.manager.healthEnabled = true

        let after = bench.defaults.dictionaryRepresentation().filter { $0.key.hasPrefix("sardor.WaterBuddy.") }
        #expect(Set(after.keys).subtracting(before.keys) == [DataManager.Key.healthEnabled])
        #expect(bench.defaults.object(forKey: DataManager.Key.healthEnabled) as? Bool == true)
        #expect(Bench.manager(defaults: bench.defaults, container: bench.container).healthEnabled, "a new manager reads it back")

        bench.manager.healthEnabled = false
        #expect(bench.defaults.object(forKey: DataManager.Key.healthEnabled) as? Bool == false)
    }

    @Test func theLogsSinceABoundAreTheRowsFromIt() throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let older = try #require(bench.manager.addLog(amount: 200, at: utc(2026, 10, 27)))
        let middle = try #require(bench.manager.addLog(amount: 250, at: utc(2026, 10, 28)))
        let newest = try #require(bench.manager.addLog(amount: 300))

        let since = try #require(bench.manager.logs(since: utcDay.startOfDay(for: utc(2026, 10, 28))))
        #expect(Set(since.map(\.id)) == [middle, newest])
        #expect(Set(try #require(bench.manager.logs(since: nil)).map(\.id)) == [older, middle, newest])
    }

    /// "Cannot be read" is not "no servings": the mirror deletes what it does not find.
    @Test func aFailedReadIsNothingNotEmpty() throws {
        let store = try UnreadableStore()
        defer { store.remove() }
        let bench = try Bench(container: store.container)
        defer { bench.tearDown() }
        bench.manager.addLog(amount: 250)

        try store.breakReads()
        #expect(!store.stillReads, "the store must be unreadable before anything is asserted about a failed read")

        #expect(bench.manager.logs(since: nil) == nil)
    }

    /// Every way a serving changes ends in `saveAndRecompute()`, and each says so — with this manager as
    /// the object, so a mirror hears only its own.
    @Test func everyWayAServingChangesAnnouncesTheSave() throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let mine = Arrivals()
        let theirs = Arrivals()
        let other = Bench.manager(defaults: bench.defaults, container: bench.container)
        let a = NotificationCenter.default.addObserver(forName: DataManager.logsDidSaveNotification, object: bench.manager, queue: nil) { _ in mine.count += 1 }
        let b = NotificationCenter.default.addObserver(forName: DataManager.logsDidSaveNotification, object: other, queue: nil) { _ in theirs.count += 1 }
        defer {
            NotificationCenter.default.removeObserver(a)
            NotificationCenter.default.removeObserver(b)
        }

        let id = try #require(bench.manager.addLog(amount: 250))
        #expect(mine.count == 1, "addLog")
        let log = try #require(bench.manager.todaysLogs.first { $0.id == id })
        bench.manager.updateLog(log, newAmount: 300)
        #expect(mine.count == 2, "updateLog")
        bench.manager.removeWater(amount: 100)
        #expect(mine.count == 3, "removeWater")
        _ = bench.manager.ingest([WristPour(id: UUID(), amount: 150, at: today())])
        #expect(mine.count == 4, "ingest")
        let second = try #require(bench.manager.addLog(amount: 400))
        bench.manager.undoLog(id: second)
        #expect(mine.count == 6, "addLog, then undoLog")
        bench.manager.resetDailyProgress()
        #expect(mine.count == 7, "resetDailyProgress")
        #expect(theirs.count == 0, "another manager's notification is its own")
    }
}

// MARK: - The mirror

/// A Health of its own, in memory: a sample is replaced as HealthKit replaces one — the same sync
/// identifier at a higher version — so a test reads what Health would hold. A box, rule `85-testing`'s
/// `@unchecked Sendable` shape, so the closures it hands the mirror carry no isolation of their own.
nonisolated private final class FakeHealth: @unchecked Sendable {
    var status: HealthMirror.Status = .notDetermined
    /// What the sheet sets when it is shown.
    var answer: HealthMirror.Status = .allowed
    var samples: [HealthPlan.Sample] = []
    var readable = true
    var asked = 0
    var reads = 0
    var writes = 0
    var intervals: [DateInterval?] = []

    var servings: Set<UUID> { Set(samples.compactMap(\.serving)) }

    func sample(of id: UUID) -> HealthPlan.Sample? {
        samples.first { $0.serving == id }
    }

    @MainActor func source() -> HealthMirror.Source {
        HealthMirror.Source(
            isAvailable: { true },
            status: { self.status },
            requestWrite: {
                self.asked += 1
                self.status = self.answer
            },
            samples: { interval in
                self.reads += 1
                self.intervals.append(interval)
                return self.readable ? self.samples : nil
            },
            save: { saves in
                self.writes += 1
                for save in saves {
                    let written = HealthPlan.Sample(
                        object: UUID(), serving: save.serving.id, amount: save.serving.amount,
                        at: save.serving.at, version: save.version)
                    if let index = self.samples.firstIndex(where: { $0.serving == save.serving.id }) {
                        guard save.version > self.samples[index].version else { continue }
                        self.samples[index] = written
                    } else {
                        self.samples.append(written)
                    }
                }
                return true
            },
            delete: { objects in
                self.writes += 1
                self.samples.removeAll { objects.contains($0.object) }
                return true
            }
        )
    }
}

@MainActor
private func makeMirror(on bench: Bench, _ health: FakeHealth) -> HealthMirror {
    HealthMirror(manager: bench.manager, source: health.source(), calendar: utcDay, now: today)
}

@MainActor
struct HealthMirrorTests {

    @Test func turningItOnAsksOnceAndWritesTheWholeHistory() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        let spring = try #require(bench.manager.addLog(amount: 300, at: utc(2026, 3, 1)))
        let yesterday = try #require(bench.manager.addLog(amount: 250, at: utc(2026, 10, 28)))
        let now = try #require(bench.manager.addLog(amount: 500))

        await mirror.enable()
        await mirror.settled()

        #expect(health.asked == 1)
        #expect(bench.manager.healthEnabled)
        #expect(mirror.status == .allowed)
        #expect(health.servings == [spring, yesterday, now], "every serving, the spring's beyond the recent days among them")
        #expect(health.sample(of: spring)?.amount == 300)
    }

    @Test func aRefusalLeavesItOffAndWritesNothing() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        health.answer = .denied
        let mirror = makeMirror(on: bench, health)
        bench.manager.addLog(amount: 250)

        await mirror.enable()
        await mirror.settled()

        #expect(!bench.manager.healthEnabled)
        #expect(mirror.status == .denied)
        #expect(health.samples.isEmpty)
        #expect(health.writes == 0)
    }

    @Test func aRefusalAlreadyGivenIsNotAskedAgain() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        health.status = .denied
        let mirror = makeMirror(on: bench, health)

        await mirror.enable()

        #expect(health.asked == 0, "Health shows its sheet once; asking again shows nothing")
        #expect(!bench.manager.healthEnabled)
    }

    @Test func aPermissionAlreadyGivenIsNotAskedAgain() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        health.status = .allowed
        let mirror = makeMirror(on: bench, health)

        await mirror.enable()

        #expect(health.asked == 0)
        #expect(bench.manager.healthEnabled)
    }

    @Test func aPourWhileItIsOnReachesHealth() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        await mirror.enable()
        await mirror.settled()

        let id = try #require(bench.manager.addLog(amount: 250))
        await mirror.settled()

        #expect(health.sample(of: id)?.amount == 250)
    }

    @Test func aPourWhileItIsOffReachesNothing() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)

        bench.manager.addLog(amount: 250)
        await mirror.settled()

        #expect(health.reads == 0)
        #expect(health.writes == 0)
    }

    @Test func turningItOffWritesNothingMoreAndDeletesNothing() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        let first = try #require(bench.manager.addLog(amount: 250))
        await mirror.enable()
        await mirror.settled()

        mirror.disable()
        bench.manager.addLog(amount: 500)
        bench.manager.deleteLog(try #require(bench.manager.todaysLogs.first { $0.id == first }))
        await mirror.settled()

        #expect(!bench.manager.healthEnabled)
        #expect(health.servings == [first], "what is in Health stays; nothing new arrives")
    }

    @Test func turningItOnAgainCatchesUpWithoutDoubling() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        let first = try #require(bench.manager.addLog(amount: 250))
        await mirror.enable()
        await mirror.settled()
        mirror.disable()
        let second = try #require(bench.manager.addLog(amount: 500))

        await mirror.enable()
        await mirror.settled()

        #expect(health.asked == 1)
        #expect(health.servings == [first, second])
        #expect(health.samples.count == 2, "one sample a serving")
    }

    @Test func anEditAndADeleteFollowIntoHealth() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        await mirror.enable()
        let id = try #require(bench.manager.addLog(amount: 250))
        await mirror.settled()
        let log = try #require(bench.manager.todaysLogs.first { $0.id == id })

        bench.manager.updateLog(log, newAmount: 300)
        await mirror.settled()
        #expect(health.sample(of: id)?.amount == 300)
        #expect(health.sample(of: id)?.version == 2)

        bench.manager.deleteLog(log)
        await mirror.settled()
        #expect(health.sample(of: id) == nil)
    }

    /// D6, the owner's: Health is a copy of the log.
    @Test func aSampleDeletedInHealthComesBackWhileItsServingStands() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        await mirror.enable()
        let id = try #require(bench.manager.addLog(amount: 250))
        await mirror.settled()

        health.samples.removeAll()
        await mirror.reconcile()
        await mirror.settled()

        #expect(health.sample(of: id) != nil)
    }

    /// A failed read of the log is never a log of nothing: the samples already written stay.
    @Test func aFailedReadOfTheLogWritesAndDeletesNothing() async throws {
        let store = try UnreadableStore()
        defer { store.remove() }
        let bench = try Bench(container: store.container)
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        let id = try #require(bench.manager.addLog(amount: 250))
        await mirror.enable()
        await mirror.settled()
        let writes = health.writes

        try store.breakReads()
        #expect(!store.stillReads, "the store must be unreadable before anything is asserted about a failed read")
        mirror.request(.recent)
        await mirror.settled()

        #expect(health.writes == writes)
        #expect(health.sample(of: id) != nil)
    }

    /// A locked phone: Health cannot be read, so nothing is written until a later pass can.
    @Test func aFailedReadOfHealthWritesNothing() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        health.status = .allowed
        health.readable = false
        let mirror = makeMirror(on: bench, health)
        bench.manager.addLog(amount: 250)

        await mirror.enable()
        await mirror.settled()

        #expect(bench.manager.healthEnabled)
        #expect(health.writes == 0)
    }

    /// Review Focus 3: the switch turned off between the pass's two reads.
    @Test func turningItOffMidPassWritesNothing() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        health.status = .allowed
        var source = health.source()
        let read = source.samples
        let manager = bench.manager
        // `@MainActor` stated: it turns the switch off, which only the main actor may.
        source.samples = { @MainActor interval in
            manager.healthEnabled = false
            return await read(interval)
        }
        let mirror = HealthMirror(manager: bench.manager, source: source, calendar: utcDay, now: today)
        bench.manager.addLog(amount: 250)

        await mirror.enable()
        await mirror.settled()

        #expect(health.reads == 1)
        #expect(health.writes == 0)
    }

    @Test func comingForwardTurnsItOffWhenHealthSaysNo() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        await mirror.enable()
        await mirror.settled()

        health.status = .denied
        await mirror.reconcile()

        #expect(!bench.manager.healthEnabled)
        #expect(mirror.status == .denied)
    }

    /// Review Focus 2, and the widget's button: another manager's save is not this mirror's to hear, and
    /// the app coming forward catches it up.
    @Test func comingForwardWritesWhatAnotherProcessLogged() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        await mirror.enable()
        await mirror.settled()
        let widget = Bench.manager(defaults: bench.defaults, container: bench.container)

        let id = try #require(widget.addLog(amount: 250))
        await mirror.settled()
        #expect(health.sample(of: id) == nil, "the widget's save is the widget's")

        await mirror.reconcile()
        await mirror.settled()
        #expect(health.sample(of: id) != nil)
    }

    @Test func passesAskedForWhileOneWaitsBecomeOneOfTheWiderReach() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        await mirror.enable()
        await mirror.settled()
        health.reads = 0
        health.intervals = []

        mirror.request(.recent)
        mirror.request(.recent)
        mirror.request(.all)
        await mirror.settled()

        #expect(health.reads == 1)
        #expect(health.intervals == [nil], "widened to the whole history")
    }

    /// The review's Critical: a reinstall starts an empty log, and WaterBuddy's earlier entries in Health —
    /// months old, and yesterday's — are not deleted servings. Only this log's are this log's to delete.
    @Test func turningItOnOverANewLogKeepsWhatAnEarlierInstallWrote() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let spring = HealthPlan.Sample(object: UUID(), serving: UUID(), amount: 300, at: utc(2026, 3, 1), version: 3)
        let yesterday = HealthPlan.Sample(object: UUID(), serving: UUID(), amount: 250, at: utc(2026, 10, 28), version: 1)
        health.samples = [spring, yesterday]
        let mirror = makeMirror(on: bench, health)
        let now = try #require(bench.manager.addLog(amount: 500))

        await mirror.enable()
        await mirror.settled()

        #expect(health.samples.contains(spring))
        #expect(health.samples.contains(yesterday))
        #expect(health.sample(of: now) != nil)
    }

    /// A new log's first serving, deleted, leaves Health too: the mirror saw it in the log before it went.
    @Test func deletingTheFirstServingOfANewLogReachesHealth() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        let first = try #require(bench.manager.addLog(amount: 200, at: utc(2026, 10, 28)))
        let second = try #require(bench.manager.addLog(amount: 250))
        await mirror.enable()
        await mirror.settled()

        bench.manager.deleteLog(try #require(bench.manager.logs(since: nil)?.first { $0.id == first }))
        await mirror.settled()

        #expect(health.sample(of: first) == nil)
        #expect(health.sample(of: second) != nil)
    }

    /// A serving deleted while the switch was off leaves Health when it comes back on, in the same run.
    @Test func aServingDeletedWhileOffLeavesHealthWhenItComesBackOn() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        let first = try #require(bench.manager.addLog(amount: 200, at: utc(2026, 10, 28)))
        bench.manager.addLog(amount: 250)
        await mirror.enable()
        await mirror.settled()
        mirror.disable()

        bench.manager.deleteLog(try #require(bench.manager.logs(since: nil)?.first { $0.id == first }))
        await mirror.enable()
        await mirror.settled()

        #expect(health.sample(of: first) == nil)
    }

    /// An empty log — a new install, or a store that fell back to an empty one — deletes nothing.
    @Test func aPassOverAnEmptyLogDeletesNothing() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        health.status = .allowed
        let earlier = HealthPlan.Sample(object: UUID(), serving: UUID(), amount: 250, at: today(), version: 1)
        health.samples = [earlier]
        let mirror = makeMirror(on: bench, health)

        await mirror.enable()
        await mirror.settled()

        #expect(health.samples == [earlier])
    }

    /// The review's Important 3: Health forgot the answer (Reset Location & Privacy, a restored phone) —
    /// nothing can be written, so the switch must not read on.
    @Test func comingForwardTurnsItOffWhenHealthForgetsTheAnswer() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        await mirror.enable()
        await mirror.settled()

        health.status = .notDetermined
        await mirror.reconcile()

        #expect(!bench.manager.healthEnabled)
        #expect(mirror.status == .notDetermined)
    }

    /// Review Focus 3, the second gap: the switch turned off while the pass's deletions wait — its saves
    /// must not follow.
    @Test func turningItOffWhileADeleteWaitsSavesNothing() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        health.status = .allowed
        var source = health.source()
        let delete = source.delete
        let manager = bench.manager
        // `@MainActor` stated: it turns the switch off, which only the main actor may.
        source.delete = { @MainActor objects in
            manager.healthEnabled = false
            return await delete(objects)
        }
        let mirror = HealthMirror(manager: bench.manager, source: source, calendar: utcDay, now: today)
        bench.manager.addLog(amount: 200, at: utc(2026, 10, 28))
        let gone = try #require(bench.manager.addLog(amount: 250))
        await mirror.enable()
        await mirror.settled()

        bench.manager.deleteLog(try #require(bench.manager.todaysLogs.first { $0.id == gone }))
        let late = try #require(bench.manager.addLog(amount: 300))
        await mirror.settled()

        #expect(health.sample(of: gone) == nil, "the deletion it was waiting on ran")
        #expect(health.sample(of: late) == nil, "nothing is saved after the switch went off")
    }

    @Test func theRecentPassReadsTheRecentDays() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        await mirror.enable()
        await mirror.settled()
        health.intervals = []

        mirror.request(.recent)
        await mirror.settled()

        #expect(health.intervals == [HealthPlan.Scope.recent.interval(endingAt: today(), calendar: utcDay)])
    }
}
