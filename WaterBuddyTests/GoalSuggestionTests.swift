//
//  GoalSuggestionTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 14/10/26.
//

import Foundation
import Testing
@testable import WaterBuddy

/// The welcome's goal calculator (spec 2026-10-14 §4).
///
/// Not `@MainActor`: ``GoalSuggestion`` is a plain value, and this suite is the canary that keeps it
/// — and the menu it reads, ``WelcomeView/goalRange`` — off the main actor (rule `43-concurrency`).
struct GoalSuggestionTests {

    /// The owner's approved table, cell by cell (spec §4).
    @Test(arguments: [
        (50, GoalSuggestion.Activity.light, 1_500), (50, .moderate, 1_900), (50, .active, 2_200),
        (60, .light, 1_800), (60, .moderate, 2_200), (60, .active, 2_500),
        (70, .light, 2_100), (70, .moderate, 2_500), (70, .active, 2_800),
        (85, .light, 2_600), (85, .moderate, 2_900), (85, .active, 3_300),
        (100, .light, 3_000), (100, .moderate, 3_400), (100, .active, 3_700),
    ])
    func theApprovedTableHolds(kilograms: Int, activity: GoalSuggestion.Activity, goal: Int) {
        #expect(GoalSuggestion.goal(weight: kilograms, unit: .kilograms, activity: activity) == goal)
    }

    /// The pound's starting weight at the starting activity, beside the kilogram's: 155 lb gives
    /// 2,109 ml, plus 350, rounded to 2,500.
    @Test func aHundredAndFiftyFivePoundsAtModerateIsTwoAndAHalfLitres() {
        #expect(GoalSuggestion.goal(weight: 155, unit: .pounds, activity: .moderate) == 2_500)
    }

    @Test func aLightWeightIsLiftedToTheSlidersFloor() {
        // 30 kg × 30 = 900 ml, under the slider.
        #expect(GoalSuggestion.goal(weight: 30, unit: .kilograms, activity: .light) == WelcomeView.goalRange.lowerBound)
    }

    @Test func aHeavyWeightIsHeldToTheSlidersCeiling() {
        // 200 kg × 30 + 700 = 6,700 ml, over it.
        #expect(GoalSuggestion.goal(weight: 200, unit: .kilograms, activity: .active) == WelcomeView.goalRange.upperBound)
    }

    @Test func exactlyHalfAStepRoundsUp() {
        // 85 × 30 = 2,550: halfway between 2,500 and 2,600.
        #expect(GoalSuggestion.goal(weight: 85, unit: .kilograms, activity: .light) == 2_600)
    }

    /// The region's unit, not the app's language (spec §4, the owner's ruling).
    @Test(arguments: [
        (Locale.MeasurementSystem.us, GoalSuggestion.Unit.pounds),
        (.metric, .kilograms),
        (.uk, .kilograms),
    ])
    func theWeightStartsInTheRegionsUnit(system: Locale.MeasurementSystem, unit: GoalSuggestion.Unit) {
        #expect(GoalSuggestion.Unit.starting(for: system) == unit)
    }

    @Test(arguments: GoalSuggestion.Unit.allCases)
    func eachUnitStartsOnItsOwnWheel(unit: GoalSuggestion.Unit) {
        #expect(unit.range.contains(unit.start))
    }

    @Test func seventyKilogramsReadsAsAHundredAndFiftyFourPoundsAndBack() {
        #expect(GoalSuggestion.Unit.kilograms.convert(70, to: .pounds) == 154)
        #expect(GoalSuggestion.Unit.pounds.convert(154, to: .kilograms) == 70)
    }

    /// The switch, flicked there and back, returns the weight the wheel showed — on every weight it
    /// offers.
    @Test func everyKilogramSurvivesATripThroughPounds() {
        for kilograms in GoalSuggestion.Unit.kilograms.range {
            let pounds = GoalSuggestion.Unit.kilograms.convert(kilograms, to: .pounds)
            #expect(GoalSuggestion.Unit.pounds.range.contains(pounds), "\(kilograms) kg left the pound wheel")
            #expect(GoalSuggestion.Unit.pounds.convert(pounds, to: .kilograms) == kilograms,
                    "\(kilograms) kg came back as \(GoalSuggestion.Unit.pounds.convert(pounds, to: .kilograms))")
        }
    }

    @Test(arguments: GoalSuggestion.Unit.allCases)
    func aWeightConvertedToItsOwnUnitIsUnchanged(unit: GoalSuggestion.Unit) {
        for weight in unit.range {
            #expect(unit.convert(weight, to: unit) == weight)
        }
    }

    /// Every weight on either wheel, at every level: on the slider, on a step, and never less for
    /// someone heavier.
    @Test(arguments: GoalSuggestion.Unit.allCases)
    func everySuggestionLandsOnTheSliderAndRisesWithWeight(unit: GoalSuggestion.Unit) {
        for activity in GoalSuggestion.Activity.allCases {
            var previous = 0
            for weight in unit.range {
                let goal = GoalSuggestion.goal(weight: weight, unit: unit, activity: activity)
                #expect(WelcomeView.goalRange.contains(goal), "\(weight) \(unit) suggested \(goal)")
                #expect((goal - WelcomeView.goalRange.lowerBound) % WelcomeView.goalStep == 0,
                        "\(weight) \(unit) suggested \(goal), between two steps")
                #expect(goal >= previous, "\(weight) \(unit) suggested less than the weight under it")
                previous = goal
            }
        }
    }

    @Test(arguments: GoalSuggestion.Unit.allCases)
    func moreActivityNeverSuggestsLess(unit: GoalSuggestion.Unit) {
        for weight in unit.range {
            let goals = GoalSuggestion.Activity.allCases.map {
                GoalSuggestion.goal(weight: weight, unit: unit, activity: $0)
            }
            #expect(goals == goals.sorted(), "\(weight) \(unit): \(goals)")
        }
    }
}
