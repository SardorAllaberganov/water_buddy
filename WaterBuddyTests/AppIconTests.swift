//
//  AppIconTests.swift
//  WaterBuddyTests
//

import Testing
import UIKit
@testable import WaterBuddy

/// The icon each theme brings (spec `2026-11-22-set-c-design.md` §3.7). Not `@MainActor`: the names are plain values.
struct AppIconTests {

    @Test func auroraIsThePrimaryAndEveryOtherThemeHasItsAlternate() {
        #expect(AppTheme.aurora.iconName == nil)
        #expect(AppTheme.allCases.dropFirst().map(\.iconName) == ["AppIcon-Lagoon", "AppIcon-Dusk", "AppIcon-Midnight", "AppIcon-Bloom"])
    }

    @Test func iOSsIconNameReadsBackAsItsTheme() {
        for theme in AppTheme.allCases {
            #expect(AppTheme.icon(named: theme.iconName) == theme)
        }
        #expect(AppTheme.icon(named: "AppIcon-Unknown") == .aurora)
    }

    /// The picker draws these: a missing image draws nothing at all.
    @Test(arguments: AppTheme.allCases)
    func everyPreviewIsInTheBundle(_ theme: AppTheme) {
        #expect(UIImage(named: theme.iconPreviewName) != nil, "\(theme.iconPreviewName)")
    }
}
