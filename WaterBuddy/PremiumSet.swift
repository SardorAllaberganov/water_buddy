//
//  PremiumSet.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 21/10/26.
//

import Foundation

/// The sets Premium sells — one case per set (`docs/ROADMAP.md` §5, *Sold as sets*).
///
/// **A case is not a sale.** ``isOnSale`` says whether every feature a set lists is built. Only a set
/// on sale turns the paywall on in a Release build (``PaywallView/isOffered(arguments:)``), and only
/// those are listed there; a DEBUG build launched to offer the paywall lists every set, so it can be
/// seen whole while its features are still being built (spec
/// `2026-10-21-premium-paywall-and-monthly-design.md` §3.6, amending the foundation's *no case*).
///
/// `nonisolated`, so the switch reads it from off the main actor (rule `43-concurrency`).
nonisolated enum PremiumSet: CaseIterable, Sendable, Equatable {

    /// Set A — month view and full history, patterns, personal AI insights, the monthly recap.
    case understand

    /// One thing a set does, as the paywall and the Settings card name it.
    nonisolated enum Feature: CaseIterable, Sendable, Hashable {
        case monthView, patterns, insights, recap

        /// The paywall row's title.
        func title(in strings: Bundle) -> String {
            strings.localizedString(forKey: titleKey, value: nil, table: nil)
        }

        /// The paywall row's one line.
        func line(in strings: Bundle) -> String {
            strings.localizedString(forKey: lineKey, value: nil, table: nil)
        }

        /// The Settings card's caption for its preview — `nil` for the recap, which the card does
        /// not preview.
        func caption(in strings: Bundle) -> String? {
            captionKey.map { strings.localizedString(forKey: $0, value: nil, table: nil) }
        }

        /// The row's glyph. `PremiumSetTests` proves each resolves: an unknown symbol draws nothing.
        var symbol: String {
            switch self {
            case .monthView: "calendar"
            case .patterns: "chart.bar.fill"
            case .insights: "sparkles"
            case .recap: "doc.text.image"
            }
        }

        private var titleKey: String {
            switch self {
            case .monthView: "Month view and full history"
            case .patterns: "Your patterns"
            case .insights: "Personal AI insights"
            case .recap: "A monthly recap"
            }
        }

        private var lineKey: String {
            switch self {
            case .monthView: "Every day you have logged, a month at a glance"
            case .patterns: "When you drink, weekdays against weekends"
            case .insights: "Using Apple Intelligence, private on your iPhone"
            case .recap: "Your month in one card, yours to share"
            }
        }

        private var captionKey: String? {
            switch self {
            case .monthView: "Month view"
            case .patterns: "Patterns"
            case .insights: "AI insights"
            case .recap: nil
            }
        }
    }

    /// What the set does, in the order the paywall lists it.
    var features: [Feature] {
        switch self {
        case .understand: [.monthView, .patterns, .insights, .recap]
        }
    }

    /// Whether every feature the set lists is built. **Set A goes on sale in step 5**, with the
    /// recap; `PremiumSetTests` pins the `false` and names that step.
    var isOnSale: Bool {
        switch self {
        case .understand: false
        }
    }

    /// The sets on sale, in declaration order.
    static let onSale: [PremiumSet] = allCases.filter(\.isOnSale)
}
