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

    /// Set A — month view and full history, patterns, personal insights, the monthly recap.
    case understand

    /// Set B — your own reminder schedule, the pace line, reminders only when behind (spec
    /// `2026-10-30-coaching-design.md`).
    case coached

    /// One thing a set does, as the paywall and the Settings card name it.
    nonisolated enum Feature: CaseIterable, Sendable, Hashable {
        case monthView, patterns, insights, recap
        case schedule, pace, onlyWhenBehind

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
            case .schedule: "calendar.badge.clock"
            case .pace: "speedometer"
            case .onlyWhenBehind: "bell.badge"
            }
        }

        private var titleKey: String {
            switch self {
            case .monthView: "Month view and full history"
            case .patterns: "Your patterns"
            // Never *Apple Intelligence*: Apple's marks are not part of a feature's name, and the model
            // writes only in English — a Russian or Uzbek user reads WaterBuddy's own sentences (spec
            // `2026-10-23-insights-design.md` §3.9, the owner's ruling closing #164's naming half).
            case .insights: "Personal insights"
            case .recap: "A monthly recap"
            case .schedule: "Your own reminder schedule"
            case .pace: "A pace line"
            case .onlyWhenBehind: "Reminders only when behind"
            }
        }

        private var lineKey: String {
            switch self {
            case .monthView: "Every day you have logged, a month at a glance"
            case .patterns: "When you drink, weekdays against weekends"
            case .insights: "Each week, from your own figures, on your iPhone"
            case .recap: "Your month in one card, yours to share"
            case .schedule: "Your hours, your interval, your quiet days"
            case .pace: "Where you should be by now, on Home"
            case .onlyWhenBehind: "A nudge only when you need one"
            }
        }

        private var captionKey: String? {
            switch self {
            case .monthView: "Month view"
            case .patterns: "Patterns"
            // History's own word for the mode, so the card and the switch name it alike.
            case .insights: "Insights"
            case .recap: nil
            // D10 (spec `2026-10-30-coaching-design.md`): the card keeps set A's three previews; four abreast
            // break at the ordinary sizes. The paywall names set B's in full.
            case .schedule, .pace, .onlyWhenBehind: nil
            }
        }
    }

    /// What the set does, in the order the paywall lists it.
    var features: [Feature] {
        switch self {
        case .understand: [.monthView, .patterns, .insights, .recap]
        case .coached: [.schedule, .pace, .onlyWhenBehind]
        }
    }

    /// Whether every feature the set lists is built. **Set A went on sale in step 5**, with the recap
    /// (spec `2026-10-24-monthly-recap-design.md` §3.8); a Release build offers it only once the privacy
    /// policy's address is set (`PaywallView.isOffered(arguments:)`). **Set B went on sale with the pace
    /// line**, its last feature (spec `2026-10-30-coaching-design.md`).
    var isOnSale: Bool {
        switch self {
        case .understand: true
        case .coached: true
        }
    }

    /// The sets on sale, in declaration order.
    static let onSale: [PremiumSet] = allCases.filter(\.isOnSale)
}
