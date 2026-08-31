//
//  AppLanguageTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 29/08/26.
//

import Foundation
import Testing
@testable import WaterBuddy

// MARK: - Tests

/// The language **menu**, and the bundle each entry resolves to.
///
/// Deliberately **not** `@MainActor`, and that is load-bearing rather than tidy: ``AppLanguage`` is
/// read by ``DataManager/snapshot(defaults:calendar:now:)``, which a `TimelineProvider` calls with
/// no isolation at all. If this type ever needed the main actor the widget could not pick a
/// language, and **this suite would stop compiling** — which is the warning we want
/// (rule `43-concurrency`).
struct AppLanguageTests {

    /// The picker offers exactly what the app ships, and nothing else.
    ///
    /// A fourth entry here with no `.lproj` behind it would silently select English while claiming
    /// otherwise — the worst kind of language switcher, because the user's own language is the one
    /// thing they can check.
    @Test func theOfferedLanguagesAreExactlyTheOnesShipped() {
        let offered = Set(AppLanguage.selectable.map(\.code))
        let shipped = Set(
            ["en", "ru", "uz"].filter { Bundle.main.url(forResource: $0, withExtension: "lproj") != nil }
        )

        // `en` is the development language, so it may live in the binary rather than an `.lproj`.
        #expect(offered.subtracting(["en"]) == shipped.subtracting(["en"]),
                "the picker offers \(offered) but the bundle ships \(shipped)")
    }

    /// ``AppLanguage/system`` means **no stored preference**, which is why it has no code: absence
    /// is what carries the meaning, exactly as it does for `isGoalSet` and `remindersEnabled`
    /// (rule `25-shared-storage`).
    @Test func theSystemEntryIsTheAbsenceOfAChoice() {
        #expect(AppLanguage.system.code == nil,
                "a code would be written to the suite, and then 'follow the device' would be stored state")
        #expect(!AppLanguage.selectable.contains(.system),
                "the system entry is not one of the shipped localisations")
        #expect(AppLanguage.allCases.first == .system,
                "following the device is the default, so it is the top of the picker")
        #expect(AppLanguage.allCases.count == AppLanguage.selectable.count + 1)
    }

    /// Every entry the picker offers has to resolve to a bundle that actually answers.
    @Test(arguments: AppLanguage.allCases)
    func everyLanguageResolvesToABundleThatAnswers(language: AppLanguage) {
        let bundle = language.bundle
        let resolved = bundle.localizedString(forKey: "Settings", value: "<missing>", table: nil)

        #expect(resolved != "<missing>",
                "\(language) resolves to a bundle with no strings table")
    }

    /// The whole point: two different choices produce two different strings.
    @Test func differentLanguagesResolveDifferentStrings() {
        let english = AppLanguage.english.bundle.localizedString(forKey: "Settings", value: nil, table: nil)
        let russian = AppLanguage.russian.bundle.localizedString(forKey: "Settings", value: nil, table: nil)
        let uzbek = AppLanguage.uzbek.bundle.localizedString(forKey: "Settings", value: nil, table: nil)

        #expect(english == "Settings")
        #expect(russian == "Настройки")
        #expect(uzbek == "Sozlamalar")
    }

    /// A corrupt or future code must degrade to following the device rather than to a blank UI —
    /// **fail soft, and loudly** is the house rule, and there is a `DEBUG` diagnostic behind it
    /// (rule `75-diagnostics`).
    @Test(arguments: ["", "fr", "en-GB", "🙂", "ru_RU"])
    func anUnrecognisedStoredCodeFallsBackToTheSystem(stored: String) {
        #expect(AppLanguage(code: stored) == .system,
                "\"\(stored)\" should not select a language the app does not ship")
    }

    @Test(arguments: AppLanguage.allCases)
    func everyEntryHasANameToShowInThePicker(language: AppLanguage) {
        for bundle in AppLanguage.allCases.map(\.bundle) {
            #expect(!language.name(in: bundle).isEmpty)
        }
    }

    /// Each language names itself in its own script. A picker that lists "Russian" in English is
    /// unreadable to precisely the person looking for it.
    @Test func eachLanguageNamesItselfInItsOwnScript() {
        // Untranslated, and the bundle is therefore irrelevant for these three — which is the
        // property being asserted. A Russian speaker hunting for their language should not have to
        // read the word "Russian" in a language they do not have.
        for bundle in AppLanguage.allCases.map(\.bundle) {
            #expect(AppLanguage.english.name(in: bundle) == "English")
            #expect(AppLanguage.russian.name(in: bundle) == "Русский")
            #expect(AppLanguage.uzbek.name(in: bundle) == "O‘zbekcha")
        }

        let names = AppLanguage.allCases.map { $0.name(in: AppLanguage.english.bundle) }
        #expect(Set(names).count == names.count, "two entries reading the same in the picker")
    }

    /// *Follow device* is the one entry that **is** translated — it names a behaviour, not a
    /// language, so it has to be legible in whatever the UI is currently drawing.
    @Test func followDeviceIsTranslatedEvenThoughTheOthersAreNot() {
        #expect(AppLanguage.system.name(in: AppLanguage.english.bundle) == "Follow device")
        #expect(AppLanguage.system.name(in: AppLanguage.russian.bundle) == "Как на устройстве")
        #expect(AppLanguage.system.name(in: AppLanguage.uzbek.bundle) == "Qurilmadagidek")
    }
}
