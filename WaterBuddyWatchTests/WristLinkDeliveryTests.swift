//
//  WristLinkDeliveryTests.swift
//  WaterBuddyWatchTests
//

import Foundation
import Testing
@testable import WaterBuddyWatch

/// The condition counts its own checks through a reference box, so a closure handed to a `Task` can
/// share the tally (rule `85-testing`).
private final class Checks: @unchecked Sendable {
    var count = 0
}

/// The pure half of `WristLink.waitForPendingDelivery()`, which holds a background wake open until
/// the session has delivered (`docs/superpowers/specs/2026-10-07-complication-current-design.md`
/// §4.2) — testable with no `WCSession`, the split `WristLinkChunkingTests` already draws on the
/// phone. Not `@MainActor`: `poll` is `nonisolated`, and nothing here needs the main actor.
struct WristLinkDeliveryTests {

    @Test
    func waitingEndsAsSoonAsDeliveryIsDone() async {
        let checks = Checks()
        let delivered = await WristLink.poll(
            until: { checks.count += 1; return checks.count == 3 }, every: .milliseconds(1), atMost: 10
        )
        #expect(delivered)
        #expect(checks.count == 3, "no check after the one that found delivery done")
    }

    /// Bounded by construction: a `hasContentPending` that never clears cannot hold a wake open on
    /// its own until the system steps in.
    @Test(.timeLimit(.minutes(1)))
    func waitingGivesUpAfterItsLastCheck() async {
        let checks = Checks()
        let delivered = await WristLink.poll(
            until: { checks.count += 1; return false }, every: .milliseconds(1), atMost: 5
        )
        #expect(!delivered)
        #expect(checks.count == 5)
    }

    /// The system cancels a background task that runs out of time, and a closure still running past
    /// that risks the app being terminated. So a cancelled wait ends at once rather than sleeping on.
    @Test(.timeLimit(.minutes(1)))
    func waitingEndsWhenTheTaskIsCancelled() async {
        let checks = Checks()
        let wait = Task {
            await WristLink.poll(until: { checks.count += 1; return false }, every: .seconds(60), atMost: 10)
        }
        wait.cancel()
        #expect(await wait.value == false)
        #expect(checks.count == 1, "one check, then the cancelled sleep ends the wait")
    }
}
