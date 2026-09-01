//
//  WristInbox.swift
//  WaterBuddy
//
//  The chunk-reassembly buffer for pours arriving from the watch. App-only: it is the only thing in
//  this design that calls `DataManager.shared.ingest(_:)`, and only the phone ever does that.
//
//  Physically sits in `WaterBuddy/` but is **not** part of the watch's exception set — nothing on
//  the watch ever reads this file (`docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md`
//  §7: "a watch target's own exception set is a different contract ... and the watch's files are
//  invisible to the widget" — the same boundary holds in the other direction here).
//

#if canImport(WatchConnectivity)
import Foundation

@MainActor
final class WristInbox {

    static let shared = WristInbox()

    /// Registered against `WristLink.didReceiveBatchNotification` here in `init`, not lazily on
    /// first `receive(_:)` — `WristLink.session(_:didReceiveUserInfo:)` posts that notification
    /// rather than naming `WristInbox` directly (see the notification's own DocC in
    /// `DataManager.swift` for why: this file is deliberately absent from
    /// `WaterBuddyWidgetExtension`'s membership exceptions, and `DataManager.swift` — where
    /// `WristLink` lives — is not). That means this singleton must be touched once, before any batch
    /// can arrive, for its observer to be listening in time: the app's entry point wiring
    /// `WristLink.live.activate()` (Task 13) must also reach `WristInbox.shared` at launch.
    private var batchObserver: NSObjectProtocol?

    private init() {
        batchObserver = NotificationCenter.default.addObserver(
            forName: WristLink.didReceiveBatchNotification, object: nil, queue: .main
        ) { [weak self] note in
            guard let batch = note.userInfo?["batch"] as? WristBatch else { return }
            // `queue: .main` guarantees the main thread, which is the main actor — the same
            // reasoning `DataManager.startObservingDayChanges()` documents for its own observers.
            MainActor.assumeIsolated {
                self?.receive(batch)
            }
        }
    }

    deinit {
        if let batchObserver {
            NotificationCenter.default.removeObserver(batchObserver)
        }
    }

    /// Chunks accumulated so far, keyed by `batchId`. A batch missing a chunk stays here
    /// indefinitely — see the file's own header comment for why that's the right default rather
    /// than a ticking timeout.
    private var pending: [UUID: [WristBatch]] = [:]

    /// Folds one chunk into the buffer for its batch, and — once every chunk of that batch has
    /// arrived — ingests the reassembled pours. Reached either directly (a test) or via
    /// `WristLink.didReceiveBatchNotification`, already hopped onto the main actor either way.
    func receive(_ chunk: WristBatch) {
        pending[chunk.batchId, default: []].append(chunk)
        guard let pours = Self.reassemble(pending[chunk.batchId] ?? []) else { return }
        pending.removeValue(forKey: chunk.batchId)

        let folded = DataManager.shared.ingest(pours)
        if folded > 0 {
            DataManager.requestWristPublish()
        }
    }

    /// The pure half: given every chunk accumulated for **one** batch, decide whether it's complete
    /// and — if so — return its pours in `chunkIndex` order. `nil` means "not yet, or never will
    /// be" (a stale `schemaVersion` is folded into the same `nil`, rather than a separate case,
    /// because the caller's response is identical either way: keep waiting for a batch the sender
    /// will eventually retry at a version this binary understands).
    ///
    /// `nonisolated static` and free of `DataManager` on purpose — this is the half worth testing
    /// without a `DataManager.shared` a test fixture cannot swap out (rule `85-testing`).
    nonisolated static func reassemble(_ chunks: [WristBatch]) -> [WristPour]? {
        guard let batchId = chunks.first?.batchId else { return nil }
        let sameBatch = chunks.filter { $0.batchId == batchId && $0.schemaVersion == WristBatch.currentSchemaVersion }
        guard let expectedCount = sameBatch.first?.chunkCount, sameBatch.count == expectedCount else { return nil }
        return sameBatch
            .sorted { $0.chunkIndex < $1.chunkIndex }
            .flatMap(\.pours)
    }
}
#endif
