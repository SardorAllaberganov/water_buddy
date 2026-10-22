//
//  PremiumStore.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 21/10/26.
//

import Foundation
import Observation
import StoreKit
import UIKit

/// Premium's paid state, read from StoreKit — one of the two files that import it (rule
/// `70-privacy`, *StoreKit, for the review request and for Premium*). No `SwiftUI` here: its
/// `Transaction` would shadow StoreKit's.
///
/// **Read, never stored.** The state is read from `Transaction.currentEntitlements` when the store is
/// built, whenever the app comes forward, and after every transaction update, and is kept in memory
/// only. StoreKit keeps purchases on the device and answers offline; a cached flag would be a second
/// source of truth that could still say Premium after a refund (spec
/// `2026-10-21-premium-foundation-design.md` §3.3, decision D4). No key, no App Group write.
///
/// **Waiting, not free.** Until the first read the state is ``State/checking``, and nothing Premium
/// draws — so a paying user never sees a paywall flash at launch.
///
/// **StoreKit only through ``Source``**, a struct of closures built by ``Source/live()`` —
/// `ReminderScheduler`'s shape — so every decision here is testable without the App Store (rule
/// `43-concurrency`). App-only: the widget and the watch never compile this and never ask StoreKit
/// (rule `10-architecture`).
@MainActor
@Observable
final class PremiumStore {

    /// What is known of the user's purchases.
    nonisolated enum State: Sendable, Equatable {
        case checking
        case known(PremiumAccess.Status)

        /// What is held, or `nil` while the first read is outstanding.
        var status: PremiumAccess.Status? {
            guard case .known(let status) = self else { return nil }
            return status
        }
    }

    /// The three plans, as the paywall offers them.
    nonisolated enum Plans: Sendable, Equatable {
        case notLoaded
        case loading
        case loaded([PremiumAccess.Plan])
        /// StoreKit could not be reached, or did not return all three products: never an empty or a
        /// half paywall (plan P7).
        case unavailable
    }

    /// Where a purchase stands.
    nonisolated enum Purchase: Sendable, Equatable {
        case idle, buying, pending, bought, failed
    }

    /// How StoreKit answered a purchase.
    nonisolated enum Outcome: Sendable, Equatable {
        case bought, pending, cancelled
        /// A purchase StoreKit could not verify. Never Premium.
        case unverified
    }

    /// Where a restore stands — *Restore Purchases* shows its progress, and says so when nothing was
    /// found (the final review's minor 5).
    nonisolated enum Restoring: Sendable, Equatable {
        case idle, restoring, nothingFound
    }

    /// Every way StoreKit reaches the store. Main-actor, unlike `ReminderScheduler`: only the store
    /// calls these, on the main actor, and the purchase, the manage sheet and the scene they need are
    /// main-actor themselves (plan P2).
    struct Source {
        /// The verified current entitlements, as plain facts.
        var entitlements: () async -> [PremiumAccess.Entitlement]
        /// One element for each verified transaction update, after it has been finished.
        var updates: () -> AsyncStream<Void>
        /// The three plans, the yearly's trial only for the eligible.
        var plans: () async throws -> [PremiumAccess.Plan]
        var buy: (_ productID: String) async throws -> Outcome
        var restore: () async throws -> Void
        var manage: () async -> Void
        /// Whether Apple's manage sheet works here — not on a Mac ([MS] in the foundation spec).
        var canManage: () -> Bool
    }

    private(set) var state: State = .checking
    private(set) var plans: Plans = .notLoaded
    private(set) var purchase: Purchase = .idle
    private(set) var restoring: Restoring = .idle
    /// Whether a subscription stands — beside a lifetime purchase too — so *Manage Subscription*
    /// has something to manage (the final review's minor 3).
    private(set) var holdsSubscription = false

    @ObservationIgnored private let source: Source
    /// The store's clock — the one the card and the sheet hand to ``PremiumAccess/Status/line(in:locale:now:)``
    /// (rule `30-rollover`'s *The clock*).
    @ObservationIgnored let now: () -> Date
    @ObservationIgnored private var listener: Task<Void, Never>?
    /// Numbers every read, so a read that a newer one overtook does not publish (minor 4).
    @ObservationIgnored private var reads = 0

    /// Listens at once — so a renewal, a refund or an approved Ask to Buy is never missed while the
    /// app runs — and reads the state for the first time.
    init(source: Source, now: @escaping () -> Date = Date.init) {
        self.source = source
        self.now = now
        let updates = source.updates()
        listener = Task { [weak self] in
            for await _ in updates {
                await self?.refresh()
            }
        }
        Task { [weak self] in
            await self?.refresh()
        }
    }

    /// StoreKit itself — built here, on the main actor, rather than as a default argument, which is
    /// evaluated off it and warns.
    convenience init() {
        self.init(source: .live())
    }

    deinit {
        listener?.cancel()
    }

    /// Reads what is held, and publishes it only when it changed — and only if no newer read began
    /// while this one waited on StoreKit.
    func refresh() async {
        reads += 1
        let read = reads
        let entitlements = await source.entitlements()
        guard read == reads else { return }
        let status = PremiumAccess.resolve(entitlements)
        if state != .known(status) {
            state = .known(status)
        }
        // A purchase landed, by whichever read: a restore that found nothing earlier — or decided
        // from a read this one overtook — no longer has anything to say (step 1's final review, I1).
        if status.isPremium, restoring == .nothingFound {
            restoring = .idle
        }
        let subscribed = PremiumAccess.holdsSubscription(entitlements)
        if holdsSubscription != subscribed {
            holdsSubscription = subscribed
        }
    }

    /// Opens the paywall clean: the last purchase's outcome forgotten, the plans read again.
    ///
    /// A purchase still under way is not an outcome, and is kept. *Not now* closes the sheet while
    /// StoreKit's own is still coming up; were *See Premium*'s fresh sheet to forget it, its button
    /// would come back enabled and ``buy(_:)``'s guard would let a second purchase start.
    func prepare() async {
        if purchase != .buying {
            purchase = .idle
        }
        if restoring != .restoring {
            restoring = .idle
        }
        await loadPlans()
    }

    /// Reads the three plans; anything less is ``Plans/unavailable`` (plan P7).
    func loadPlans() async {
        plans = .loading
        do {
            let loaded = try await source.plans()
            let complete = loaded.count == 3 && Set(loaded.map(\.kind)) == [.monthly, .yearly, .lifetime]
            plans = complete ? .loaded(loaded) : .unavailable
        } catch {
            plans = .unavailable
        }
    }

    /// Buys one plan. A second tap while one is under way buys nothing.
    func buy(_ plan: PremiumAccess.Plan) async {
        guard purchase != .buying else { return }
        purchase = .buying
        do {
            switch try await source.buy(plan.id) {
            case .bought:
                await refresh()
                purchase = .bought
            case .pending:
                purchase = .pending
            case .cancelled:
                purchase = .idle
            case .unverified:
                purchase = .failed
            }
        } catch {
            purchase = .failed
        }
    }

    /// Asks the App Store for the user's purchases again, then reads them — App Review asks every
    /// app that sells something restorable for this (foundation spec §3.3). A second tap while one
    /// runs asks nothing; what it found is said either way.
    func restore() async {
        guard restoring != .restoring else { return }
        restoring = .restoring
        do {
            try await source.restore()
        } catch {
            #if DEBUG
            print("WaterBuddy: restoring purchases failed; the state is read as it stands.")
            #endif
        }
        await refresh()
        restoring = state.status?.isPremium == true ? .idle : .nothingFound
    }

    /// Apple's own sheet for the subscription, which says whether it renews.
    func manage() async {
        await source.manage()
    }

    /// Whether *Manage Subscription* is offered here.
    var canManage: Bool {
        source.canManage()
    }

    /// The scene a purchase is confirmed in and the manage sheet is shown on: the one in the
    /// foreground, else any.
    static func foregroundScene() -> UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
    }

    /// Neither a product nor a scene to buy it in. `fileprivate`, not `private`: ``Source/live()``
    /// throws it from an extension outside this declaration.
    fileprivate struct Unreachable: Error {}
}

extension PremiumStore.Source {

    /// StoreKit itself. Every closure calls it in its own body; nothing StoreKit is stored.
    static func live() -> Self {
        Self(
            entitlements: {
                var found: [PremiumAccess.Entitlement] = []
                for await result in Transaction.currentEntitlements {
                    // An unverified transaction is not taken as paid, here or anywhere.
                    guard case .verified(let transaction) = result else { continue }
                    found.append(PremiumAccess.Entitlement(transaction))
                }
                return found
            },
            updates: {
                let (stream, continuation) = AsyncStream<Void>.makeStream()
                let listener = Task {
                    for await result in Transaction.updates {
                        guard case .verified(let transaction) = result else { continue }
                        await transaction.finish()
                        continuation.yield()
                    }
                    continuation.finish()
                }
                continuation.onTermination = { _ in listener.cancel() }
                return stream
            },
            plans: {
                let products = try await Product.products(for: PremiumAccess.productIDs)
                var plans: [PremiumAccess.Plan] = []
                for id in PremiumAccess.productIDs {
                    guard let product = products.first(where: { $0.id == id }) else { continue }
                    plans.append(await PremiumAccess.Plan(product))
                }
                return plans
            },
            buy: { productID in
                guard let product = try await Product.products(for: [productID]).first,
                      let scene = PremiumStore.foregroundScene() else {
                    throw PremiumStore.Unreachable()
                }
                switch try await product.purchase(confirmIn: scene) {
                case .success(.verified(let transaction)):
                    await transaction.finish()
                    return .bought
                case .success(.unverified):
                    return .unverified
                case .pending:
                    return .pending
                case .userCancelled:
                    return .cancelled
                @unknown default:
                    return .unverified
                }
            },
            restore: {
                try await AppStore.sync()
            },
            manage: {
                // Apple's sheet is not supported on a Mac ([MS] in the spec).
                guard !ProcessInfo.processInfo.isiOSAppOnMac,
                      let scene = PremiumStore.foregroundScene() else { return }
                do {
                    try await AppStore.showManageSubscriptions(in: scene)
                } catch {
                    #if DEBUG
                    print("WaterBuddy: the manage-subscriptions sheet could not be shown.")
                    #endif
                }
            },
            canManage: { !ProcessInfo.processInfo.isiOSAppOnMac }
        )
    }

    /// A source that answers nothing and reaches no store — for a `#Preview` (plan P12).
    static func silent() -> Self {
        Self(
            entitlements: { [] },
            updates: { AsyncStream { $0.finish() } },
            plans: { [] },
            buy: { _ in .cancelled },
            restore: {},
            manage: {},
            canManage: { false }
        )
    }
}

private extension PremiumAccess.Entitlement {

    init(_ transaction: Transaction) {
        self.init(
            productID: transaction.productID,
            expires: transaction.expirationDate,
            revoked: transaction.revocationDate
        )
    }
}

private extension PremiumAccess.Plan {

    /// The plan a product offers this user — the trial only when it is a free one and StoreKit says
    /// they are eligible for it.
    init(_ product: Product) async {
        var trial: Period?
        if let subscription = product.subscription,
           let offer = subscription.introductoryOffer,
           offer.paymentMode == .freeTrial,
           await subscription.isEligibleForIntroOffer {
            trial = Period(offer.period, count: offer.periodCount)
        }
        let kind: Kind = switch product.id {
        case PremiumAccess.lifetimeID: .lifetime
        case PremiumAccess.monthlyID: .monthly
        default: .yearly
        }
        self.init(
            id: product.id,
            kind: kind,
            price: product.displayPrice,
            amount: product.price,
            trial: trial
        )
    }
}

private extension PremiumAccess.Plan.Period {

    init?(_ period: Product.SubscriptionPeriod, count: Int) {
        let unit: Unit
        switch period.unit {
        case .day: unit = .day
        case .week: unit = .week
        case .month: unit = .month
        case .year: unit = .year
        @unknown default: return nil
        }
        self.init(value: period.value * max(1, count), unit: unit)
    }
}
