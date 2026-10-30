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
        #expect(PremiumSet.allCases == [.understand, .coached])
        #expect(PremiumSet.understand.features == [.monthView, .patterns, .insights, .recap])
    }

    /// Set B (spec `2026-10-30-coaching-design.md` §3.4).
    @Test func setBListsItsThreeFeaturesInOrder() {
        #expect(PremiumSet.coached.features == [.schedule, .pace, .onlyWhenBehind])
    }

    /// Set A went on sale with the recap (spec `2026-10-24-monthly-recap-design.md` §3.8), set B with its last
    /// feature (spec `2026-10-30-coaching-design.md`).
    @Test func bothSetsAreOnSaleNowEveryFeatureIsBuilt() {
        #expect(PremiumSet.understand.isOnSale)
        #expect(PremiumSet.coached.isOnSale)
        #expect(PremiumSet.onSale == [.understand, .coached])
    }

    /// D10: Settings' Premium card keeps its three previews — four abreast break at the ordinary sizes.
    @Test func setBsFeaturesAreNotPreviewedOnTheCard() {
        for feature in PremiumSet.coached.features {
            #expect(feature.caption(in: Bundle.main) == nil, "\(feature) would join the card's previews")
        }
    }

    @Test func setBsRowsAreWordedInEveryLanguage() {
        for language in [AppLanguage.english, .russian, .uzbek] {
            let strings = language.bundle
            #expect(strings.bundleURL.lastPathComponent == "\(language.code ?? "").lproj")
            for feature in PremiumSet.coached.features {
                let title = feature.title(in: strings), line = feature.line(in: strings)
                #expect(!title.isEmpty && !line.isEmpty)
                #expect(!title.contains { $0.isNumber } && !line.contains { $0.isNumber })
                #expect(language == .english || title != feature.title(in: AppLanguage.english.bundle),
                        "\(language.code ?? ""): \(title) was not translated")
            }
        }
        #expect(PremiumSet.Feature.schedule.title(in: AppLanguage.english.bundle) == "Your own reminder schedule")
    }

    /// An unknown symbol draws nothing at all (rule `65-accessibility`).
    @Test @MainActor func everyFeatureGlyphResolves() {
        for feature in PremiumSet.Feature.allCases {
            #expect(UIImage(systemName: feature.symbol) != nil, "\(feature.symbol) draws nothing")
        }
    }

    /// The insights row names Apple's on-device model nowhere, and never *Apple Intelligence*: Apple's
    /// marks are never part of a feature's name, and the model writes only English (spec
    /// `2026-10-23-insights-design.md` §3.9, the owner's ruling on #164).
    @Test func theInsightsRowCarriesNoAppleMark() {
        for language in [AppLanguage.english, .russian, .uzbek] {
            let code = language.code ?? ""
            let strings = language.bundle
            #expect(strings.bundleURL.lastPathComponent == "\(code).lproj", "the \(code) strings did not resolve")
            let feature = PremiumSet.Feature.insights
            for words in [feature.title(in: strings), feature.line(in: strings), feature.caption(in: strings) ?? ""] {
                #expect(!words.contains("Apple Intelligence"), "\(code): \(words)")
                #expect(!words.contains("AI") && !words.contains("ИИ"), "\(code): \(words)")
            }
        }
        #expect(PremiumSet.Feature.insights.title(in: AppLanguage.english.bundle) == "Personal insights")
    }

    @Test func theCardPreviewsEveryFeatureButTheRecap() {
        let strings = Bundle.main
        #expect(PremiumSet.Feature.recap.caption(in: strings) == nil)
        #expect(PremiumSet.Feature.allCases.filter { $0.caption(in: strings) != nil } == [.monthView, .patterns, .insights])
    }
}
