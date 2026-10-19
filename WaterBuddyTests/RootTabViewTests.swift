//
//  RootTabViewTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 29/08/26.
//

import Foundation
import SwiftUI
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

    /// On the app's own bar, below iOS 26, three slots share a bar capped at 420pt, so each is
    /// 140pt wide before padding — comfortably past the 44pt floor. A fourth would put this back
    /// under review (rule `65-accessibility`). Apple's bar lays its own slots out.
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

    /// The week widget's link opens History (spec 2026-10-19-the-widget-stage §3.6, rule `50-views`).
    @Test func theWeekWidgetsLinkOpensHistory() throws {
        let link = try #require(WidgetLink.history, "the week widget has no link to set")
        #expect(AppTab(link: link) == .history)
    }

    /// Only the link a widget sets turns a page — a whole-URL match.
    @Test(arguments: ["waterbuddy://home", "waterbuddy://", "waterbuddy://history/today", "https://history", "history"])
    func anyOtherLinkOpensNothing(_ link: String) throws {
        let url = try #require(URL(string: link))
        #expect(AppTab(link: url) == nil)
    }
}

// MARK: - The shade under Apple's bar

/// The shade the screens draw under Apple's tab bar, as numbers. Not `@MainActor`: ``BarShade`` is
/// `nonisolated` on purpose (rule `43-concurrency`).
struct BarShadeTests {

    /// **Measured, not chosen.** On iOS 26.5 the system draws the selected tab's lozenge lighter
    /// than the bar and mixes its caption toward it: over the bare aurora that caption read
    /// 3.79–4.46:1 against the 4.5:1 floor, whatever tint the bar was given. The lozenge follows
    /// what is behind the bar, so the ground there is darkened: at `0.20` the worst frame of a
    /// minute read 4.78:1, and `0.25` is the first rung with room (`docs/DESIGN.md`, *Apple's
    /// tab bar, measured*). Re-take the figures before lowering it; never estimate one rung from
    /// another.
    @Test func theShadeIsNoLighterThanTheFirstRungWithRoom() {
        #expect(BarShade.opacity >= 0.25)
    }

    /// It darkens the ground under the bar; it is not a plate over the aurora.
    @Test func theShadeLeavesTheAuroraShowing() {
        #expect(BarShade.opacity <= 0.5)
    }

    /// The shade fades in above the bar, and that ramp is no taller than the padding Home keeps
    /// at its foot — so where Home fits its screen, it dims nothing Home draws.
    @Test func theRampFitsInsideHomesFoot() {
        #expect(BarShade.ramp > 0)
        #expect(BarShade.ramp <= HomeView.columnPadding.bottom)
    }
}
