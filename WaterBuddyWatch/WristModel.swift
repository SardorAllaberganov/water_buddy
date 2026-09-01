//
//  WristModel.swift
//  WaterBuddyWatch
//
//  The watch's whole state — `DataManager`'s replacement on this side, named in its own
//  `@available(watchOS, unavailable)` message (`WaterBuddy/DataManager.swift`). Holds no SwiftData
//  store: an append-only outbox of pours authored here, and a mirror of what the phone last said,
//  both in this device's own local App Group suite
//  (`docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md` §1).
//
//  Watch-only by *placement*, not by an availability marker: nothing outside `WaterBuddyWatch/`
//  references this type, so there is nothing to guard against the way `DataManager`'s three
//  entry points guard against the watch.
//

import Foundation
import Observation

@MainActor
@Observable
final class WristModel {

    static let shared = WristModel()

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let calendar: Calendar
    @ObservationIgnored private let now: () -> Date
    /// Hands new pours to the transport. Injected so tests never touch `WCSession`
    /// (`WristLinkTests` would need a paired watch to reach the real one at all).
    @ObservationIgnored private let send: ([WristPour]) -> Void

    private var storedMirror: WristMirror?
    private var storedOutbox: [WristPour]

    init(
        defaults: UserDefaults = DataManager.sharedDefaults,
        calendar: Calendar = .waterBuddyDay,
        now: @escaping () -> Date = Date.init,
        send: @escaping ([WristPour]) -> Void = WristModel.requestSend
    ) {
        self.defaults = defaults
        self.calendar = calendar
        self.now = now
        self.send = send
        self.storedOutbox = Self.readOutbox(from: defaults)
        self.storedMirror = Self.readMirror(from: defaults)
    }

    /// Pending pours not yet acked by the phone. Exposed (not just `todaysTotal`) so `WristView`
    /// can show an in-flight indicator, and so tests can assert the outbox shrinks on `apply(_:)`
    /// without depending on the arithmetic in `todaysTotal` to prove it.
    var pendingOutbox: [WristPour] {
        access(keyPath: \.pendingOutbox)
        return storedOutbox
    }

    var mirror: WristMirror? {
        access(keyPath: \.mirror)
        return storedMirror
    }

    /// `true` when the mirror's own day and the watch's own day disagree — the phone may not have
    /// rolled over yet, or the two devices are in different time zones right now. The number is
    /// still shown; this only tells the UI to soften how confidently it presents it (spec §5:
    /// "withheld and attributed, never a confident zero").
    ///
    /// Reads through `self.mirror`, not `storedMirror` directly — Observation tracks a computed
    /// property's dependencies transitively through the tracked properties its getter reads, so
    /// this needs no `access(keyPath:)`/`withMutation(keyPath:)` of its own: it changes exactly
    /// when `mirror` does, because that's the only tracked state it touches.
    var isMirrorStale: Bool {
        guard let mirror else { return false }
        return !calendar.isDate(mirror.phoneDayStart, inSameDayAs: now())
    }

    /// The mirror's own total, plus whatever's still in the outbox waiting to be acked. Reads
    /// through `self.mirror` and `self.pendingOutbox` for the same reason `isMirrorStale` does —
    /// no separate tracking of its own; it changes exactly when either of those does, which is
    /// what keeps this from ever double-counting a pour the phone has folded but not yet acked
    /// (see this task's own header note: `apply(_:)` moves both together, synchronously).
    var todaysTotal: Int {
        let base = mirror?.currentWater ?? 0
        return base + WristPlan.todaysTotal(from: pendingOutbox, now: now(), calendar: calendar)
    }

    /// Records a pour the user just made, and hands it to the transport. Non-positive amounts are
    /// rejected — the same floor `DataManager.addLog` holds, even though nothing here shares its
    /// code (rule `20-state`'s clamp-on-the-way-in, restated for the second writer this design
    /// introduces — see spec §7's "one honest weakening").
    func pour(amount: Int) {
        guard amount > 0 else { return }
        let pour = WristPour(id: UUID(), amount: amount, at: now())
        withMutation(keyPath: \.pendingOutbox) {
            storedOutbox.append(pour)
        }
        persistOutbox()
        send([pour])
    }

    /// The one entry point for a fresh `WristMirror`: replaces it and retires every outbox pour the
    /// phone has now acked, together, in one synchronous method with no suspension point between
    /// the two — so nothing reads a torn mix of the two.
    func apply(_ mirror: WristMirror) {
        withMutation(keyPath: \.mirror) {
            storedMirror = mirror
        }
        withMutation(keyPath: \.pendingOutbox) {
            storedOutbox.removeAll { mirror.acked.contains($0.id) }
        }
        persistOutbox()
        persistMirror()
    }

    // MARK: - Persistence

    private func persistOutbox() {
        guard let data = try? JSONEncoder().encode(storedOutbox) else { return }
        defaults.set(data, forKey: DataManager.Key.wristOutbox)
    }

    private func persistMirror() {
        guard let mirror = storedMirror, let data = try? JSONEncoder().encode(mirror) else { return }
        defaults.set(data, forKey: DataManager.Key.wristMirror)
    }

    private static func readOutbox(from defaults: UserDefaults) -> [WristPour] {
        guard let data = defaults.data(forKey: DataManager.Key.wristOutbox),
              let outbox = try? JSONDecoder().decode([WristPour].self, from: data) else { return [] }
        return outbox
    }

    private static func readMirror(from defaults: UserDefaults) -> WristMirror? {
        guard let data = defaults.data(forKey: DataManager.Key.wristMirror) else { return nil }
        return try? JSONDecoder().decode(WristMirror.self, from: data)
    }

    /// The production default for `send:`. `pour(amount:)`'s own tests inject their own `send`
    /// (`WristModelTests.pouringAppendsToTheOutboxAndCallsSend` and its siblings), so this wiring
    /// has no behavioural test of its own beyond Task 12's `WristLinkChunkingTests` — the same split
    /// every WCSession-facing seam in this design draws between "the pure logic, tested" and "the
    /// one line that hands it to the SDK, verified by inspection and the simulator run below."
    ///
    /// `nonisolated` — like `DataManager`'s own `requestWidgetReload`/`requestReminderReschedule`/
    /// `requestWristPublish` (rule `43-concurrency`) — so this reference stays a plain non-isolated
    /// closure at the `send:` parameter's default-value site. Without it, `WristModel` being
    /// `@MainActor` makes this a `@MainActor` function value implicitly, and using it to default a
    /// `([WristPour]) -> Void` parameter drops that isolation silently — a warning today, a Swift 6
    /// error tomorrow.
    nonisolated static func requestSend(_ pours: [WristPour]) {
        WristLink.send(pours)
    }
}
