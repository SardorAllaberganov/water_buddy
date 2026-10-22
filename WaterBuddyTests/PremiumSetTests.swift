//
//  PremiumSetTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 21/10/26.
//

import Foundation
import Testing
import UIKit
@testable import WaterBuddy

/// Set A as the paywall and the card draw it (spec `2026-10-21-premium-paywall-and-monthly-design.md`
/// §3.6). The suite is not `@MainActor`: the switch reads the sets from off it.
struct PremiumSetTests {

    @Test func setAListsItsFourFeaturesInOrder() {
        #expect(PremiumSet.allCases == [.understand])
        #expect(PremiumSet.understand.features == [.monthView, .patterns, .insights, .recap])
    }

    /// Step 5 of the spec's §1 puts set A on sale, with the recap — and changes this test with it.
    @Test func setAIsNotOnSaleUntilItsLastFeatureIsBuilt() {
        #expect(!PremiumSet.understand.isOnSale)
        #expect(PremiumSet.onSale.isEmpty)
    }

    /// An unknown symbol draws nothing at all (rule `65-accessibility`).
    @Test @MainActor func everyFeatureGlyphResolves() {
        for feature in PremiumSet.Feature.allCases {
            #expect(UIImage(systemName: feature.symbol) != nil, "\(feature.symbol) draws nothing")
        }
    }

    @Test func theCardPreviewsEveryFeatureButTheRecap() {
        let strings = Bundle.main
        #expect(PremiumSet.Feature.recap.caption(in: strings) == nil)
        #expect(PremiumSet.Feature.allCases.filter { $0.caption(in: strings) != nil } == [.monthView, .patterns, .insights])
    }
}
