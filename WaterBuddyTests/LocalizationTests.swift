//
//  LocalizationTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 29/08/26.
//

import Foundation
import Testing
@testable import WaterBuddy

// MARK: - Fixtures

/// The languages the product ships beyond its development language.
private let translated = ["ru", "uz"]

/// The app bundle, which hosts this test target.
private let appBundle = Bundle.main

/// The widget extension, embedded inside the app it belongs to.
///
/// Reaching it this way — through the *built* app rather than through the source tree — is the
/// whole point of this suite. An earlier version read the two `.xcstrings` files off disk with
/// `#filePath`, which is wrong twice over: it asserts the *inputs* rather than the artifact, and
/// these tests execute on the simulator, where a host path under `~/Desktop` is TCC-protected and
/// the read blocks on a privacy prompt no headless run can answer. That version did not fail — it
/// hung the gate.
private let widgetBundle = Bundle(
    url: appBundle.bundleURL.appending(path: "PlugIns/WaterBuddyWidgetExtension.appex")
)

/// The watch app, embedded inside the phone app the way it ships. The watch's own test target
/// cannot make the comparisons below — it is hosted by the watch app and cannot see the phone's
/// bundle — so this suite is the one place all four bundles are in reach.
private let watchBundle = Bundle(
    url: appBundle.bundleURL.appending(path: "Watch/WaterBuddyWatch.app")
)

/// The complication's extension, embedded inside the watch app.
private let watchWidgetBundle = watchBundle.flatMap {
    Bundle(url: $0.bundleURL.appending(path: "PlugIns/WaterBuddyWatchWidget.appex"))
}

/// Every phone string the watch draws, copied into the watch's own catalogue value for value
/// (`docs/superpowers/specs/2026-10-06-watch-localization-design.md` §4.4).
private let watchSharedKeys = [
    "Today's hydration",
    "%1$d percent. %2$d of %3$d millilitres.",
    "%1$d ml",
    "Cup",
    "Glass",
    "Bottle",
]

/// The watch's own strings, which have no phone equivalent. Listed by name because the build
/// extracts only `Text` literals: a key resolved with `localizedString(forKey:)` never reaches the
/// extracted table, so a coverage check cannot see one go missing — the gap
/// `theShortcutsVocabularyIsTranslated` exists for.
private let watchOwnKeys = [
    "%1$@ / %2$@ ml",
    "Logs %1$d millilitres",
    "More",
    "Shows the other serving sizes",
    "Not yet synced · default goal",
    "Set your goal in WaterBuddy on iPhone",
    "Not yet synced",
    "Synced just now",
    "Synced %1$dm ago",
]

/// Every string the widget draws or files, and therefore every string that has to exist in **both**
/// bundles.
///
/// `NotificationManager` is one of the six shared files and `AddWaterIntent` reschedules from the
/// extension, so the reminder copy is on this list even though nothing in the widget's view tree
/// renders it.
private let sharedKeys = [
    "Hydration",
    "Track today's hydration and log a glass without opening the app.",
    "Today's hydration",
    "%1$d ml",
    "of %1$d ml",
    "+%1$d ml",
    "%1$d percent. %2$d of %3$d millilitres.",
    "Add %1$d millilitres",
    "Time for water",
    "A glass now keeps you on track for the day.",
]

/// Home's strings. Listed by name because each is resolved with `localizedString(forKey:)` or
/// through ``Bundle/figure(_:_:locale:)``, which the build's extraction cannot see: a key that
/// went missing would fall back to drawing itself, in English, with nothing to notice.
private let homeKeys = [
    "%1$@ of %2$@ ml",
    "%1$@ ml",
    "%1$@ ml to go",
    "%1$d millilitres to go",
    "Goal reached",
    "Next reminder %1$@",
    "Last drink %1$@",
    "Added %1$@ ml",
    "Undo",
    "Day streak",
]

/// History's strings that the build's extraction cannot see — resolved with
/// `localizedString(forKey:)` or through ``Bundle/figure(_:_:locale:)`` — and the labels drawn
/// beside them.
private let historyKeys = [
    "Average",
    "Best day",
    "Goal met",
    "%1$@ of %2$@",
    "When you drank",
    "Average %1$d millilitres. Best %2$d millilitres. Goal met on %3$d of %4$d days.",
]

/// The welcome's own strings (spec 2026-10-14 §8). The keys it shares with Settings or the reminder
/// are checked where those are.
private let welcomeKeys = [
    "One tap logs a glass. Watch your day fill up.",
    "Continue",
    "Back",
    "Home pours these in one tap. Set each to what yours holds.",
    "You can change these later in Settings.",
    "Reminders",
    "A gentle nudge when it has been a while.",
    "Turn on reminders",
    "Not now",
    "Step %1$d of %2$d",
    "now",
    "Work it out for me",
    "Your weight",
    "kg",
    "lb",
    "%1$d kg",
    "%1$d lb",
    "How active are you?",
    "Light",
    "Moderate",
    "Active",
    "Mostly sitting",
    "Exercise some days",
    "Exercise most days",
    "Use %1$@ ml",
    "Use %1$d millilitres",
    "Your goal is %1$@ ml",
    "A starting point, not medical advice.",
]

private let reminderCopy = ["Time for water", "A glass now keeps you on track for the day."]

/// The `.lproj` for one language inside one bundle, or `nil` if that language was not shipped.
private func localization(_ bundle: Bundle?, _ language: String) -> Bundle? {
    bundle?.url(forResource: language, withExtension: "lproj").flatMap(Bundle.init(url:))
}

/// A sentinel no translation could ever be, so a **missing** key is distinguishable from one whose
/// translation happens to equal the English.
///
/// That distinction is not academic. `%1$d ml` and `+%1$d ml` are correct *and identical* in
/// Uzbek, so "the value differs from the key" cannot mean "the key was found" — the first version
/// of this suite asserted exactly that and failed on two strings that were right.
private let missingMarker = "\u{0}__missing__\u{0}"

/// What a bundle returns for a key in a given language, or `nil` if the table has no such key.
private func value(_ bundle: Bundle?, _ language: String, _ key: String) -> String? {
    guard let lproj = localization(bundle, language) else { return nil }
    let resolved = lproj.localizedString(forKey: key, value: missingMarker, table: nil)
    return resolved == missingMarker ? nil : resolved
}

/// The whole compiled table for one language, straight out of the bundle.
///
/// `Localizable.strings` in a built bundle is a binary plist, which `NSDictionary` reads. Going
/// through the table rather than key-by-key is what lets a test assert something about *all* the
/// strings without a hardcoded list that would itself go stale.
private func table(_ bundle: Bundle?, _ language: String) -> [String: String]? {
    guard let url = localization(bundle, language)?
        .url(forResource: "Localizable", withExtension: "strings") else { return nil }
    return NSDictionary(contentsOf: url) as? [String: String]
}

/// Every `%1$d` / `%2$@` token in a format string, as a set.
private func specifiers(in text: String) -> Set<String> {
    guard let pattern = try? NSRegularExpression(pattern: "%\\d+\\$[@ds]") else { return [] }
    let range = NSRange(text.startIndex..., in: text)
    return Set(pattern.matches(in: text, range: range).compactMap {
        Range($0.range, in: text).map { String(text[$0]) }
    })
}

// MARK: - Tests

/// The app ships in English, Russian and Uzbek, and **the widget carries its own copy of the
/// strings it needs.**
///
/// That duplication is not a preference, it is what the toolchain allows. `Localizable.xcstrings`
/// was first put in `WaterBuddy/` and added to the widget's `membershipExceptions`, exactly as the
/// six shared `.swift` files are — and it does not work: `xcodebuild` ran `xcstringstool` against
/// the *app* target's build directory only, the `.appex` came out with no `.lproj` at all, and the
/// build then **rewrote `project.pbxproj` to delete the entry**. A synchronized-folder membership
/// exception carries source, not resources.
///
/// So there are two catalogues, and this suite is what stops them drifting — the failure the
/// shared-file contract normally prevents by construction (rule `10-architecture`).
@Suite struct LocalizationTests {

    @Test func theWidgetExtensionIsWhereWeThinkItIs() {
        #expect(widgetBundle != nil,
                "no .appex inside the test host — every assertion below would pass vacuously")
    }

    /// **The regression test for the `membershipExceptions` attempt.**
    ///
    /// It went green on the app and silently shipped an English-only widget. Asserting the
    /// *extension* carries the languages is the only form of this check that would have caught it.
    @Test(arguments: translated)
    func bothBundlesShipTheLanguage(language: String) {
        #expect(localization(appBundle, language) != nil,
                "the app does not ship \(language)")
        #expect(localization(widgetBundle, language) != nil,
                "the widget extension does not ship \(language) — it will draw English")
    }

    /// **Presence in the table, not difference from the key.**
    ///
    /// `localizedString` hands back the key itself when a lookup misses, so a missing translation
    /// is silent by construction — but a translation that legitimately *equals* the English is
    /// indistinguishable from that by comparison alone. `%1$d ml` is the same string in Uzbek and
    /// is perfectly correct. Asking the table via ``missingMarker`` separates the two cases.
    @Test(arguments: translated)
    func everySharedKeyIsPresentInBothBundles(language: String) {
        for key in sharedKeys {
            for (name, bundle) in [("app", appBundle), ("widget", widgetBundle)] as [(String, Bundle?)] {
                #expect(value(bundle, language, key) != nil,
                        "\(name): \"\(key)\" is absent from the \(language) table, so it will draw English")
            }
        }
    }

    /// **The two catalogues agree, value for value.**
    ///
    /// This is the reason the suite exists. Two files holding one key is fine right up until
    /// somebody improves a translation in one of them.
    @Test(arguments: translated)
    func theWidgetAgreesWithTheAppOnEverySharedString(language: String) {
        for key in sharedKeys {
            #expect(value(appBundle, language, key) == value(widgetBundle, language, key),
                    "\"\(key)\" differs between the app and the widget in \(language)")
        }
    }

    /// A translation that drops or invents a positional argument produces wrong output from
    /// `String(format:)` — silently, and only in that language. Positional (`%1$d`) rather than
    /// bare `%d` is precisely so a translator *may* reorder; the set has to survive the reordering.
    @Test(arguments: translated)
    func everyTranslationKeepsTheFormatArgumentsOfItsKey(language: String) {
        for key in sharedKeys {
            let expected = specifiers(in: key)
            guard !expected.isEmpty, let resolved = value(appBundle, language, key) else { continue }

            #expect(specifiers(in: resolved) == expected,
                    "\"\(key)\" in \(language) does not carry the same format arguments")
        }
    }

    /// Rule `70-privacy` and rule `80-notifications`: a delivered banner renders on a locked
    /// screen, in public, outside the App Group boundary — so the reminder names no total, no goal
    /// and no serving. `theReminderCopyCarriesNoUserValues` asserts that of the English; adding two
    /// languages is exactly the moment a number could creep back in.
    @Test(arguments: translated)
    func theTranslatedReminderCopyStillCarriesNoUserValues(language: String) {
        for key in reminderCopy {
            for (name, bundle) in [("app", appBundle), ("widget", widgetBundle)] as [(String, Bundle?)] {
                guard let resolved = value(bundle, language, key) else { continue }
                let carriesADigit = resolved.contains(where: \.isNumber)
                #expect(!carriesADigit,
                        "\(name): the \(language) reminder copy contains a digit — \"\(resolved)\"")
            }
        }
    }

    /// **Russian and Uzbek cover exactly the same keys.**
    ///
    /// The per-key checks above only reach the ten strings the widget shares. This one reads the
    /// compiled tables whole, so it covers every string in the app — and catches the failure that
    /// actually happens when a catalogue is edited by hand: a key translated into one language and
    /// forgotten in the other, which falls back to English for half the users and is invisible to
    /// anyone testing in the other half.
    @Test func bothLanguagesCoverExactlyTheSameKeys() {
        for (name, bundle) in [("app", appBundle), ("widget", widgetBundle)] as [(String, Bundle?)] {
            guard let ru = table(bundle, "ru"), let uz = table(bundle, "uz") else {
                Issue.record("\(name): could not read the compiled string tables")
                continue
            }

            // One interpolated *literal*, never a concatenation: swift-testing's `Comment` is
            // `ExpressibleByStringInterpolation`, so a built `String` does not convert
            // (`tasks/lessons.md`).
            let onlyRu = Set(ru.keys).subtracting(uz.keys).sorted()
            let onlyUz = Set(uz.keys).subtracting(ru.keys).sorted()

            #expect(onlyRu.isEmpty, "\(name): translated into ru but not uz — \(onlyRu)")
            #expect(onlyUz.isEmpty, "\(name): translated into uz but not ru — \(onlyUz)")
            #expect(!ru.isEmpty, "\(name): the ru table is empty")
        }
    }

    /// Every string in the app, not just the shared ten, keeps its positional arguments in both
    /// languages. `String(format:)` given the wrong argument set prints nonsense silently.
    @Test(arguments: translated)
    func noTranslationAnywhereLosesAFormatArgument(language: String) {
        guard let strings = table(appBundle, language) else {
            Issue.record("could not read the \(language) table")
            return
        }
        for (key, translation) in strings {
            let expected = specifiers(in: key)
            guard !expected.isEmpty else { continue }
            #expect(specifiers(in: translation) == expected,
                    "\"\(key)\" in \(language) does not carry the same format arguments")
        }
    }

    /// **Every string the build extracted is translated, unless it is deliberately not.**
    ///
    /// This is the check that catches a *new* untranslated string. Xcode's build extracts every
    /// `Text` / `Label` literal into the catalogue itself, so the English table is the complete
    /// list of what the app can draw — including strings nobody remembered to add by hand. Anything
    /// in it and not in Russian falls back to English for a Russian user, silently.
    ///
    /// It found one: `Label("Delete", systemImage: "trash")` on the log's swipe action, which had
    /// no bundle and no translation. The allowlist below is small on purpose — an entry here is a
    /// claim that a string is *not words*, and it should be argued for.
    @Test func everyDrawnStringIsTranslatedUnlessDeliberatelyNot() {
        /// `%` is a symbol. `WaterBuddy` is the product's name. The other two are `#Preview`
        /// scaffolding in `LiquidGlassModifier.swift`, which never ships in a running screen.
        let deliberatelyEnglishOnly: Set<String> = ["%", "WaterBuddy", "1,450 ml", "+%lld"]

        guard let english = table(appBundle, "en") else {
            Issue.record("no en table — AppLanguage.english would fall back to the device language")
            return
        }

        for language in translated {
            guard let other = table(appBundle, language) else {
                Issue.record("could not read the \(language) table")
                continue
            }
            let untranslated = Set(english.keys)
                .subtracting(other.keys)
                .subtracting(deliberatelyEnglishOnly)
                .sorted()

            #expect(untranslated.isEmpty,
                    "these draw English for a \(language) user — \(untranslated)")
        }
    }

    /// **The same check, against the extension's own catalogue.**
    ///
    /// ``everyDrawnStringIsTranslatedUnlessDeliberatelyNot()`` reads `appBundle` and therefore could
    /// never see `AddWaterIntent`'s vocabulary, which lives only in the widget's catalogue — so five
    /// strings Shortcuts renders (`Log Water`, its `IntentDescription`, `Amount`, its description and
    /// the parameter summary) shipped untranslated while the widget beside them drew the user's
    /// language. That was `docs/AI_CONTEXT.md` known issue #1, and this test is the half that stops
    /// it recurring.
    ///
    /// Those five are `LocalizedStringResource` and `@Parameter` macro arguments, so they are
    /// compile-time constants and cannot follow the in-app picker. Translating the keys is what makes
    /// Shortcuts follow the **device** language, which is the most this surface can honour.
    @Test func everyWidgetStringIsTranslatedUnlessDeliberatelyNot() {
        /// `%` is a symbol; the other three are `#Preview` scaffolding in `LiquidGlassModifier.swift`,
        /// which is one of the six files compiled into the extension. They carry no `en` value, so
        /// they reach neither table and this allowlist is currently belt and braces — it becomes
        /// load-bearing the moment somebody gives them one.
        let deliberatelyEnglishOnly: Set<String> = ["%", "1,450 ml", "+%lld", "Today"]

        guard let english = table(widgetBundle, "en") else {
            Issue.record("no en table in the extension — a widget string would fall back to the device language")
            return
        }

        for language in translated {
            guard let other = table(widgetBundle, language) else {
                Issue.record("could not read the extension's \(language) table")
                continue
            }
            let untranslated = Set(english.keys)
                .subtracting(other.keys)
                .subtracting(deliberatelyEnglishOnly)
                .sorted()

            #expect(untranslated.isEmpty,
                    "these draw English for a \(language) user in Shortcuts or on the widget — \(untranslated)")
        }
    }

    /// **`AddWaterIntent`'s Shortcuts vocabulary resolves in every shipped language.**
    ///
    /// Named explicitly, because the general check above **structurally cannot see these**. A
    /// String Catalogue entry with no `en` value emits nothing into any `.lproj`, so an extracted-
    /// but-untranslated key is absent from the English table too — and a check that subtracts one
    /// table from another finds nothing to report. That is how these five shipped English to a
    /// Russian user for two releases while every localization test stayed green, and it is the
    /// third time this repo has been caught by a catalogue's build half rather than its source
    /// half (`tasks/lessons.md`).
    ///
    /// These are the strings Shortcuts renders when the user adds the WaterBuddy action. They are
    /// macro arguments and therefore compile-time constants: they follow the **device** language,
    /// never the in-app picker (`docs/WIDGET.md`, `docs/AI_CONTEXT.md` known issue #1).
    ///
    /// **Two of them are also the Control Center control's.** *Log Water* is its gallery name and its
    /// title — the title resolved through the snapshot's bundle, so it *does* follow the in-app picker —
    /// and the description is its gallery description. This test is what pins them in every language,
    /// so trimming the list must keep both.
    @Test(arguments: translated)
    func theShortcutsVocabularyIsTranslated(language: String) {
        let shortcutsKeys = [
            "Log Water",
            "Adds a serving of water to today's total in WaterBuddy.",
            "Amount",
            "Millilitres of water to log.",
            "Log ${amount} ml of water",
        ]

        for key in shortcutsKeys {
            #expect(value(widgetBundle, language, key) != nil,
                    "\"\(key)\" has no \(language) entry — Shortcuts would show it in English")
        }
    }

    /// The development language needs a real `.lproj` of its own, or *English* in the picker
    /// resolves through `Bundle.main` — which is the **device's** language, not English. A String
    /// Catalogue emits one only when its keys carry explicit `en` values (`tasks/lessons.md`).
    @Test func theAppShipsARealEnglishTable() {
        #expect(localization(appBundle, "en") != nil,
                "no en.lproj: choosing English on a Russian phone would keep drawing Russian")
    }

    /// The product's own name is not a word to be translated, and a catalogue entry for it is an
    /// invitation to translate it. Its **absence** from every table is the intended state — worth
    /// pinning so nobody later "fixes" the apparent gap.
    @Test(arguments: translated)
    func theProductNameIsNeverTranslated(language: String) {
        #expect(value(appBundle, language, "WaterBuddy") == nil,
                "WaterBuddy has a \(language) entry — the product name is not a word")
    }

    /// **Settings' vessels note names the Glass by the word its own row uses.**
    ///
    /// The note is the one place a user learns which vessel the widget, Siri and Control Center log
    /// (spec 2026-10-09 §7). Written around another word for it — *the middle vessel*, or a synonym
    /// a translator reached for — it points at no row on the card it sits on. Read from the built
    /// tables, in every language, because the note is resolved through the in-app picker's bundle.
    @Test(arguments: ["en"] + translated)
    func theVesselsNoteNamesTheGlassByItsOwnName(language: String) {
        let note = value(appBundle, language, "The Glass is the one your widget, Siri and Control Center log.")
        let glass = value(appBundle, language, "Glass")

        #expect(note != nil, "Settings' vessels note has no \(language) entry")
        #expect(glass != nil, "the Glass has no \(language) name")
        if let note, let glass {
            #expect(note.contains(glass), "the \(language) note does not call the Glass \(glass): \(note)")
        }
        #expect(value(appBundle, language, "The middle vessel is the one your widget logs.") == nil,
                "the old note is still in the \(language) table")
    }

    // MARK: - The watch (spec 2026-10-06 §6.3)

    @Test func theWatchBundlesAreWhereWeThinkTheyAre() {
        #expect(watchBundle != nil,
                "no Watch/WaterBuddyWatch.app inside the test host — every watch assertion below would pass vacuously")
        #expect(watchWidgetBundle != nil,
                "no WaterBuddyWatchWidget.appex inside the watch app — its assertions would pass vacuously")
    }

    /// **The regression test for a catalogue that lands in the wrong target**, and — review focus —
    /// run over the languages the product *offers*, so a case added to `AppLanguage.selectable`
    /// without a watch translation fails here instead of drawing English on the wrist.
    @Test(arguments: AppLanguage.selectable.compactMap(\.code))
    func theWatchShipsEveryLanguage(language: String) {
        #expect(localization(watchBundle, language) != nil,
                "the watch app does not ship \(language) — choosing it on the phone would draw the watch's own language")
        #expect(localization(watchWidgetBundle, language) != nil,
                "the watch widget does not ship \(language)")
    }

    /// **The watch's copies agree with the phone, value for value**, in English too — two catalogues
    /// holding one key is fine right up until somebody improves a translation in one of them.
    @Test(arguments: ["en"] + translated)
    func theWatchAgreesWithThePhoneOnEverySharedString(language: String) {
        for key in watchSharedKeys {
            let phone = value(appBundle, language, key)
            #expect(phone != nil, "\"\(key)\" is missing from the phone's \(language) table — nothing to agree with")
            #expect(value(watchBundle, language, key) == phone,
                    "\"\(key)\" differs between the phone and the watch in \(language)")
        }
        let description = "Today's hydration"
        #expect(value(watchWidgetBundle, language, description) == value(appBundle, language, description),
                "the complication's description differs from the phone's in \(language)")
    }

    @Test(arguments: ["en"] + translated)
    func theWatchsOwnKeysResolveInEveryLanguage(language: String) {
        for key in watchOwnKeys {
            #expect(value(watchBundle, language, key) != nil,
                    "\"\(key)\" has no \(language) entry in the watch app — it would draw the raw key")
        }
    }

    @Test(arguments: translated)
    func noWatchTranslationLosesAFormatArgument(language: String) {
        for (name, bundle) in [("watch", watchBundle), ("watch widget", watchWidgetBundle)] as [(String, Bundle?)] {
            guard let strings = table(bundle, language) else {
                Issue.record("\(name): could not read the \(language) table")
                continue
            }
            for (key, translation) in strings {
                let expected = specifiers(in: key)
                guard !expected.isEmpty else { continue }
                #expect(specifiers(in: translation) == expected,
                        "\(name): \"\(key)\" in \(language) does not carry the same format arguments")
            }
        }
    }

    /// **Every string the watch's build extracted is translated, unless it is deliberately not.**
    /// `%` is a symbol and `WaterBuddy` the product's name; nothing else is argued for.
    @Test func everyWatchStringIsTranslatedUnlessDeliberatelyNot() {
        let deliberatelyEnglishOnly: Set<String> = ["%", "WaterBuddy"]

        for (name, bundle) in [("watch", watchBundle), ("watch widget", watchWidgetBundle)] as [(String, Bundle?)] {
            guard let english = table(bundle, "en") else {
                Issue.record("\(name): no en table — choosing English would fall back to the watch's own language")
                continue
            }
            for language in translated {
                guard let other = table(bundle, language) else {
                    Issue.record("\(name): could not read the \(language) table")
                    continue
                }
                let untranslated = Set(english.keys)
                    .subtracting(other.keys)
                    .subtracting(deliberatelyEnglishOnly)
                    .sorted()
                #expect(untranslated.isEmpty,
                        "\(name): these draw English for a \(language) user — \(untranslated)")
            }
        }
    }

    @Test(arguments: translated)
    func theProductNameIsNeverTranslatedOnTheWatch(language: String) {
        for (name, bundle) in [("watch", watchBundle), ("watch widget", watchWidgetBundle)] as [(String, Bundle?)] {
            #expect(value(bundle, language, "WaterBuddy") == nil,
                    "\(name): WaterBuddy has a \(language) entry — the product name is not a word")
        }
    }
}

// MARK: - Home

/// Home's own strings, in every language the app ships.
struct HomeStringTests {

    @Test(arguments: ["en"] + translated)
    func everyHomeStringExistsAndKeepsItsArguments(language: String) {
        for key in homeKeys {
            let resolved = value(appBundle, language, key)
            #expect(resolved != nil, "\(language) has no value for \"\(key)\"")
            if let resolved {
                #expect(specifiers(in: resolved) == specifiers(in: key),
                        "\"\(key)\" in \(language) does not carry the same format arguments")
            }
        }
    }

    /// The visible keys take `%@` — a figure already grouped — and the one spoken key takes `%d`,
    /// the split spec §3.1 sets.
    @Test func onlyTheSpokenHomeStringTakesARawNumber() {
        let raw = homeKeys.filter { $0.contains("$d") }

        #expect(raw == ["%1$d millilitres to go"])
    }
}

// MARK: - History

/// History's own strings, in every language the app ships.
struct HistoryStringTests {

    @Test(arguments: ["en"] + translated)
    func everyHistoryStringExistsAndKeepsItsArguments(language: String) {
        for key in historyKeys {
            let resolved = value(appBundle, language, key)
            #expect(resolved != nil, "\(language) has no value for \"\(key)\"")
            if let resolved {
                #expect(specifiers(in: resolved) == specifiers(in: key),
                        "\"\(key)\" in \(language) does not carry the same format arguments")
            }
        }
    }

    /// A volume History draws is a figure already grouped (spec §3.1): a `%@` key, never a raw
    /// `%d` beside the unit. **Read off the built table, not off a list in this file** — a key
    /// that draws a raw `%d ml`, one of the three this stage retired or a new one, fails here
    /// without anybody having named it.
    ///
    /// Three are left, and none is History's or — since the redesign's stage 4 — Settings': all
    /// three are the widget's, kept in the app's table because the two must agree (`sharedKeys`).
    /// They go when their own screens are redrawn, and this set shrinks with them.
    @Test func theOnlyRawVolumesLeftToDrawAreOtherScreens() throws {
        let english = try #require(table(appBundle, "en"), "the app ships no en table")

        let raw = english.keys.filter { $0.contains("$d") && $0.hasSuffix(" ml") }

        #expect(Set(raw) == ["%1$d ml", "of %1$d ml", "+%1$d ml"])
    }

    /// The keys History's ungrouped figures were drawn from are gone with their last reader, so
    /// nothing can draw `2000` beside Home's `2,000` again.
    @Test(arguments: ["Average %1$d ml", "Best %1$d ml", "%1$d of %2$d ml", "Average %1$d millilitres. Best %2$d millilitres."])
    func theUngroupedHistoryKeysAreGone(key: String) throws {
        // A table that did not resolve has no keys at all, and would pass this for nothing.
        _ = try #require(localization(appBundle, "en"), "the app ships no en table")

        #expect(value(appBundle, "en", key) == nil, "\"\(key)\" is still in the catalogue with no reader")
    }
}

// MARK: - The welcome

/// The welcome's own strings, in every language the app ships.
struct WelcomeStringTests {

    @Test(arguments: ["en"] + translated)
    func everyWelcomeStringExistsAndKeepsItsArguments(language: String) {
        for key in welcomeKeys {
            let resolved = value(appBundle, language, key)
            #expect(resolved != nil, "\(language) has no value for \"\(key)\"")
            if let resolved {
                #expect(specifiers(in: resolved) == specifiers(in: key),
                        "\"\(key)\" in \(language) does not carry the same format arguments")
            }
        }
    }
}

/// ``Bundle/figure(_:_:locale:)`` — a volume grouped the way the language groups it, set into a
/// `%@` key. Not `@MainActor`: the widget's stage will call it from a view the extension draws.
struct GroupedFigureTests {

    @Test func figuresAreGroupedTheWayTheLocaleGroups() throws {
        let english = try #require(localization(appBundle, "en"), "the app ships no en table")
        let russian = try #require(localization(appBundle, "ru"), "the app ships no ru table")
        let en = Locale(identifier: "en_US")
        let ru = Locale(identifier: "ru_RU")

        #expect(english.figure("%1$@ of %2$@ ml", 1_300, 2_000, locale: en) == "1,300 of 2,000 ml")

        let grouped = 1_300.formatted(.number.locale(ru))
        #expect(grouped != "1300", "a Russian thousand is grouped too, with its own separator")
        #expect(russian.figure("%1$@ of %2$@ ml", 1_300, 2_000, locale: ru)
                == "\(grouped) из \(2_000.formatted(.number.locale(ru))) мл")
    }

    @Test func aFigureUnderAThousandCarriesNoSeparator() throws {
        let english = try #require(localization(appBundle, "en"), "the app ships no en table")

        #expect(english.figure("%1$@ ml to go", 700, locale: Locale(identifier: "en_US")) == "700 ml to go")
    }

    /// Uzbek puts the goal first: "2,000 dan 1,300 ml". The arguments follow the key's numbering,
    /// not the sentence's order.
    @Test func theArgumentsFollowTheKeysNumberingNotTheSentencesOrder() throws {
        let uzbek = try #require(localization(appBundle, "uz"), "the app ships no uz table")
        let uz = Locale(identifier: "uz_UZ")

        let drawn = uzbek.figure("%1$@ of %2$@ ml", 1_300, 2_000, locale: uz)
        let total = 1_300.formatted(.number.locale(uz))
        let goal = 2_000.formatted(.number.locale(uz))

        #expect(drawn == "\(goal) dan \(total) ml")
    }

    /// *Goal met* is a count set into a key of its own, and Uzbek puts the whole first here too.
    @Test func aCountOfDaysFollowsTheLanguagesOrder() throws {
        let english = try #require(localization(appBundle, "en"), "the app ships no en table")
        let russian = try #require(localization(appBundle, "ru"), "the app ships no ru table")
        let uzbek = try #require(localization(appBundle, "uz"), "the app ships no uz table")

        #expect(english.figure("%1$@ of %2$@", 6, 7, locale: Locale(identifier: "en_US")) == "6 of 7")
        #expect(russian.figure("%1$@ of %2$@", 6, 7, locale: Locale(identifier: "ru_RU")) == "6 из 7")
        #expect(uzbek.figure("%1$@ of %2$@", 6, 7, locale: Locale(identifier: "uz_UZ")) == "7 dan 6")
    }
}
