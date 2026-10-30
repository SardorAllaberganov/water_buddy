//
//  HealthMirror.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 29/10/26.
//

import Foundation
import HealthKit
import Observation

/// Keeps a copy of the log in Apple Health — the one file that imports HealthKit (rule `70-privacy`, spec
/// `2026-10-29-apple-health-design.md`).
///
/// **Write only, Water only.** It asks Health to write Water and to read nothing; the only samples it
/// reads back are its own, which a write permission allows. No figure WaterBuddy draws comes from Health.
///
/// **Reconciled, never streamed** — `NotificationManager`'s shape. ``HealthPlan`` decides from the rows and
/// the samples WaterBuddy already wrote; this carries the answer out, one pass at a time on one
/// ``ReconcileQueue``. A pass asks for both reads before it writes anything, so a locked phone or a failed
/// read leaves Health as it was until the next pass — the app coming forward, or any later save.
///
/// **Health through ``Source`` only**, a struct of closures built by ``Source/live()`` — `PremiumStore`'s
/// and `InsightWriter`'s shape — so every decision here is tested without HealthKit (rule `85-testing`).
/// App-only, built once by `WaterBuddyApp.init()`; the widget and the watch never compile it.
@MainActor
@Observable
final class HealthMirror {

    /// What Health says of WaterBuddy's permission to write Water.
    nonisolated enum Status: Sendable, Equatable {
        case notDetermined, allowed, denied
    }

    /// Every way Health is reached. Main-actor, as `InsightWriter.Source` is: only the mirror calls these.
    struct Source {
        var isAvailable: () -> Bool
        var status: () -> Status
        /// Shows Health's sheet — write Water, read nothing — and returns once it is answered. Health's
        /// request succeeds whether or not Water was allowed, so the mirror reads ``status`` after it.
        var requestWrite: () async -> Void
        /// WaterBuddy's own Water samples around `interval` — every one for `nil` — or `nil` when Health
        /// cannot be read.
        var samples: (_ interval: DateInterval?) async -> [HealthPlan.Sample]?
        var save: (_ saves: [HealthPlan.Save]) async -> Bool
        var delete: (_ objects: Set<UUID>) async -> Bool
    }

    /// Whether this device has Health at all. Every iPhone does; Settings draws no card where it does not.
    let isAvailable: Bool

    /// What Health last said — read when the switch is tapped and whenever the app or Settings comes
    /// forward. Settings draws its refusal line from it.
    private(set) var status: Status

    @ObservationIgnored private let manager: DataManager
    @ObservationIgnored private let source: Source
    @ObservationIgnored private let calendar: Calendar
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private let passes = ReconcileQueue()
    /// The pass waiting its turn, if one is: a request while it waits widens it rather than queueing a
    /// second.
    @ObservationIgnored private var waiting: HealthPlan.Scope?
    @ObservationIgnored private var saveObserver: NSObjectProtocol?
    /// Every serving this run has read in the log — in memory only, never stored (rule `70-privacy`). A
    /// sample whose serving is gone is deleted only if its serving is here: one deleted in the app was read
    /// before it went, and an earlier install's or another iPhone's never was (``HealthPlan``).
    @ObservationIgnored private var seen: Set<UUID> = []

    init(manager: DataManager, source: Source, calendar: Calendar, now: @escaping () -> Date = Date.init) {
        self.manager = manager
        self.source = source
        self.calendar = calendar
        self.now = now
        isAvailable = source.isAvailable()
        status = source.status()
        // This manager's saves only — not another process's, not a test's beside this one.
        saveObserver = NotificationCenter.default.addObserver(
            forName: DataManager.logsDidSaveNotification, object: manager, queue: .main
        ) { [weak self] _ in
            // `queue: .main` is the main thread, so the main actor — `WristInbox`'s reasoning.
            MainActor.assumeIsolated {
                self?.request(.recent)
            }
        }
    }

    /// The product's calendar, named in the body rather than as a default argument: a default is evaluated
    /// outside the main actor, where `Calendar.waterBuddyDay` cannot be reached without a warning.
    convenience init(manager: DataManager, source: Source) {
        self.init(manager: manager, source: source, calendar: .waterBuddyDay)
    }

    convenience init(manager: DataManager) {
        self.init(manager: manager, source: .live())
    }

    deinit {
        if let saveObserver {
            NotificationCenter.default.removeObserver(saveObserver)
        }
    }

    /// The switch turning on — the one place Health's sheet is asked for (rule `70-privacy`), and only while
    /// Health has not been asked, since it shows its sheet once. Allowed, it writes the whole history.
    func enable() async {
        if source.status() == .notDetermined {
            await source.requestWrite()
        }
        status = source.status()
        manager.healthEnabled = status == .allowed
        request(.all)
    }

    /// The switch turning off: nothing more is written, and nothing is deleted (D4).
    func disable() {
        manager.healthEnabled = false
    }

    /// What Health says now — for Settings coming forward.
    func readStatus() {
        status = source.status()
    }

    /// The app coming forward: the permission read again — withdrawn in Health, or forgotten (*Reset
    /// Location & Privacy*, a restored phone), the switch goes off, since nothing could be written — and a
    /// pass over the recent days, for what was logged where this process could not write: the widget's
    /// button, Control Center, a locked phone.
    func reconcile() async {
        readStatus()
        if status != .allowed, manager.healthEnabled {
            manager.healthEnabled = false
        }
        request(.recent)
    }

    /// Asks for a pass while the switch is on. A pass already waiting takes the wider reach instead of a
    /// second joining the queue.
    func request(_ scope: HealthPlan.Scope) {
        guard manager.healthEnabled else { return }
        if let waiting {
            self.waiting = waiting.widened(by: scope)
            return
        }
        waiting = scope
        passes.enqueue { [weak self] in
            await self?.runWaitingPass()
        }
    }

    /// Returns once every pass asked for before it has run.
    func settled() async {
        await passes.settled()
    }

    private func runWaitingPass() async {
        guard let scope = waiting else { return }
        waiting = nil
        await pass(scope)
    }

    /// One pass: the log read first, then Health — and nothing written unless both answered, and only while
    /// the switch is still on after the wait (spec §3.5).
    private func pass(_ scope: HealthPlan.Scope) async {
        guard manager.healthEnabled else { return }
        let interval = scope.interval(endingAt: now(), calendar: calendar)
        guard let rows = manager.logs(since: interval?.start) else { return }
        let servings = rows.map { HealthPlan.Serving(id: $0.id, amount: $0.amount, at: $0.timestamp) }
        // Seen as soon as read, so a pass Health cannot answer still remembers them for the next.
        seen.formUnion(servings.map(\.id))
        guard let samples = await source.samples(interval), manager.healthEnabled else { return }

        let changes = HealthPlan.changes(servings: servings, samples: samples, within: interval, deletable: seen)
        if !changes.deletions.isEmpty, !(await source.delete(changes.deletions)) {
            #if DEBUG
            // Names the condition, never a sample (rule `75-diagnostics`).
            print("[WaterBuddy] Could not delete from Apple Health; the next pass tries again.")
            #endif
        }
        // Read again after the wait: a switch turned off while the deletions ran writes nothing more.
        guard manager.healthEnabled else { return }
        if !changes.saves.isEmpty, !(await source.save(changes.saves)) {
            #if DEBUG
            print("[WaterBuddy] Could not save to Apple Health; the next pass tries again.")
            #endif
        }
    }
}

extension HealthMirror.Source {

    /// A device with Health that was never asked, and writes nowhere — for a `#Preview`, the DEBUG fresh
    /// start and the UI tests' captures.
    static func silent() -> Self {
        Self(
            isAvailable: { true },
            status: { .notDetermined },
            requestWrite: {},
            samples: { _ in [] },
            save: { _ in true },
            delete: { _ in true }
        )
    }

    /// Health itself. Water in millilitres, start and end at the serving's instant, the serving's id as the
    /// sync identifier: HealthKit replaces a sample whose identifier matches and whose version is lower.
    /// The `Double`s are HealthKit's: each is made from an `Int` and rounded back to one (rule
    /// `00-workspace`).
    static func live() -> Self {
        let store = HKHealthStore()
        let water = HKQuantityType(.dietaryWater)
        let millilitres = HKUnit.literUnit(with: .milli)
        return Self(
            isAvailable: { HKHealthStore.isHealthDataAvailable() },
            status: {
                switch store.authorizationStatus(for: water) {
                case .sharingAuthorized: .allowed
                case .sharingDenied: .denied
                default: .notDetermined
                }
            },
            requestWrite: {
                // Write Water, read nothing (rule `70-privacy`). A sheet that could not be shown leaves the
                // status as it was, which is what the mirror reads next.
                try? await store.requestAuthorization(toShare: [water], read: [])
            },
            samples: { interval in
                var predicates = [HKQuery.predicateForObjects(from: HKSource.default())]
                if let interval {
                    // Loose at the edges: `HealthPlan.changes` cuts both sides to the same half-open interval.
                    predicates.append(HKQuery.predicateForSamples(withStart: interval.start, end: interval.end))
                }
                let query = HKSampleQueryDescriptor(
                    predicates: [.quantitySample(type: water, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates))],
                    sortDescriptors: []
                )
                guard let found = try? await query.result(for: store) else { return nil }
                return found.map { sample in
                    HealthPlan.Sample(
                        object: sample.uuid,
                        serving: (sample.metadata?[HKMetadataKeySyncIdentifier] as? String).flatMap(UUID.init(uuidString:)),
                        amount: Int(sample.quantity.doubleValue(for: millilitres).rounded()),
                        at: sample.startDate,
                        version: (sample.metadata?[HKMetadataKeySyncVersion] as? NSNumber)?.intValue ?? 0
                    )
                }
            },
            save: { saves in
                let samples = saves.map { save in
                    HKQuantitySample(
                        type: water,
                        quantity: HKQuantity(unit: millilitres, doubleValue: Double(save.serving.amount)),
                        start: save.serving.at,
                        end: save.serving.at,
                        metadata: [
                            HKMetadataKeySyncIdentifier: save.serving.id.uuidString,
                            HKMetadataKeySyncVersion: save.version,
                            HKMetadataKeyWasUserEntered: true,
                        ]
                    )
                }
                do {
                    try await store.save(samples)
                    return true
                } catch {
                    return false
                }
            },
            delete: { objects in
                do {
                    _ = try await store.deleteObjects(of: water, predicate: HKQuery.predicateForObjects(with: objects))
                    return true
                } catch {
                    return false
                }
            }
        )
    }
}
