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
    private init() {}

    /// Chunks accumulated so far, keyed by `batchId`. A batch missing a chunk stays here
    /// indefinitely — see the file's own header comment for why that's the right default rather
    /// than a ticking timeout.
    private var pending: [UUID: [WristBatch]] = [:]

    /// Called from `WristLink.session(_:didReceiveUserInfo:)`, already hopped onto the main actor.
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
