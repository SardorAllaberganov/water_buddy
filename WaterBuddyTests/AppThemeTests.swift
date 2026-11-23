//
//  AppThemeTests.swift
//  WaterBuddyTests
//

import Foundation
import Testing
@testable import WaterBuddy

/// The stored theme's codes and names (spec `2026-11-22-set-c-design.md` D9). **Deliberately not `@MainActor`**:
/// the widget's snapshot and the watch read it (rule `43-concurrency`).
struct AppThemeTests {

    @Test func theFiveThemesInTheirOrder() {
        #expect(AppTheme.allCases == [.aurora, .lagoon, .dusk, .midnight, .bloom])
    }

    /// Aurora is the key's absence, as `.system` is the language's: "never chose" and "chose Aurora" are one state.
    @Test func auroraIsStoredAsNothing() {
        #expect(AppTheme.aurora.code == nil)
        #expect(AppTheme.allCases.dropFirst().allSatisfy { $0.code == $0.rawValue })
    }

    @Test func aStoredCodeReadsBackAndAnythingElseIsAurora() {
        for theme in AppTheme.allCases {
            #expect(AppTheme(code: theme.code) == theme)
        }
        #expect(AppTheme(code: nil) == .aurora)
        #expect(AppTheme(code: "aurora") == .aurora)
        #expect(AppTheme(code: "neon") == .aurora, "a theme this build does not know draws Aurora")
        #expect(AppTheme(code: "") == .aurora)
    }

    @Test(arguments: ["en", "ru", "uz"])
    func everyThemeIsNamedInEveryLanguage(language: String) throws {
        let bundle = try #require(AppLanguage(code: language).bundle as Bundle?)
        for theme in AppTheme.allCases {
            let name = bundle.localizedString(forKey: theme.nameKey, value: nil, table: nil)
            #expect(!name.isEmpty)
            if language != "en" {
                #expect(name != theme.nameKey, "\(theme) is untranslated in \(language)")
            }
        }
    }
}
