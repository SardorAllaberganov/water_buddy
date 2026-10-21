//
//  PremiumAccess.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 21/10/26.
//

import Foundation

/// What Premium is, decided without StoreKit.
///
/// `ReminderPlan`'s shape for `ReminderPlan`'s reason: a pure function of plain facts, so every case
/// of the decision is testable without the framework, the App Store or a simulator's purchases
/// (spec `2026-10-21-premium-foundation-design.md` §3.2). ``PremiumStore`` reads StoreKit and hands
/// this file what it found. Nothing here imports StoreKit, and nothing here is stored: the paid state
/// is read again every time (rule `70-privacy`).
///
/// `nonisolated`, and every nested type with it, stated outright: the app's default isolation is the
/// main actor, and `PremiumAccessTests` reads all of this from off it, as a canary
/// (rule `43-concurrency`).
nonisolated enum PremiumAccess {

    /// The yearly subscription — group *WaterBuddy Premium*, one week free for the eligible.
    static let yearlyID = "sardor.WaterBuddy.premium.yearly"

    /// The lifetime purchase, a non-consumable.
    static let lifetimeID = "sardor.WaterBuddy.premium.lifetime"

    /// The one spelling of both. Nothing else in the product writes either string.
    static let productIDs = [yearlyID, lifetimeID]

    /// The facts read off one verified transaction — and nothing else of it.
    nonisolated struct Entitlement: Sendable, Equatable {
        let productID: String
        /// When a subscription's current period ends. `nil` for the lifetime purchase.
        let expires: Date?
        /// When Apple refunded or revoked it. `nil` while it stands.
        let revoked: Date?
    }

    /// What the user holds.
    nonisolated enum Status: Sendable, Equatable {
        case free
        /// The yearly plan, paid through the end of its current period — which is all a transaction
        /// says. Whether it renews is Apple's own sheet's to say (spec §3.6).
        case yearly(until: Date)
        case lifetime

        var isPremium: Bool { self != .free }

        /// *Yearly, until 21 October 2027* or *Lifetime* — the Settings card's line and the paywall's
        /// once it is held. `nil` when nothing is.
        func line(in strings: Bundle, locale: Locale) -> String? {
            switch self {
            case .free:
                return nil
            case .lifetime:
                return strings.localizedString(forKey: "Lifetime", value: nil, table: nil)
            case .yearly(let until):
                let date = until.formatted(Date.FormatStyle(date: .long, time: .omitted).locale(locale))
                return strings.localized("Yearly, until %1$@", date, locale: locale)
            }
        }
    }

    /// The answer, from whatever StoreKit said.
    ///
    /// Ignores a product ID it does not know, anything revoked, and a subscription whose period ended
    /// at or before `now`. StoreKit's current entitlements already leave out a refund, but an
    /// ``Entitlement`` also arrives from `Transaction.updates`, and a rule that held for one caller's
    /// input only would not be a rule. A subscription with no end is not taken as paid: StoreKit gives
    /// every subscription one, and a missing one is not evidence of payment. The lifetime purchase wins
    /// over a yearly plan held beside it; of two yearly periods, the later end.
    static func resolve(_ entitlements: [Entitlement], now: Date) -> Status {
        let standing = entitlements.filter { $0.revoked == nil }
        if standing.contains(where: { $0.productID == lifetimeID }) {
            return .lifetime
        }
        let until = standing
            .filter { $0.productID == yearlyID }
            .compactMap(\.expires)
            .filter { $0 > now }
            .max()
        return until.map(Status.yearly(until:)) ?? .free
    }

    /// One plan as the paywall draws it — a plain value, so no view holds a StoreKit `Product`
    /// (rule `50-views`).
    nonisolated struct Plan: Sendable, Equatable, Identifiable {

        nonisolated enum Kind: Sendable, Equatable, Hashable {
            case yearly, lifetime
        }

        /// A length of time, as StoreKit gives an offer's.
        nonisolated struct Period: Sendable, Equatable {

            nonisolated enum Unit: Sendable, Equatable {
                case day, week, month, year
            }

            let value: Int
            let unit: Unit

            /// *1 week*, *1 неделя*, *1 hafta* — Foundation's own words for a length, in `locale`'s
            /// language (plan P3). `nil` only if Foundation cannot say it; then the line is drawn
            /// without it.
            func formatted(locale: Locale) -> String? {
                var calendar = Calendar(identifier: .gregorian)
                calendar.locale = locale
                let formatter = DateComponentsFormatter()
                formatter.calendar = calendar
                formatter.unitsStyle = .full
                formatter.maximumUnitCount = 1
                var components = DateComponents()
                switch unit {
                case .day:
                    formatter.allowedUnits = [.day]
                    components.day = value
                case .week:
                    formatter.allowedUnits = [.weekOfMonth]
                    components.weekOfMonth = value
                case .month:
                    formatter.allowedUnits = [.month]
                    components.month = value
                case .year:
                    formatter.allowedUnits = [.year]
                    components.year = value
                }
                return formatter.string(from: components)
            }
        }

        /// The product's identifier.
        let id: String
        let kind: Kind
        /// StoreKit's `displayPrice`, in the storefront's currency — drawn as it comes.
        let price: String
        /// The free introductory offer's length — present only when StoreKit says this user is
        /// eligible for it. The subscription's own period is not carried: the product is yearly by
        /// its identity (plan P5).
        let trial: Period?

        /// *Yearly* or *Lifetime* — the row's name and its VoiceOver label.
        func name(in strings: Bundle) -> String {
            switch kind {
            case .yearly: strings.localizedString(forKey: "Yearly", value: nil, table: nil)
            case .lifetime: strings.localizedString(forKey: "Lifetime", value: nil, table: nil)
            }
        }

        /// The row's second line and its VoiceOver value: *1 week free, then $19.99 a year*,
        /// *$19.99 a year*, or *$39.99, once*. The price is StoreKit's string; the trial's length is
        /// Foundation's, in `locale`'s language (plan P3).
        func priceLine(in strings: Bundle, locale: Locale) -> String {
            switch kind {
            case .lifetime:
                return strings.localized("%1$@, once", price, locale: locale)
            case .yearly:
                if let length = trial?.formatted(locale: locale) {
                    return strings.localized("%1$@ free, then %2$@ a year", length, price, locale: locale)
                }
                return strings.localized("%1$@ a year", price, locale: locale)
            }
        }

        /// What happens after the purchase, drawn under the button (spec §3.7, 5).
        func terms(in strings: Bundle, locale: Locale) -> String {
            switch kind {
            case .lifetime:
                return strings.localizedString(forKey: "One payment. It never renews.", value: nil, table: nil)
            case .yearly:
                if let length = trial?.formatted(locale: locale) {
                    return strings.localized(
                        "Free trial: %1$@. Then %2$@ is charged each year until you cancel. Cancel at least 24 hours before it renews, in your Apple Account settings.",
                        length, price, locale: locale
                    )
                }
                return strings.localized(
                    "%1$@ is charged each year until you cancel. Cancel at least 24 hours before it renews, in your Apple Account settings.",
                    price, locale: locale
                )
            }
        }

        /// The primary surface's label. No length in it: Russian would need another case (plan P4).
        func action(in strings: Bundle) -> String {
            let key = switch kind {
            case .lifetime: "Buy Lifetime"
            case .yearly: trial == nil ? "Subscribe" : "Start Free Trial"
            }
            return strings.localizedString(forKey: key, value: nil, table: nil)
        }
    }
}
