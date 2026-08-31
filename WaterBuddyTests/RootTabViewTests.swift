//
//  RootTabViewTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 29/08/26.
//

import Foundation
import Testing
import UIKit
@testable import WaterBuddy

// MARK: - Tests

/// The tab bar's **menu**, in the same sense as ``HomeServingTests`` and ``HistoryServingTests``:
/// what a view offers, pinned where the compiler cannot notice one of them moving.
///
/// Deliberately **not** `@MainActor`, and that is load-bearing rather than incidental. ``AppTab``
/// is a top-level enum precisely so it carries no isolation — nesting it inside a `View` would
/// inherit SwiftUI's `@MainActor` and this suite would stop compiling, which is exactly what
/// `HomeView.servings` cost before it was marked `nonisolated` (rule `43-concurrency`).
struct AppTabTests {

    /// The order is the layout. Home is first because it is the default and the left-hand slot,
    /// and a reordering here silently reorders the bar.
    ///
    /// Settings is **last**, and that is the ordinary reading of a tab bar: the two destinations
    /// the product is *for* come first, and preferences sit at the end. It arrived as a tab when
    /// the gear in `HistoryView`'s header stopped being the only way in — one screen of preferences
    /// reached through another screen's header is a route nobody finds twice.
    @Test func theTabsAreExactlyHomeHistoryAndSettingsInThatOrder() {
        #expect(AppTab.allCases == [.home, .history, .settings])
    }

    /// Three slots share a bar capped at 420pt, so each is 140pt wide before padding — comfortably
    /// past the 44pt floor. A fourth would put this back under review (rule `65-accessibility`).
    @Test func theBarHoldsThreeTabs() {
        #expect(AppTab.allCases.count == 3)
    }

    @Test func theAppOpensOnHome() {
        #expect(AppTab.opening == .home, "the app opens on the vessel, not on the log")
        #expect(AppTab.allCases.first == AppTab.opening,
                "the opening tab is not the leftmost one, so the bar opens mid-row")
    }

    /// An SF Symbol that does not resolve renders as **nothing at all** — no glyph, no warning and
    /// no failed build. In a tab bar that is an invisible control, not merely a blank icon.
    @Test(arguments: AppTab.allCases)
    func everyTabSymbolResolves(tab: AppTab) {
        #expect(UIImage(systemName: tab.symbol) != nil,
                "an unresolved SF Symbol draws an empty tab")
    }

    /// The title is drawn *and* read by VoiceOver, so an empty one is both a blank slot and an
    /// unlabelled control (rule `65-accessibility`).
    @Test(arguments: AppTab.allCases)
    func everyTabIsTitledAndSymbolled(tab: AppTab) {
        #expect(!tab.title(in: .main).isEmpty)
        #expect(!tab.symbol.isEmpty)
    }

    @Test func theTabsAreDistinguishable() {
        let titles = AppTab.allCases.map { $0.title(in: .main) }
        let symbols = AppTab.allCases.map(\.symbol)

        #expect(Set(titles).count == titles.count, "two tabs reading the same name to VoiceOver")
        #expect(Set(symbols).count == symbols.count, "two tabs drawing the same glyph")
    }
}
