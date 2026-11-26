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
            ["en", "ru", "uz", "es-419"].filter { Bundle.main.url(forResource: $0, withExtension: "lproj") != nil }
        )

        // `en` is the development language, so it may live in the binary rather than an `.lproj`.
        #expect(offered.subtracting(["en"]) == shipped.subtracting(["en"]),
                "the picker offers \(offered) but the bundle ships \(shipped)")
        #expect(shipped.contains("es-419"), "the app ships no es-419.lproj")
    }

    /// Spanish is Latin America's, `es-419`: one spelling for the stored code, the bundle and the
    /// locale, as `ru` and `uz` have one each (spec `2026-11-26-spanish-and-language-selector-design.md`
    /// R1, D1). It goes last, so nobody's list moves (D2).
    @Test func spanishIsLatinAmericasAndComesLast() {
        #expect(AppLanguage.spanish.code == "es-419")
        #expect(AppLanguage(code: "es-419") == .spanish)
        #expect(AppLanguage.selectable == [.english, .russian, .uzbek, .spanish])
    }

    /// An explicit *Español* writes figures as Mexico does, as the Spanish (Mexico) store page does:
    /// *2,000*, never Spain's *2000* (R1).
    @Test func spanishWritesFiguresTheWayLatinAmericaDoes() {
        let locale = AppLanguage.spanish.locale

        #expect(2_000.formatted(.number.locale(locale)) == "2,000")
        #expect(12_500.formatted(.number.locale(locale)) == "12,500")
    }

    /// *Follow device* on any Spanish phone reaches the one Spanish table, by iOS's own matching —
    /// measured with Foundation on macOS while the spec was written, and pinned here on the simulator.
    @Test(arguments: ["es-MX", "es-ES", "es-US", "es-AR", "es"])
    func everySpanishPhoneGetsTheSpanishTable(preference: String) {
        let shipped = ["en", "ru", "uz", "es-419"]

        #expect(Bundle.preferredLocalizations(from: shipped, forPreferences: [preference, "en"]) == ["es-419"],
                "a phone in \(preference) would not get the Spanish table")
    }

    /// Each language greets in its own words, untranslated as its name is (spec §4.2, D3a). The sheet
    /// draws the greeting beside the name; *Follow device* has none.
    @Test func eachLanguageGreetsInItsOwnWords() {
        #expect(AppLanguage.system.greeting == nil)
        #expect(AppLanguage.english.greeting == "Hello")
        #expect(AppLanguage.russian.greeting == "Привет")
        #expect(AppLanguage.uzbek.greeting == "Salom")
        #expect(AppLanguage.spanish.greeting == "Hola")
    }

    /// *Follow device*'s second line names the language it draws today: the bundle's own resolution, so
    /// English on a phone in a language the app does not ship (spec §4.2, D5).
    @Test(arguments: [
        (["es-419"], AppLanguage.spanish),
        (["ru"], AppLanguage.russian),
        (["uz", "en"], AppLanguage.uzbek),
        (["en"], AppLanguage.english),
        ([], AppLanguage.english),
        (["Base"], AppLanguage.english),
    ])
    func followDeviceNamesTheLanguageItDraws(preferred: [String], drawn: AppLanguage) {
        #expect(AppLanguage.drawnOnFollowDevice(preferredLocalizations: preferred) == drawn)
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
        let spanish = AppLanguage.spanish.bundle.localizedString(forKey: "Settings", value: nil, table: nil)

        #expect(english == "Settings")
        #expect(russian == "Настройки")
        #expect(uzbek == "Sozlamalar")
        #expect(spanish == "Configuración")
    }

    /// A corrupt or future code must degrade to following the device rather than to a blank UI —
    /// **fail soft, and loudly** is the house rule, and there is a `DEBUG` diagnostic behind it
    /// (rule `75-diagnostics`).
    @Test(arguments: ["", "fr", "en-GB", "🙂", "ru_RU", "es", "es-MX"])
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
            #expect(AppLanguage.spanish.name(in: bundle) == "Español")
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
        #expect(AppLanguage.system.name(in: AppLanguage.spanish.bundle) == "Como en el dispositivo")
    }
}
