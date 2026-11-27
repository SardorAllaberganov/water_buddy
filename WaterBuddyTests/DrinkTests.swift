//
//  DrinkTests.swift
//  WaterBuddyTests
//

import Foundation
import Testing
@testable import WaterBuddy

/// The drinks a serving can be (spec `2026-11-27-other-drinks-design.md` §3.1, R1) and Home's choice among
/// them (R3, D4). Not `@MainActor`: a canary that `Drink` and `DrinkChoice` stay `nonisolated` (rule
/// `43-concurrency`).
struct DrinkTests {

    /// Water first, then the roadmap's four, in the row's order (R1).
    @Test func theDrinksAreWaterAndTheRoadmapsFourInTheRowsOrder() {
        #expect(Drink.allCases == [.water, .tea, .coffee, .juice, .milk])
    }

    /// Water stores no code, so every serving logged before 1.5 is water with nothing rewritten (D1).
    @Test func waterStoresNoCodeAndEveryOtherDrinkItsOwn() {
        #expect(Drink.water.code == nil)
        #expect(Drink.allCases.dropFirst().map(\.code) == ["tea", "coffee", "juice", "milk"])
    }

    /// A code this build does not know — written by a later one — still counts, as water (D1).
    @Test func aMissingOrUnknownCodeReadsAsWater() {
        #expect(Drink(code: nil) == .water)
        #expect(Drink(code: "lemonade") == .water)
        #expect(Drink(code: "") == .water)
        for drink in Drink.allCases where drink != .water {
            #expect(Drink(code: drink.code) == drink)
        }
    }

    /// The catalogues' keys, and the export's words: fixed English in every language, like its headings (R6).
    @Test func eachDrinkHasANameKeyAndAnExportWord() {
        #expect(Drink.allCases.map(\.nameKey) == ["Water", "Tea", "Coffee", "Juice", "Milk"])
        #expect(Drink.allCases.map(\.rawValue) == ["water", "tea", "coffee", "juice", "milk"])
    }

    /// Home's row: water when the app opens, the drink a tap chooses, and water again once the app goes to
    /// the background (R3, D4).
    @Test func homesChoiceStartsOnWaterAndReturnsToWaterInTheBackground() {
        var choice = DrinkChoice()
        #expect(choice.drink == .water)
        choice.choose(.coffee)
        #expect(choice.drink == .coffee)
        choice.choose(.tea)
        #expect(choice.drink == .tea)
        choice.appWentToBackground()
        #expect(choice.drink == .water)
    }

    /// The sheet's five stand on one line where it fits, and on the fewest even lines where it does not: of the
    /// splits into two, three over two is the one whose wider line is narrowest. Worked by hand, spacing 6:
    /// one line 64 + 45 + 68 + 59 + 52 + 24 = 312; four over one 254; three over two 189 over 117; two over
    /// three 115 over 191; one over four 64 over 242.
    @Test func theSheetsDrinksStandOnTheFewestEvenLinesThatFit() {
        let widths: [CGFloat] = [64, 45, 68, 59, 52]
        #expect(DrinkPicker.lines(widths: widths, spacing: 6, within: 312) == [[0, 1, 2, 3, 4]])
        #expect(DrinkPicker.lines(widths: widths, spacing: 6, within: 311) == [[0, 1, 2], [3, 4]])
        // 189 still fits, and three over two is still the narrowest.
        #expect(DrinkPicker.lines(widths: widths, spacing: 6, within: 189) == [[0, 1, 2], [3, 4]])
    }

    /// Where two splits are as wide, the longer line stands on top: five of 50 at spacing 6 in 200 are three
    /// (162) over two (106) or two over three, and in 110 two, two and one — never one drink first.
    @Test func aTieStandsTheLongerLineOnTop() {
        let widths: [CGFloat] = [50, 50, 50, 50, 50]
        #expect(DrinkPicker.lines(widths: widths, spacing: 6, within: 200) == [[0, 1, 2], [3, 4]])
        #expect(DrinkPicker.lines(widths: widths, spacing: 6, within: 110) == [[0, 1], [2, 3], [4]])
    }

    /// A drink wider than the line on its own still gets a line, and nothing is dropped: no split fits a
    /// 300-pt name in 100, so each stands alone.
    @Test func aDrinkWiderThanTheLineStillGetsOne() {
        #expect(DrinkPicker.lines(widths: [300, 40], spacing: 6, within: 100) == [[0], [1]])
        #expect(DrinkPicker.lines(widths: [], spacing: 6, within: 100) == [])
    }

    /// At every width, every drink stands once and in the row's order, and every line of more than one fits.
    @Test func everyDrinkStandsOnceInOrderAndEveryLineFits() {
        let widths: [CGFloat] = [64, 45, 68, 59, 52]
        for within in stride(from: CGFloat(40), through: 400, by: 7) {
            let lines = DrinkPicker.lines(widths: widths, spacing: 6, within: within)
            #expect(lines.flatMap { $0 } == Array(0..<5), "at \(within) the lines are \(lines)")
            for line in lines where line.count > 1 {
                let span = line.map { widths[$0] }.reduce(0, +) + 6 * CGFloat(line.count - 1)
                #expect(span <= within, "at \(within) the line \(line) is \(span) wide")
            }
        }
    }
}
