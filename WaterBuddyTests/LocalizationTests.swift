//
//  LocalizationTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 29/08/26.
//

import Foundation
import Testing
import UserNotifications
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
    "%1$@ of %2$@ ml",
    "%1$@, add %2$d millilitres",
]

/// The watch's own strings, which have no phone equivalent. Listed by name because the build
/// extracts only `Text` literals: a key resolved with `localizedString(forKey:)` never reaches the
/// extracted table, so a coverage check cannot see one go missing — the gap
/// `theShortcutsVocabularyIsTranslated` exists for.
private let watchOwnKeys = [
    "Not yet synced · default goal",
    "Set your goal in WaterBuddy on iPhone",
    "Not yet synced",
    "Synced just now",
    "Synced %1$dm ago",
]

/// Every phone string a watch face draws or speaks, copied into the complication's own catalogue
/// value for value (spec 2026-10-20 §3.7). *Today's hydration* is also its gallery description.
private let watchWidgetSharedKeys = [
    "Today's hydration",
    "Hydration",
    "%1$@ of %2$@ ml",
    "%1$d percent. %2$d of %3$d millilitres.",
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
    "Week",
    "Your last seven days against your goal.",
    "Open WaterBuddy to see your week.",
    "Last %1$d days",
    "Goal met",
    "%1$@ of %2$@",
    "Average %1$d millilitres. Best %2$d millilitres. Goal met on %3$d of %4$d days.",
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
    "%1$d days",
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
    "%1$d servings",
    "Average %1$d millilitres. Best %2$d millilitres. Goal met on %3$d of %4$d days.",
    "Month",
    "Part of it",
    "Days on goal",
    "Best streak",
    "This month",
    "%1$@/%2$@",
    "%1$@ L",
    "Average %1$@ ml a day",
    "Up %1$@ ml on the month before",
    "Down %1$@ ml on the month before",
    "The same as the month before",
    "Your whole month at a glance",
    "Every day you have logged is kept. Premium shows it as months, with your patterns and a recap.",
    "Back to this week",
    "The week, today and every serving stay free. Nothing you logged is ever hidden or deleted.",
    "%1$d of %2$d days",
    "%1$d of %2$d days on goal",
    "Average %1$d millilitres a day",
    "Up %1$d millilitres on the month before",
    "Down %1$d millilitres on the month before",
    "Patterns",
    "From this month's finished days",
    "When you drink",
    "Most around %1$@",
    "Weekdays",
    "Weekends",
    "%1$@ ml a day",
    "%1$d millilitres a day",
    "First drink, usually",
    "Last drink, usually",
    "Patterns need %1$d days of water",
    "Insights",
    "The one thing",
    "What is working",
    "Worth knowing",
    "Writing…",
    "Written by WaterBuddy from your own figures, on your iPhone. Not medical advice.",
    "Written by Apple's on-device model from your own figures, on your iPhone. Not medical advice.",
    "Insights need %1$d days of water in a week",
    "Next on %1$@",
    "A few lines each week on how you drank",
    "Premium writes them from your own figures, on your iPhone, with one thing to try.",
    "Weekends ran %1$@ ml a day below weekdays.",
    "Weekdays ran %1$@ ml a day below weekends.",
    "%1$@ ml a day less than the week before.",
    "%1$@ ml a day more than the week before.",
    "An average day was %1$@ ml short of your goal.",
    "An average day: %1$@ ml, against a goal of %2$@ ml.",
    "Another %1$@ ml on each weekend day would help close the gap.",
    "Another %1$@ ml on each weekday would help close the gap.",
    "Another %1$@ ml each morning would help close the gap.",
    "Another %1$@ ml each afternoon would help close the gap.",
    "Another %1$@ ml each evening would help close the gap.",
    "Every day on goal.",
    "Your goal on every weekday.",
    "Your goal on every weekend day.",
    "Goal met on %1$d days, up from %2$d.",
    "Your first drink came %1$d minutes earlier than the week before.",
    "Your first drink came %1$d minutes later than the week before.",
    "Nothing was logged on %1$d days.",
    "Half your water came before %1$@.",
    // The monthly recap (spec 2026-10-24 §3.10).
    "Monthly recap",
    "A day, on average",
    "Share as an image",
    "Stays in the app, not on the image",
    "The image leaves your phone only when you send it.",
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

/// The paywall's and the Premium card's strings (spec 2026-10-21 §3.8). Most are resolved by name in
/// `PremiumAccess`, where the build's extraction cannot see them.
private let premiumKeys = [
    "WaterBuddy Premium",
    "Logging water is free, always.",
    "Restore Purchases",
    "Terms of Use",
    "Privacy Policy",
    "The App Store can't be reached right now.",
    "Try Again",
    "Waiting for approval.",
    "The purchase didn't go through.",
    "Thank you",
    "You have Premium.",
    "Premium",
    "Extras for the way you drink. Logging water stays free.",
    "See Premium",
    "Manage Subscription",
    "Yearly",
    "Lifetime",
    "%1$@ free, then %2$@ a year",
    "%1$@ a year",
    "%1$@, once",
    "Start Free Trial",
    "Subscribe",
    "Buy Lifetime",
    "Free trial: %1$@. Then %2$@ is charged each year until you cancel. Cancel at least 24 hours before it renews, in your Apple Account settings.",
    "%1$@ is charged each year until you cancel. Cancel at least 24 hours before it renews, in your Apple Account settings.",
    "One payment. It never renews.",
    "Yearly, until %1$@",
    "Monthly",
    "a month",
    "a year",
    "once",
    "%1$@ a month",
    "save %1$@",
    "%1$@ free",
    "Best value",
    "Cancel any time",
    "Yours for good",
    "%1$@ is charged each month until you cancel. Cancel at least 24 hours before it renews, in your Apple Account settings.",
    "Monthly, until %1$@",
    "See how you really drink, and what would help.",
    "Month view and full history",
    "Every day you have logged, a month at a glance",
    "Your patterns",
    "When you drink, weekdays against weekends",
    "Personal insights",
    "Each week, from your own figures, on your iPhone",
    "A monthly recap",
    "Your month in one card, yours to share",
    "New Premium features arrive in updates, included.",
    "Month view",
    "Patterns",
    "Insights",
    "Done",
    "No purchases to restore.",
]

/// Settings' *Apple Health* card (spec `2026-10-29-apple-health-design.md` §6).
private let healthKeys = [
    "Apple Health",
    "Saves each serving to Apple Health as water. WaterBuddy reads nothing from Health.",
    "Health access is off for WaterBuddy. Turn it on in Settings › Privacy & Security › Health › WaterBuddy.",
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

/// Every key one language's table holds, with every sentence it can produce: a plain value, or — for a
/// key with plural forms, which the build moves out of `Localizable.strings` into
/// `Localizable.stringsdict` — each form.
///
/// Both files are binary plists in a built bundle, which `NSDictionary` reads. Reading only the first
/// lost every key with forms from English and Russian while Uzbek, which keeps one value, still had it
/// (spec 2026-10-16 §6.2). Going through the table rather than key by key is what lets a test assert
/// something about *all* the strings without a hardcoded list that would itself go stale.
private func table(_ bundle: Bundle?, _ language: String) -> [String: [String]]? {
    guard let lproj = localization(bundle, language) else { return nil }
    let plain = lproj.url(forResource: "Localizable", withExtension: "strings")
        .flatMap { NSDictionary(contentsOf: $0) as? [String: String] }
    let plural = lproj.url(forResource: "Localizable", withExtension: "stringsdict")
        .flatMap { NSDictionary(contentsOf: $0) as? [String: [String: Any]] }
    guard plain != nil || plural != nil else { return nil }

    var table = (plain ?? [:]).mapValues { [$0] }
    for (key, entry) in plural ?? [:] {
        table[key] = forms(of: entry)
    }
    return table
}

/// A `.stringsdict` entry's sentences: its format key with each `%#@name@` replaced by every form of
/// that substitution, in every combination — in a fixed order, so two bundles compare form by form.
private func forms(of entry: [String: Any]) -> [String] {
    guard let format = entry["NSStringLocalizedFormatKey"] as? String else { return [] }
    var sentences = [format]
    for name in entry.keys.sorted() where name != "NSStringLocalizedFormatKey" {
        guard let rule = entry[name] as? [String: String] else { continue }
        let variants = rule.keys.sorted().filter { !$0.hasPrefix("NSString") }.compactMap { rule[$0] }
        sentences = sentences.flatMap { sentence in
            variants.map {
                sentence.replacingOccurrences(of: "%(\\d+\\$)?#@\(name)@",
                                              with: NSRegularExpression.escapedTemplate(for: $0),
                                              options: .regularExpression)
            }
        }
    }
    return sentences
}

/// Every sentence `key` gives in one language, or `nil` if the table has no such key.
private func sentences(_ bundle: Bundle?, _ language: String, _ key: String) -> [String]? {
    table(bundle, language)?[key]
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
            #expect(sentences(appBundle, language, key) == sentences(widgetBundle, language, key),
                    "\"\(key)\" differs between the app and the widget in \(language)")
        }
    }

    /// The week widget's three new strings, exactly, in both bundles and every shipped language
    /// (spec 2026-10-19-the-widget-stage §3.7).
    @Test(arguments: [
        ("en", "Week", "Week"),
        ("ru", "Week", "Неделя"),
        ("uz", "Week", "Hafta"),
        ("en", "Your last seven days against your goal.", "Your last seven days against your goal."),
        ("ru", "Your last seven days against your goal.", "Последние семь дней в сравнении с вашей целью."),
        ("uz", "Your last seven days against your goal.", "Oxirgi yetti kun — maqsadingizga nisbatan."),
        ("en", "Open WaterBuddy to see your week.", "Open WaterBuddy to see your week."),
        ("ru", "Open WaterBuddy to see your week.", "Откройте WaterBuddy, чтобы увидеть свою неделю."),
        ("uz", "Open WaterBuddy to see your week.", "Haftangizni ko‘rish uchun WaterBuddy’ni oching."),
    ])
    func theWeekWidgetSaysWhatTheSpecSays(language: String, key: String, expected: String) {
        for (name, bundle) in [("app", appBundle), ("widget", widgetBundle)] as [(String, Bundle?)] {
            #expect(value(bundle, language, key) == expected,
                    "\(name): \"\(key)\" in \(language) is not the spec's wording")
        }
    }

    /// A translation that drops or invents a positional argument produces wrong output from
    /// `String(format:)` — silently, and only in that language. Positional (`%1$d`) rather than
    /// bare `%d` is precisely so a translator *may* reorder; the set has to survive the reordering.
    @Test(arguments: translated)
    func everyTranslationKeepsTheFormatArgumentsOfItsKey(language: String) {
        for key in sharedKeys {
            let expected = specifiers(in: key)
            guard !expected.isEmpty, let resolved = sentences(appBundle, language, key) else { continue }
            for sentence in resolved {
                #expect(specifiers(in: sentence) == expected,
                        "\"\(key)\" in \(language) does not carry the same format arguments: \(sentence)")
            }
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

        // The button's title, which only the app resolves (rule `80-notifications`) — so read in the
        // app's bundle alone, and required there: a missing key would pass for a title with no digit.
        let button = value(appBundle, language, "Log a Glass")
        #expect(button != nil, "app: the \(language) catalogue has no \"Log a Glass\"")
        if let button {
            let carriesADigit = button.contains(where: \.isNumber)
            #expect(!carriesADigit, "app: the \(language) reminder button contains a digit — \"\(button)\"")
        }
    }

    /// Spec 2026-10-15 §3.7. The app's queue and the widget's `AddWaterIntent` both reconcile, each in
    /// its own bundle, and each files again any reminder whose words differ from its own. Composed in
    /// different words, every foreground and every widget tap would file the other's reminders again.
    @Test(arguments: ["en"] + translated)
    func theAppAndTheWidgetFileRemindersInTheSameWords(language: String) throws {
        let app = try #require(localization(appBundle, language), "the app ships no \(language)")
        let widget = try #require(localization(widgetBundle, language), "the widget ships no \(language)")

        let filedByTheWidget = PendingReminder(UNNotificationRequest(
            identifier: "\(ReminderPlan.identifierPrefix)20260828.09",
            content: NotificationManager.reminderContent(in: widget),
            trigger: nil
        ))

        #expect(filedByTheWidget.isWorded(like: NotificationManager.reminderContent(in: app)),
                "\(language): the app would file the widget's reminders again")
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

    /// The readers in this file see a key with plural forms, which the build moves out of
    /// `Localizable.strings` into `Localizable.stringsdict` (spec 2026-10-16 §6.2): two forms in
    /// English, four in Russian, and Uzbek's one value.
    @Test func theTablesSeeAKeyWithPluralForms() {
        #expect(table(appBundle, "en")?["Add %1$d millilitres"]?.count == 2)
        #expect(table(appBundle, "ru")?["Add %1$d millilitres"]?.count == 4)
        #expect(table(appBundle, "uz")?["Add %1$d millilitres"]?.count == 1)
    }

    /// Every string in the app, not just the shared ten, keeps its positional arguments in both
    /// languages. `String(format:)` given the wrong argument set prints nonsense silently.
    @Test(arguments: translated)
    func noTranslationAnywhereLosesAFormatArgument(language: String) {
        guard let strings = table(appBundle, language) else {
            Issue.record("could not read the \(language) table")
            return
        }
        for (key, translations) in strings {
            let expected = specifiers(in: key)
            guard !expected.isEmpty else { continue }
            for translation in translations {
                #expect(specifiers(in: translation) == expected,
                        "\"\(key)\" in \(language) does not carry the same format arguments: \(translation)")
            }
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
            let phone = sentences(appBundle, language, key)
            #expect(phone != nil, "\"\(key)\" is missing from the phone's \(language) table — nothing to agree with")
            #expect(sentences(watchBundle, language, key) == phone,
                    "\"\(key)\" differs between the phone and the watch in \(language)")
        }
        for key in watchWidgetSharedKeys {
            let phone = sentences(appBundle, language, key)
            #expect(phone != nil, "\"\(key)\" is missing from the phone's \(language) table — nothing to agree with")
            #expect(sentences(watchWidgetBundle, language, key) == phone,
                    "\"\(key)\" differs between the phone and the watch's faces in \(language)")
        }
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
            for (key, translations) in strings {
                let expected = specifiers(in: key)
                guard !expected.isEmpty else { continue }
                for translation in translations {
                    #expect(specifiers(in: translation) == expected,
                            "\(name): \"\(key)\" in \(language) does not carry the same format arguments: \(translation)")
                }
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
            let resolved = sentences(appBundle, language, key)
            #expect(resolved != nil, "\(language) has no value for \"\(key)\"")
            for sentence in resolved ?? [] {
                #expect(specifiers(in: sentence) == specifiers(in: key),
                        "\"\(key)\" in \(language) does not carry the same format arguments: \(sentence)")
            }
        }
    }

    /// Home's keys that take a raw number are its two counted ones: the status line's, and the
    /// streak's. Both are formatted through ``Bundle/localized(_:_:locale:)``, so both are grouped
    /// and take their plural forms (spec 2026-10-16 §3.6); the drawn volumes keep their `%@` keys.
    @Test func theHomeKeysThatTakeARawNumberAreTheCountedOnes() {
        let raw = homeKeys.filter { $0.contains("$d") }

        #expect(raw == ["%1$d millilitres to go", "%1$d days"])
    }
}

// MARK: - History

/// History's own strings, in every language the app ships.
struct HistoryStringTests {

    @Test(arguments: ["en"] + translated)
    func everyHistoryStringExistsAndKeepsItsArguments(language: String) {
        for key in historyKeys {
            let resolved = sentences(appBundle, language, key)
            #expect(resolved != nil, "\(language) has no value for \"\(key)\"")
            for sentence in resolved ?? [] {
                #expect(specifiers(in: sentence) == specifiers(in: key),
                        "\"\(key)\" in \(language) does not carry the same format arguments: \(sentence)")
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
    /// Since roadmap item 1.2.6 they are grouped too, formatted through
    /// ``Bundle/localized(_:_:locale:)``; they are `%d` keys only because their screens have not been
    /// redrawn. This set shrinks when they are.
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
            let resolved = sentences(appBundle, language, key)
            #expect(resolved != nil, "\(language) has no value for \"\(key)\"")
            for sentence in resolved ?? [] {
                #expect(specifiers(in: sentence) == specifiers(in: key),
                        "\"\(key)\" in \(language) does not carry the same format arguments: \(sentence)")
            }
        }
    }
}

// MARK: - Premium

/// The paywall's own strings, in every language the app ships.
struct PremiumStringTests {

    @Test(arguments: ["en"] + translated)
    func everyPremiumStringExistsAndKeepsItsArguments(language: String) {
        for key in premiumKeys {
            let resolved = sentences(appBundle, language, key)
            #expect(resolved != nil, "\(language) has no value for \"\(key)\"")
            for sentence in resolved ?? [] {
                #expect(specifiers(in: sentence) == specifiers(in: key),
                        "\"\(key)\" in \(language) does not carry the same format arguments: \(sentence)")
            }
        }
    }
}

struct HealthStringTests {

    @Test(arguments: ["en"] + translated)
    func everyHealthStringExistsAndCarriesNoDigit(language: String) {
        for key in healthKeys {
            let resolved = sentences(appBundle, language, key)
            #expect(resolved != nil, "\(language) has no value for \"\(key)\"")
            for sentence in resolved ?? [] {
                #expect(!sentence.contains { $0.isNumber }, "\"\(key)\" in \(language) carries a digit: \(sentence)")
            }
        }
    }
}

/// Apple Health's usage description — the sentence Health's sheet shows (spec
/// `2026-10-29-apple-health-design.md` §3.8). Review Focus 5: the app asks to write and never to read.
struct HealthPurposeTests {

    @Test func theAppAsksHealthToWriteAndNeverToRead() {
        #expect(appBundle.object(forInfoDictionaryKey: "NSHealthUpdateUsageDescription") as? String != nil)
        #expect(appBundle.object(forInfoDictionaryKey: "NSHealthShareUsageDescription") == nil,
                "a read permission's key — WaterBuddy reads nothing from Health")
    }

    @Test(arguments: ["en"] + translated)
    func thePurposeIsInEveryLanguageAndCarriesNoDigit(language: String) throws {
        let folder = try #require(appBundle.path(forResource: language, ofType: "lproj"))
        let bundle = try #require(Bundle(path: folder))
        let purpose = bundle.localizedString(forKey: "NSHealthUpdateUsageDescription", value: nil, table: "InfoPlist")
        #expect(purpose != "NSHealthUpdateUsageDescription", "\(language) has no usage description")
        #expect(!purpose.contains { $0.isNumber }, "\(language)'s usage description carries a digit")
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

// MARK: - Plural forms (spec 2026-10-16 §6.1)

/// Russian's whole-number forms by CLDR's rule, written out here so these tests do not ask Foundation
/// the question they check it answers. A fraction would take *other*; this app formats none.
private func russian(_ count: Int, _ one: String, _ few: String, _ many: String) -> String {
    let last = count % 10, lastTwo = count % 100
    if last == 1 && lastTwo != 11 { return one }
    if (2...4).contains(last) && !(12...14).contains(lastTwo) { return few }
    return many
}

private func english(_ count: Int, _ one: String, _ other: String) -> String {
    count == 1 ? one : other
}

/// The counts spec §1 names: every Russian form, the teens that end in 1–4 and still take *many*, and a
/// figure that groups.
private let pluralCounts = [0, 1, 2, 5, 11, 12, 21, 22, 25, 101, 111, 1_001]

/// A key with a counted noun: how many arguments it takes, which of them count (from zero), and which
/// bundles hold it.
private struct CountedKey: Sendable {
    let key: String
    let arity: Int
    let counted: [Int]
    let bundles: [String]
}

private let averageKey = "Average %1$d millilitres. Best %2$d millilitres. Goal met on %3$d of %4$d days."

private let countedKeys = [
    CountedKey(key: "%1$d millilitres", arity: 1, counted: [0], bundles: ["app"]),
    CountedKey(key: "%1$@, add %2$d millilitres", arity: 2, counted: [1], bundles: ["app", "watch"]),
    CountedKey(key: "%1$d millilitres to go", arity: 1, counted: [0], bundles: ["app"]),
    CountedKey(key: "%1$d of %2$d millilitres", arity: 2, counted: [1], bundles: ["app"]),
    CountedKey(key: "%1$d percent. %2$d of %3$d millilitres.", arity: 3, counted: [0, 2],
               bundles: ["app", "widget", "watch", "watchWidget"]),
    CountedKey(key: "Add %1$d millilitres", arity: 1, counted: [0], bundles: ["app", "widget"]),
    CountedKey(key: "Use %1$d millilitres", arity: 1, counted: [0], bundles: ["app"]),
    CountedKey(key: averageKey, arity: 4, counted: [0, 1, 3], bundles: ["app"]),
    CountedKey(key: "Last %1$d days", arity: 1, counted: [0], bundles: ["app"]),
    CountedKey(key: "%1$d days", arity: 1, counted: [0], bundles: ["app"]),
    CountedKey(key: "%1$d servings", arity: 1, counted: [0], bundles: ["app"]),
    CountedKey(key: "%1$d of %2$d days", arity: 2, counted: [1], bundles: ["app"]),
    CountedKey(key: "%1$d of %2$d days on goal", arity: 2, counted: [1], bundles: ["app"]),
    CountedKey(key: "Average %1$d millilitres a day", arity: 1, counted: [0], bundles: ["app"]),
    CountedKey(key: "Up %1$d millilitres on the month before", arity: 1, counted: [0], bundles: ["app"]),
    CountedKey(key: "Down %1$d millilitres on the month before", arity: 1, counted: [0], bundles: ["app"]),
    CountedKey(key: "%1$d millilitres a day", arity: 1, counted: [0], bundles: ["app"]),
    CountedKey(key: "Patterns need %1$d days of water", arity: 1, counted: [0], bundles: ["app"]),
    CountedKey(key: "Insights need %1$d days of water in a week", arity: 1, counted: [0], bundles: ["app"]),
    CountedKey(key: "Goal met on %1$d days, up from %2$d.", arity: 2, counted: [0], bundles: ["app"]),
    CountedKey(key: "Your first drink came %1$d minutes earlier than the week before.", arity: 1, counted: [0], bundles: ["app"]),
    CountedKey(key: "Your first drink came %1$d minutes later than the week before.", arity: 1, counted: [0], bundles: ["app"]),
    CountedKey(key: "Nothing was logged on %1$d days.", arity: 1, counted: [0], bundles: ["app"]),
    CountedKey(key: "%1$lld millilitres so far today — %2$lld millilitres to go.", arity: 2,
               counted: [0, 1], bundles: ["app"]),
    CountedKey(key: "%1$lld millilitres so far today — you've reached your goal.", arity: 1,
               counted: [0], bundles: ["app"]),
    CountedKey(key: "Nothing logged yet today — %1$lld millilitres to go.", arity: 1,
               counted: [0], bundles: ["app"]),
]

private func shipped(_ name: String) -> Bundle? {
    switch name {
    case "widget": widgetBundle
    case "watch": watchBundle
    case "watchWidget": watchWidgetBundle
    default: appBundle
    }
}

/// A key's arguments: its counts, except a leading `%1$@`, which takes a vessel's name.
private func arguments(for key: String, counts: [Int]) -> [any CVarArg] {
    var values: [any CVarArg] = counts
    if key.hasPrefix("%1$@") { values[0] = "Glass" }
    return values
}

/// `localized` with a list of arguments: it is variadic, and a list cannot be spread into it.
private func format(_ strings: Bundle, _ key: String, _ arguments: [any CVarArg], _ locale: Locale) -> String {
    switch arguments.count {
    case 1: strings.localized(key, arguments[0], locale: locale)
    case 2: strings.localized(key, arguments[0], arguments[1], locale: locale)
    case 3: strings.localized(key, arguments[0], arguments[1], arguments[2], locale: locale)
    case 4: strings.localized(key, arguments[0], arguments[1], arguments[2], arguments[3], locale: locale)
    default: "no case for \(arguments.count) arguments"
    }
}

/// Spec §3.3's sentence for `key` in `language`, each figure formatted by `locale` the way the screens
/// format theirs, or `nil` for a pair this table does not know.
private func expected(_ key: String, _ language: String, _ n: [Int], _ locale: Locale) -> String? {
    let f = n.map { $0.formatted(.number.locale(locale)) }
    let ml = { (i: Int) in english(n[i], "millilitre", "millilitres") }
    let mlRu = { (i: Int) in russian(n[i], "миллилитр", "миллилитра", "миллилитров") }
    switch (key, language) {
    case ("%1$d millilitres", "en"): return "\(f[0]) \(ml(0))"
    case ("%1$d millilitres", "ru"): return "\(f[0]) \(mlRu(0))"
    case ("%1$d millilitres", "uz"): return "\(f[0]) millilitr"

    case ("%1$@, add %2$d millilitres", "en"): return "Glass, add \(f[1]) \(ml(1))"
    case ("%1$@, add %2$d millilitres", "ru"): return "Glass, добавить \(f[1]) \(mlRu(1))"
    case ("%1$@, add %2$d millilitres", "uz"): return "Glass, \(f[1]) millilitr qo‘shish"

    case ("%1$d millilitres to go", "en"): return "\(f[0]) \(ml(0)) to go"
    case ("%1$d millilitres to go", "ru"):
        return russian(n[0], "Остался \(f[0]) миллилитр", "Осталось \(f[0]) миллилитра", "Осталось \(f[0]) миллилитров")
    case ("%1$d millilitres to go", "uz"): return "\(f[0]) millilitr qoldi"

    case ("%1$d of %2$d millilitres", "en"): return "\(f[0]) of \(f[1]) \(ml(1))"
    case ("%1$d of %2$d millilitres", "ru"):
        return "\(f[0]) из \(f[1]) " + russian(n[1], "миллилитра", "миллилитров", "миллилитров")
    case ("%1$d of %2$d millilitres", "uz"): return "\(f[1]) millilitrdan \(f[0])"

    case ("%1$d percent. %2$d of %3$d millilitres.", "en"): return "\(f[0]) percent. \(f[1]) of \(f[2]) \(ml(2))."
    case ("%1$d percent. %2$d of %3$d millilitres.", "ru"):
        return "\(f[0]) " + russian(n[0], "процент", "процента", "процентов")
            + ". \(f[1]) из \(f[2]) " + russian(n[2], "миллилитра", "миллилитров", "миллилитров") + "."
    case ("%1$d percent. %2$d of %3$d millilitres.", "uz"): return "\(f[0]) foiz. \(f[2]) millilitrdan \(f[1])."

    case ("Add %1$d millilitres", "en"): return "Add \(f[0]) \(ml(0))"
    case ("Add %1$d millilitres", "ru"): return "Добавить \(f[0]) \(mlRu(0))"
    case ("Add %1$d millilitres", "uz"): return "\(f[0]) millilitr qo‘shish"

    case ("Use %1$d millilitres", "en"): return "Use \(f[0]) \(ml(0))"
    case ("Use %1$d millilitres", "ru"): return "Выбрать \(f[0]) \(mlRu(0))"
    case ("Use %1$d millilitres", "uz"): return "Tanlash: \(f[0]) millilitr"

    case (averageKey, "en"):
        return "Average \(f[0]) \(ml(0)). Best \(f[1]) \(ml(1)). Goal met on \(f[2]) of \(f[3]) "
            + english(n[3], "day", "days") + "."
    case (averageKey, "ru"):
        return "В среднем \(f[0]) \(mlRu(0)). Лучший день \(f[1]) \(mlRu(1)). Цель достигнута в \(f[2]) из \(f[3]) "
            + russian(n[3], "дня", "дней", "дней") + "."
    case (averageKey, "uz"):
        return "O‘rtacha \(f[0]) millilitr. Eng yaxshi kun \(f[1]) millilitr. \(f[3]) kundan \(f[2]) kunida maqsadga erishildi."

    case ("Last %1$d days", "en"): return "Last \(f[0]) " + english(n[0], "day", "days")
    case ("Last %1$d days", "ru"): return "Последние \(f[0]) " + russian(n[0], "день", "дня", "дней")
    case ("Last %1$d days", "uz"): return "Oxirgi \(f[0]) kun"

    case ("%1$d days", "en"): return "\(f[0]) " + english(n[0], "day", "days")
    case ("%1$d days", "ru"): return "\(f[0]) " + russian(n[0], "день", "дня", "дней")
    case ("%1$d days", "uz"): return "\(f[0]) kun"

    case ("%1$d servings", "en"): return "\(f[0]) " + english(n[0], "serving", "servings")
    case ("%1$d servings", "ru"): return "\(f[0]) " + russian(n[0], "порция", "порции", "порций")
    case ("%1$d servings", "uz"): return "\(f[0]) porsiya"

    case ("%1$d of %2$d days", "en"): return "\(f[0]) of \(f[1]) " + english(n[1], "day", "days")
    case ("%1$d of %2$d days", "ru"): return "\(f[0]) из \(f[1]) " + russian(n[1], "дня", "дней", "дней")
    case ("%1$d of %2$d days", "uz"): return "\(f[1]) kundan \(f[0])"

    case ("%1$d of %2$d days on goal", "en"): return "\(f[0]) of \(f[1]) " + english(n[1], "day", "days") + " on goal"
    case ("%1$d of %2$d days on goal", "ru"):
        return "Цель достигнута в \(f[0]) из \(f[1]) " + russian(n[1], "дня", "дней", "дней")
    case ("%1$d of %2$d days on goal", "uz"): return "\(f[1]) kundan \(f[0]) kunida maqsadga erishildi"

    case ("Average %1$d millilitres a day", "en"): return "Average \(f[0]) \(ml(0)) a day"
    case ("Average %1$d millilitres a day", "ru"): return "В среднем \(f[0]) \(mlRu(0)) в день"
    case ("Average %1$d millilitres a day", "uz"): return "Kuniga o‘rtacha \(f[0]) millilitr"

    case ("Up %1$d millilitres on the month before", "en"): return "Up \(f[0]) \(ml(0)) on the month before"
    case ("Up %1$d millilitres on the month before", "ru"): return "На \(f[0]) \(mlRu(0)) больше, чем в предыдущем месяце"
    case ("Up %1$d millilitres on the month before", "uz"): return "Oldingi oydan \(f[0]) millilitr ko‘p"

    case ("Down %1$d millilitres on the month before", "en"): return "Down \(f[0]) \(ml(0)) on the month before"
    case ("Down %1$d millilitres on the month before", "ru"): return "На \(f[0]) \(mlRu(0)) меньше, чем в предыдущем месяце"
    case ("Down %1$d millilitres on the month before", "uz"): return "Oldingi oydan \(f[0]) millilitr kam"

    case ("%1$d millilitres a day", "en"): return "\(f[0]) \(ml(0)) a day"
    case ("%1$d millilitres a day", "ru"): return "\(f[0]) \(mlRu(0)) в день"
    case ("%1$d millilitres a day", "uz"): return "Kuniga \(f[0]) millilitr"

    case ("Patterns need %1$d days of water", "en"):
        return "Patterns need \(f[0]) " + english(n[0], "day", "days") + " of water"
    case ("Patterns need %1$d days of water", "ru"):
        // «Нужен» agrees with a singular «день»; «нужно» goes with «дня» and «дней».
        return russian(n[0], "Для привычек нужен \(f[0]) день", "Для привычек нужно \(f[0]) дня", "Для привычек нужно \(f[0]) дней")
            + " с водой"
    case ("Patterns need %1$d days of water", "uz"):
        return "Odatlar uchun suv ichilgan \(f[0]) kun kerak"

    case ("Insights need %1$d days of water in a week", "en"):
        return "Insights need \(f[0]) " + english(n[0], "day", "days") + " of water in a week"
    case ("Insights need %1$d days of water in a week", "ru"):
        // «Нужен» agrees with a singular «день», as the patterns' line does.
        return russian(n[0], "Для советов нужен \(f[0]) день", "Для советов нужно \(f[0]) дня", "Для советов нужно \(f[0]) дней")
            + " с водой за неделю"
    case ("Insights need %1$d days of water in a week", "uz"):
        return "Tavsiyalar uchun haftada suv ichilgan \(f[0]) kun kerak"

    case ("Goal met on %1$d days, up from %2$d.", "en"):
        return "Goal met on \(f[0]) " + english(n[0], "day", "days") + ", up from \(f[1])."
    // A label and its count: no noun stands beside the figure, so no form to take.
    case ("Goal met on %1$d days, up from %2$d.", "ru"): return "Дней с целью: \(f[0]), на прошлой неделе — \(f[1])."
    case ("Goal met on %1$d days, up from %2$d.", "uz"): return "Maqsadga erishilgan kunlar: \(f[0]), oldingi haftada — \(f[1])."

    case ("Your first drink came %1$d minutes earlier than the week before.", "en"):
        return "Your first drink came \(f[0]) " + english(n[0], "minute", "minutes") + " earlier than the week before."
    case ("Your first drink came %1$d minutes earlier than the week before.", "ru"):
        return "Первая порция — на \(f[0]) " + russian(n[0], "минуту", "минуты", "минут") + " раньше, чем на прошлой неделе."
    case ("Your first drink came %1$d minutes earlier than the week before.", "uz"):
        return "Birinchi porsiya oldingi haftadan \(f[0]) daqiqa erta bo‘ldi."

    case ("Your first drink came %1$d minutes later than the week before.", "en"):
        return "Your first drink came \(f[0]) " + english(n[0], "minute", "minutes") + " later than the week before."
    case ("Your first drink came %1$d minutes later than the week before.", "ru"):
        return "Первая порция — на \(f[0]) " + russian(n[0], "минуту", "минуты", "минут") + " позже, чем на прошлой неделе."
    case ("Your first drink came %1$d minutes later than the week before.", "uz"):
        return "Birinchi porsiya oldingi haftadan \(f[0]) daqiqa kech bo‘ldi."

    case ("Nothing was logged on %1$d days.", "en"):
        return "Nothing was logged on \(f[0]) " + english(n[0], "day", "days") + "."
    case ("Nothing was logged on %1$d days.", "ru"):
        return "Ничего не записано за \(f[0]) " + russian(n[0], "день", "дня", "дней") + "."
    case ("Nothing was logged on %1$d days.", "uz"): return "\(f[0]) kun hech narsa qayd etilmadi."

    case ("%1$lld millilitres so far today — %2$lld millilitres to go.", "en"):
        return "\(f[0]) \(ml(0)) so far today — \(f[1]) \(ml(1)) to go."
    case ("%1$lld millilitres so far today — %2$lld millilitres to go.", "ru"):
        return "Сегодня уже \(f[0]) \(mlRu(0)) — "
            + russian(n[1], "остался \(f[1]) миллилитр", "осталось \(f[1]) миллилитра", "осталось \(f[1]) миллилитров") + "."
    case ("%1$lld millilitres so far today — %2$lld millilitres to go.", "uz"):
        return "Bugun \(f[0]) millilitr — \(f[1]) millilitr qoldi."

    case ("%1$lld millilitres so far today — you've reached your goal.", "en"):
        return "\(f[0]) \(ml(0)) so far today — you've reached your goal."
    case ("%1$lld millilitres so far today — you've reached your goal.", "ru"):
        return "Сегодня уже \(f[0]) \(mlRu(0)) — цель достигнута."
    case ("%1$lld millilitres so far today — you've reached your goal.", "uz"):
        return "Bugun \(f[0]) millilitr — maqsadga erishildi."

    case ("Nothing logged yet today — %1$lld millilitres to go.", "en"):
        return "Nothing logged yet today — \(f[0]) \(ml(0)) to go."
    case ("Nothing logged yet today — %1$lld millilitres to go.", "ru"):
        return "Сегодня ещё ничего не записано — "
            + russian(n[0], "остался \(f[0]) миллилитр", "осталось \(f[0]) миллилитра", "осталось \(f[0]) миллилитров") + "."
    case ("Nothing logged yet today — %1$lld millilitres to go.", "uz"):
        return "Bugun hali hech narsa qayd etilmagan — \(f[0]) millilitr qoldi."

    default: return nil
    }
}

/// ``Bundle/localized(_:_:locale:)`` and the counted keys' forms. Not `@MainActor`: the helper is
/// `nonisolated`, and the widget's views call it.
struct PluralFormTests {

    /// Spec §6.1: every counted key, in every bundle that holds it, at every count, in the form §3.3
    /// gives it — a key with more than one counted argument varied one argument at a time, the
    /// others held at 5. The locale is the one `AppLanguage.locale` makes for a chosen language.
    @Test(arguments: ["en", "ru", "uz"])
    func everyCountedKeyTakesTheFormItsCountNeeds(language: String) throws {
        let locale = Locale(identifier: language)
        for counted in countedKeys {
            for name in counted.bundles {
                let strings = try #require(localization(shipped(name), language),
                                           "the \(name) bundle ships no \(language)")
                for position in counted.counted {
                    for count in pluralCounts {
                        var counts = Array(repeating: 5, count: counted.arity)
                        counts[position] = count
                        let drawn = format(strings, counted.key, arguments(for: counted.key, counts: counts), locale)
                        #expect(drawn == expected(counted.key, language, counts, locale),
                                "\(name), \(language): \"\(counted.key)\" with \(counts)")
                    }
                }
            }
        }
    }

    /// Spec §2, finding 2, on the simulator: the Russian table formatted with no locale does not take
    /// its form from Russian. The probes ran under an English process locale, so this means something
    /// only under one, and says so rather than passing or failing for another reason.
    @Test func withNoLocaleTheRussianTableIsNotReadAsRussian() throws {
        try #require(Locale.current.language.languageCode == .english,
                     "the test host runs in \(Locale.current.identifier), not English — the probes' finding is not what this run can see")
        let russian = try #require(localization(appBundle, "ru"), "the app ships no ru table")
        let key = russian.localizedString(forKey: "Add %1$d millilitres", value: nil, table: nil)

        #expect(String(format: key, 5) == "Добавить 5 миллилитра")
        #expect(russian.localized("Add %1$d millilitres", 5, locale: Locale(identifier: "ru")) == "Добавить 5 миллилитров")
    }

    /// Spec §8, as measured: *Follow device* on a phone in a language the app does not ship formats the
    /// English table with `en_` and the phone's region — `en_DE` on a German phone (iOS 27.0
    /// simulator, `-testLanguage de -testRegion DE`, 2026-10-17) — so English words, in English's forms,
    /// with the region's grouping.
    @Test func aGermanPhoneOnFollowDeviceGetsEnglishWordsAndGermanFigures() throws {
        let english = try #require(localization(appBundle, "en"), "the app ships no en table")
        let german = Locale(identifier: "en_DE")

        #expect(english.localized("%1$d millilitres", 1, locale: german) == "1 millilitre")
        #expect(english.localized("%1$d millilitres", 1_300, locale: german)
                == "\(1_300.formatted(.number.locale(german))) millilitres")
    }

    /// A Japanese phone gets `en_JP` (measured as above), so Japanese's single form never reaches the
    /// English table: *1 millilitre*. The spec expected *1 millilitres* until the final review measured
    /// the locale; ``theFollowDeviceLocaleSpeaksTheBundlesLanguage()`` pins why.
    @Test func aJapanesePhoneOnFollowDeviceGetsEnglishForms() throws {
        let english = try #require(localization(appBundle, "en"), "the app ships no en table")

        #expect(english.localized("%1$d millilitres", 1, locale: Locale(identifier: "en_JP")) == "1 millilitre")
    }

    /// The rule every form rests on: on *Follow device* the locale `AppLanguage.system` hands the views
    /// speaks the language of the table it formats, so the plural rule is the words' own. Foundation
    /// takes `Locale.current`'s language from the bundle's resolved localization — a Japanese phone
    /// formats the English table with `en_JP` — where a `.system` locale built from the phone's own
    /// first language would format it by Japanese's one form, *1 millilitres*. Run under
    /// `-testLanguage ja -testRegion JP` to see a phone in a language the app does not ship.
    @Test func theFollowDeviceLocaleSpeaksTheBundlesLanguage() {
        let bundleLanguage = Bundle.main.preferredLocalizations.first
        let locale = AppLanguage.system.locale

        #expect(locale.language.languageCode?.identifier == bundleLanguage,
                "Follow device formats the \(bundleLanguage ?? "nil") table with \(locale.identifier)")
    }
}
