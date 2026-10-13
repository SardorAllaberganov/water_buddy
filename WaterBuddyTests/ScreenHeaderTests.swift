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
