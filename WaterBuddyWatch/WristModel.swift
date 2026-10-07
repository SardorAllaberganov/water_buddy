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
#if canImport(WidgetKit)
import WidgetKit
#endif

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
    /// Reloads the complication's timeline whenever the store it reads changes — the watch's twin of
    /// `DataManager`'s `reloadWidgets`, injected so tests never reach `WidgetCenter`
    /// (`docs/superpowers/specs/2026-10-07-complication-current-design.md` §4.1).
    @ObservationIgnored private let reloadComplication: () -> Void

    private var storedMirror: WristMirror?
    private var storedOutbox: [WristPour]

    /// Registered against `WristLink.didReceiveMirrorNotification` here in `init`, not lazily on
    /// first `apply(_:)` — see that notification's own DocC in `DataManager.swift` (Task 16) for why
    /// `WristLink.session(_:didReceiveApplicationContext:)` posts rather than naming `WristModel`
    /// directly: `WaterBuddyWatchWidget` also compiles `DataManager.swift` and has no access to this
    /// file at all.
    @ObservationIgnored private var mirrorObserver: NSObjectProtocol?

    init(
        defaults: UserDefaults = DataManager.sharedDefaults,
        calendar: Calendar = .waterBuddyDay,
        now: @escaping () -> Date = Date.init,
        send: @escaping ([WristPour]) -> Void = WristModel.requestSend,
        reloadComplication: @escaping () -> Void = WristModel.requestComplicationReload
    ) {
        self.defaults = defaults
        self.calendar = calendar
        self.now = now
        self.send = send
        self.reloadComplication = reloadComplication
        self.storedOutbox = Self.readOutbox(from: defaults)
        self.storedMirror = Self.readMirror(from: defaults)
        mirrorObserver = NotificationCenter.default.addObserver(
            forName: WristLink.didReceiveMirrorNotification, object: nil, queue: .main
        ) { [weak self] note in
            guard let mirror = note.userInfo?["mirror"] as? WristMirror else { return }
            // `queue: .main` guarantees the main thread, which is the main actor — the same
            // reasoning `WristInbox.init()` documents for its own observer.
            MainActor.assumeIsolated {
                self?.apply(mirror)
            }
        }
    }

    deinit {
        if let mirrorObserver {
            NotificationCenter.default.removeObserver(mirrorObserver)
        }
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

    /// The goal the screen draws against: the phone's when a mirror has arrived, and
    /// ``DataManager/defaultDailyGoal`` before it ever has.
    ///
    /// The fallback is not a guess dressed as a fact. It is the identical figure the phone
    /// materialises into its own suite for a fresh install (`DataManager.init`), so the two devices
    /// already agree on it before they have ever spoken — and the moment a real mirror lands, this
    /// switches to the phone's own number with no reconciliation needed, because nothing was ever
    /// *stored* here. `WristView.attribution(mirror:now:strings:)` names which of the two is on
    /// screen, so the number is attributed rather than asserted (spec §5's "withheld and
    /// attributed, never a confident zero", read across to the never-synced case).
    ///
    /// Reads through `self.mirror` for the same reason `isMirrorStale` and `todaysTotal` do — it
    /// needs no tracking of its own, because `mirror` is the only tracked state it touches.
    var displayGoal: Int {
        mirror?.dailyGoal ?? DataManager.defaultDailyGoal
    }

    /// The language the watch draws in: the phone's own in-app choice, carried on the mirror
    /// (`docs/superpowers/specs/2026-10-06-watch-localization-design.md` §4.1).
    ///
    /// `nil` on the wire — the phone set to *Follow device* — and no mirror at all, before the first
    /// sync, both resolve to ``AppLanguage/system``: this watch's own `Bundle.main`, its own system
    /// language. "Follow device", read on the wrist, means *this* device.
    ///
    /// **Resolved through the phone's own `AppLanguage(code:)`**, so an unrecognised code — a
    /// language a newer phone ships and this build does not, or anything corrupt — falls back to the
    /// watch's own language and says so under `#if DEBUG` (rule `70-privacy`), rather than reaching
    /// for a bundle that isn't there.
    ///
    /// **A read, never a write.** Nothing new is stored: `languageCode` already rides inside the
    /// persisted mirror, which is why the choice survives a relaunch. This is not
    /// `DataManager.language` and never touches `Key.language` — one writer per store (rule
    /// `20-state`). Like `displayGoal`, it needs no tracking of its own: it changes exactly when
    /// `mirror` does.
    var language: AppLanguage {
        AppLanguage(code: mirror?.languageCode)
    }

    /// `true` when the mirror's own day and the watch's own day disagree, compared on the watch's
    /// calendar — the phone may not have rolled over yet, or the two devices are in different time
    /// zones right now.
    ///
    /// **This flag does not decide what is counted**, and nothing reads it yet. `todaysTotal` asks
    /// the sharper question — has the phone's own day *ended*? — because under time-zone skew this
    /// comparison calls a minute-old mirror stale, and zeroing on it is exactly the false zero spec §5
    /// rules out (spec §17). What it remains is a signal the UI could use to soften how a number is
    /// presented; wiring it into the attribution line is a separate decision.
    ///
    /// Reads through `self.mirror`, not `storedMirror` directly — Observation tracks a computed
    /// property's dependencies transitively through the tracked properties its getter reads, so
    /// this needs no `access(keyPath:)`/`withMutation(keyPath:)` of its own: it changes exactly
    /// when `mirror` does, because that's the only tracked state it touches.
    var isMirrorStale: Bool {
        guard let mirror else { return false }
        return !calendar.isDate(mirror.phoneDayStart, inSameDayAs: now())
    }

    /// The phone's total until the phone's own day ends, plus whatever's still in the outbox waiting
    /// to be acked — decided by `WristPlan.todaysTotal(mirror:outbox:now:calendar:)`, the same
    /// function the complication reads, so the screen and the face cannot disagree (spec §17).
    ///
    /// Reads through `self.mirror` and `self.pendingOutbox` for the same reason `isMirrorStale` does —
    /// no separate tracking of its own; it changes exactly when either of those does, which is what
    /// keeps this from ever double-counting a pour the phone has folded but not yet acked (see this
    /// task's own header note: `apply(_:)` moves both together, synchronously). The phone's day
    /// ending is not a change Observation can see: `WristView` re-reads this on its 30-second clock,
    /// and the complication schedules a timeline entry for it.
    var todaysTotal: Int {
        WristPlan.todaysTotal(mirror: mirror, outbox: pendingOutbox, now: now(), calendar: calendar)
    }

    /// Records a pour the user just made, and hands the transport the **whole current outbox** —
    /// not just this pour. Non-positive amounts are rejected — the same floor `DataManager.addLog`
    /// holds, even though nothing here shares its code (rule `20-state`'s clamp-on-the-way-in,
    /// restated for the second writer this design introduces — see spec §7's "one honest
    /// weakening").
    ///
    /// **Sending only `[pour]` would make the outbox a write-only log, not the retry queue the
    /// rest of the design already assumes it is.** `WristLink.chunk(_:batchId:)`'s multi-chunk
    /// path, `WristInbox.reassemble`'s promise that a batch pinned to an unrecognised
    /// `schemaVersion` "will eventually retry," and a pour tapped while `WCSession` isn't yet
    /// activated all depend on *something* re-sending an already-queued pour later — and nothing
    /// else in this design ever does. Sending the whole outbox here is what makes every earlier
    /// un-acked pour ride along on the next tap, cheaply, with no separate retry timer or
    /// reachability observer. `WristLink.send(_:)` re-chunks and the phone's applied-ledger
    /// conjunction guard (`DataManager.ingest(_:)`) makes re-sending an already-applied pour a
    /// no-op, so resending is always safe.
    ///
    /// The face is reloaded once the outbox is persisted, because it reads the same outbox — so the
    /// ring moves with the tap, not on a timer.
    func pour(amount: Int) {
        guard amount > 0 else { return }
        let pour = WristPour(id: UUID(), amount: amount, at: now())
        withMutation(keyPath: \.pendingOutbox) {
            storedOutbox.append(pour)
        }
        persistOutbox()
        reloadComplication()
        send(storedOutbox)
    }

    /// The one entry point for a fresh `WristMirror`, from either lane — the application context or a
    /// complication push (`docs/superpowers/specs/2026-10-07-complication-current-design.md` §4.5).
    /// Replaces the mirror held and retires every outbox pour the phone has now acked, together, in
    /// one synchronous method with no suspension point between the two — so nothing reads a torn mix
    /// of the two.
    ///
    /// **Never older.** A mirror composed before the one held is set aside (``isSuperseded(_:)``): a
    /// superseded push can land after the push that replaced it, and the context re-read at activation
    /// can lag a push, and taking either would put the face back a drink. A tie is taken — the same
    /// composition arrives by both lanes.
    ///
    /// **The face is reloaded only on news,** or when a pour is retired. A republish of unchanged state
    /// still moves "synced at" on the screen, so it is taken; but a reload from the background counts
    /// against the face's daily budget, and this one would change nothing it draws.
    func apply(_ mirror: WristMirror) {
        guard !isSuperseded(mirror) else { return }
        let isNews = mirror.isNews(since: storedMirror)
        let pendingBefore = storedOutbox.count
        withMutation(keyPath: \.mirror) {
            storedMirror = mirror
        }
        withMutation(keyPath: \.pendingOutbox) {
            storedOutbox.removeAll { mirror.acked.contains($0.id) }
        }
        persistOutbox()
        persistMirror()
        if isNews || storedOutbox.count != pendingBefore {
            reloadComplication()
        }
    }

    /// Whether the mirror held was composed after `mirror` — unless the one held is stamped more than
    /// ``clockSkewAllowance`` ahead of this watch's own clock. That means a clock was set back after it
    /// was composed: the phone's stamps no longer say which came last, and refusing everything older
    /// would freeze the face for as long as the clock was moved.
    private func isSuperseded(_ mirror: WristMirror) -> Bool {
        guard let held = storedMirror, mirror.composedAt < held.composedAt else { return false }
        return held.composedAt <= now().addingTimeInterval(Self.clockSkewAllowance)
    }

    /// How far a mirror's stamp may run ahead of this watch's clock and still order it. Paired devices'
    /// clocks differ by far less, and a clock set back by less than this stalls the watch no longer
    /// than this.
    private static let clockSkewAllowance: TimeInterval = 60

    // MARK: - Persistence

    private func persistOutbox() {
        guard let data = try? JSONEncoder().encode(storedOutbox) else { return }
        defaults.set(data, forKey: DataManager.Key.wristOutbox)
    }

    private func persistMirror() {
        guard let mirror = storedMirror else { return }
        do {
            defaults.set(try JSONEncoder().encode(mirror), forKey: DataManager.Key.wristMirror)
        } catch {
            // Rule `75-diagnostics`: every fallback in this product announces itself. A silent
            // `try?` here meant a watch that had genuinely received a mirror could still come back
            // from a relaunch showing the pre-sync screen, with nothing anywhere saying why.
            #if DEBUG
            print("[WaterBuddy] Could not persist the wrist mirror: \(error.localizedDescription)")
            #endif
        }
    }

    private static func readOutbox(from defaults: UserDefaults) -> [WristPour] {
        guard let data = defaults.data(forKey: DataManager.Key.wristOutbox),
              let outbox = try? JSONDecoder().decode([WristPour].self, from: data) else { return [] }
        return outbox
    }

    private static func readMirror(from defaults: UserDefaults) -> WristMirror? {
        // An absent key is the ordinary never-synced case, not a failure — only a *present but
        // undecodable* value is worth announcing (rule `75-diagnostics`).
        guard let data = defaults.data(forKey: DataManager.Key.wristMirror) else { return nil }
        do {
            return try JSONDecoder().decode(WristMirror.self, from: data)
        } catch {
            #if DEBUG
            print("[WaterBuddy] Stored wrist mirror could not be decoded: \(error.localizedDescription)")
            #endif
            return nil
        }
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

    /// The production default for `reloadComplication:` — `nonisolated` for ``requestSend(_:)``'s
    /// reason: a `@MainActor` function value defaulting a plain closure parameter drops its isolation
    /// silently.
    nonisolated static func requestComplicationReload() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}
