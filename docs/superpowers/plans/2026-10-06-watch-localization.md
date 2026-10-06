# Watch Localization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:executing-plans, run inline in the main
> loop. `CLAUDE.md` says "There is **no implementation subagent**", which rules out
> superpowers:subagent-driven-development unless the owner overrides it for this plan. Steps use
> checkbox (`- [ ]`) syntax for tracking.

> **Status:** executed in full on 2026-10-06, inline on `main`, staged for the owner's `/commit`.
> The checkboxes below were left unticked — progress was tracked in the executor's ledger — so read
> `HISTORY.md`'s checkpoint of that date for the results and for every ruling that departed from a
> step. Task 7 Steps 3 and 4 were skipped at the owner's choice.

**Goal:** The watch app and its complication draw English, Russian or Uzbek. The language follows
the phone's in-app choice, and falls back to the watch's own system language.

**Architecture:** `WristModel.language` reads `WristMirror.languageCode` (already sent and already
saved). A private `WristRoot` view injects `\.strings` and `\.locale` above `WristView`. Every watch
string resolves through that bundle, copying the phone's call style. Two new string catalogues ship
the words. The phone's `LocalizationTests` reaches the watch bundles inside the built phone app and
holds them to the phone's own strings.

**Tech Stack:** Swift (`SWIFT_VERSION = 5.0`), SwiftUI, Observation, WidgetKit, String Catalogs
(`.xcstrings`), swift-testing. Xcode 27.0, iOS 26.5 and watchOS 26.5 simulators.

**Spec:** `docs/superpowers/specs/2026-10-06-watch-localization-design.md` (owner-approved
2026-10-06). Read it alongside this plan: the plan argues from it.

## Global Constraints

- **Languages:** exactly `en`, `ru` and `uz`. `sourceLanguage` is `en`. Every authored key has
  explicit `en`, `ru` and `uz` values, except `%` and `WaterBuddy`, which are `en` only.
- **Positional format specifiers** in every key (`%1$d`, `%1$@`), never bare `%d`.
- **Where the language comes from:** the watch follows `WristMirror.languageCode`. `nil`, and no
  mirror at all, both resolve the watch's own `Bundle.main`.
- **Injection:** `\.strings` and `\.locale` are injected **together**, at `WristRoot`, which is a
  `View`, never the `App` body.
- Pure functions take their `Bundle` with **no default value**.
- **English copy is unchanged, with three exceptions:**
  - the VoiceOver value adopts `%1$d percent. %2$d of %3$d millilitres.`
  - the complication's description becomes `Today's hydration`, with no full stop
  - the "More" button loses its separate `More servings` label
- **Copied, never retranslated:** six keys come value for value from
  `WaterBuddy/Localizable.xcstrings`: `Today's hydration`, `%1$d percent. %2$d of %3$d millilitres.`,
  `%1$d ml`, `Cup`, `Glass`, `Bottle`.
- **Untouched:**
  - nothing on the phone
  - nothing sent between the devices (`schemaVersion` stays 1)
  - no new shared Swift file, and no change to the exception sets
  - no `project.pbxproj` edit, no entitlement change, no `PrivacyInfo.xcprivacy` change
  - the complication's view tree and timeline
- **Git:** never commit (`CLAUDE.md`). Stage by explicit path only (rule `90-git`).
- **Test fixtures:** each uses its own UUID-named throwaway suite and tears it down. Never touch
  the real `group.sardor.WaterBuddy` suite or `UserDefaults.standard`. Inject the clock.
- **Running `xcodebuild`:**
  - in the foreground, on one simulator, after `xcrun simctl shutdown all`
  - always with `-parallel-testing-enabled NO`
  - add `-collect-test-diagnostics never` to every filtered run, so a run that fails doesn't stall
    collecting diagnostics (`tasks/lessons.md`, 2026-10-05)
- **Read the executed-test count** on every filtered run, never the exit status
  (`tasks/lessons.md`, 2026-08-31).
- **No new warning** against the Xcode 27 baseline. Compare clean builds per file and message: 31
  unique lines on `-scheme WaterBuddy`, plus two `actool` lines on `WaterBuddyWatchWidget`.
- **A denied tool call is a stop sign** (`CLAUDE.md`). Report it and stop.
- **Never weaken an assertion.** If a test and the code disagree, stop and report.

## Review Focus

1. **A language added to `AppLanguage.selectable` later** must not silently draw English on the
   watch. Two tests iterate `AppLanguage.selectable`, not a literal list:
   `theWatchShipsEveryLanguage` (Task 2) and `theWatchShipsAStringsBundleForEveryLanguage`
   (Task 3).
2. **A phone whose clock runs ahead** stamps `composedAt` in the watch's future. That must read
   "just now" in every language, never a negative minute count:
   `aMirrorFromThePhonesFutureReadsAsJustNow` (Task 3).
3. **A malformed code on the wire** (`"system"`, `""`, `"xx"`) must leave the watch on its own
   language: `anUnrecognisedLanguageCodeFallsBackToTheWatchsOwn`, parameterized (Task 1).
4. **The readout's extremes:** the empty state `0 / 2,000 ml` and five-digit figures must be
   grouped the language's way: `theVesselReadoutGroupsThousandsInTheChosenLanguage` (Task 4).
5. **A phone put back on *Follow device*** must hand the watch back its own language; the switch
   runs both ways: `aNewMirrorSwitchesTheLanguageForObservers` (Task 1).

---

## File map

| File | Change | Responsibility |
|---|---|---|
| `WaterBuddyWatch/WristModel.swift` | modify | `language` — which language the watch draws in |
| `WaterBuddyWatch/WaterBuddyWatchApp.swift` | modify | `WristRoot` — injects `\.strings` and `\.locale` |
| `WaterBuddyWatch/WristView.swift` | modify | captions, serving names, VoiceOver, the "More" button, the sheet |
| `WaterBuddyWatch/WristVessel.swift` | modify | the grouped readout, and the percentage formatted for the locale |
| `WaterBuddyWatch/Localizable.xcstrings` | **create** | the watch app's 16 keys |
| `WaterBuddyWatchWidget/Localizable.xcstrings` | **create** | `Today's hydration` and `WaterBuddy` |
| `WaterBuddyWatchWidget/WaterBuddyWatchWidget.swift` | modify (line 85) | the description loses its full stop |
| `WaterBuddyWatchTests/WristModelTests.swift` | modify | language tests |
| `WaterBuddyWatchTests/WristViewLogicTests.swift` | modify | caption, name and readout tests |
| `WaterBuddyTests/LocalizationTests.swift` | modify | the watch bundles, checked from the phone |
| `.claude/rules/{70-privacy,15-project,50-views,65-accessibility}.md` | modify | spec §7 amendments |
| `HISTORY.md`, `tasks/lessons.md`, `docs/*` | modify | checkpoint and `/doc_sync` |

## Conventions used below

- **`SCRATCH`** is the session's scratchpad. In the session that wrote this plan it was
  `/private/tmp/claude-501/-Users-sardorallaberganov-Desktop-Projects-MobileApps-WaterBuddy/6f1e0dcf-dd67-4357-aa6f-b46288159a77/scratchpad`.
  A later session substitutes its own. Shell state doesn't carry between commands, so every block
  that uses it sets it.
- **Every command runs from the repository root**,
  `/Users/sardorallaberganov/Desktop/Projects/MobileApps/WaterBuddy`.
- **Filtered runs** pipe through `grep -E "error:|✔|✘|Test run with|Executed|\*\* TEST|\*\* BUILD"`,
  so the counts and errors are what's read.
- **Expected `@Test` counts:**

  | Target | Today | After this plan | Breakdown |
  |---|---|---|---|
  | Phone | 309 | **316** | `LocalizationTests` 13 → 20 |
  | Watch | 30 | **42** | `WristModelTests` 11 → 17; `WristViewLogicTests` 13 → 19 |

---

### Task 1: `WristModel.language`

**Files:**
- Modify: `WaterBuddyWatch/WristModel.swift` (right after `displayGoal`, lines 98–100)
- Test: `WaterBuddyWatchTests/WristModelTests.swift`

**Interfaces:**
- **Consumes:** `AppLanguage(code: String?)` (`DataManager.swift:1539`), `WristModel.mirror`,
  `WristModel.apply(_:)`.
- **Produces:** `var language: AppLanguage { get }` on the `@MainActor` `WristModel`.
  Observation tracks it through `mirror`. Task 5's `WristRoot` reads `language.bundle` and
  `language.locale` from it.

- [ ] **Step 1: Add the Observation import and the counter box**

In `WaterBuddyWatchTests/WristModelTests.swift`, find:

```swift
import Foundation
import Testing
@testable import WaterBuddyWatch

@MainActor
struct WristModelTests {
```

Replace with:

```swift
import Foundation
import Observation
import Testing
@testable import WaterBuddyWatch

/// `withObservationTracking`'s `onChange` is `@Sendable`, so the tally needs a reference box
/// (rule `85-testing`).
private final class Counter: @unchecked Sendable {
    var count = 0
}

@MainActor
struct WristModelTests {
```

- [ ] **Step 2: Write the failing tests**

In the same file, find the last test's tail and the closing brace:

```swift
            #expect(model.todaysTotal == 250)
            #expect(model.displayGoal == DataManager.defaultDailyGoal)
            #expect(makeModel(defaults, now: { now }).pendingOutbox.map(\.amount) == [250])
        }
    }
}
```

Replace with:

```swift
            #expect(model.todaysTotal == 250)
            #expect(model.displayGoal == DataManager.defaultDailyGoal)
            #expect(makeModel(defaults, now: { now }).pendingOutbox.map(\.amount) == [250])
        }
    }

    // MARK: - The language the watch draws in (spec 2026-10-06 §4.1)

    /// A mirror that differs from the ones above only in the language the phone chose.
    private static func mirror(language code: String?) -> WristMirror {
        let now = Date(timeIntervalSince1970: 1_000)
        return WristMirror(
            schemaVersion: WristMirror.currentSchemaVersion, currentWater: 0, dailyGoal: 2_000,
            servings: [150, 250, 500], languageCode: code, isGoalSet: true,
            composedAt: now, phoneDayStart: utc.startOfDay(for: now), phoneDayEnd: endOfFirstDay,
            acked: []
        )
    }

    @Test
    func theWatchFollowsTheLanguageChosenOnThePhone() {
        withTempDefaults { defaults in
            let model = makeModel(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            model.apply(Self.mirror(language: "ru"))
            #expect(model.language == .russian)
        }
    }

    @Test
    func withNoMirrorTheWatchFollowsItsOwnLanguage() {
        withTempDefaults { defaults in
            let model = makeModel(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            #expect(model.mirror == nil, "precondition: never synced")
            #expect(model.language == .system)
        }
    }

    /// `nil` is the phone saying *Follow device*. On the wrist that means the watch's own language,
    /// not the phone's — the two usually match, because watchOS mirrors the iPhone's language by
    /// default, but only the watch knows its own.
    @Test
    func aPhoneFollowingItsDeviceLeavesTheWatchOnItsOwn() {
        withTempDefaults { defaults in
            let model = makeModel(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            model.apply(Self.mirror(language: nil))
            #expect(model.language == .system)
        }
    }

    /// Review focus: whatever arrives on the wire, the watch never reaches for a bundle it doesn't
    /// have. `"system"` is a case name the phone never stores (rule `70-privacy`), `""` is what a
    /// corrupt encode would carry, and `"xx"` stands for a language a newer phone ships and this
    /// build does not.
    @Test(arguments: ["xx", "system", ""])
    func anUnrecognisedLanguageCodeFallsBackToTheWatchsOwn(code: String) {
        withTempDefaults { defaults in
            let model = makeModel(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            model.apply(Self.mirror(language: code))
            #expect(model.language == .system)
        }
    }

    /// `WristRoot` re-injects the bundle only if Observation tells it the language moved. And —
    /// review focus — the switch runs both ways: a phone put back on *Follow device* hands the watch
    /// back its own language rather than leaving it on the last one it was told.
    @Test
    func aNewMirrorSwitchesTheLanguageForObservers() {
        withTempDefaults { defaults in
            let model = makeModel(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            model.apply(Self.mirror(language: "ru"))

            let changes = Counter()
            withObservationTracking {
                _ = model.language
            } onChange: {
                changes.count += 1
            }
            model.apply(Self.mirror(language: "uz"))

            #expect(changes.count == 1)
            #expect(model.language == .uzbek)

            model.apply(Self.mirror(language: nil))
            #expect(model.language == .system)
        }
    }

    @Test
    func theChosenLanguageSurvivesARelaunch() {
        withTempDefaults { defaults in
            let now = Date(timeIntervalSince1970: 1_000)
            makeModel(defaults, now: { now }).apply(Self.mirror(language: "ru"))
            let relaunched = makeModel(defaults, now: { now })
            #expect(relaunched.language == .russian,
                    "the language rides in the persisted mirror, so a relaunch keeps it")
        }
    }
}
```

- [ ] **Step 3: Run the suite and confirm RED**

```bash
xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' \
  -only-testing:WaterBuddyWatchTests/WristModelTests -parallel-testing-enabled NO \
  -collect-test-diagnostics never 2>&1 | grep -E "error:|✔|✘|Test run with|Executed|\*\* TEST|\*\* BUILD"
```

Expected: `error: value of type 'WristModel' has no member 'language'` (at each use), then
`** TEST FAILED **`.

- [ ] **Step 4: Implement**

In `WaterBuddyWatch/WristModel.swift`, find:

```swift
    var displayGoal: Int {
        mirror?.dailyGoal ?? DataManager.defaultDailyGoal
    }
```

Replace with:

```swift
    var displayGoal: Int {
        mirror?.dailyGoal ?? DataManager.defaultDailyGoal
    }

    /// The language the watch draws in: the phone's own in-app choice, carried on the mirror
    /// (`docs/superpowers/specs/2026-10-06-watch-localization-design.md` §4.1).
    ///
    /// `nil` on the wire — the phone set to *Follow device* — and no mirror at all, before the first
    /// sync, both resolve to ``AppLanguage/system``: this watch's own `Bundle.main`, its own system
    /// language. "Follow device", read on the wrist, means *this* device.
    ///
    /// **Resolved through the phone's own `AppLanguage(code:)`**, so an unrecognised code — a
    /// language a newer phone ships and this build does not, or anything corrupt — falls back to the
    /// watch's own language and says so under `#if DEBUG` (rule `70-privacy`), rather than reaching
    /// for a bundle that isn't there.
    ///
    /// **A read, never a write.** Nothing new is stored: `languageCode` already rides inside the
    /// persisted mirror, which is why the choice survives a relaunch. This is not
    /// `DataManager.language` and never touches `Key.language` — one writer per store (rule
    /// `20-state`). Like `displayGoal`, it needs no tracking of its own: it changes exactly when
    /// `mirror` does.
    var language: AppLanguage {
        AppLanguage(code: mirror?.languageCode)
    }
```

- [ ] **Step 5: Run the suite and confirm GREEN**

Run the Step 3 command again.
Expected: `✔ Test run with 17 tests in 1 suite passed`.

- [ ] **Step 6: Stage**

```bash
git add WaterBuddyWatch/WristModel.swift WaterBuddyWatchTests/WristModelTests.swift
```

---

### Task 2: The watch's two catalogues, checked from the phone

**Files:**
- Create: `WaterBuddyWatch/Localizable.xcstrings`
- Create: `WaterBuddyWatchWidget/Localizable.xcstrings`
- Modify: `WaterBuddyWatchWidget/WaterBuddyWatchWidget.swift:85`
- Test: `WaterBuddyTests/LocalizationTests.swift`

**Interfaces:**
- **Consumes:** `AppLanguage.selectable` and `AppLanguage.code` (both `nonisolated`); the six
  shared keys in `WaterBuddy/Localizable.xcstrings`; the existing helpers `localization(_:_:)`,
  `value(_:_:_:)`, `table(_:_:)` and `specifiers(in:)`.
- **Produces:**
  - The watch app's `en.lproj`, `ru.lproj` and `uz.lproj`, holding 16 keys between them: 15 in all
    three languages, plus `%` in `en` only.
  - The watch widget's three `.lproj` folders, holding `Today's hydration` (all three languages)
    and `WaterBuddy` (`en` only).
  - Tasks 3–5 resolve these keys.

- [ ] **Step 1: Add the watch fixtures**

In `WaterBuddyTests/LocalizationTests.swift`, find:

```swift
private let widgetBundle = Bundle(
    url: appBundle.bundleURL.appending(path: "PlugIns/WaterBuddyWidgetExtension.appex")
)
```

Replace with:

```swift
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
```

- [ ] **Step 2: Write the failing tests**

In the same file, find the suite's last test and closing brace:

```swift
    @Test(arguments: translated)
    func theProductNameIsNeverTranslated(language: String) {
        #expect(value(appBundle, language, "WaterBuddy") == nil,
                "WaterBuddy has a \(language) entry — the product name is not a word")
    }
}
```

Replace with:

```swift
    @Test(arguments: translated)
    func theProductNameIsNeverTranslated(language: String) {
        #expect(value(appBundle, language, "WaterBuddy") == nil,
                "WaterBuddy has a \(language) entry — the product name is not a word")
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
```

- [ ] **Step 3: Run the suite and confirm RED**

```bash
xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests/LocalizationTests -parallel-testing-enabled NO \
  -collect-test-diagnostics never 2>&1 | grep -E "error:|✔|✘|Test run with|Executed|\*\* TEST|\*\* BUILD"
```

Expected: `✘ Test run with 20 tests in 1 suite failed`.
- **Fail (five):** `theWatchShipsEveryLanguage`, `theWatchAgreesWithThePhoneOnEverySharedString`,
  `theWatchsOwnKeysResolveInEveryLanguage`, `noWatchTranslationLosesAFormatArgument` and
  `everyWatchStringIsTranslatedUnlessDeliberatelyNot`. The watch has no `.lproj` yet.
- **Pass:** `theWatchBundlesAreWhereWeThinkTheyAre`, `theProductNameIsNeverTranslatedOnTheWatch`
  (vacuous until there are tables), and the 13 existing tests.

**Stop condition:** if `theWatchBundlesAreWhereWeThinkTheyAre` **fails**, stop. The installed test
host doesn't embed the watch app, so spec §6.3 doesn't hold. Report it to the owner. Do not move
the tests to another target on your own.

- [ ] **Step 4: Generate both catalogues**

The script copies the six shared keys straight out of the phone's catalogue, so a copying mistake
can't happen at all rather than merely being caught by a test. Run from the repository root:

```bash
python3 - <<'EOF'
import json, pathlib

phone = json.loads(pathlib.Path("WaterBuddy/Localizable.xcstrings").read_text(encoding="utf-8"))["strings"]

def unit(value):
    return {"stringUnit": {"state": "translated", "value": value}}

def copied(key):
    loc = phone[key]["localizations"]
    return {"extractionState": "manual", "localizations": {lang: loc[lang] for lang in ("en", "ru", "uz")}}

def authored(key, ru, uz):
    return {"extractionState": "manual", "localizations": {"en": unit(key), "ru": unit(ru), "uz": unit(uz)}}

SHARED = ["Today's hydration", "%1$d percent. %2$d of %3$d millilitres.", "%1$d ml", "Cup", "Glass", "Bottle"]

OWN = {
    "%1$@ / %2$@ ml": ("%1$@ / %2$@ мл", "%1$@ / %2$@ ml"),
    "Logs %1$d millilitres": ("Записывает %1$d миллилитров", "%1$d millilitr qayd etadi"),
    "More": ("Ещё", "Yana"),
    "Shows the other serving sizes": ("Показывает другие порции", "Boshqa porsiyalarni ko‘rsatadi"),
    "Not yet synced · default goal": ("Нет синхронизации · цель по умолчанию", "Hali sinxronlanmagan · standart maqsad"),
    "Set your goal in WaterBuddy on iPhone": ("Задайте цель в WaterBuddy на iPhone", "Maqsadni iPhone’dagi WaterBuddy’da belgilang"),
    "Not yet synced": ("Нет синхронизации", "Hali sinxronlanmagan"),
    "Synced just now": ("Синхронизировано только что", "Hozirgina sinxronlandi"),
    "Synced %1$dm ago": ("Синхронизировано %1$d мин назад", "%1$d daqiqa oldin sinxronlandi"),
}

watch = {key: copied(key) for key in SHARED}
watch.update({key: authored(key, ru, uz) for key, (ru, uz) in OWN.items()})
watch["%"] = {"localizations": {"en": unit("%")}}  # a symbol: en only, exactly like the phone's entry

widget = {
    "Today's hydration": copied("Today's hydration"),
    "WaterBuddy": {"localizations": {"en": unit("WaterBuddy")}},  # the product's name: en only
}

for path, strings in [("WaterBuddyWatch/Localizable.xcstrings", watch),
                      ("WaterBuddyWatchWidget/Localizable.xcstrings", widget)]:
    doc = {"sourceLanguage": "en", "strings": dict(sorted(strings.items())), "version": "1.0"}
    pathlib.Path(path).write_text(json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(path, len(strings), "keys")
EOF
```

Expected:

```
WaterBuddyWatch/Localizable.xcstrings 16 keys
WaterBuddyWatchWidget/Localizable.xcstrings 2 keys
```

- [ ] **Step 5: Drop the description's full stop**

In `WaterBuddyWatchWidget/WaterBuddyWatchWidget.swift`, find:

```swift
        .description("Today's hydration.")
```

Replace with:

```swift
        // No full stop: this is the phone's own `Today's hydration`, so the complication's catalogue
        // holds it value for value and `LocalizationTests` keeps the two from drifting.
        .description("Today's hydration")
```

- [ ] **Step 6: Run the suite and confirm GREEN, then build the watch widget**

Run the Step 3 command again.
Expected: `✔ Test run with 20 tests in 1 suite passed`.

Then, because a watch-widget source changed and no other scheme compiles it on its own (rule
`15-project`):

```bash
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' \
  2>&1 | grep -E "warning:|error:|\*\* BUILD"
```

Expected: `** BUILD SUCCEEDED **`. The only warnings should be the two known `actool` lines,
*"Could not get trait set for device Watch7,18 with version 26.5"* (known issue #36).

The build may have added keys to the two catalogues that it extracted from code not yet migrated
(for example `More servings`, `Logs %lld millilitres`). That is expected: they carry no values and
reach no table, and Task 6 removes the ones that go stale.

- [ ] **Step 7: Stage**

```bash
git add WaterBuddyWatch/Localizable.xcstrings WaterBuddyWatchWidget/Localizable.xcstrings \
  WaterBuddyWatchWidget/WaterBuddyWatchWidget.swift WaterBuddyTests/LocalizationTests.swift
```

---

### Task 3: The captions, in the chosen language

**Files:**
- Modify: `WaterBuddyWatch/WristView.swift`:
  - the `@Environment` property, after line 75
  - DocC at lines 138–140, 232–235 and 349
  - `attributionLine` (line 237)
  - `attribution` and `syncedCaption` (lines 351–366)
- Modify: `WaterBuddyWatch/WristModel.swift:92-94` (a DocC reference to the old signature)
- Test: `WaterBuddyWatchTests/WristViewLogicTests.swift`

**Interfaces:**
- **Consumes:** the watch catalogue (Task 2); `AppLanguage.selectable`.
- **Produces** (both `nonisolated static`):
  - `WristView.attribution(mirror: WristMirror?, now: Date, strings: Bundle) -> String`
  - `WristView.syncedCaption(composedAt: Date?, now: Date, strings: Bundle) -> String`
- **Also produces** a file-scope test helper, `private func shipped(_ language: String) -> Bundle?`,
  in `WristViewLogicTests.swift`. Task 4 uses it.

- [ ] **Step 1: Add the bundle helper and the guard test**

In `WaterBuddyWatchTests/WristViewLogicTests.swift`, find:

```swift
import Foundation
import Testing
@testable import WaterBuddyWatch
```

Replace with:

```swift
import Foundation
import Testing
@testable import WaterBuddyWatch

/// One language's strings as the watch ships them. This suite is hosted by the watch app
/// (`TEST_HOST`), so `Bundle.main` here is `WaterBuddyWatch.app` and these are its own `.lproj`s —
/// the same lookup `AppLanguage.bundle` makes.
private func shipped(_ language: String) -> Bundle? {
    Bundle.main.url(forResource: language, withExtension: "lproj").flatMap(Bundle.init(url:))
}
```

Then find:

```swift
struct WristViewLogicTests {

    @Test
    func fallsBackToTheDefaultServingsWithNoMirrorYet() {
```

Replace with:

```swift
struct WristViewLogicTests {

    /// Every bundle below is the watch app's own, and every assertion against one is vacuous if it
    /// didn't resolve — so this runs over the languages the product *offers*, not a list typed here
    /// (review focus: a language added to `AppLanguage.selectable` must not silently draw English
    /// on the watch).
    @Test(arguments: AppLanguage.selectable.compactMap(\.code))
    func theWatchShipsAStringsBundleForEveryLanguage(language: String) {
        #expect(shipped(language) != nil, "the watch app ships no \(language).lproj")
    }

    @Test
    func fallsBackToTheDefaultServingsWithNoMirrorYet() {
```

- [ ] **Step 2: Pass the English bundle to the six existing caption tests, keeping their exact
  expectations**

Find:

```swift
    @Test
    func syncedJustNowReadsAsNow() {
        let text = WristView.syncedCaption(composedAt: Date(timeIntervalSince1970: 1_000), now: Date(timeIntervalSince1970: 1_030))
        #expect(text == "Synced just now")
    }

    @Test
    func syncedMinutesAgoReadsInWholeMinutes() {
        let text = WristView.syncedCaption(composedAt: Date(timeIntervalSince1970: 1_000), now: Date(timeIntervalSince1970: 1_000 + 245))
        #expect(text == "Synced 4m ago")
    }

    @Test
    func noMirrorYetReadsAsNeverSynced() {
        #expect(WristView.syncedCaption(composedAt: nil, now: .now) == "Not yet synced")
    }
```

Replace with:

```swift
    @Test
    func syncedJustNowReadsAsNow() throws {
        let english = try #require(shipped("en"))
        let text = WristView.syncedCaption(composedAt: Date(timeIntervalSince1970: 1_000), now: Date(timeIntervalSince1970: 1_030), strings: english)
        #expect(text == "Synced just now")
    }

    @Test
    func syncedMinutesAgoReadsInWholeMinutes() throws {
        let english = try #require(shipped("en"))
        let text = WristView.syncedCaption(composedAt: Date(timeIntervalSince1970: 1_000), now: Date(timeIntervalSince1970: 1_000 + 245), strings: english)
        #expect(text == "Synced 4m ago")
    }

    @Test
    func noMirrorYetReadsAsNeverSynced() throws {
        let english = try #require(shipped("en"))
        #expect(WristView.syncedCaption(composedAt: nil, now: .now, strings: english) == "Not yet synced")
    }
```

Find:

```swift
    func beforeTheFirstSyncTheAttributionNamesTheDefaultGoal() {
        let text = WristView.attribution(mirror: nil, now: Date(timeIntervalSince1970: 1_000))
        #expect(text == "Not yet synced · default goal")
    }
```

Replace with:

```swift
    func beforeTheFirstSyncTheAttributionNamesTheDefaultGoal() throws {
        let english = try #require(shipped("en"))
        let text = WristView.attribution(mirror: nil, now: Date(timeIntervalSince1970: 1_000), strings: english)
        #expect(text == "Not yet synced · default goal")
    }
```

Find:

```swift
    func aMirrorWithNoGoalSetAsksForSetupOnTheePhone() {
        let text = WristView.attribution(mirror: Self.mirror(isGoalSet: false), now: Date(timeIntervalSince1970: 1_030))
        #expect(text == "Set your goal in WaterBuddy on iPhone")
    }
```

Replace with:

```swift
    func aMirrorWithNoGoalSetAsksForSetupOnTheePhone() throws {
        let english = try #require(shipped("en"))
        let text = WristView.attribution(mirror: Self.mirror(isGoalSet: false), now: Date(timeIntervalSince1970: 1_030), strings: english)
        #expect(text == "Set your goal in WaterBuddy on iPhone")
    }
```

Find:

```swift
    @Test
    func aFullySyncedMirrorFallsBackToTheSyncedCaption() {
        let text = WristView.attribution(mirror: Self.mirror(isGoalSet: true), now: Date(timeIntervalSince1970: 1_000 + 245))
        #expect(text == "Synced 4m ago")
    }
```

Replace with the same test taking the bundle, followed by the three new tests:

```swift
    @Test
    func aFullySyncedMirrorFallsBackToTheSyncedCaption() throws {
        let english = try #require(shipped("en"))
        let text = WristView.attribution(mirror: Self.mirror(isGoalSet: true), now: Date(timeIntervalSince1970: 1_000 + 245), strings: english)
        #expect(text == "Synced 4m ago")
    }

    /// Every caption state in the owner-approved Russian, word for word
    /// (`docs/superpowers/specs/2026-10-06-watch-localization-design.md` §4.4).
    @Test
    func everyCaptionReadsInRussian() throws {
        let russian = try #require(shipped("ru"))
        let start = Date(timeIntervalSince1970: 1_000)
        let neverSynced = WristView.attribution(mirror: nil, now: start, strings: russian)
        let noGoal = WristView.attribution(mirror: Self.mirror(isGoalSet: false), now: start, strings: russian)
        let noDate = WristView.syncedCaption(composedAt: nil, now: start, strings: russian)
        let justNow = WristView.syncedCaption(composedAt: start, now: start.addingTimeInterval(30), strings: russian)
        let minutes = WristView.syncedCaption(composedAt: start, now: start.addingTimeInterval(245), strings: russian)

        #expect(neverSynced == "Нет синхронизации · цель по умолчанию")
        #expect(noGoal == "Задайте цель в WaterBuddy на iPhone")
        #expect(noDate == "Нет синхронизации")
        #expect(justNow == "Синхронизировано только что")
        #expect(minutes == "Синхронизировано 4 мин назад")
    }

    /// The same states in Uzbek. The apostrophes are `’` and `‘`, the ones the phone's catalogue
    /// already uses.
    @Test
    func everyCaptionReadsInUzbek() throws {
        let uzbek = try #require(shipped("uz"))
        let start = Date(timeIntervalSince1970: 1_000)
        let neverSynced = WristView.attribution(mirror: nil, now: start, strings: uzbek)
        let noGoal = WristView.attribution(mirror: Self.mirror(isGoalSet: false), now: start, strings: uzbek)
        let noDate = WristView.syncedCaption(composedAt: nil, now: start, strings: uzbek)
        let justNow = WristView.syncedCaption(composedAt: start, now: start.addingTimeInterval(30), strings: uzbek)
        let minutes = WristView.syncedCaption(composedAt: start, now: start.addingTimeInterval(245), strings: uzbek)

        #expect(neverSynced == "Hali sinxronlanmagan · standart maqsad")
        #expect(noGoal == "Maqsadni iPhone’dagi WaterBuddy’da belgilang")
        #expect(noDate == "Hali sinxronlanmagan")
        #expect(justNow == "Hozirgina sinxronlandi")
        #expect(minutes == "4 daqiqa oldin sinxronlandi")
    }

    /// Review focus: a phone whose clock runs ahead of the watch's stamps `composedAt` in the
    /// watch's future. That reads "just now" in every language — never "Synced -3m ago".
    @Test(arguments: ["en", "ru", "uz"])
    func aMirrorFromThePhonesFutureReadsAsJustNow(language: String) throws {
        let strings = try #require(shipped(language))
        let expected = ["en": "Synced just now", "ru": "Синхронизировано только что", "uz": "Hozirgina sinxronlandi"]
        let watchNow = Date(timeIntervalSince1970: 1_000)
        let text = WristView.syncedCaption(composedAt: watchNow.addingTimeInterval(180), now: watchNow, strings: strings)
        #expect(text == expected[language])
    }
```

- [ ] **Step 3: Run the suite and confirm RED**

```bash
xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' \
  -only-testing:WaterBuddyWatchTests/WristViewLogicTests -parallel-testing-enabled NO \
  -collect-test-diagnostics never 2>&1 | grep -E "error:|✔|✘|Test run with|Executed|\*\* TEST|\*\* BUILD"
```

Expected: `error: extra argument 'strings' in call` at the updated call sites, then
`** TEST FAILED **`.

- [ ] **Step 4: Implement**

In `WaterBuddyWatch/WristView.swift`, make five replacements.

(a) Find:

```swift
    @State private var model = WristModel.shared
    @State private var now = Date()
    @State private var isMenuPresented = false
```

Replace with:

```swift
    @State private var model = WristModel.shared
    @State private var now = Date()
    @State private var isMenuPresented = false

    @Environment(\.strings) private var strings
```

(b) Find:

```swift
    /// The number is never presented as more certain than it is: ``WristModel/displayGoal`` names
    /// the goal actually in use, and ``attribution(mirror:now:)`` — always on screen, outside every
    /// branch, as spec §8 requires — says whether it came from the phone or is still the default.
```

Replace with:

```swift
    /// The number is never presented as more certain than it is: ``WristModel/displayGoal`` names
    /// the goal actually in use, and ``attribution(mirror:now:strings:)`` — always on screen,
    /// outside every branch, as spec §8 requires — says whether it came from the phone or is still
    /// the default.
```

(c) Find:

```swift
    /// Named `attributionLine`, not `attribution`: a private computed property of that name shadows
    /// the `static func attribution(mirror:now:)` it is trying to call, and `Self.attribution(…)`
    /// then fails to resolve. Caught at compile time here, but the same collision with a
    /// *different* return type would have compiled and drawn the wrong thing.
    private var attributionLine: some View {
        Text(Self.attribution(mirror: model.mirror, now: now))
```

Replace with:

```swift
    /// Named `attributionLine`, not `attribution`: a private computed property of that name shadows
    /// the `static func attribution(mirror:now:strings:)` it is trying to call, and
    /// `Self.attribution(…)` then fails to resolve. Caught at compile time here, but the same
    /// collision with a *different* return type would have compiled and drawn the wrong thing.
    private var attributionLine: some View {
        Text(Self.attribution(mirror: model.mirror, now: now, strings: strings))
```

(d) Find:

```swift
    /// - **a mirror with a goal** — ordinary attribution, delegated to ``syncedCaption(composedAt:now:)``.
    ///
    /// Kept `nonisolated static` and free of view state for the same reason its siblings are:
    /// `WristViewLogicTests` pins every branch without instantiating a `View`.
    nonisolated static func attribution(mirror: WristMirror?, now: Date) -> String {
        guard let mirror else { return "Not yet synced · default goal" }
        guard mirror.isGoalSet else { return "Set your goal in WaterBuddy on iPhone" }
        return syncedCaption(composedAt: mirror.composedAt, now: now)
    }

    /// "Synced Nm ago", rounded to whole minutes; "Synced just now" under a minute; "Not yet
    /// synced" before the first mirror ever arrives — attribution, always present, never an alert
    /// (spec §8).
    nonisolated static func syncedCaption(composedAt: Date?, now: Date) -> String {
        guard let composedAt else { return "Not yet synced" }
        let minutes = Int(now.timeIntervalSince(composedAt) / 60)
        return minutes < 1 ? "Synced just now" : "Synced \(minutes)m ago"
    }
```

Replace with:

```swift
    /// - **a mirror with a goal** — ordinary attribution, delegated to
    ///   ``syncedCaption(composedAt:now:strings:)``.
    ///
    /// Kept `nonisolated static` and free of view state for the same reason its siblings are:
    /// `WristViewLogicTests` pins every branch without instantiating a `View`.
    ///
    /// **It takes its `Bundle`, and with no default.** A function taking a bundle rather than a
    /// stored string is what lets a language switch reach it (`tasks/lessons.md`, 2026-08-29), and a
    /// defaulted parameter would quietly mean `Bundle.main` — the device's language, not the one the
    /// phone chose. Rule `80-notifications` holds `reconcile`'s `strings:` to the same.
    nonisolated static func attribution(mirror: WristMirror?, now: Date, strings: Bundle) -> String {
        guard let mirror else {
            return strings.localizedString(forKey: "Not yet synced · default goal", value: nil, table: nil)
        }
        guard mirror.isGoalSet else {
            return strings.localizedString(forKey: "Set your goal in WaterBuddy on iPhone", value: nil, table: nil)
        }
        return syncedCaption(composedAt: mirror.composedAt, now: now, strings: strings)
    }

    /// "Synced Nm ago", rounded to whole minutes; "Synced just now" under a minute — and for a
    /// `composedAt` in the watch's future, which a phone clock running ahead produces; "Not yet
    /// synced" without a date — attribution, always present, never an alert (spec §8).
    ///
    /// The `nil` branch is unreachable from production today: `WristMirror.composedAt` is
    /// non-optional, and `attribution(mirror:now:strings:)` answers a missing mirror before it gets
    /// here. Kept, and translated, because the parameter is optional
    /// (`docs/superpowers/specs/2026-10-06-watch-localization-design.md` §8.3).
    ///
    /// Russian writes the minutes as `мин`, which needs no plural form, and Uzbek takes none after a
    /// numeral — so one `%1$d` key serves every count.
    nonisolated static func syncedCaption(composedAt: Date?, now: Date, strings: Bundle) -> String {
        guard let composedAt else {
            return strings.localizedString(forKey: "Not yet synced", value: nil, table: nil)
        }
        let minutes = Int(now.timeIntervalSince(composedAt) / 60)
        guard minutes >= 1 else {
            return strings.localizedString(forKey: "Synced just now", value: nil, table: nil)
        }
        return String(format: strings.localizedString(forKey: "Synced %1$dm ago", value: nil, table: nil), minutes)
    }
```

(e) In `WaterBuddyWatch/WristModel.swift`, find:

```swift
    /// *stored* here. `WristView.attribution(mirror:now:)` names which of the two is on screen, so
    /// the number is attributed rather than asserted (spec §5's "withheld and attributed, never a
    /// confident zero", read across to the never-synced case).
```

Replace with:

```swift
    /// *stored* here. `WristView.attribution(mirror:now:strings:)` names which of the two is on
    /// screen, so the number is attributed rather than asserted (spec §5's "withheld and
    /// attributed, never a confident zero", read across to the never-synced case).
```

- [ ] **Step 5: Run the suite and confirm GREEN**

Run the Step 3 command again.
Expected: `✔ Test run with 17 tests in 1 suite passed` (13 existing plus 4 new).

- [ ] **Step 6: Stage**

```bash
git add WaterBuddyWatch/WristView.swift WaterBuddyWatch/WristModel.swift \
  WaterBuddyWatchTests/WristViewLogicTests.swift
```

---

### Task 4: Serving names, the readout and the sheet

**Files:**
- Modify: `WaterBuddyWatch/WristView.swift` (`WristServing.name(in:)`; `WristServingMenu`)
- Modify: `WaterBuddyWatch/WristVessel.swift` (environment, percentage, readout)
- Test: `WaterBuddyWatchTests/WristViewLogicTests.swift`

**Interfaces:**
- **Consumes:** `shipped(_:)` (Task 3), the watch catalogue (Task 2), and `AppLanguage.english`,
  `.russian` and `.uzbek`'s `.locale`.
- **Produces:**
  - `func name(in bundle: Bundle) -> String` on the `nonisolated struct WristServing`
  - `nonisolated static func readout(volume: Int, goal: Int, strings: Bundle, locale: Locale) -> String`
    on `WristVessel`

- [ ] **Step 1: Write the failing tests**

In `WaterBuddyWatchTests/WristViewLogicTests.swift`, find the suite's last test and closing brace:

```swift
    @Test
    func aMirrorWithNoServingsOffersAnEmptyMenuRatherThanInventedAmounts() {
        let mirror = Self.mirror(isGoalSet: true, servings: [])
        #expect(WristView.secondary(from: mirror).isEmpty)
        #expect(WristView.primary(from: mirror).amount == DataManager.defaultServing)
    }
}
```

Replace with:

```swift
    @Test
    func aMirrorWithNoServingsOffersAnEmptyMenuRatherThanInventedAmounts() {
        let mirror = Self.mirror(isGoalSet: true, servings: [])
        #expect(WristView.secondary(from: mirror).isEmpty)
        #expect(WristView.primary(from: mirror).amount == DataManager.defaultServing)
    }

    // MARK: - Names and the readout, in the chosen language (spec 2026-10-06 §4.3)

    /// All three slots, in order, so a name that slid onto the wrong vessel fails too. The names
    /// are the phone's own (`Cup`, `Glass`, `Bottle`), copied value for value.
    @Test
    func theServingNamesAreTranslated() throws {
        let english = try #require(shipped("en"))
        let russian = try #require(shipped("ru"))
        let uzbek = try #require(shipped("uz"))
        let slots = WristView.servings(from: nil)

        let inEnglish = slots.map { $0.name(in: english) }
        let inRussian = slots.map { $0.name(in: russian) }
        let inUzbek = slots.map { $0.name(in: uzbek) }

        #expect(inEnglish == ["Cup", "Glass", "Bottle"])
        #expect(inRussian == ["Чашка", "Стакан", "Бутылка"])
        #expect(inUzbek == ["Chashka", "Stakan", "Shisha"])
    }

    /// Review focus: the empty state and five-digit figures as well as the everyday four. English is
    /// pinned exactly. Russian and Uzbek group with a no-break space whose exact code point has
    /// changed between OS releases (U+00A0 on this toolchain, U+202F in some), so it is matched as
    /// "a non-digit splits the figure" rather than spelled.
    @Test
    func theVesselReadoutGroupsThousandsInTheChosenLanguage() throws {
        let english = try #require(shipped("en"))
        let russian = try #require(shipped("ru"))
        let uzbek = try #require(shipped("uz"))
        let en = AppLanguage.english.locale

        let everyday = WristVessel.readout(volume: 1_250, goal: 2_000, strings: english, locale: en)
        let empty = WristVessel.readout(volume: 0, goal: 2_000, strings: english, locale: en)
        let large = WristVessel.readout(volume: 12_500, goal: 10_000, strings: english, locale: en)
        #expect(everyday == "1,250 / 2,000 ml")
        #expect(empty == "0 / 2,000 ml")
        #expect(large == "12,500 / 10,000 ml")

        let others: [(Bundle, Locale, String)] = [
            (russian, AppLanguage.russian.locale, "мл"),
            (uzbek, AppLanguage.uzbek.locale, "ml"),
        ]
        for (strings, locale, unit) in others {
            let text = WristVessel.readout(volume: 1_250, goal: 2_000, strings: strings, locale: locale)
            let digits = text.filter(\.isNumber)
            #expect(text.hasSuffix(" \(unit)"), "\(text) does not end in its own unit")
            #expect(digits == "12502000", "\(text) lost or gained a digit")
            #expect(!text.contains("1250") && !text.contains("2000"), "\(text) is not grouped")
            #expect(!text.contains(","), "\(text) groups with the English separator")
        }
    }
}
```

- [ ] **Step 2: Run the suite and confirm RED**

Run the command from Task 3, Step 3.
Expected: `error: value of type 'WristServing' has no member 'name'` and
`error: type 'WristVessel' has no member 'readout'`, then `** TEST FAILED **`.

- [ ] **Step 3: Implement the two functions**

In `WaterBuddyWatch/WristView.swift`, find:

```swift
    /// The slot's name, not the amount. Two vessels holding the same figure is a state the user is
    /// allowed to choose (rule `20-state`), so keying a `ForEach` on the amount would collapse two
    /// legitimate rows into one.
    var id: String { nameKey }
}
```

Replace with:

```swift
    /// The slot's name, not the amount. Two vessels holding the same figure is a state the user is
    /// allowed to choose (rule `20-state`), so keying a `ForEach` on the amount would collapse two
    /// legitimate rows into one.
    var id: String { nameKey }

    /// The slot's name in the language being drawn — `HomeView.Serving.name(in:)`'s twin, down to
    /// the `value:` fallback. A function taking a bundle rather than a stored string, so a language
    /// switch reaches it (`tasks/lessons.md`, 2026-08-29).
    func name(in bundle: Bundle) -> String {
        bundle.localizedString(forKey: nameKey, value: nameKey, table: nil)
    }
}
```

In `WaterBuddyWatch/WristVessel.swift`, find:

```swift
    nonisolated static func diameter(fitting availableWidth: CGFloat, within availableHeight: CGFloat) -> CGFloat {
        max(60, min(availableWidth, availableHeight))
    }
}
```

Replace with:

```swift
    nonisolated static func diameter(fitting availableWidth: CGFloat, within availableHeight: CGFloat) -> CGFloat {
        max(60, min(availableWidth, availableHeight))
    }

    /// `1 250 / 2 000 мл` — both figures grouped the way the language being drawn groups them.
    ///
    /// **Deliberately not the phone's `%1$d / %2$d ml`.** `%d` never groups, which is why the phone
    /// draws `1300 / 2000 ml` in every language (spec 2026-10-06 §8.1). The watch grouped this
    /// readout before it was ever localized, and the owner chose to keep that (§3, ruling 3): the
    /// figures are formatted first, against the locale `WristRoot` injects beside the bundle, and
    /// handed to a `%1$@ / %2$@ ml` key only the watch holds.
    ///
    /// `nonisolated static` and free of view state, so `WristViewLogicTests` can pin it.
    nonisolated static func readout(volume: Int, goal: Int, strings: Bundle, locale: Locale) -> String {
        String(
            format: strings.localizedString(forKey: "%1$@ / %2$@ ml", value: nil, table: nil),
            volume.formatted(.number.locale(locale)),
            goal.formatted(.number.locale(locale))
        )
    }
}
```

- [ ] **Step 4: Draw them**

In `WaterBuddyWatch/WristVessel.swift`, find:

```swift
    let goal: Int
    let diameter: CGFloat

    var body: some View {
```

Replace with:

```swift
    let goal: Int
    let diameter: CGFloat

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    var body: some View {
```

Find:

```swift
                    Text("\(percentage)")
                        .font(.system(size: diameter * 0.28, weight: .bold, design: .rounded))
```

Replace with:

```swift
                    // `HomeView`'s own spelling: formatted against the injected locale, and not a
                    // `%lld` key the build would extract for nobody to translate.
                    Text(percentage, format: .number)
                        .font(.system(size: diameter * 0.28, weight: .bold, design: .rounded))
```

Find:

```swift
                Text("\(volume) / \(goal) ml")
```

Replace with:

```swift
                Text(Self.readout(volume: volume, goal: goal, strings: strings, locale: locale))
```

In `WaterBuddyWatch/WristView.swift`, find:

```swift
    @Environment(\.dismiss) private var dismiss
```

Replace with:

```swift
    @Environment(\.dismiss) private var dismiss
    @Environment(\.strings) private var strings
```

Find:

```swift
                        HStack(spacing: 8) {
                            // `Text(verbatim:)` rather than an interpolated `LocalizedStringKey`:
                            // the watch draws hard-coded English throughout (`docs/AI_CONTEXT.md`'s
                            // known issue #18), and manufacturing a key like "%lld ml" that no
                            // catalogue contains would add a false localization surface to a target
                            // that has none. Verbatim states the debt instead of disguising it.
                            Label {
                                Text(verbatim: serving.nameKey)
                            } icon: {
                                Image(systemName: serving.symbol)
                            }
                            Spacer(minLength: 8)
                            Text(verbatim: "\(serving.amount) ml")
                                .foregroundStyle(.secondary)
                        }
```

Replace with:

```swift
                        HStack(spacing: 8) {
                            // The phone's own two calls — `HomeView.Serving.name(in:)` and the
                            // `%1$d ml` caption under each quick-add vessel — so a serving reads the
                            // same on both devices and `LocalizationTests` can hold the two
                            // catalogues to it.
                            Label {
                                Text(serving.name(in: strings))
                            } icon: {
                                Image(systemName: serving.symbol)
                            }
                            Spacer(minLength: 8)
                            Text(String(format: strings.localizedString(forKey: "%1$d ml", value: nil, table: nil), serving.amount))
                                .foregroundStyle(.secondary)
                        }
```

- [ ] **Step 5: Run the suite and confirm GREEN**

Run the command from Task 3, Step 3.
Expected: `✔ Test run with 19 tests in 1 suite passed`.

If the Russian or Uzbek grouping assertion fails, **stop**. A runtime that doesn't group four-digit
figures in that language is a fact for the owner, and ruling 3 may need revisiting. Do not change
the assertion.

- [ ] **Step 6: Stage**

```bash
git add WaterBuddyWatch/WristView.swift WaterBuddyWatch/WristVessel.swift \
  WaterBuddyWatchTests/WristViewLogicTests.swift
```

---

### Task 5: The root, and the strings only the screen can show

**Files:**
- Modify: `WaterBuddyWatch/WaterBuddyWatchApp.swift`
- Modify: `WaterBuddyWatch/WristView.swift` (the vessel's VoiceOver; the "More" button)

**Interfaces:**
- **Consumes:** `WristModel.language` (Task 1); the catalogue keys (Task 2).
- **Produces:** `private struct WristRoot: View`. Nothing outside this file names it.

No unit test can observe this task. Environment injection and VoiceOver modifiers are facts about
the view tree. The tool that could see them is a watch UI-test target — XCUITest *is* in the
watchOS SDK (`XCUIAutomation.framework`), contrary to what known issue #32 said when this plan was
written — but none exists, and adding one needs a `project.pbxproj` edit this plan rules out. Three
things cover it:
- the whole watch suite stays green
- the check in Step 4 that every key the code asks for exists
- Task 7's screens

- [ ] **Step 1: Inject the language at a root view**

In `WaterBuddyWatch/WaterBuddyWatchApp.swift`, find:

```swift
        WindowGroup {
            WristView()
        }
```

Replace with:

```swift
        WindowGroup {
            WristRoot()
        }
```

At the end of the same file, after the closing brace of `struct WaterBuddyWatchApp`, append:

```swift

// MARK: - Root

/// Injects the language the watch draws in, once, above everything it draws
/// (`docs/superpowers/specs/2026-10-06-watch-localization-design.md` §4.2).
///
/// A `View` rather than two modifiers on `WristView()` inside `body` above, for the reason the
/// phone's own `RootView` gives: Observation tracks reads made while a *view* body evaluates, and an
/// `App` body is not a reliable scope for it — so a mirror that changes the language would redraw
/// nothing.
///
/// **Both values, together** (rule `70-privacy`). The bundle switches the words; the locale switches
/// how the figures are grouped. One without the other draws `2,000` inside a Russian sentence.
private struct WristRoot: View {
    @State private var model = WristModel.shared

    var body: some View {
        WristView()
            .environment(\.strings, model.language.bundle)
            .environment(\.locale, model.language.locale)
    }
}
```

- [ ] **Step 2: The vessel's VoiceOver**

In `WaterBuddyWatch/WristView.swift`, find:

```swift
            .accessibilityLabel(Text("Today's hydration"))
            .accessibilityValue(Text("\(percentage) percent, \(model.todaysTotal) of \(model.displayGoal) millilitres"))
            .accessibilityHint(Text("Logs \(serving.amount) millilitres"))
```

Replace with:

```swift
            .accessibilityLabel(Text("Today's hydration", bundle: strings))
            // The phone vessel's own sentence, so VoiceOver reads the same figures the same way on
            // both devices (spec 2026-10-06 §3, ruling 5).
            .accessibilityValue(String(format: strings.localizedString(forKey: "%1$d percent. %2$d of %3$d millilitres.", value: nil, table: nil), percentage, model.todaysTotal, model.displayGoal))
            .accessibilityHint(String(format: strings.localizedString(forKey: "Logs %1$d millilitres", value: nil, table: nil), serving.amount))
```

- [ ] **Step 3: The "More" button, one string**

Find:

```swift
                Label {
                    Text(verbatim: "More")
                } icon: {
```

Replace with:

```swift
                Label {
                    Text("More", bundle: strings)
                } icon: {
```

Find:

```swift
            .buttonStyle(.plain)
            .accessibilityLabel(Text("More servings"))
            .accessibilityHint(Text("Shows the other serving sizes"))
```

Replace with:

```swift
            .buttonStyle(.plain)
            // No `.accessibilityLabel`: VoiceOver reads the visible "More", then the hint. A
            // control's visible text and its VoiceOver label are one string (rule `65-accessibility`).
            .accessibilityHint(Text("Shows the other serving sizes", bundle: strings))
```

- [ ] **Step 4: Check that every key the code asks for exists**

Read-only, from the repository root:

```bash
python3 - <<'EOF'
import json, pathlib, re
src = "\n".join(p.read_text(encoding="utf-8") for p in sorted(pathlib.Path("WaterBuddyWatch").glob("*.swift")))
used = set(re.findall(r'forKey: "([^"]*)"', src)) | set(re.findall(r'Text\("([^"]*)", bundle: strings\)', src))
keys = set(json.loads(pathlib.Path("WaterBuddyWatch/Localizable.xcstrings").read_text(encoding="utf-8"))["strings"])
print("asked for:", len(used), "| missing from the catalogue:", sorted(used - keys))
EOF
```

Expected: `asked for: 12 | missing from the catalogue: []`. That's nine `forKey:` literals and three
`Text(…, bundle: strings)` literals. A typo in a literal would otherwise draw the raw English key in
every language, and no test would see it.

- [ ] **Step 5: Run the whole watch suite**

```bash
xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' \
  -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO \
  -collect-test-diagnostics never 2>&1 | grep -E "error:|✔|✘|Test run with|Executed|\*\* TEST|\*\* BUILD"
```

Expected: `✔ Test run with 42 tests in 5 suites passed`.

- [ ] **Step 6: Stage**

```bash
git add WaterBuddyWatch/WaterBuddyWatchApp.swift WaterBuddyWatch/WristView.swift
```

---

### Task 6: Tidy the catalogues, then the full gate

**Files:**
- Modify: `WaterBuddyWatch/Localizable.xcstrings` and `WaterBuddyWatchWidget/Localizable.xcstrings`
  (remove only the keys the build marked stale)

- [ ] **Step 1: Remove the extracted keys that went stale, and inspect what nobody wrote**

```bash
python3 - <<'EOF'
import json, pathlib
for path in ["WaterBuddyWatch/Localizable.xcstrings", "WaterBuddyWatchWidget/Localizable.xcstrings"]:
    p = pathlib.Path(path)
    doc = json.loads(p.read_text(encoding="utf-8"))
    stale = sorted(k for k, e in doc["strings"].items() if e.get("extractionState") == "stale")
    for k in stale:
        del doc["strings"][k]
    if stale:
        p.write_text(json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    unauthored = {k: sorted(e.get("localizations", {})) for k, e in doc["strings"].items()
                  if e.get("extractionState") != "manual"}
    print(path, "\n  removed (stale):", stale, "\n  not authored:", unauthored)
EOF
```

Expected:
- **removed (stale):** the leftovers from the code Tasks 3–5 replaced, if the build extracted any
  (for example `More servings`, `Logs %lld millilitres`, `%lld / %lld ml`,
  `%lld percent, %lld of %lld millilitres`, `Today's hydration.`). An empty list is also fine.
- **not authored:** `%` → `['en']` in the watch app, and `WaterBuddy` → `['en']` in the widget.
  Anything else must carry no localizations at all (`[]`): a `#Preview` literal from the shared
  files, or the complication's `%lld`.
- **Stop condition:** a key that nobody authored but that carries `ru` or `uz` means something has
  gone wrong. Stop and look before going on.

- [ ] **Step 2: Re-run the key check from Task 5, Step 4**

Expected: `asked for: 12 | missing from the catalogue: []`.

- [ ] **Step 3: The full gate, one invocation per command, in the foreground**

These are rule `85-testing`'s commands, verbatim:

```bash
xcrun simctl shutdown all

xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests -parallel-testing-enabled NO
```

Expected: `✔ Test run with 316 tests in 33 suites passed`.

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyUITests -parallel-testing-enabled NO \
  -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests
```

Expected: `Executed 25 tests, with 0 failures`.

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' \
  -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO
```

Expected: `✔ Test run with 42 tests in 5 suites passed`.

```bash
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17'
```

Expected: `** BUILD SUCCEEDED **`.

```bash
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)'
```

Expected: `** BUILD SUCCEEDED **`, with only the two known `actool` warnings.

- [ ] **Step 4: Compare warnings against the code before this change**

Clean builds into empty DerivedData folders, compared per file and message, as the baseline was
measured. `git archive HEAD` exports the committed code without touching `.git` or the working
tree. Run each build as its own foreground command.

```bash
SCRATCH=/private/tmp/claude-501/-Users-sardorallaberganov-Desktop-Projects-MobileApps-WaterBuddy/6f1e0dcf-dd67-4357-aa6f-b46288159a77/scratchpad
rm -rf "$SCRATCH/wb-head" "$SCRATCH/dd-head" && mkdir -p "$SCRATCH/wb-head"
git archive HEAD | tar -x -C "$SCRATCH/wb-head"
xcodebuild build -project "$SCRATCH/wb-head/WaterBuddy.xcodeproj" -scheme WaterBuddy \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath "$SCRATCH/dd-head" \
  > "$SCRATCH/build-head.log" 2>&1; tail -1 "$SCRATCH/build-head.log"
```

```bash
SCRATCH=/private/tmp/claude-501/-Users-sardorallaberganov-Desktop-Projects-MobileApps-WaterBuddy/6f1e0dcf-dd67-4357-aa6f-b46288159a77/scratchpad
rm -rf "$SCRATCH/dd-tree"
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath "$SCRATCH/dd-tree" \
  > "$SCRATCH/build-tree.log" 2>&1; tail -1 "$SCRATCH/build-tree.log"
```

```bash
SCRATCH=/private/tmp/claude-501/-Users-sardorallaberganov-Desktop-Projects-MobileApps-WaterBuddy/6f1e0dcf-dd67-4357-aa6f-b46288159a77/scratchpad
for side in head tree; do
  grep -E ': warning: ' "$SCRATCH/build-$side.log" \
    | sed -E 's#^.*/((WaterBuddy[A-Za-z]*)/[^:]+):[0-9]+:[0-9]+: warning: #\1: warning: #' \
    | sort -u > "$SCRATCH/warnings-$side.txt"
done
wc -l "$SCRATCH/warnings-head.txt" "$SCRATCH/warnings-tree.txt"
echo "--- new in the tree:"; comm -13 "$SCRATCH/warnings-head.txt" "$SCRATCH/warnings-tree.txt"
echo "--- gone in the tree:"; comm -23 "$SCRATCH/warnings-head.txt" "$SCRATCH/warnings-tree.txt"
```

Expected:
- Both builds end `** BUILD SUCCEEDED **`.
- **"new in the tree" is empty.** Any line there is a new warning and fails the task.
- "gone in the tree" may list lines this change removed.
- The two counts are line-number-free, so they can read lower than the 31 recorded with line
  numbers.

- [ ] **Step 5: The project file is untouched**

```bash
git diff --exit-code --stat -- WaterBuddy.xcodeproj/project.pbxproj && echo "project.pbxproj untouched"
git status --short
```

Expected: `project.pbxproj untouched`. `git status` shows only the files this plan names, plus the
pre-existing untracked `Screenshots/census/`.

- [ ] **Step 6: Review the diff against the rules**

```bash
git diff --cached -- WaterBuddyWatch WaterBuddyWatchWidget WaterBuddyWatchTests WaterBuddyTests
grep -n 'Text("' WaterBuddyWatch/*.swift | grep -v 'bundle: strings'
grep -nE 'Text\(verbatim:|More servings' WaterBuddyWatch/*.swift
grep -n 'print(' WaterBuddyWatch/*.swift WaterBuddyWatchWidget/*.swift
```

Expected:
- The first `grep` prints only `WristVessel.swift`'s `Text("%")`. That's a symbol, drawn exactly as
  `HomeView` draws its own.
- The second prints nothing.
- The third prints only `WristModel.swift`'s two existing `#if DEBUG` prints.

Then read the diff against these rules:
- `43-concurrency`: every new static is `nonisolated`, and there's no `MainActor.assumeIsolated`.
- `50-views` and `70-privacy`: no `Bundle.main` for copy, no string in a `static let`, and
  `\.strings` and `\.locale` injected together.
- `65-accessibility`: one string per control, and VoiceOver goes through `strings`.
- `20-state`: `WristModel.language` writes nothing.
- `85-testing`: no assertion was narrowed. The six caption tests still expect their original
  English.

- [ ] **Step 7: Stage the catalogues as they stand after the last build**

```bash
git add WaterBuddyWatch/Localizable.xcstrings WaterBuddyWatchWidget/Localizable.xcstrings
```

---

### Task 7: On screen

No test sees a rendered screen (rule `85-testing`). These steps install the builds that Task 6's
gate left in the default DerivedData.

- [ ] **Step 1: Find the builds and the devices**

```bash
DD=$(ls -d ~/Library/Developer/Xcode/DerivedData/WaterBuddy-* | head -1)
ls -d "$DD/Build/Products/Debug-watchsimulator/WaterBuddyWatch.app" "$DD/Build/Products/Debug-iphonesimulator/WaterBuddy.app"
xcrun simctl list devices available | sed -n '/-- watchOS 26.5 --/,/-- /p'
xcrun simctl list devices available | sed -n '/-- iOS 26.5 --/,/-- /p' | grep 'iPhone 17 ('
xcrun simctl list pairs | grep -B1 -A2 'Series 11 (46mm)'
```

Note the UDIDs. On 2026-10-06 they were:
- Apple Watch Series 11 (46mm): `93ADDD75-0D1D-41F4-90CD-C771AC505EEF`
- Apple Watch SE 3 (40mm), watchOS 26.5: `6F087A7B-23B1-41C0-8BDF-3A48F2F14D0F`
- iPhone 17, iOS 26.5: `EE56B958-E33F-40A3-99EA-B14D45963685`, paired with the Series 11 as
  `75392FDC-66C9-4C69-9FB8-C9442AE02DFF`

- [ ] **Step 2: The device-language path in Russian and Uzbek, at 40mm and 46mm**

For each watch UDID (`W`) and each pair `ru ru_RU`, then `uz uz_UZ`:

```bash
SCRATCH=/private/tmp/claude-501/-Users-sardorallaberganov-Desktop-Projects-MobileApps-WaterBuddy/6f1e0dcf-dd67-4357-aa6f-b46288159a77/scratchpad
DD=$(ls -d ~/Library/Developer/Xcode/DerivedData/WaterBuddy-* | head -1)
W=6F087A7B-23B1-41C0-8BDF-3A48F2F14D0F   # then 93ADDD75-0D1D-41F4-90CD-C771AC505EEF
LANG_CODE=ru; LOCALE_ID=ru_RU            # then uz / uz_UZ
xcrun simctl shutdown all
xcrun simctl boot "$W"
xcrun simctl install "$W" "$DD/Build/Products/Debug-watchsimulator/WaterBuddyWatch.app"
xcrun simctl terminate "$W" sardor.WaterBuddy.watchkitapp 2>/dev/null
xcrun simctl launch "$W" sardor.WaterBuddy.watchkitapp -AppleLanguages "($LANG_CODE)" -AppleLocale "$LOCALE_ID"
xcrun simctl io "$W" screenshot --mask=ignored "$SCRATCH/onscreen-$W-$LANG_CODE.png"
```

- Open each PNG with the Read tool. If it still shows the launch screen, take the screenshot again.
- `-AppleLanguages` and `-AppleLocale` are argument-domain overrides: they persist nothing and write
  no suite.
- **Pass when all of these hold:**
  - the caption is in Russian (or Uzbek)
  - nothing is cut off with "…"
  - the readout shows grouping, for example `0 / 2 000 мл` in the empty state
  - on a watch with a mirror, the caption reads "Синхронизировано …" or "… sinxronlandi"
- The caption may wrap; the 40mm already scrolls.
- **One exception:** if a watch holds a stored mirror whose `languageCode` isn't `nil`, the launch
  arguments are ignored by design (ruling 1). Record that rather than treating it as a failure.

- [ ] **Step 3: The live switch and the "More" sheet — these need the owner's taps**

Two simulators run together here, the paired phone and watch. No `xcodebuild test` runs alongside.

```bash
DD=$(ls -d ~/Library/Developer/Xcode/DerivedData/WaterBuddy-* | head -1)
PHONE=EE56B958-E33F-40A3-99EA-B14D45963685; WATCH=93ADDD75-0D1D-41F4-90CD-C771AC505EEF
xcrun simctl shutdown all
xcrun simctl boot "$PHONE"; xcrun simctl boot "$WATCH"
xcrun simctl install "$PHONE" "$DD/Build/Products/Debug-iphonesimulator/WaterBuddy.app"      # the phone app first
xcrun simctl install "$WATCH" "$DD/Build/Products/Debug-watchsimulator/WaterBuddyWatch.app"  # then the watch app
xcrun simctl launch "$PHONE" sardor.WaterBuddy
xcrun simctl launch "$WATCH" sardor.WaterBuddy.watchkitapp
```

The install order comes from `tasks/lessons.md`, 2026-10-05. Then ask the owner to do these in
DeviceHub, taking a watch screenshot after each, as in Step 2:

1. On the iPhone 17, open WaterBuddy → Settings → Language → **Русский**. Expect the watch to
   redraw in Russian without a relaunch.
2. On the watch, tap **Ещё**. Expect the sheet to read `Чашка` / `150 мл` and `Бутылка` / `500 мл`
   (or whatever the phone's own servings are).
3. On the iPhone, set Language back to **Follow device**. Expect the watch to return to its own
   language.

If the owner chooses to skip this step, record that it was skipped. `WristModelTests` pins the
switch logic either way.

- [ ] **Step 4: The complication's description, if the owner wants it checked**

In the watch-face editor, add the WaterBuddy complication with the watch set to Russian and read
its description. This is the owner's call, as it was for spec §17's complication check. Record
either way.

- [ ] **Step 5: Leave the simulators as they were**

```bash
xcrun simctl shutdown all
```

The phone app's language choice is back on *Follow device* if Step 3 ran.

---

### Task 8: The rule amendments (spec §7, owner-authorised by approving the spec)

**Files:** `.claude/rules/70-privacy.md`, `.claude/rules/15-project.md`,
`.claude/rules/50-views.md`, `.claude/rules/65-accessibility.md`.

If any edit here is refused by a permission rule, **stop and report it** (`CLAUDE.md`'s hard
limits). Never route around a refusal.

- [ ] **Step 1: `70-privacy.md`. Delete the "Known gap" paragraph**

Find:

```markdown
**Known gap, tracked, not fixed here:** this glob widened to `WaterBuddyWatch/**/*.swift`, and every
string `WristView` draws is currently a hard-coded English literal — none of them route through
`\.strings`, unlike every rule below. `docs/AI_CONTEXT.md`'s known issue #18 records it. Out of scope
for this pass; this note exists so the rule does not silently claim compliance the watch does not
have.

- Route every user-facing string through `@Environment(\.strings)` and
```

Replace with:

```markdown
- Route every user-facing string through `@Environment(\.strings)` and
```

- [ ] **Step 2: `70-privacy.md`. The watch's language source**

Find:

```markdown
- The widget takes its language from `entry.snapshot.language`, never `Bundle.main` or the device
  locale
```

Replace with:

```markdown
- The widget takes its language from `entry.snapshot.language`, never `Bundle.main` or the device
  locale
- The watch takes its language from `WristMirror.languageCode`, through `WristModel.language`,
  injected at `WristRoot`. `nil` — the phone set to *Follow device* — and the time before the first
  mirror both resolve the watch's own `Bundle.main`. The complication's `.description` is resolved by
  WidgetKit and follows the watch's system language
```

- [ ] **Step 3: `70-privacy.md`. Four catalogues**

Find:

```markdown
  shipping the matching translations in **both** `Localizable.xcstrings` files, and keep
```

Replace with:

```markdown
  shipping the matching translations in **all four** `Localizable.xcstrings` files, and keep
```

Find:

```markdown
- Keep the two catalogues separate — one in `WaterBuddy/`, one in `WaterBuddyWidget/`. A string
  catalogue is not shareable through a `membershipExceptions` entry
```

Replace with:

```markdown
- Keep the four catalogues separate — `WaterBuddy/`, `WaterBuddyWidget/`, `WaterBuddyWatch/` and
  `WaterBuddyWatchWidget/`. A string catalogue is not shareable through a `membershipExceptions` entry
```

- [ ] **Step 4: `70-privacy.md`. Shared keys and test paths**

Find:

```markdown
- Every key in `sharedKeys` must resolve to the identical value in both bundles, in every language.
  Add any new widget-drawn or widget-filed string to it
```

Replace with:

```markdown
- Every key in `sharedKeys` must resolve to the identical value in both bundles, in every language.
  Add any new widget-drawn or widget-filed string to it. The watch's copies of phone strings are held
  to the same standard: `LocalizationTests` compares them against the app bundle in every language
```

Find:

```markdown
- Never read a `.xcstrings` file off disk with `#filePath` in a test — assert against the built
  bundle via `Bundle.main` and `PlugIns/WaterBuddyWidgetExtension.appex`
```

Replace with:

```markdown
- Never read a `.xcstrings` file off disk with `#filePath` in a test — assert against the built
  bundle via `Bundle.main`, `PlugIns/WaterBuddyWidgetExtension.appex`, `Watch/WaterBuddyWatch.app`
  and its `PlugIns/WaterBuddyWatchWidget.appex`
```

- [ ] **Step 5: `15-project.md`**

Find:

```markdown
- Adding a language means the catalogue in **both** `WaterBuddy/` and `WaterBuddyWidget/`, plus
  `knownRegions`, plus `AppLanguage.selectable` (rule `70-privacy`)
```

Replace with:

```markdown
- Adding a language means the catalogue in **all four** of `WaterBuddy/`, `WaterBuddyWidget/`,
  `WaterBuddyWatch/` and `WaterBuddyWatchWidget/`, plus `knownRegions`, plus `AppLanguage.selectable`
  (rule `70-privacy`)
```

- [ ] **Step 6: `50-views.md`**

Find:

```markdown
- Resolve every user-visible string through `@Environment(\.strings) private var strings`, injected
  once at the root from `manager.language` together with `\.locale`. Never `Bundle.main`, and never
  resolve a string into a `static let`
```

Replace with:

```markdown
- Resolve every user-visible string through `@Environment(\.strings) private var strings`, injected
  once at the root from `manager.language` — on the watch, `WristModel.language` — together with
  `\.locale`. Never `Bundle.main`, and never resolve a string into a `static let`
```

- [ ] **Step 7: `65-accessibility.md`**

Find:

```markdown
- Every VoiceOver string resolves through the `strings` environment bundle, and the shared ones go
  into `sharedKeys` so both bundles are checked (rule `70-privacy`)
```

Replace with:

```markdown
- Every VoiceOver string resolves through the `strings` environment bundle, and the shared ones are
  listed in `LocalizationTests` so every bundle that draws them is checked (rule `70-privacy`)
```

- [ ] **Step 8: Verify, then stage**

```bash
grep -n 'Known gap\|two catalogues\|\*\*both\*\* `Localizable\|so both bundles are checked' .claude/rules/*.md
grep -c 'WristModel.language' .claude/rules/70-privacy.md .claude/rules/50-views.md
git add .claude/rules/70-privacy.md .claude/rules/15-project.md .claude/rules/50-views.md .claude/rules/65-accessibility.md
```

Expected: the first `grep` prints nothing. The second prints `1` for each file.

---

### Task 9: Checkpoint, lessons, doc sync

**Files:** `HISTORY.md` (append), `tasks/lessons.md` (append, only if something was learned), and
whatever `/doc_sync` changes under `docs/` and in `CLAUDE.md`.

- [ ] **Step 1: Append the checkpoint to the bottom of `HISTORY.md`**

`HISTORY.md` is append-only (rule `90-git`). Use these headings and fill each from this session's
actual output. Never write a number that wasn't just printed.

```markdown
## [2026-10-06] — The watch draws in the user's language: known issues #18 and #19

### What
### The rulings this rests on
### Files touched
### Verification
### Not verified
### Staged, not committed
```

- **What:**
  - the language source (`WristModel.language` from `WristMirror.languageCode`)
  - `WristRoot`
  - the two catalogues (16 keys and 2 keys)
  - the three English-copy exceptions
  - the corrected inventory: 15 strings in three files, where #18 counted 11
- **The rulings this rests on:** spec §3, rulings 1–7, citing the spec path.
- **Files touched:** every path from this plan's file map that actually changed.
- **Verification:**
  - the RED lines and GREEN lines quoted from Tasks 1–5
  - the key check output
  - the five gate result lines verbatim
  - the warning comparison: both counts, and "new in the tree: none"
  - `project.pbxproj untouched`
- **Not verified:**
  - spec §10's list
  - whether the owner's taps in Task 7, Step 3 were done or skipped
  - the complication's description, checked or skipped
- **Staged, not committed:** written last, from a fresh `git diff --cached --name-status`.

- [ ] **Step 2: Lessons, if any were learned**

Append to `tasks/lessons.md` only for a surprise that cost something. Candidates: whether
`xcodebuild` wrote extracted keys back into a catalogue, and whether the phone test host's
`Watch/` folder behaved as expected. Use the existing format: `## 2026-10-06 — <claim>`, then what
happened, then **The rule:**. Don't add an entry for its own sake.

- [ ] **Step 3: Run `/doc_sync`**

Invoke the `doc_sync` skill. Its output must include:
- **#18 and #19 closed**, with the fix on disk.
- **Spec §8.1–§8.3 recorded as new known issues:** the phone's ungrouped `String(format:)` figures;
  the single Russian plural form in the shared keys; `syncedCaption`'s dead `nil` branch.
- **The drift found while orienting:**
  - #1 is fixed on disk
  - #12 is fixed on disk
  - #25's claim that the phone widget never shows more than 100% is false
  - #18's own count was low
  - the Git section's HEAD is stale
- **The new test counts:** 316 phone, 42 watch.
- **`docs/STATE.md`:** the watch's language resolution belongs beside the phone's.

- [ ] **Step 4: Stage everything, explicitly, and stop**

```bash
git add HISTORY.md docs/AI_CONTEXT.md docs/STATE.md docs/superpowers/plans/2026-10-06-watch-localization.md
git add tasks/lessons.md      # only if Step 2 appended to it
git add CLAUDE.md             # only if /doc_sync changed it
# …and, by explicit path, every other file /doc_sync reports changing (docs/WIDGET.md, docs/DESIGN.md)
git diff --cached --name-status
echo "--- unstaged:"; git diff --name-status
```

Expected:
- **Staged:** the spec, this plan, the four watch sources, the two catalogues, the widget source,
  the three test files, the four rule files, `HISTORY.md` and the docs `/doc_sync` touched.
- **Unstaged:** nothing.
- `Screenshots/census/` is still untracked.
- **Do not run `git commit`.** The owner runs `/commit`.
