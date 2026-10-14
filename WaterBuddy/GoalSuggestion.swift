//
//  GoalSuggestion.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 14/10/26.
//

import Foundation

/// A daily goal worked out from a weight and how active someone is — the welcome's *Work it out for
/// me* (spec 2026-10-14 §4).
///
/// **30 ml for each kilogram, and 0, 350 or 700 ml more for a light, moderate or active day**,
/// rounded half-up to the slider's step and kept on the slider (``WelcomeView/goalRange``). The
/// owner ruled the formula and approved its table on 2026-10-14; `GoalSuggestionTests` holds the
/// table cell by cell. It is an estimate for a hydration app's daily target, not advice about
/// anyone's health, and the screen says so under it.
///
/// **In whole numbers only.** A pound is exactly 0.45359237 kg, so a weight in pounds becomes
/// millilitres as a fraction of integers, rounded once to the whole millilitre. No `Double` ever
/// holds a volume (`CLAUDE.md`, *No floating-point millilitres*).
///
/// **It keeps nothing.** A weight goes in and a goal comes out. Neither the weight nor its unit is
/// stored anywhere (rule `70-privacy`).
///
/// A plain value at file scope and `nonisolated`, so its suite reads it off the main actor (rule
/// `43-concurrency`).
nonisolated enum GoalSuggestion {

    /// What each kilogram adds.
    static let millilitresPerKilogram = 30

    /// A pound is `poundNumerator / poundDenominator` kilograms — 0.45359237, the international
    /// pound, exactly.
    static let poundNumerator = 45_359_237
    static let poundDenominator = 100_000_000

    /// The goal for `weight` in `unit` at `activity`, on the slider's step and inside its range.
    static func goal(weight: Int, unit: Unit, activity: Activity) -> Int {
        let step = WelcomeView.goalStep
        let total = millilitres(for: weight, in: unit) + activity.millilitres
        // Half-up to the nearest step: a total exactly between two takes the higher.
        let rounded = (total + step / 2) / step * step
        return min(max(rounded, WelcomeView.goalRange.lowerBound), WelcomeView.goalRange.upperBound)
    }

    /// What `weight` contributes, to the nearest whole millilitre.
    private static func millilitres(for weight: Int, in unit: Unit) -> Int {
        switch unit {
        case .kilograms:
            weight * millilitresPerKilogram
        case .pounds:
            // 13.6077711 ml a pound, rounded once: (lb × 30 × 45,359,237 + 50,000,000) ÷ 100,000,000.
            (weight * millilitresPerKilogram * poundNumerator + poundDenominator / 2) / poundDenominator
        }
    }

    /// The unit a weight is entered in.
    nonisolated enum Unit: CaseIterable, Sendable {

        case kilograms
        case pounds

        /// What the wheel offers: thirty kilograms to two hundred, and about the same span in whole
        /// pounds.
        var range: ClosedRange<Int> {
            switch self {
            case .kilograms: 30...200
            case .pounds: 66...440
            }
        }

        /// Where the wheel starts: round figures, close to one another (decision W2).
        var start: Int {
            switch self {
            case .kilograms: 70
            case .pounds: 155
            }
        }

        /// The unit a phone's region weighs in: pounds where it measures in US units, kilograms
        /// everywhere else. The region, deliberately not the app's language — choosing English in
        /// the app must not make an Uzbek user weigh in pounds (spec §4, the owner's ruling).
        static func starting(for system: Locale.MeasurementSystem) -> Unit {
            system == .us ? .pounds : .kilograms
        }

        /// `weight` in this unit as the nearest whole `unit`, kept on that unit's wheel: 70 kg is
        /// 154 lb, and 154 lb is 70 kg.
        func convert(_ weight: Int, to unit: Unit) -> Int {
            let converted: Int
            switch (self, unit) {
            case (.kilograms, .pounds):
                // kg ÷ 0.45359237, half-up: (2 × kg × 10⁸ + 45,359,237) ÷ (2 × 45,359,237).
                converted = (2 * weight * GoalSuggestion.poundDenominator + GoalSuggestion.poundNumerator)
                    / (2 * GoalSuggestion.poundNumerator)
            case (.pounds, .kilograms):
                converted = (weight * GoalSuggestion.poundNumerator + GoalSuggestion.poundDenominator / 2)
                    / GoalSuggestion.poundDenominator
            default:
                converted = weight
            }
            return min(max(converted, unit.range.lowerBound), unit.range.upperBound)
        }
    }

    /// How active a day is.
    nonisolated enum Activity: CaseIterable, Sendable {

        case light
        case moderate
        case active

        /// What a day like this adds.
        var millilitres: Int {
            switch self {
            case .light: 0
            case .moderate: 350
            case .active: 700
            }
        }
    }
}
