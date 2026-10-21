//
//  PremiumStoreTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 21/10/26.
//

import Foundation
import StoreKitTest
import Testing
@testable import WaterBuddy

// MARK: - Fixtures

private let now = ISO8601DateFormatter().date(from: "2026-10-21T12:00:00Z")!
private let later = now.addingTimeInterval(3_600)

private let yearlyPlan = PremiumAccess.Plan(
    id: PremiumAccess.yearlyID, kind: .yearly, price: "$19.99",
    trial: PremiumAccess.Plan.Period(value: 1, unit: .week)
)
private let lifetimePlan = PremiumAccess.Plan(id: PremiumAccess.lifetimeID, kind: .lifetime, price: "$39.99", trial: nil)

private let heldLifetime = PremiumAccess.Entitlement(productID: PremiumAccess.lifetimeID, expires: nil, revoked: nil)
private let heldYearly = PremiumAccess.Entitlement(productID: PremiumAccess.yearlyID, expires: later, revoked: nil)

private struct Refused: Error {}

/// StoreKit as a test answers it: what is held, the plans, what a purchase says — and a count of
/// every call, so a test sees what the store asked for. Every closure is a plain one: ``PremiumStore``
/// calls them on the main actor (plan P2).
@MainActor
private final class FakeAppStore {
    var held: [PremiumAccess.Entitlement] = []
    var plans: Result<[PremiumAccess.Plan], any Error> = .success([yearlyPlan, lifetimePlan])
    var outcome: Result<PremiumStore.Outcome, any Error> = .success(.bought)
    /// What a successful purchase leaves held, as the real one's finished transaction would.
    var boughtLeaves: [PremiumAccess.Entitlement] = [heldLifetime]
    var restoreFails = false
    /// Set, a purchase waits here until the test resumes it.
    var holdsPurchase = false
    var gate: CheckedContinuation<Void, Never>?
    private(set) var bought: [String] = []
    private(set) var restores = 0
    private(set) var manages = 0
    let (updates, update) = AsyncStream<Void>.makeStream()

    var source: PremiumStore.Source {
        PremiumStore.Source(
            entitlements: { self.held },
            updates: { self.updates },
            plans: { try self.plans.get() },
            buy: { productID in
                self.bought.append(productID)
                if self.holdsPurchase {
                    await withCheckedContinuation { self.gate = $0 }
                }
                let outcome = try self.outcome.get()
                if outcome == .bought { self.held = self.boughtLeaves }
                return outcome
            },
            restore: {
                self.restores += 1
                if self.restoreFails { throw Refused() }
            },
            manage: { self.manages += 1 }
        )
    }
}

/// Gives the store's listener its turns, until `condition` holds or a thousand have passed.
@MainActor
private func settle(_ condition: () -> Bool) async {
    for _ in 0..<1_000 where !condition() {
        await Task.yield()
    }
}

// MARK: - The store

@MainActor
struct PremiumStoreTests {

    @Test func theStateWaitsForItsFirstRead() async {
        let fake = FakeAppStore()
        let store = PremiumStore(source: fake.source, now: { now })
        #expect(store.state == .checking)
        await store.refresh()
        #expect(store.state == .known(.free))
    }

    @Test func aLifetimePurchaseHeldReadsPremium() async {
        let fake = FakeAppStore()
        fake.held = [heldLifetime]
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        #expect(store.state == .known(.lifetime))
        #expect(store.state.status?.isPremium == true)
    }

    @Test func aVerifiedPurchaseIsBoughtAndReadsPremium() async {
        let fake = FakeAppStore()
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        await store.buy(lifetimePlan)
        #expect(fake.bought == [PremiumAccess.lifetimeID])
        #expect(store.purchase == .bought)
        #expect(store.state == .known(.lifetime))
    }

    @Test func anUnverifiedPurchaseFailsAndStaysFree() async {
        let fake = FakeAppStore()
        fake.outcome = .success(.unverified)
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        await store.buy(yearlyPlan)
        #expect(store.purchase == .failed)
        #expect(store.state == .known(.free))
    }

    @Test func aPendingPurchaseIsPending() async {
        let fake = FakeAppStore()
        fake.outcome = .success(.pending)
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        await store.buy(yearlyPlan)
        #expect(store.purchase == .pending)
        #expect(store.state == .known(.free))
    }

    @Test func aCancelledPurchaseChangesNothing() async {
        let fake = FakeAppStore()
        fake.outcome = .success(.cancelled)
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        await store.buy(yearlyPlan)
        #expect(store.purchase == .idle)
        #expect(store.state == .known(.free))
    }

    @Test func aPurchaseThatThrowsFails() async {
        let fake = FakeAppStore()
        fake.outcome = .failure(Refused())
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        await store.buy(yearlyPlan)
        #expect(store.purchase == .failed)
        #expect(store.state == .known(.free))
    }

    /// Review Focus 1.
    @Test func aSecondTapWhileBuyingBuysNothing() async {
        let fake = FakeAppStore()
        fake.holdsPurchase = true
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        let first = Task { await store.buy(lifetimePlan) }
        await settle { fake.gate != nil }
        #expect(store.purchase == .buying)
        await store.buy(lifetimePlan)
        #expect(fake.bought.count == 1)
        fake.gate?.resume()
        await first.value
        #expect(store.purchase == .bought)
        #expect(fake.bought.count == 1)
    }

    @Test func aRefundArrivingAsAnUpdateReadsFree() async {
        let fake = FakeAppStore()
        fake.held = [heldLifetime]
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        #expect(store.state == .known(.lifetime))
        fake.held = []
        fake.update.yield()
        await settle { store.state == .known(.free) }
        #expect(store.state == .known(.free))
    }

    /// Review Focus 2.
    @Test func anApprovalArrivingAsAnUpdateReadsPremium() async {
        let fake = FakeAppStore()
        fake.outcome = .success(.pending)
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        await store.buy(yearlyPlan)
        #expect(store.purchase == .pending)
        fake.held = [heldYearly]
        fake.update.yield()
        await settle { store.state == .known(.yearly(until: later)) }
        #expect(store.state == .known(.yearly(until: later)))
    }

    @Test func plansLoadBoth() async {
        let fake = FakeAppStore()
        let store = PremiumStore(source: fake.source, now: { now })
        #expect(store.plans == .notLoaded)
        await store.loadPlans()
        #expect(store.plans == .loaded([yearlyPlan, lifetimePlan]))
    }

    /// Review Focus 4.
    @Test func oneProductMissingIsUnavailable() async {
        let fake = FakeAppStore()
        fake.plans = .success([yearlyPlan])
        let store = PremiumStore(source: fake.source, now: { now })
        await store.loadPlans()
        #expect(store.plans == .unavailable)
    }

    @Test func aFailedLoadIsUnavailableAndTryingAgainRecovers() async {
        let fake = FakeAppStore()
        fake.plans = .failure(Refused())
        let store = PremiumStore(source: fake.source, now: { now })
        await store.loadPlans()
        #expect(store.plans == .unavailable)
        fake.plans = .success([yearlyPlan, lifetimePlan])
        await store.loadPlans()
        #expect(store.plans == .loaded([yearlyPlan, lifetimePlan]))
    }

    /// Review Focus 3.
    @Test func openingTheSheetAgainForgetsTheLastFailure() async {
        let fake = FakeAppStore()
        fake.outcome = .failure(Refused())
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        await store.buy(yearlyPlan)
        #expect(store.purchase == .failed)
        await store.prepare()
        #expect(store.purchase == .idle)
        #expect(store.plans == .loaded([yearlyPlan, lifetimePlan]))
    }

    @Test func restoreAsksTheAppStoreThenReads() async {
        let fake = FakeAppStore()
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        fake.held = [heldLifetime]
        await store.restore()
        #expect(fake.restores == 1)
        #expect(store.state == .known(.lifetime))
    }

    @Test func aFailedRestoreStillReads() async {
        let fake = FakeAppStore()
        fake.restoreFails = true
        fake.held = [heldYearly]
        let store = PremiumStore(source: fake.source, now: { now })
        await store.restore()
        #expect(fake.restores == 1)
        #expect(store.state == .known(.yearly(until: later)))
    }

    @Test func manageOpensApplesSheet() async {
        let fake = FakeAppStore()
        let store = PremiumStore(source: fake.source, now: { now })
        await store.manage()
        #expect(fake.manages == 1)
    }

    /// Review Focus 5, through the store's own clock. Named apart from `PremiumAccessTests`' case:
    /// no name is used twice across suites (rule `85-testing`).
    @Test func anExpiryPassingWhileTheAppRunsReadsFreeOnTheStoresNextRead() async {
        let fake = FakeAppStore()
        fake.held = [heldYearly]
        var clock = now
        let store = PremiumStore(source: fake.source, now: { clock })
        await store.refresh()
        #expect(store.state == .known(.yearly(until: later)))
        clock = later.addingTimeInterval(1)
        await store.refresh()
        #expect(store.state == .known(.free))
    }
}

// MARK: - The live source, against the local configuration

private final class TestBundle {}

/// StoreKit itself, through ``PremiumStore/Source/live()``, against
/// `WaterBuddyTests/WaterBuddy.storekit` — never the App Store or its sandbox (rule `85-testing`).
/// Serialized: a session is the simulator's own state, shared by every test in the run. A minute's
/// limit: the first purchase on a freshly booted simulator once went to the sandbox and waited on a
/// sign-in alert, and a test that waits forever holds the whole gate.
@MainActor
@Suite(.serialized, .timeLimit(.minutes(1)))
struct StoreKitSessionTests {

    private func withSession(_ body: (SKTestSession) async throws -> Void) async throws {
        let url = try #require(Bundle(for: TestBundle.self).url(forResource: "WaterBuddy", withExtension: "storekit"))
        let session = try SKTestSession(contentsOf: url)
        session.resetToDefaultState()
        session.disableDialogs = true
        session.clearTransactions()
        defer { session.clearTransactions() }
        try await body(session)
    }

    /// What StoreKit holds once it has caught up with a change the session made — a refund lands a
    /// beat later (measured on iOS 27.0: still held at 100 ms, gone by 300). Reads for up to five
    /// seconds, and answers whatever it last read.
    private func status(
        settlingOn expected: PremiumAccess.Status,
        from source: PremiumStore.Source
    ) async throws -> PremiumAccess.Status {
        var status = PremiumAccess.resolve(await source.entitlements(), now: .now)
        for _ in 0..<50 where status != expected {
            try await Task.sleep(for: .milliseconds(100))
            status = PremiumAccess.resolve(await source.entitlements(), now: .now)
        }
        return status
    }

    @Test func bothProductsLoadAndTheYearlyOffersAFreeWeek() async throws {
        try await withSession { _ in
            let plans = try await PremiumStore.Source.live().plans()
            #expect(plans.map(\.id) == PremiumAccess.productIDs)
            #expect(plans.map(\.kind) == [.yearly, .lifetime])
            #expect(plans.allSatisfy { !$0.price.isEmpty })
            #expect(plans.first?.trial == PremiumAccess.Plan.Period(value: 1, unit: .week))
            #expect(plans.last?.trial == nil)
        }
    }

    /// Plan P5's premise: the local configuration's yearly plan is a year.
    @Test func theConfigurationsYearlyRenewsEveryYear() throws {
        let url = try #require(Bundle(for: TestBundle.self).url(forResource: "WaterBuddy", withExtension: "storekit"))
        let text = try String(contentsOf: url, encoding: .utf8)
        #expect(text.contains("\"recurringSubscriptionPeriod\" : \"P1Y\""))
    }

    @Test func aBoughtYearlyReadsPremium() async throws {
        try await withSession { _ in
            let source = PremiumStore.Source.live()
            let outcome = try await source.buy(PremiumAccess.yearlyID)
            #expect(outcome == .bought)
            let status = PremiumAccess.resolve(await source.entitlements(), now: .now)
            guard case .yearly(let until) = status else {
                Issue.record("a bought yearly read \(status)")
                return
            }
            #expect(until > .now)
        }
    }

    @Test func aBoughtLifetimeReadsPremiumForGood() async throws {
        try await withSession { _ in
            let source = PremiumStore.Source.live()
            let outcome = try await source.buy(PremiumAccess.lifetimeID)
            #expect(outcome == .bought)
            #expect(PremiumAccess.resolve(await source.entitlements(), now: .now) == .lifetime)
        }
    }

    /// **Disabled, and kept in sight for the owner.** StoreKit testing cannot end a free trial early:
    /// after `expireSubscription`, `Transaction.currentEntitlements` still answered the trial's
    /// transaction with its first expiry for three seconds and more, a second purchase answered
    /// *bought* and changed nothing, and a second expiry threw `SKServiceErrorDomain` 2 (measured on
    /// iOS 27.0, 2026-10-21). In the App Store a period ends on its own expiry, which
    /// `PremiumAccess.resolve` reads (`aYearlyEndingAtThisInstantIsOver`, `aYearlyThatEndedIsOver`,
    /// both `anExpiryPassing…` cases) and the live mapping carries (`aBoughtYearlyReadsPremium`).
    @Test(.disabled("StoreKit testing does not end a free trial early in current entitlements (2026-10-21)"))
    func anExpiredYearlyReadsFree() async throws {
        try await withSession { session in
            let source = PremiumStore.Source.live()
            let outcome = try await source.buy(PremiumAccess.yearlyID)
            #expect(outcome == .bought)
            try session.expireSubscription(productIdentifier: PremiumAccess.yearlyID)
            let status = try await status(settlingOn: .free, from: source)
            #expect(status == .free)
        }
    }

    @Test func aRefundedLifetimeReadsFree() async throws {
        try await withSession { session in
            let source = PremiumStore.Source.live()
            let outcome = try await source.buy(PremiumAccess.lifetimeID)
            #expect(outcome == .bought)
            let bought = try #require(session.allTransactions().first { $0.productIdentifier == PremiumAccess.lifetimeID })
            try session.refundTransaction(identifier: bought.identifier)
            let status = try await status(settlingOn: .free, from: source)
            #expect(status == .free)
        }
    }

    /// Plan P11: eligibility is StoreKit's answer.
    @Test func aTrialUsedOnceIsNotOfferedAgain() async throws {
        try await withSession { session in
            let source = PremiumStore.Source.live()
            let outcome = try await source.buy(PremiumAccess.yearlyID)
            #expect(outcome == .bought)
            try session.expireSubscription(productIdentifier: PremiumAccess.yearlyID)
            let plans = try await source.plans()
            #expect(plans.first?.kind == .yearly)
            #expect(plans.first?.trial == nil)
        }
    }

    @Test func anAskToBuyIsPendingUntilApproved() async throws {
        try await withSession { session in
            session.askToBuyEnabled = true
            let store = PremiumStore(source: .live())
            await store.refresh()
            await store.buy(PremiumAccess.Plan(id: PremiumAccess.lifetimeID, kind: .lifetime, price: "", trial: nil))
            #expect(store.purchase == .pending)
            let asked = try #require(session.allTransactions().first { $0.pendingAskToBuyConfirmation })
            try session.approveAskToBuyTransaction(identifier: asked.identifier)
            for _ in 0..<50 where store.state != .known(.lifetime) {
                try await Task.sleep(for: .milliseconds(100))
            }
            #expect(store.state == .known(.lifetime))
        }
    }
}
