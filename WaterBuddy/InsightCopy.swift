//
//  InsightCopy.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 23/10/26.
//

import Foundation

/// The app's own sentences for a week's insights — the one mapping from a ``WeekInsights/Finding`` to
/// words (spec `2026-10-23-insights-design.md` §3.5, §3.9).
///
/// **One mapping, two readers.** History draws these sentences in the app's language, and on an English
/// iPhone ``InsightWriter`` hands the same English sentences to Apple's on-device model to be reworded
/// — so the model is given what the page would show anyway and nothing more, and where it is
/// unavailable, refuses or fails, these are what the user reads.
///
/// Every sentence goes through ``Foundation/Bundle/localized(_:_:locale:)`` or
/// ``Foundation/Bundle/figure(_:_:locale:)`` with the app's locale (rule `50-views`), so a count takes its
/// plural form and every figure is grouped. Millilitres are drawn and spoken as *ml*: a sentence the model
/// writes has no spoken twin, so neither does this one.
///
/// App-only, `Foundation` alone, `nonisolated` — `InsightCopyTests` reads it off the main actor (rule
/// `43-concurrency`).
nonisolated enum InsightCopy {

    /// A week's insights as sentences: the page History draws, and what the model is given and hands
    /// back.
    nonisolated struct Page: Sendable, Hashable {
        let oneThing: String
        /// The suggestion under a shortfall, the average day under an improvement.
        let detail: String?
        let working: String?
        let worthKnowing: String?
        /// The suggested vessel's name, in the page's language — handed to the model so it may name it,
        /// and never drawn: the page draws the vessel's glyph.
        let vessel: String?
    }

    /// `content` as sentences, the suggestion's amount taken from `vessels` — the user's three, in slot
    /// order.
    static func page(for content: WeekInsights.Content, vessels: [Int], in strings: Bundle, locale: Locale) -> Page {
        let slot = content.suggestion?.vessel(in: vessels)
        let detail: String?
        if let suggestion = content.suggestion, let slot {
            detail = Self.suggestion(suggestion, amount: vessels[slot], in: strings, locale: locale)
        } else {
            detail = content.detail.map { sentence(for: $0, in: strings, locale: locale) }
        }
        return Page(
            oneThing: sentence(for: content.oneThing, in: strings, locale: locale),
            detail: detail,
            working: content.working.map { sentence(for: $0, in: strings, locale: locale) },
            worthKnowing: content.worthKnowing.map { sentence(for: $0, in: strings, locale: locale) },
            vessel: slot.flatMap { vesselSlots.indices.contains($0) ? vesselSlots[$0].nameKey : nil }
                .map { strings.localizedString(forKey: $0, value: nil, table: nil) }
        )
    }

    /// One finding as a sentence.
    static func sentence(for finding: WeekInsights.Finding, in strings: Bundle, locale: Locale) -> String {
        switch finding {
        case .weekendsLower(let millilitres):
            strings.figure("Weekends ran %1$@ ml a day below weekdays.", millilitres, locale: locale)
        case .weekdaysLower(let millilitres):
            strings.figure("Weekdays ran %1$@ ml a day below weekends.", millilitres, locale: locale)
        case .lessThanBefore(let millilitres):
            strings.figure("%1$@ ml a day less than the week before.", millilitres, locale: locale)
        case .shortOfGoal(let millilitres):
            strings.figure("An average day was %1$@ ml short of your goal.", millilitres, locale: locale)
        case .everyDayMet:
            strings.localizedString(forKey: "Every day on goal.", value: nil, table: nil)
        case .everyWeekdayMet:
            strings.localizedString(forKey: "Your goal on every weekday.", value: nil, table: nil)
        case .everyWeekendDayMet:
            strings.localizedString(forKey: "Your goal on every weekend day.", value: nil, table: nil)
        case .moreDaysMet(let days, let before):
            strings.localized("Goal met on %1$d days, up from %2$d.", days, before, locale: locale)
        case .moreThanBefore(let millilitres):
            strings.figure("%1$@ ml a day more than the week before.", millilitres, locale: locale)
        case .earlierStart(let minutes):
            strings.localized("Your first drink came %1$d minutes earlier than the week before.", minutes, locale: locale)
        case .daysMet(let days, let of):
            strings.localized("%1$d of %2$d days on goal", days, of, locale: locale)
        case .emptyDays(let days):
            strings.localized("Nothing was logged on %1$d days.", days, locale: locale)
        case .laterStart(let minutes):
            strings.localized("Your first drink came %1$d minutes later than the week before.", minutes, locale: locale)
        case .halfBy(let time):
            // The phone's own 12- or 24-hour form under the app's locale, as every time in History.
            strings.localized(
                "Half your water came before %1$@.",
                time.formatted(.dateTime.hour().minute().locale(locale)),
                locale: locale
            )
        case .average(let millilitres, let goal):
            strings.figure("An average day: %1$@ ml, against a goal of %2$@ ml.", millilitres, goal, locale: locale)
        }
    }

    /// A shortfall's suggestion: `amount` more, when the week fell short. It promises only that it would
    /// *help close the gap*, which is true of any amount (spec §3.3).
    static func suggestion(_ suggestion: WeekInsights.Suggestion, amount: Int, in strings: Bundle, locale: Locale) -> String {
        let key = switch suggestion.when {
        case .weekendDays: "Another %1$@ ml on each weekend day would help close the gap."
        case .weekdays: "Another %1$@ ml on each weekday would help close the gap."
        case .each(.morning): "Another %1$@ ml each morning would help close the gap."
        case .each(.afternoon): "Another %1$@ ml each afternoon would help close the gap."
        case .each(.evening): "Another %1$@ ml each evening would help close the gap."
        }
        return strings.figure(key, amount, locale: locale)
    }
}
