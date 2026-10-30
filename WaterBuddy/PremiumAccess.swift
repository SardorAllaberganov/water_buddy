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

    /// The monthly subscription — group *WaterBuddy Premium*, one level below the yearly, no
    /// introductory offer.
    static let monthlyID = "sardor.WaterBuddy.premium.monthly"

    /// The yearly subscription — the same group, its highest level, one week free for the eligible.
    static let yearlyID = "sardor.WaterBuddy.premium.yearly"

    /// The lifetime purchase, a non-consumable.
    static let lifetimeID = "sardor.WaterBuddy.premium.lifetime"

    /// The one spelling of all three, in the order the paywall draws them. Nothing else in the
    /// product writes any of these strings.
    static let productIDs = [monthlyID, yearlyID, lifetimeID]

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
        /// A subscription, paid through the end of its current period — which is all a transaction
        /// says; whether it renews is Apple's own sheet's to say. In a billing grace period that date
        /// has already passed and the plan is still held (spec
        /// `2026-10-21-premium-paywall-and-monthly-design.md` §3.2).
        case monthly(until: Date)
        case yearly(until: Date)
        case lifetime

        var isPremium: Bool { self != .free }

        /// *Monthly, until 21 November 2026*, *Yearly, until 21 October 2027* or *Lifetime* — the
        /// Settings card's line and the paywall's once something is held. Once the date has passed —
        /// a subscriber in grace — the plan's name alone. `nil` when nothing is held. `now` is
        /// ``PremiumStore/now``, never a bare `Date()` in a view (rule `30-rollover`).
        func line(in strings: Bundle, locale: Locale, now: Date) -> String? {
            switch self {
            case .free:
                return nil
            case .lifetime:
                return strings.localizedString(forKey: "Lifetime", value: nil, table: nil)
            case .monthly(let until):
                guard until > now else {
                    return strings.localizedString(forKey: "Monthly", value: nil, table: nil)
                }
                return strings.localized("Monthly, until %1$@", Self.day(until, locale: locale), locale: locale)
            case .yearly(let until):
                guard until > now else {
                    return strings.localizedString(forKey: "Yearly", value: nil, table: nil)
                }
                return strings.localized("Yearly, until %1$@", Self.day(until, locale: locale), locale: locale)
            }
        }

        /// A period's end, as the locale writes a date in full.
        private static func day(_ date: Date, locale: Locale) -> String {
            date.formatted(Date.FormatStyle(date: .long, time: .omitted).locale(locale))
        }
    }

    /// The answer, from whatever StoreKit said.
    ///
    /// **StoreKit's current entitlements say whether a subscription is held** — the owner's ruling
    /// of 2026-10-21 (spec `2026-10-21-premium-paywall-and-monthly-design.md` §3.2). They carry a
    /// subscription that is subscribed or in its billing grace period and leave out one that has
    /// lapsed; checking the period's end again here, as the foundation did, read a subscriber in
    /// grace — and one opening the app between a period's end and the renewal's transaction — as
    /// free. So this ignores an unknown product and anything revoked, and nothing else, and takes no
    /// clock.
    ///
    /// A subscription with no end is not taken as paid: StoreKit gives every subscription one, and a
    /// missing one is not evidence of payment. A lifetime purchase wins; else the subscription with
    /// the later end, the yearly on a tie.
    static func resolve(_ entitlements: [Entitlement]) -> Status {
        let standing = entitlements.filter { $0.revoked == nil }
        if standing.contains(where: { $0.productID == lifetimeID }) {
            return .lifetime
        }
        let held = standing.compactMap { entitlement -> (kind: Plan.Kind, until: Date)? in
            guard let until = entitlement.expires else { return nil }
            switch entitlement.productID {
            case yearlyID: return (.yearly, until)
            case monthlyID: return (.monthly, until)
            default: return nil
            }
        }
        let latest = held.max { first, second in
            first.until != second.until
                ? first.until < second.until
                : first.kind == .monthly && second.kind == .yearly
        }
        guard let latest else { return .free }
        return latest.kind == .yearly ? .yearly(until: latest.until) : .monthly(until: latest.until)
    }

    /// Whether a subscription stands among the entitlements — beside a lifetime purchase too, which
    /// ``resolve(_:)`` reads as ``Status/lifetime``. What *Manage Subscription* manages (the final
    /// review's minor 3).
    static func holdsSubscription(_ entitlements: [Entitlement]) -> Bool {
        entitlements.contains { entitlement in
            entitlement.revoked == nil
                && entitlement.expires != nil
                && (entitlement.productID == yearlyID || entitlement.productID == monthlyID)
        }
    }

    /// What the yearly saves against twelve months of the monthly, `1 − yearly ÷ (12 × monthly)`,
    /// rounded **down** to a whole percent — never more than is true — as a fraction (`0.44`).
    /// Computed in `Decimal`, so a price like 2.99 is exact. `nil` when either price is not positive
    /// or the saving is under one percent (Review Focus 2).
    static func yearlySaving(yearly: Decimal, monthly: Decimal) -> Double? {
        guard yearly > 0, monthly > 0 else { return nil }
        var percent = (1 - yearly / (monthly * 12)) * 100
        var whole = Decimal()
        NSDecimalRound(&whole, &percent, 0, .down)
        guard whole >= 1 else { return nil }
        return NSDecimalNumber(decimal: whole).doubleValue / 100
    }

    /// The saving among the plans the paywall loaded; `nil` while either subscription is missing.
    static func yearlySaving(among plans: [Plan]) -> Double? {
        guard let yearly = plans.first(where: { $0.kind == .yearly }),
              let monthly = plans.first(where: { $0.kind == .monthly }) else { return nil }
        return yearlySaving(yearly: yearly.amount, monthly: monthly.amount)
    }

    /// One plan as the paywall draws it — a plain value, so no view holds a StoreKit `Product`
    /// (rule `50-views`).
    nonisolated struct Plan: Sendable, Equatable, Identifiable {

        nonisolated enum Kind: Sendable, Equatable, Hashable {
            case monthly, yearly, lifetime
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
        /// StoreKit's `price` — for the yearly's saving alone, never drawn (spec §3.2).
        let amount: Decimal
        /// The free introductory offer's length — present only when StoreKit says this user is
        /// eligible for it. The subscription's own period is not carried: the product is monthly or
        /// yearly by its identity (foundation plan P5).
        let trial: Period?

        /// *Monthly*, *Yearly* or *Lifetime* — the tile's name and its VoiceOver label.
        func name(in strings: Bundle) -> String {
            switch kind {
            case .monthly: strings.localizedString(forKey: "Monthly", value: nil, table: nil)
            case .yearly: strings.localizedString(forKey: "Yearly", value: nil, table: nil)
            case .lifetime: strings.localizedString(forKey: "Lifetime", value: nil, table: nil)
            }
        }

        /// The row's second line and its VoiceOver value: *$2.99 a month*,
        /// *1 week free, then $19.99 a year*, *$19.99 a year*, or *$39.99, once*. The price is StoreKit's string; the trial's length is
        /// Foundation's, in `locale`'s language (plan P3).
        func priceLine(in strings: Bundle, locale: Locale) -> String {
            switch kind {
            case .lifetime:
                return strings.localized("%1$@, once", price, locale: locale)
            case .monthly:
                return strings.localized("%1$@ a month", price, locale: locale)
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
            case .monthly:
                return strings.localized(
                    "%1$@ is charged each month until you cancel. Cancel at least 24 hours before it renews, in your Apple Account settings.",
                    price, locale: locale
                )
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
            case .monthly: "Subscribe"
            case .yearly: trial == nil ? "Subscribe" : "Start Free Trial"
            }
            return strings.localizedString(forKey: key, value: nil, table: nil)
        }

        /// The tile's third line: *a month*; *a year*; *once*.
        func period(in strings: Bundle) -> String {
            let key = switch kind {
            case .monthly: "a month"
            case .yearly: "a year"
            case .lifetime: "once"
            }
            return strings.localizedString(forKey: key, value: nil, table: nil)
        }

        /// The yearly's saving, in the locale's own percent, on a line of its own: joined to *a
        /// year* by a dot, it broke after the dot on every phone and in every language the walk drew
        /// (plan S1, superseded). `nil` for the other plans, and when the yearly saves nothing.
        func savingLine(in strings: Bundle, locale: Locale, saving: Double?) -> String? {
            guard kind == .yearly, let saving else { return nil }
            return strings.localized("save %1$@", saving.formatted(.percent.locale(locale)), locale: locale)
        }

        /// Whether the tile carries *Best value* — the yearly's, and only while it saves something: a
        /// yearly priced at twelve months of the monthly or more is not the better buy, and the badge
        /// would say it is (step 1's final review, I2; Review Focus 2).
        func showsBestValue(saving: Double?) -> Bool {
            kind == .yearly && saving != nil
        }

        /// The tile's last line: *Cancel any time*; the free week — Foundation's words for its length
        /// (foundation plan P3) — when StoreKit offers it; *Yours for good*. `nil` for a yearly with
        /// no free week.
        func note(in strings: Bundle, locale: Locale) -> String? {
            switch kind {
            case .monthly:
                return strings.localizedString(forKey: "Cancel any time", value: nil, table: nil)
            case .lifetime:
                return strings.localizedString(forKey: "Yours for good", value: nil, table: nil)
            case .yearly:
                guard let length = trial?.formatted(locale: locale) else { return nil }
                return strings.localized("%1$@ free", length, locale: locale)
            }
        }
    }

    /// How a Premium extra drawn in place of a free screen shows (spec `2026-10-30-coaching-design.md` D4).
    nonisolated enum Gate: Sendable, Equatable {
        /// The paywall is not offered here: nothing is drawn.
        case hidden
        /// Drawn with a lock; a tap opens the paywall. Also while the first read is still out.
        case locked
        case open
    }

    /// One answer for every extra drawn in place: open for Premium, locked where the paywall is offered,
    /// hidden where it is not. `status` is `nil` while StoreKit has not answered.
    static func gate(status: Status?, offered: Bool) -> Gate {
        if status?.isPremium == true { return .open }
        return offered ? .locked : .hidden
    }
}
