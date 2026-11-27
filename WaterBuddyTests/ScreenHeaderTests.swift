//
//  ScreenHeaderTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 11/10/26.
//

import SwiftUI
import Testing
@testable import WaterBuddy

/// The numbers the three tabs share. Not `@MainActor`: everything read here is `nonisolated` on
/// purpose (rule `43-concurrency`), and the suite is the canary that keeps it so.
struct ScreenMetricsTests {

    /// History's week card gives each of its seven days one slot across the card, inside the
    /// margin and the row's own inset. On the narrowest supported iPhone that slot must still be a
    /// tap target — measured on the slot the card draws, not on the screen's width alone, which is
    /// how stage 3c's inset slipped under the floor unseen.
    @Test func sevenDaysClearTheTapFloorOnTheNarrowestPhone() {
        let card = 375 - 2 * ScreenMetrics.margin
        #expect(HistoryView.daySlot(across: card, count: DataManager.historyWindow) >= 44)
    }

    /// Home's five drinks stand on one line on the narrowest supported iPhone at the default text size, in
    /// every language the app speaks — so the row scrolls only at the larger sizes (`DrinkPicker`). Measured
    /// in the font the capsules draw, from each language's own names, every capsule at its bold width, which
    /// it keeps whether chosen or not. The walk found the first row 337 pt wide in English against Home's 327
    /// (2026-11-27).
    @Test func theFiveDrinksFitHomeOnTheNarrowestPhoneInEveryLanguage() {
        let row = 375 - HomeView.columnPadding.leading - HomeView.columnPadding.trailing
        func font(_ weight: UIFont.Weight) -> UIFont {
            let system = UIFont.systemFont(ofSize: DrinkPicker.typeSize, weight: weight)
            let rounded = system.fontDescriptor.withDesign(.rounded) ?? system.fontDescriptor
            return UIFont(descriptor: rounded, size: DrinkPicker.typeSize)
        }
        func capsule(_ name: String) -> CGFloat {
            let text = ceil((name as NSString).size(withAttributes: [.font: font(.bold)]).width)
            return max(text + 2 * DrinkPicker.capsuleInset, DrinkPicker.capsuleMinimumWidth)
        }
        for language in AppLanguage.selectable {
            let names = Drink.allCases.map { language.bundle.localizedString(forKey: $0.nameKey, value: nil, table: nil) }
            // English's names are its keys; any other language that returns them never resolved its bundle.
            if language != .english {
                #expect(names != Drink.allCases.map(\.nameKey), "\(language.rawValue)'s names did not resolve")
            }
            let width = names.map(capsule).reduce(0, +) + DrinkPicker.spacing * CGFloat(names.count - 1)
            #expect(width <= row, "\(language.rawValue)'s row is \(width) pt against \(row)")
        }
    }

    /// One margin and one top inset, read by every screen — which is what puts a title in one
    /// place on all of them.
    @Test func everyScreenReadsTheSameNumbers() {
        #expect(HomeView.columnPadding.leading == ScreenMetrics.margin)
        #expect(HomeView.columnPadding.trailing == ScreenMetrics.margin)
        #expect(HomeView.columnPadding.top == ScreenMetrics.topInset)
        #expect(HistoryView.margin == ScreenMetrics.margin)
    }

    /// The title's line is as tall as the tallest thing that may share it, so a 36 pt chip and a
    /// 44 pt button do not centre the title at two heights.
    @Test func theTitlesLineIsAsTallAsATapTarget() {
        #expect(ScreenMetrics.titleLine >= 44)
    }

    @Test func aSlotOfNothingIsNotADivisionByZero() {
        #expect(ScreenMetrics.slot(of: 0, across: 375).isFinite)
    }
}
