# Plural Forms Implementation Plan

> **For the session that runs it:** executed in the main loop, task by task, tests first — `CLAUDE.md`
> has no implementation subagent. Steps use checkboxes (`- [ ]`). **Nothing is committed**: each task
> ends with its files staged by name, and the owner runs `/commit` (rule `90-git`).

**Goal:** every sentence the app, the widgets and the watch build from a key with a count reads in the
right grammatical form in English and Russian, figures grouped as the screen groups them — and the
streak chip's *12 days* and the strip's *5 servings* come back.

**Architecture:** one new `nonisolated` helper, `Bundle.localized(_:_:locale:)`, beside `figure` in
`DataManager.swift`, formats a resolved key with the app's injected `\.locale`; 31 of the 32
`String(format:)` sites move to it and `WristVessel.readout` moves to `figure`. The ten counted keys
gain Apple's plural variations in the catalogues that hold them (English *one*/*other*, Russian
*one*/*few*/*many*/*other*; Uzbek keeps one value), and two new keys carry the chip's and the strip's
nouns. `LocalizationTests`' readers learn to read `Localizable.stringsdict`, where the build moves a
key with forms.

**Tech Stack:** Swift 5 mode, SwiftUI, WidgetKit, String Catalogs (`.xcstrings` → `.strings` +
`.stringsdict`), swift-testing, XCTest UI tests, Xcode 27.0.

**Spec:** `docs/superpowers/specs/2026-10-16-plural-forms-design.md` — approved by the owner on
2026-10-17. Its §3.3 holds the Russian words, §6 the tests, §7 the verification. Read it with this plan.

**What was checked in writing it** (2026-10-17, HEAD `52ee815`): every line number, type and test name
below was read from the tree; the helper, `arguments(for:counts:)`, `format`, `expected`'s patterns
and `forms(of:)` were compiled by `swiftc` on macOS with warnings as errors, and `forms(of:)` expanded
the probe's compiled `.stringsdict` correctly (16 sentences for the percentage key, 4 for *Add*). The
`Testing` and XCTest code was not compiled.

## Global Constraints

- Deployment floors stay `IPHONEOS_DEPLOYMENT_TARGET = 17.0` and `WATCHOS_DEPLOYMENT_TARGET = 26.0`; no
  `#available` is added (rule `15-project`).
- Zero dependencies; no new file in any exception set — the helper goes in `DataManager.swift`, which all
  three sets already name (rule `40-widget`, rule `95-dependencies`).
- `Bundle.localized(_:_:locale:)` is `nonisolated`: the app target sets
  `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, the widget and watch targets do not, and the test suites
  that call it are not `@MainActor` (rule `43-concurrency`).
- Every key keeps its English text as its key; no reader's key changes (spec §3.3).
- Every format specifier is positional, in each plural form and substitution as in a plain value
  (rule `70-privacy`, as amended).
- Uzbek keeps one value in every key (spec §3.3).
- The two new keys are added to the app's catalogue only, with `"extractionState": "manual"`.
- Never `String(format:)` over a resolved key once a task is done (rule `50-views`, as amended).
- Never weaken an assertion; a test that disagrees with the code is a stop (rule `85-testing`).
- No new warning against a clean baseline of HEAD, compared per file and message (`CLAUDE.md`: 29
  unique lines on Xcode 27.0).
- The tree is edited with Edit and Write only — no `sed -i`, no heredoc or script writing into it
  (`tasks/lessons.md`; the harness refuses them).
- `xcodebuild` in the foreground, one simulator, `-parallel-testing-enabled NO`; never
  `xcrun simctl shutdown all` — another project's simulators run on this Mac; shut down by UDID. Run
  `uptime` before a UI run, and put `-collect-test-diagnostics never` on every UI run.
- Devices: unit tests on the stock iOS 27.0 *iPhone 17*; UI tests on *WaterBuddy Gate 27* and
  *WaterBuddy Gate 26.5*; watch tests on *WaterBuddy Watch 27*; renders on *WaterBuddy Probe 27*,
  *WaterBuddy Probe 26.5* and *WaterBuddy Small 26.5* — never pour on a Gate device for a render.

## Review Focus

The five inputs the spec implies and its own tests do not reach, most likely first, each pinned in the
task that owns it:

1. **A phone on *Follow device* in a language the app does not ship.** English words, the phone's own
   grouping and plural rule: German gives *1 millilitre* and *1.300 millilitres*; Japanese, with one
   form, *1 millilitres* (spec §8). Pinned in Task 1. *(2026-10-17, after the final review: wrong
   for Japanese — the locale is English with the phone's region, `en_JP`, so *1 millilitre*. Task 1's
   two tests were re-aimed at `en_DE` and `en_JP`, and `theFollowDeviceLocaleSpeaksTheBundlesLanguage`
   added; spec §8 is corrected. The code below is the plan as written.)*
2. **The largest text size.** The chip draws the count alone and still speaks the noun; the strip's
   count moves under its heading and stays out of VoiceOver. Pinned by UI tests at
   `UICTContentSizeCategoryAccessibilityXXXL` in Tasks 6 and 7.
3. **A five-digit figure.** `maximumDailyIntake` is 100,000; grouped, a widget hero or a watch row is a
   character wider than it was. No test can see a cut figure from outside: a render at a total of
   12,500 in Task 8.
4. **The Lock Screen widget's quiet form.** The pour button's label branches on
   `redactionReasons.contains(.privacy)`; the move to `localized` must keep *Log Water* in that branch.
   A render with *Allow Access When Locked → Lock Screen Widgets* off in Task 8.
5. **A language changed while the app is open.** Eleven types read `\.locale` for the first time; each
   must follow the root's injection without a relaunch. Renders after switching to Русский in Settings
   with Home and History already drawn, in Task 8.

## Preconditions — before any code

- [ ] **The owner has approved the §5 rule wording** typed into `.claude/rules/50-views.md`,
  `65-accessibility.md` and `70-privacy.md` (unstaged, 2026-10-17). If the owner changed it, re-read the
  three files before Task 1.
- [ ] **D7 is settled.** This must print nothing:

```bash
git diff --stat -- WaterBuddyWatch/Localizable.xcstrings WaterBuddyWatchWidget/Localizable.xcstrings WaterBuddy/AppShortcuts.xcstrings
```

  If it prints anything, stop: Task 2 edits `WaterBuddyWatch/Localizable.xcstrings`, and the owner
  decides whether Xcode's rewrite is committed or discarded first (spec §9, D7).
- [ ] Read the DocC on `Bundle.figure` (`DataManager.swift:2070`–`2089`), `HomeView.streakChip`
  (`HomeView.swift:369`–`408`), `DayStrip` (`HistoryView.swift:1031`–`1116`) and
  `WristVessel.readout` (`WristVessel.swift:124`–`139`) — rule `00-workspace`.

## Files

| File | Change | Task |
|---|---|---|
| `WaterBuddy/DataManager.swift` | `Bundle.localized(_:_:locale:)`; `figure`'s DocC | 1, 3 |
| `WaterBuddyTests/LocalizationTests.swift` | `PluralFormTests`; readers of `.stringsdict`; key lists; two tests re-read | 1, 2 |
| `WaterBuddy/Localizable.xcstrings` | forms for nine keys; `%1$d days`, `%1$d servings` | 2 |
| `WaterBuddyWidget/Localizable.xcstrings` | forms for the percentage key and *Add* | 2 |
| `WaterBuddyWatch/Localizable.xcstrings` | forms for the percentage key and *Logs* | 2 |
| `WaterBuddy/HomeView.swift` | five sites; the chip's noun | 3, 6 |
| `WaterBuddy/HistoryView.swift` | seven sites; the strip's count | 3, 7 |
| `WaterBuddy/WelcomeView.swift` | four sites; `@Environment(\.locale)` on `WelcomeView` | 3 |
| `WaterBuddy/SettingsView.swift` | one site; `@Environment(\.locale)` on `GoalCard` | 3 |
| `WaterBuddy/VesselSliders.swift` | one site | 3 |
| `WaterBuddyUITests/WelcomeUITests.swift` | 18 lines read grouped figures | 3 |
| `WaterBuddyUITests/GoalSetupUITests.swift` | three helpers; the chip's and the strip's tests | 3, 6, 7 |
| `WaterBuddyUITests/AppStoreScreenshotUITests.swift` | eleven lines, outside the gate | 3 |
| `WaterBuddyWidget/WaterBuddyWidget.swift` | five sites; three types gain the locale | 4 |
| `WaterBuddyWidget/LockScreenWidget.swift` | four sites; `spokenFigures(in:locale:)` | 4 |
| `WaterBuddyWatch/WristView.swift` | four sites; two helpers gain `locale:` | 5 |
| `WaterBuddyWatch/WristVessel.swift` | `readout` through `figure` | 5 |
| `WaterBuddyWatchTests/WristViewLogicTests.swift` | the two helpers' calls pass `locale:` | 5 |
| `docs/DESIGN.md` | the strip count's contrast, measured | 8 |
| `HISTORY.md`, `docs/AI_CONTEXT.md`, `docs/ROADMAP.md`, `docs/STATE.md`, `docs/WIDGET.md` | records | 9 |

Throughout, `S` is the session's scratchpad directory, as the environment names it. A shell's
variables do not carry from one call to the next, so every block that uses it sets it first
(`S=<that directory>`). Nothing here removes a directory: each run that needs a clean one makes a new
one, named for the time.

---

### Task 1: The helper, and the forms' tests — run red

**Files:**
- Modify: `WaterBuddy/DataManager.swift` (the `extension Bundle` at about line 2070)
- Modify: `WaterBuddyTests/LocalizationTests.swift` (append a suite at the end)

**Interfaces:**
- Produces: `extension Bundle { nonisolated func localized(_ key: String, _ arguments: any CVarArg..., locale: Locale) -> String }`
  — every later task calls it as `strings.localized("…", a, b, locale: locale)`.

- [ ] **Step 1: Write the failing tests.** Append to `WaterBuddyTests/LocalizationTests.swift`:

```swift
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
    CountedKey(key: "%1$@, add %2$d millilitres", arity: 2, counted: [1], bundles: ["app"]),
    CountedKey(key: "%1$d millilitres to go", arity: 1, counted: [0], bundles: ["app"]),
    CountedKey(key: "%1$d of %2$d millilitres", arity: 2, counted: [1], bundles: ["app"]),
    CountedKey(key: "%1$d percent. %2$d of %3$d millilitres.", arity: 3, counted: [0, 2],
               bundles: ["app", "widget", "watch"]),
    CountedKey(key: "Add %1$d millilitres", arity: 1, counted: [0], bundles: ["app", "widget"]),
    CountedKey(key: "Use %1$d millilitres", arity: 1, counted: [0], bundles: ["app"]),
    CountedKey(key: averageKey, arity: 4, counted: [0, 1, 3], bundles: ["app"]),
    CountedKey(key: "Last %1$d days", arity: 1, counted: [0], bundles: ["app"]),
    CountedKey(key: "Logs %1$d millilitres", arity: 1, counted: [0], bundles: ["watch"]),
    CountedKey(key: "%1$d days", arity: 1, counted: [0], bundles: ["app"]),
    CountedKey(key: "%1$d servings", arity: 1, counted: [0], bundles: ["app"]),
]

private func shipped(_ name: String) -> Bundle? {
    switch name {
    case "widget": widgetBundle
    case "watch": watchBundle
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

    case ("Logs %1$d millilitres", "en"): return "Logs \(f[0]) \(ml(0))"
    case ("Logs %1$d millilitres", "ru"): return "Записывает \(f[0]) \(mlRu(0))"
    case ("Logs %1$d millilitres", "uz"): return "\(f[0]) millilitr qayd etadi"

    case ("%1$d days", "en"): return "\(f[0]) " + english(n[0], "day", "days")
    case ("%1$d days", "ru"): return "\(f[0]) " + russian(n[0], "день", "дня", "дней")
    case ("%1$d days", "uz"): return "\(f[0]) kun"

    case ("%1$d servings", "en"): return "\(f[0]) " + english(n[0], "serving", "servings")
    case ("%1$d servings", "ru"): return "\(f[0]) " + russian(n[0], "порция", "порции", "порций")
    case ("%1$d servings", "uz"): return "\(f[0]) porsiya"

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

    /// Spec §8: *Follow device* on a phone in a language the app does not ship draws English words with
    /// the phone's own grouping and plural rule. German's rule is English's, so the words come right.
    @Test func aGermanPhoneOnFollowDeviceGetsEnglishWordsAndGermanFigures() throws {
        let english = try #require(localization(appBundle, "en"), "the app ships no en table")
        let german = Locale(identifier: "de_DE")

        #expect(english.localized("%1$d millilitres", 1, locale: german) == "1 millilitre")
        #expect(english.localized("%1$d millilitres", 1_300, locale: german)
                == "\(1_300.formatted(.number.locale(german))) millilitres")
    }

    /// Japanese has one form, so English words read *1 millilitres* there — the limitation spec §8
    /// states, pinned so a change to it is seen (rule `75-diagnostics`: a degraded path gets a test).
    @Test func aJapanesePhoneOnFollowDeviceGetsTheOneFormJapaneseHas() throws {
        let english = try #require(localization(appBundle, "en"), "the app ships no en table")

        #expect(english.localized("%1$d millilitres", 1, locale: Locale(identifier: "ja_JP")) == "1 millilitres")
    }
}
```

- [ ] **Step 2: Add the helper, so the tests compile.** In `WaterBuddy/DataManager.swift`, inside
  `extension Bundle`, above `figure(_:_:locale:)`:

```swift
    /// A sentence from a key with arguments, formatted with `locale`: a count takes the plural form
    /// its language gives it, and every figure is grouped the way the language groups it.
    ///
    /// **The locale chooses the form, not this bundle.** Foundation reads a key's plural variations
    /// by the locale handed to the format; with none, it does not take the form from the app's
    /// language — on an English phone the Russian table gave *Добавить 5 миллилитра*
    /// (spec 2026-10-16 §2). Formatted with a locale, a `%d` is grouped too, which is why spoken
    /// figures read *2,000* as the screen draws them (rule `50-views`).
    ///
    /// `nonisolated`, as ``figure(_:_:locale:)`` is, so a suite off the main actor can pin it and the
    /// widget's views can call it. Here, beside it, because every bundle that draws a sentence compiles
    /// this file and the shared set does not grow (rule `15-project`).
    nonisolated func localized(_ key: String, _ arguments: any CVarArg..., locale: Locale) -> String {
        String(format: localizedString(forKey: key, value: nil, table: nil),
               locale: locale, arguments: arguments)
    }
```

- [ ] **Step 3: Run the suite and verify red.**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/PluralFormTests -parallel-testing-enabled NO -collect-test-diagnostics never
```

  Expected: `** TEST FAILED **`, and the failures are exactly these (spec §6.1). Read every failure
  line against the list; a failure not on it, or an item on it that passes, is a stop:
  - in Russian, every count outside *many* (1, 2, 21, 22, 101, 1,001), except the *few* counts
    (2, 22) of an argument after *из* — `%1$d of %2$d millilitres`' second, the percentage key's
    third, the average's fourth;
  - in English, count 1 of every argument whose noun changes — not the percentage key's first, since
    *percent* does not;
  - `%1$d days` and `%1$d servings`, which no catalogue holds yet, at every count in Russian and Uzbek;
  - `withNoLocaleTheRussianTableIsNotReadAsRussian`'s first expectation (it gets
    *Добавить 5 миллилитров*);
  - `aGermanPhoneOnFollowDeviceGetsEnglishWordsAndGermanFigures`' first expectation.

  `aJapanesePhoneOnFollowDeviceGetsTheOneFormJapaneseHas` passes. **If a figure differs from the
  expected one only in its grouping separator's character**, stop and report it: it would mean
  `String(format:locale:)` and `formatted(.number.locale(_:))` group differently, and the spec says
  they agree. Do not change the expectation to match. (On macOS, on 2026-10-17, a scratch check found
  the two paths give the same separator — U+002C, U+00A0, U+002E — for `en`, `ru`, `uz`, `de_DE`,
  `ja_JP` and `en_US`, at 1,001, 1,240, 12,500 and 100,000. The simulator is not yet seen.)

- [ ] **Step 4: Stage.**

```bash
git add WaterBuddy/DataManager.swift WaterBuddyTests/LocalizationTests.swift
```

---

### Task 2: The forms in the catalogues, and readers that see them

**Files:**
- Modify: `WaterBuddy/Localizable.xcstrings`, `WaterBuddyWidget/Localizable.xcstrings`,
  `WaterBuddyWatch/Localizable.xcstrings`
- Modify: `WaterBuddyTests/LocalizationTests.swift` (fixtures and readers at lines 94–192; the
  tests at 247–267, 340–352, 521–556, 595–660)

**Interfaces:**
- Consumes: `Bundle.localized(_:_:locale:)` (Task 1).
- Produces: the keys `%1$d days` and `%1$d servings` in the app's catalogue; `table(_:_:)` now returns
  `[String: [String]]` — each key with every sentence it can produce — and a new
  `sentences(_:_:_:)`.

- [ ] **Step 1: Write the readers' failing test.** In `LocalizationTests`, after
  `bothLanguagesCoverExactlyTheSameKeys`:

```swift
    /// The readers in this file see a key with plural forms, which the build moves out of
    /// `Localizable.strings` into `Localizable.stringsdict` (spec 2026-10-16 §6.2): two forms in
    /// English, four in Russian, and Uzbek's one value.
    @Test func theTablesSeeAKeyWithPluralForms() {
        #expect(table(appBundle, "en")?["Add %1$d millilitres"]?.count == 2)
        #expect(table(appBundle, "ru")?["Add %1$d millilitres"]?.count == 4)
        #expect(table(appBundle, "uz")?["Add %1$d millilitres"]?.count == 1)
    }
```

  It compiles against today's `table`, whose values are `String`s — `.count` counts characters, so it
  fails now, for no useful reason. What it is for is the red in Step 4, after the forms exist.

- [ ] **Step 2: Give the counted keys their forms.** Every edit keeps the file's own style: two-space
  indent, `"key": value`, the keys of every object in alphabetical order (`few`, `many`, `one`,
  `other`; `argNum`, `formatSpecifier`, `variations`; `stringUnit` before `substitutions`). Uzbek's
  `uz` object is not touched in any key.

  **Shape A — the count is the only argument.** The localization's `stringUnit` becomes
  `variations.plural`. `Add %1$d millilitres` in the app's catalogue, whole, as it reads after the
  edit:

```json
    "Add %1$d millilitres": {
      "extractionState": "manual",
      "localizations": {
        "en": {
          "variations": {
            "plural": {
              "one": {
                "stringUnit": {
                  "state": "translated",
                  "value": "Add %1$d millilitre"
                }
              },
              "other": {
                "stringUnit": {
                  "state": "translated",
                  "value": "Add %1$d millilitres"
                }
              }
            }
          }
        },
        "ru": {
          "variations": {
            "plural": {
              "few": {
                "stringUnit": {
                  "state": "translated",
                  "value": "Добавить %1$d миллилитра"
                }
              },
              "many": {
                "stringUnit": {
                  "state": "translated",
                  "value": "Добавить %1$d миллилитров"
                }
              },
              "one": {
                "stringUnit": {
                  "state": "translated",
                  "value": "Добавить %1$d миллилитр"
                }
              },
              "other": {
                "stringUnit": {
                  "state": "translated",
                  "value": "Добавить %1$d миллилитра"
                }
              }
            }
          }
        },
        "uz": {
          "stringUnit": {
            "state": "translated",
            "value": "%1$d millilitr qo‘shish"
          }
        }
      }
    },
```

  **Shape B — a count among other arguments.** The localization keeps a `stringUnit` whose value
  names each counted argument as `%#@argN@`, beside `substitutions`, one per counted argument, by
  `argNum`; each form says `%arg` where the figure goes (measured: `xcstringstool` compiles this to
  `%N$#@argN@`, spec §3.3). The percentage key's `en` and `ru`, as they read after the edit:

```json
        "en": {
          "stringUnit": {
            "state": "translated",
            "value": "%1$d percent. %2$d of %#@arg3@."
          },
          "substitutions": {
            "arg3": {
              "argNum": 3,
              "formatSpecifier": "d",
              "variations": {
                "plural": {
                  "one": {
                    "stringUnit": {
                      "state": "translated",
                      "value": "%arg millilitre"
                    }
                  },
                  "other": {
                    "stringUnit": {
                      "state": "translated",
                      "value": "%arg millilitres"
                    }
                  }
                }
              }
            }
          }
        },
        "ru": {
          "stringUnit": {
            "state": "translated",
            "value": "%#@arg1@. %2$d из %#@arg3@."
          },
          "substitutions": {
            "arg1": {
              "argNum": 1,
              "formatSpecifier": "d",
              "variations": {
                "plural": {
                  "few": {
                    "stringUnit": {
                      "state": "translated",
                      "value": "%arg процента"
                    }
                  },
                  "many": {
                    "stringUnit": {
                      "state": "translated",
                      "value": "%arg процентов"
                    }
                  },
                  "one": {
                    "stringUnit": {
                      "state": "translated",
                      "value": "%arg процент"
                    }
                  },
                  "other": {
                    "stringUnit": {
                      "state": "translated",
                      "value": "%arg процента"
                    }
                  }
                }
              }
            },
            "arg3": {
              "argNum": 3,
              "formatSpecifier": "d",
              "variations": {
                "plural": {
                  "few": {
                    "stringUnit": {
                      "state": "translated",
                      "value": "%arg миллилитров"
                    }
                  },
                  "many": {
                    "stringUnit": {
                      "state": "translated",
                      "value": "%arg миллилитров"
                    }
                  },
                  "one": {
                    "stringUnit": {
                      "state": "translated",
                      "value": "%arg миллилитра"
                    }
                  },
                  "other": {
                    "stringUnit": {
                      "state": "translated",
                      "value": "%arg миллилитра"
                    }
                  }
                }
              }
            }
          }
        },
```

  **Every key, and every value** (Russian forms in the order *one* / *few* / *many* / *other*; *other*,
  reached only by a fraction, is the genitive singular):

  | Key, catalogues | Shape | `en` | `ru` |
  |---|---|---|---|
  | `%1$d millilitres` — app | A | `%1$d millilitre` / `%1$d millilitres` | `%1$d миллилитр` / `%1$d миллилитра` / `%1$d миллилитров` / `%1$d миллилитра` |
  | `%1$@, add %2$d millilitres` — app | B, `arg2` | value `%1$@, add %#@arg2@`; `arg2`: `%arg millilitre` / `%arg millilitres` | value `%1$@, добавить %#@arg2@`; `arg2`: `%arg миллилитр` / `%arg миллилитра` / `%arg миллилитров` / `%arg миллилитра` |
  | `%1$d millilitres to go` — app | A | `%1$d millilitre to go` / `%1$d millilitres to go` | `Остался %1$d миллилитр` / `Осталось %1$d миллилитра` / `Осталось %1$d миллилитров` / `Осталось %1$d миллилитра` |
  | `%1$d of %2$d millilitres` — app | B, `arg2` | value `%1$d of %#@arg2@`; `arg2`: `%arg millilitre` / `%arg millilitres` | value `%1$d из %#@arg2@`; `arg2`: `%arg миллилитра` / `%arg миллилитров` / `%arg миллилитров` / `%arg миллилитра` |
  | `%1$d percent. %2$d of %3$d millilitres.` — app, widget, watch | B | as written above | as written above |
  | `Add %1$d millilitres` — app, widget | A | as written above | as written above |
  | `Use %1$d millilitres` — app | A | `Use %1$d millilitre` / `Use %1$d millilitres` | `Выбрать %1$d миллилитр` / `Выбрать %1$d миллилитра` / `Выбрать %1$d миллилитров` / `Выбрать %1$d миллилитра` |
  | `Average %1$d millilitres. Best %2$d millilitres. Goal met on %3$d of %4$d days.` — app | B, `arg1`, `arg2`, `arg4` | value `Average %#@arg1@. Best %#@arg2@. Goal met on %3$d of %#@arg4@.`; `arg1` and `arg2`: `%arg millilitre` / `%arg millilitres`; `arg4`: `%arg day` / `%arg days` | value `В среднем %#@arg1@. Лучший день %#@arg2@. Цель достигнута в %3$d из %#@arg4@.`; `arg1` and `arg2`: `%arg миллилитр` / `%arg миллилитра` / `%arg миллилитров` / `%arg миллилитра`; `arg4`: `%arg дня` / `%arg дней` / `%arg дней` / `%arg дня` |
  | `Last %1$d days` — app | A | `Last %1$d day` / `Last %1$d days` | `Последние %1$d день` / `Последние %1$d дня` / `Последние %1$d дней` / `Последние %1$d дня` |
  | `Logs %1$d millilitres` — watch | A | `Logs %1$d millilitre` / `Logs %1$d millilitres` | `Записывает %1$d миллилитр` / `Записывает %1$d миллилитра` / `Записывает %1$d миллилитров` / `Записывает %1$d миллилитра` |

  The widget's and the watch's copies of the percentage key, and the widget's of *Add*, are the app's
  value for value.

- [ ] **Step 3: Add the two new keys** to `WaterBuddy/Localizable.xcstrings` only, shape A, with
  `"extractionState": "manual"` and a plain `uz` value. `"%1$d days"` goes between
  `"%1$@, add %2$d millilitres"` and `"%1$d kg"`; `"%1$d servings"` between
  `"%1$d percent. %2$d of %3$d millilitres."` and `"+%1$d ml"`:

  | Key | `en` | `ru` | `uz` |
  |---|---|---|---|
  | `%1$d days` | `%1$d day` / `%1$d days` | `%1$d день` / `%1$d дня` / `%1$d дней` / `%1$d дня` | `%1$d kun` |
  | `%1$d servings` | `%1$d serving` / `%1$d servings` | `%1$d порция` / `%1$d порции` / `%1$d порций` / `%1$d порции` | `%1$d porsiya` |

  Check the three files still parse and hold what the table says (read-only; `-I` because a scratch
  module can shadow the standard library, `tasks/lessons.md`):

```bash
for f in WaterBuddy/Localizable.xcstrings WaterBuddyWidget/Localizable.xcstrings WaterBuddyWatch/Localizable.xcstrings; do python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(sys.argv[1], len(d["strings"]), "keys")' "$f"; done
```

  Expected: app 105 keys (103 + 2), widget 19, watch 19 — the watch's count after D7: 16 if Xcode's
  rewrite was discarded. Write the count it printed into the task's notes; do not assume it.

- [ ] **Step 4: Run the suites; the forms pass and the readers break.**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/PluralFormTests -only-testing:WaterBuddyTests/LocalizationTests -only-testing:WaterBuddyTests/HomeStringTests -only-testing:WaterBuddyTests/HistoryStringTests -only-testing:WaterBuddyTests/WelcomeStringTests -parallel-testing-enabled NO -collect-test-diagnostics never
```

  Expected: `PluralFormTests` passes, the German test and the no-locale test included — the first
  sight of the simulator choosing the form by the locale (spec §8). If the no-locale test fails, the
  simulator does not do what macOS did: stop and report. The readers' red (spec §6.2), and nothing
  else failing:
  - `theTablesSeeAKeyWithPluralForms`, on all three lines: English and Russian find no such key —
    it has left their `Localizable.strings` — and Uzbek's one value is still counted in characters;
  - `bothLanguagesCoverExactlyTheSameKeys`: *app: translated into uz but not ru* — every key with
    forms, which Uzbek's table still holds as one value;
  - `everyTranslationKeepsTheFormatArgumentsOfItsKey` in Russian, and the Home, History and welcome
    suites' `…KeepsItsArguments`, on each key with forms in English and Russian: the resolved value is
    a `%#@…@` format key, whose arguments `specifiers(in:)` does not see.

  The checks that read `table` whole — `noTranslationAnywhereLosesAFormatArgument`, the coverage
  tests — pass, blind: the keys with forms are not in the table they read. The agreement tests pass,
  comparing `%#@value@` with `%#@value@`.

- [ ] **Step 5: Teach the readers the `.stringsdict`.** Replace `table(_:_:)` at
  `LocalizationTests.swift:174`–`183` with:

```swift
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
```

  The suite no longer compiles: `noTranslationAnywhereLosesAFormatArgument` and
  `noWatchTranslationLosesAFormatArgument` read a value as a `String`. Step 6 moves them.

- [ ] **Step 6: Move every caller onto sentences.** In `LocalizationTests.swift`:

  `everyTranslationKeepsTheFormatArgumentsOfItsKey` (247–267) — the loop body becomes:

```swift
        for key in sharedKeys {
            let expected = specifiers(in: key)
            guard !expected.isEmpty, let resolved = sentences(appBundle, language, key) else { continue }
            for sentence in resolved {
                #expect(specifiers(in: sentence) == expected,
                        "\"\(key)\" in \(language) does not carry the same format arguments: \(sentence)")
            }
        }
```

  `theWidgetAgreesWithTheAppOnEverySharedString` — compare every form, not the resolved value, which
  is the same `%#@value@` in every bundle and would pass for nothing (spec §6.2). Every form is what
  formatting at every count would reach, without arguments to choose:

```swift
        for key in sharedKeys {
            #expect(sentences(appBundle, language, key) == sentences(widgetBundle, language, key),
                    "\"\(key)\" differs between the app and the widget in \(language)")
        }
```

  `noTranslationAnywhereLosesAFormatArgument` — the loop:

```swift
        for (key, translations) in strings {
            let expected = specifiers(in: key)
            guard !expected.isEmpty else { continue }
            for translation in translations {
                #expect(specifiers(in: translation) == expected,
                        "\"\(key)\" in \(language) does not carry the same format arguments: \(translation)")
            }
        }
```

  `noWatchTranslationLosesAFormatArgument` — the inner loop, the same way:

```swift
            for (key, translations) in strings {
                let expected = specifiers(in: key)
                guard !expected.isEmpty else { continue }
                for translation in translations {
                    #expect(specifiers(in: translation) == expected,
                            "\(name): \"\(key)\" in \(language) does not carry the same format arguments: \(translation)")
                }
            }
```

  `theWatchAgreesWithThePhoneOnEverySharedString` — the loop (the complication's description, a plain
  value, keeps `value`):

```swift
        for key in watchSharedKeys {
            let phone = sentences(appBundle, language, key)
            #expect(phone != nil, "\"\(key)\" is missing from the phone's \(language) table — nothing to agree with")
            #expect(sentences(watchBundle, language, key) == phone,
                    "\"\(key)\" differs between the phone and the watch in \(language)")
        }
```

  `everyHomeStringExistsAndKeepsItsArguments`, `everyHistoryStringExistsAndKeepsItsArguments` and
  `everyWelcomeStringExistsAndKeepsItsArguments` — each loop body becomes (the list's name differs):

```swift
            let resolved = sentences(appBundle, language, key)
            #expect(resolved != nil, "\(language) has no value for \"\(key)\"")
            for sentence in resolved ?? [] {
                #expect(specifiers(in: sentence) == specifiers(in: key),
                        "\"\(key)\" in \(language) does not carry the same format arguments: \(sentence)")
            }
```

  The key lists: `"%1$d days",` joins `homeKeys` after `"Day streak",`; `"%1$d servings",` joins
  `historyKeys` after `"When you drank",`.

  `onlyTheSpokenHomeStringTakesARawNumber` (609–615) is re-read: since 1.2.6 a `%d` key is formatted
  with the locale and groups, so the split it pinned — spoken `%d`, drawn `%@` — no longer decides
  grouping. What is left to pin is which of Home's keys carry a count. Replace it with:

```swift
    /// Home's keys that take a raw number are its two counted ones: the status line's, and the
    /// streak's. Both are formatted through ``Bundle/localized(_:_:locale:)``, so both are grouped
    /// and take their plural forms (spec 2026-10-16 §3.6); the drawn volumes keep their `%@` keys.
    @Test func theHomeKeysThatTakeARawNumberAreTheCountedOnes() {
        let raw = homeKeys.filter { $0.contains("$d") }

        #expect(raw == ["%1$d millilitres to go", "%1$d days"])
    }
```

  `theOnlyRawVolumesLeftToDrawAreOtherScreens` keeps its assertion; its DocC's last paragraph
  becomes:

```swift
    /// Three are left, and none is History's or — since the redesign's stage 4 — Settings': all
    /// three are the widget's, kept in the app's table because the two must agree (`sharedKeys`).
    /// Since roadmap item 1.2.6 they are grouped too, formatted through
    /// ``Bundle/localized(_:_:locale:)``; they are `%d` keys only because their screens have not been
    /// redrawn. This set shrinks when they are.
```

  `HomeStringTests`' doc comment on the deleted test goes with it.

- [ ] **Step 7: Run the unit suite green.**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests -parallel-testing-enabled NO
```

  Expected: `✔ Test run with N tests … passed`, where N is the attribute grep's count:

```bash
grep -chE '^[[:space:]]*@Test' WaterBuddyTests/*.swift | awk '{s+=$1} END {print s}'
```

  616 before this plan; Task 1 adds four, Task 2 one, and replaces one: 621. The suites Step 4 saw
  fail now pass, and the ones that passed blind now read every key with forms.

- [ ] **Step 8: Stage.**

```bash
git add WaterBuddy/Localizable.xcstrings WaterBuddyWidget/Localizable.xcstrings WaterBuddyWatch/Localizable.xcstrings WaterBuddyTests/LocalizationTests.swift
```

---

### Task 3: The app's sentences through the helper

**Files:**
- Modify: `WaterBuddy/HomeView.swift` (512, 592, 687, 795, 1015)
- Modify: `WaterBuddy/HistoryView.swift` (431, 690, 702, 774, 1299, 1486, 1599; `ServingSheet` gains the locale)
- Modify: `WaterBuddy/WelcomeView.swift` (645, 804, 959, 1095; `WelcomeView` gains the locale)
- Modify: `WaterBuddy/SettingsView.swift` (486; `GoalCard` gains the locale)
- Modify: `WaterBuddy/VesselSliders.swift` (106)
- Modify: `WaterBuddy/DataManager.swift` (`figure`'s DocC)
- Test: `WaterBuddyUITests/WelcomeUITests.swift`, `WaterBuddyUITests/GoalSetupUITests.swift`,
  `WaterBuddyUITests/AppStoreScreenshotUITests.swift`

**Interfaces:**
- Consumes: `Bundle.localized(_:_:locale:)`.
- Produces: nothing new; each type below reads `@Environment(\.locale) private var locale`.

- [ ] **Step 1: The UI tests read grouped figures** (spec §6.3 — product speech changing on purpose;
  no assertion is narrowed).

  `WelcomeUITests.swift`, these 18 lines, each figure written grouped and nothing else changed:
  194 and 218 (`"1000 millilitres"` → `"1,000 millilitres"`); 199 and 222
  (`"Bottle, add 1000 millilitres"` → `"Bottle, add 1,000 millilitres"`); 297, 303, 304, 346, 347 and
  351 (`2500` → `2,500`); 299 and 322 (`2000` → `2,000`); 317, 360 and 367 (`2800` → `2,800`); 321
  (`2100` → `2,100`); 339 (`2400` → `2,400`); 350 (`4000` → `4,000`).

  `GoalSetupUITests.swift`, the three helpers:

```swift
    /// The vessel's value ends "… <total> of <goal> millilitres." — the one place a UI test can
    /// read today's total. Its figures are grouped as the screen's are (*1,300*), so the digits are
    /// read without the separator.
    private static func total(in app: XCUIApplication) -> Int {
        let words = (app.otherElements["Today's hydration"].value as? String ?? "").split(separator: " ")
        return words.count > 2 ? Int(words[2].filter(\.isNumber)) ?? -1 : -1
    }

    /// Waits until the vessel speaks `total`, grouped as the app groups it, and says whether it did.
    private static func waitForTotal(_ total: Int, in app: XCUIApplication) -> Bool {
        let spoken = NSPredicate(format: "value CONTAINS %@", " \(total.formatted(.number)) of ")
        let reached = XCTNSPredicateExpectation(predicate: spoken, object: app.otherElements["Today's hydration"])
        return XCTWaiter().wait(for: [reached], timeout: 5) == .completed
    }
```

```swift
    /// A day's total, off its button on the week card: the value reads "<n> millilitres", the figure
    /// grouped.
    @MainActor
    private static func millilitres(on day: XCUIElement) -> Int {
        Int((day.value as? String ?? "").split(separator: " ").first?.filter(\.isNumber) ?? "") ?? -1
    }
```

  `total.formatted(.number)` uses the runner's locale, which is the device's — the app's too, on
  *Follow device*, as every UI test runs.

  `AppStoreScreenshotUITests.swift` (outside the gate; the next capture must run): lines 218, 223,
  228, 235, 243, 261, 270, 331, 346, 365 and 370, each four-digit figure grouped — `2000` → `2,000`,
  `1000` → `1,000`, `4000` → `4,000`, `1300` → `1,300`, `1750` → `1,750`, `2500` → `2,500`. The
  capture names on 220, 225 and 230 are file names and stay.

- [ ] **Step 2: Run the welcome's UI tests and verify red.**

```bash
uptime
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' -only-testing:WaterBuddyUITests/WelcomeUITests -parallel-testing-enabled NO -collect-test-diagnostics never
```

  Expected: `** TEST FAILED **`; every test that holds one of the 18 lines fails on its first grouped
  figure (it reads *1000*), and the others pass. Read the executed count, never only the last line.

- [ ] **Step 3: Move the app's sites.** Each `String(format: strings.localizedString(forKey: K, value: nil, table: nil), A…)`
  becomes `strings.localized(K, A…, locale: locale)` — the key and the arguments unchanged:

  | File:line | Type | After |
  |---|---|---|
  | `HomeView.swift:512` | `HomeView` | `: strings.localized("%1$d millilitres to go", manager.remaining, locale: locale)` |
  | `HomeView.swift:591`–`594` | `HomeView` | `Text(strings.localized(key, date.formatted(.dateTime.hour().minute().locale(locale)), locale: locale))` |
  | `HomeView.swift:687` | `HomeView` | `.accessibilityValue(strings.localized("%1$d millilitres", offer.amount, locale: locale))` |
  | `HomeView.swift:795` | `HomeView` | `.accessibilityLabel(strings.localized("%1$@, add %2$d millilitres", serving.name(in: strings), serving.amount, locale: locale))` |
  | `HomeView.swift:1015` | `WaterVessel` | `.accessibilityValue(strings.localized("%1$d percent. %2$d of %3$d millilitres.", percentage, volume, goal, locale: locale))` |
  | `HistoryView.swift:431` | `HistoryView` | `.accessibilityValue(strings.localized("%1$d of %2$d millilitres", shownTotal, manager.dailyGoal, locale: locale))` |
  | `HistoryView.swift:690` | `HistoryCard` | `Text(strings.localized("Last %1$d days", DataManager.historyWindow, locale: locale))` |
  | `HistoryView.swift:701`–`707` | `HistoryCard` | `.accessibilityValue(strings.localized("Average %1$d millilitres. Best %2$d millilitres. Goal met on %3$d of %4$d days.", DaySummary.average(of: manager.history), DaySummary.best(of: manager.history), DaySummary.daysMet(in: manager.history, goal: manager.dailyGoal), manager.history.count, locale: locale))` |
  | `HistoryView.swift:774` | `HistoryCard` | `.accessibilityValue(strings.localized("%1$d millilitres", day.total, locale: locale))` |
  | `HistoryView.swift:1299` | `ServingRow` | `.accessibilityLabel(strings.localized("%1$d millilitres", log.amount, locale: locale))` |
  | `HistoryView.swift:1486` | `ServingSheet` | `.accessibilityValue(strings.localized("%1$d millilitres", amount, locale: locale))` |
  | `HistoryView.swift:1599` | `ServingSheet` | `.accessibilityValue(strings.localized("%1$d millilitres", serving.amount, locale: locale))` |
  | `WelcomeView.swift:645`–`646` | `WelcomeView` | `.accessibilityLabel(strings.localized("Step %1$d of %2$d", step.number, WelcomeStep.allCases.count, locale: locale))` |
  | `WelcomeView.swift:804` | `WelcomeView` | `strings.localized("%1$d millilitres", volume, locale: locale)` |
  | `WelcomeView.swift:959` | `CalculatorPanel` | `return strings.localized(key, value, locale: locale)` |
  | `WelcomeView.swift:1095` | `CalculatorPanel` | `.accessibilityLabel(strings.localized("Use %1$d millilitres", suggestion, locale: locale))` |
  | `SettingsView.swift:486` | `GoalCard` | `.accessibilityValue(strings.localized("%1$d millilitres", goal, locale: locale))` |
  | `VesselSliders.swift:106` | `VesselSliders` | `.accessibilityValue(strings.localized("%1$d millilitres", amounts[index], locale: locale))` |

  Three types read the locale for the first time — add, under each one's `@Environment(\.strings)`:

```swift
    @Environment(\.locale) private var locale
```

  `WelcomeView` (after `WelcomeView.swift:109`), `ServingSheet` (after `HistoryView.swift:1365`) and
  `GoalCard` (after `SettingsView.swift:379`).

  The comments the change makes false. `HistoryView.swift:699`–`700`, *"Spoken as raw numbers, where
  the figures are drawn grouped."*, becomes:

```swift
            // Spoken grouped, as the figures are drawn (rule `50-views`).
```

  `WelcomeView.swift:802`'s DocC becomes:

```swift
    /// A volume as VoiceOver reads it: the noun in the form its count takes, the figure grouped as
    /// the language groups it (rule `50-views`).
```

  `Bundle.figure`'s DocC (`DataManager.swift`) — its second paragraph becomes:

```swift
    /// The keys it serves were written as `%n$@` when a `%1$d` key could not group: formatted
    /// without a locale, `String(format:)` prints `1300` in every language. ``localized(_:_:locale:)``
    /// formats with one and groups a `%d` too, so the two give the same figures; these keys stay as
    /// they are (spec 2026-10-16 §3.7). Spoken figures are grouped as well — VoiceOver reads
    /// *2,000 millilitres* where the screen draws *2,000 ml* (rule `50-views`).
```

  Confirm no app site is left:

```bash
grep -rnE 'format: (strings|bundle)\.localizedString' --include='*.swift' WaterBuddy
```

  Expected: no output.

- [ ] **Step 4: Run the welcome's UI tests green, then the unit suite.**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' -only-testing:WaterBuddyUITests/WelcomeUITests -parallel-testing-enabled NO -collect-test-diagnostics never
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests -parallel-testing-enabled NO
```

  Expected: `Executed 13 tests, with 0 failures`; then the unit suite's `✔`, 621 tests.

- [ ] **Step 5: Stage.**

```bash
git add WaterBuddy/HomeView.swift WaterBuddy/HistoryView.swift WaterBuddy/WelcomeView.swift WaterBuddy/SettingsView.swift WaterBuddy/VesselSliders.swift WaterBuddy/DataManager.swift WaterBuddyUITests/WelcomeUITests.swift WaterBuddyUITests/GoalSetupUITests.swift WaterBuddyUITests/AppStoreScreenshotUITests.swift
```

---

### Task 4: The widgets' sentences

**Files:**
- Modify: `WaterBuddyWidget/WaterBuddyWidget.swift` (221, 238, 326, 435, 450; `MediumColumn`,
  `MiniVessel`, `PourButton` gain the locale)
- Modify: `WaterBuddyWidget/LockScreenWidget.swift` (176, 180, 290, 302; `LockScreenCard`,
  `LockScreenPourButton` gain the locale; `spokenFigures` gains `locale:`)

**Interfaces:**
- Consumes: `Bundle.localized(_:_:locale:)`.
- Produces: `private extension WaterSnapshot { func spokenFigures(in strings: Bundle, locale: Locale) -> String }`,
  called from `LockScreenRing` (`:124`), `LockScreenCard` (`:203`) and `LockScreenLine` (`:241`).

No automated test can render the extension (rule `85-testing`); its strings are pinned by Task 1 and
Task 2, and the build and Task 8's renders are this task's proof.

- [ ] **Step 1: Move the sites.**

  | File:line | Type | After |
  |---|---|---|
  | `WaterBuddyWidget.swift:221` | `MediumColumn` | `Text(strings.localized("%1$d ml", snapshot.currentWater, locale: locale))` |
  | `WaterBuddyWidget.swift:238` | `MediumColumn` | `Text(strings.localized("of %1$d ml", snapshot.dailyGoal, locale: locale))` |
  | `WaterBuddyWidget.swift:326` | `MiniVessel` | `.accessibilityValue(strings.localized("%1$d percent. %2$d of %3$d millilitres.", snapshot.percentage, snapshot.currentWater, snapshot.dailyGoal, locale: locale))` |
  | `WaterBuddyWidget.swift:435` | `PourButton` | `.accessibilityLabel(strings.localized("Add %1$d millilitres", serving, locale: locale))` |
  | `WaterBuddyWidget.swift:450` | `PourButton` | `Text(strings.localized("+%1$d ml", serving, locale: locale))` |
  | `LockScreenWidget.swift:176` | `LockScreenCard` | `Text(strings.localized("%1$d ml", snapshot.currentWater, locale: locale))` |
  | `LockScreenWidget.swift:180` | `LockScreenCard` | `Text(strings.localized("of %1$d ml", snapshot.dailyGoal, locale: locale))` |
  | `LockScreenWidget.swift:290` | `LockScreenPourButton` | `strings.localized("Add %1$d millilitres", serving, locale: locale)` — inside the `else`; the `.privacy` branch's *Log Water* is untouched |

  `spokenFigures` (`LockScreenWidget.swift:297`–`303`):

```swift
private extension WaterSnapshot {

    /// The Home Screen vessel's own sentence — the percentage and both volumes — so VoiceOver says the
    /// same thing about today on either screen, in the forms and the grouping of `locale`.
    func spokenFigures(in strings: Bundle, locale: Locale) -> String {
        strings.localized("%1$d percent. %2$d of %3$d millilitres.", percentage, currentWater, dailyGoal, locale: locale)
    }
}
```

  Its three callers become `.accessibilityValue(snapshot.spokenFigures(in: strings, locale: locale))`.
  `LockScreenRing` and `LockScreenLine` read the locale already.

  Five types gain `@Environment(\.locale) private var locale`, under their `@Environment(\.strings)`:
  `MediumColumn` (`WaterBuddyWidget.swift:213`), `MiniVessel` (`:272`), `PourButton` (`:406`),
  `LockScreenCard` (`LockScreenWidget.swift:136`), `LockScreenPourButton` (`:259`).

  Confirm:

```bash
grep -rnE 'format: (strings|bundle)\.localizedString' --include='*.swift' WaterBuddyWidget
```

  Expected: no output.

- [ ] **Step 2: Build the extension.**

```bash
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17'
```

  Expected: `** BUILD SUCCEEDED **`, and no warning in either file (compare against Task 8's baseline
  if one appears).

- [ ] **Step 3: Stage.**

```bash
git add WaterBuddyWidget/WaterBuddyWidget.swift WaterBuddyWidget/LockScreenWidget.swift
```

---

### Task 5: The watch's sentences

**Files:**
- Modify: `WaterBuddyWatch/WristView.swift` (235, 236, 249, 372–401, 445; `WristView` and
  `WristServingMenu` gain the locale)
- Modify: `WaterBuddyWatch/WristVessel.swift` (`readout`, 124–139)
- Test: `WaterBuddyWatchTests/WristViewLogicTests.swift`

**Interfaces:**
- Consumes: `Bundle.localized(_:_:locale:)`, `Bundle.figure(_:_:locale:)`.
- Produces:
  `nonisolated static func syncedCaption(composedAt: Date?, now: Date, strings: Bundle, locale: Locale) -> String`
  and
  `nonisolated static func attribution(mirror: WristMirror?, now: Date, strings: Bundle, locale: Locale) -> String`
  on `WristView`.

- [ ] **Step 1: The tests pass the locale.** In `WristViewLogicTests.swift`, every call of
  `syncedCaption` and `attribution` gains `locale:` after `strings:` — the language's own locale, as
  `AppLanguage.locale` makes it: `locale: Locale(identifier: "en")` beside `english`,
  `Locale(identifier: "ru")` beside `russian`, `Locale(identifier: "uz")` beside `uzbek`, and in
  `aMirrorFromThePhonesFutureReadsAsJustNow`, `locale: Locale(identifier: language)`. The expected
  strings stay: a count of minutes under 1,000 formats the same (spec §6.3). The calls are at lines
  52, 59, 66, 95, 104, 111, 121–125, 140–144 and 160.

- [ ] **Step 2: Run the watch tests and verify red.**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO -collect-test-diagnostics never
```

  Expected: the build fails — `extra argument 'locale' in call` at each changed call.

- [ ] **Step 3: Implement.** In `WristView.swift`:

```swift
    nonisolated static func attribution(mirror: WristMirror?, now: Date, strings: Bundle, locale: Locale) -> String {
        guard let mirror else {
            return strings.localizedString(forKey: "Not yet synced · default goal", value: nil, table: nil)
        }
        guard mirror.isGoalSet else {
            return strings.localizedString(forKey: "Set your goal in WaterBuddy on iPhone", value: nil, table: nil)
        }
        return syncedCaption(composedAt: mirror.composedAt, now: now, strings: strings, locale: locale)
    }
```

```swift
    nonisolated static func syncedCaption(composedAt: Date?, now: Date, strings: Bundle, locale: Locale) -> String {
        guard let composedAt else {
            return strings.localizedString(forKey: "Not yet synced", value: nil, table: nil)
        }
        let minutes = Int(now.timeIntervalSince(composedAt) / 60)
        guard minutes >= 1 else {
            return strings.localizedString(forKey: "Synced just now", value: nil, table: nil)
        }
        return strings.localized("Synced %1$dm ago", minutes, locale: locale)
    }
```

  The two DocC blocks above them keep their text. Every mention of the two signatures gains
  `locale:` — `syncedCaption(composedAt:now:strings:locale:)`,
  `attribution(mirror:now:strings:locale:)` — at `WristView.swift:145`, `:148`, `:245`, `:363` and
  `:387`, and `WristModel.swift:101`; find each with
  `grep -n 'syncedCaption(composedAt\|attribution(mirror' WaterBuddyWatch/*.swift`. The `attribution`
  DocC's paragraph on its bundle gains one sentence:
  `/// It takes the locale beside it, for the same reason and with no default either.`

  The sites:
  - `:235` → `.accessibilityValue(strings.localized("%1$d percent. %2$d of %3$d millilitres.", percentage, model.todaysTotal, model.displayGoal, locale: locale))`
  - `:236` → `.accessibilityHint(strings.localized("Logs %1$d millilitres", serving.amount, locale: locale))`
  - `:249` → `Text(Self.attribution(mirror: model.mirror, now: now, strings: strings, locale: locale))`
  - `:445` → `Text(strings.localized("%1$d ml", serving.amount, locale: locale))`

  `WristView` (after `:84`) and `WristServingMenu` (after `:422`) gain
  `@Environment(\.locale) private var locale`.

  In `WristVessel.swift`, `readout` hands its figures to `figure`, which formats them the way it did
  by hand:

```swift
    /// `1 250 / 2 000 мл` — both figures grouped the way the language being drawn groups them,
    /// through ``Bundle/figure(_:_:locale:)`` as the phone's own volumes are, against the locale
    /// `WristRoot` injects beside the bundle, set into a `%1$@ / %2$@ ml` key only the watch holds.
    /// The watch grouped this readout before it was ever localized, and the owner chose to keep that
    /// (spec 2026-10-06 §3, ruling 3).
    ///
    /// `nonisolated static` and free of view state, so `WristViewLogicTests` can pin it.
    nonisolated static func readout(volume: Int, goal: Int, strings: Bundle, locale: Locale) -> String {
        strings.figure("%1$@ / %2$@ ml", volume, goal, locale: locale)
    }
```

  Confirm:

```bash
grep -rnE 'format: (strings|bundle)\.localizedString' --include='*.swift' WaterBuddyWatch WaterBuddyWatchWidget
```

  Expected: no output.

- [ ] **Step 4: Run the watch tests green, and build the watch widget.**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27'
```

  Expected: `✔ Test run with 57 tests in 6 suites passed` — the readout's tests at
  `WristViewLogicTests.swift:253`–`265` among them, unchanged — and `** BUILD SUCCEEDED **`.

- [ ] **Step 5: Stage.**

```bash
git add WaterBuddyWatch/WristView.swift WaterBuddyWatch/WristVessel.swift WaterBuddyWatch/WristModel.swift WaterBuddyWatchTests/WristViewLogicTests.swift
```

---

### Task 6: The streak chip's noun

**Files:**
- Modify: `WaterBuddy/HomeView.swift` (`streakChip`, 368–410)
- Test: `WaterBuddyUITests/GoalSetupUITests.swift` (`testTheTitleKeepsItsSizeBesideTheStreak`, 842;
  one new test)

**Interfaces:**
- Consumes: `Bundle.localized(_:_:locale:)`, the key `%1$d days` (Task 2).

- [ ] **Step 1: Write the failing tests.** At the end of `testTheTitleKeepsItsSizeBesideTheStreak`,
  after the title's assertion:

```swift
        assertTheChipSpeaksItsCountWithItsNoun(chip)
```

  And beside it, a helper and a test at the largest size (Review Focus 2):

```swift
    /// The chip's value is its count with the noun in that count's form — *1 day*, *12 days* — not a
    /// bare number (spec 2026-10-16 §3.4). Read for whatever streak the device holds: a gate device
    /// keeps the servings earlier runs poured, so the count is not known here.
    @MainActor
    private func assertTheChipSpeaksItsCountWithItsNoun(_ chip: XCUIElement) {
        let value = chip.value as? String ?? ""
        let count = Int(value.split(separator: " ").first?.filter(\.isNumber) ?? "") ?? 0
        XCTAssertGreaterThan(count, 0, "the chip's value carries no count: \"\(value)\"")
        XCTAssertEqual(value, "\(count.formatted(.number)) \(count == 1 ? "day" : "days")",
                       "the chip does not speak its count with its noun")
    }

    /// At the largest text size the chip may draw its count alone beside the title; it still speaks
    /// the noun, and is still one element (rule `65-accessibility`).
    @MainActor
    func testTheChipSpeaksItsNounAtTheLargestTextSize() throws {
        launchedOnHome().terminate()

        let app = XCUIApplication()
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5), "the app did not open on Home")

        let reached = app.staticTexts["Goal reached"]
        let bottle = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Bottle,")).firstMatch
        var pours = 0
        while !reached.exists && pours < 20 {
            bottle.tap()
            pours += 1
            _ = reached.waitForExistence(timeout: 1)
        }
        XCTAssertTrue(reached.exists, "the goal was not reached after \(pours) Bottles")

        let chip = app.descendants(matching: .any).matching(identifier: "Day streak").firstMatch
        XCTAssertTrue(chip.waitForExistence(timeout: 5), "a day that reached its goal shows no streak")
        XCTAssertEqual(app.descendants(matching: .any).matching(identifier: "Day streak").count, 1,
                       "the streak must resolve to exactly one element")
        assertTheChipSpeaksItsCountWithItsNoun(chip)
    }
```

- [ ] **Step 2: Run both and verify red.**

```bash
uptime
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' -only-testing:WaterBuddyUITests/GoalSetupUITests/testTheTitleKeepsItsSizeBesideTheStreak -only-testing:WaterBuddyUITests/GoalSetupUITests/testTheChipSpeaksItsNounAtTheLargestTextSize -parallel-testing-enabled NO -collect-test-diagnostics never
```

  Expected: both fail on the value — it reads a bare number — and on nothing else.

- [ ] **Step 3: Implement.** Replace `streakChip` and its DocC (`HomeView.swift:368`–`410`) with:

```swift
    /// A flame, a count and its noun: the days in a row the goal was reached — *12 days*. Absent at
    /// zero.
    ///
    /// **The noun yields before the title does.** It shares a line with *Today* — *Сегодня* — and the
    /// title has the line first (``ScreenHeader``). Where the whole chip does not fit beside it, the
    /// chip draws the count alone rather than *12 д…*; it speaks the noun at every size
    /// (spec 2026-10-16 §3.4, rule `65-accessibility`).
    ///
    /// `.frosted` like the discs, and `.resting` where they are `.raised`: it is a label, and
    /// sitting lower is what keeps it from reading as something to press.
    @ViewBuilder
    private var streakChip: some View {
        if manager.streak > 0 {
            // Each candidate at its own width, so the fit is decided on the whole chip.
            ViewThatFits(in: .horizontal) {
                streakCapsule(Text(streakDays))
                streakCapsule(Text(manager.streak, format: .number))
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Day streak", bundle: strings))
            .accessibilityValue(Text(streakDays))
            // The first day of a streak: the chip arrives small and lands at its size.
            .transition(.scale(scale: 0.8).combined(with: .opacity))
        }
    }

    /// *12 days*, *12 дней*, *12 kun*.
    private var streakDays: String {
        strings.localized("%1$d days", manager.streak, locale: locale)
    }

    private func streakCapsule(_ count: Text) -> some View {
        HStack(spacing: 6) {
            Image(systemName: Self.streakSymbol)
                .foregroundStyle(Aurora.cyan)
                // Once, when the count goes up. The first day of a streak is the chip itself
                // arriving, and plays no bounce.
                .symbolEffect(.bounce, value: streakRises)
            count
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(manager.streak)))
        }
        .font(.subheadline.weight(.bold))
        .fontDesign(.rounded)
        .foregroundStyle(.white)
        .lineLimit(1)
        .padding(.leading, 10)
        .padding(.trailing, 14)
        // Nothing at the ordinary sizes, where the 36 pt floor is taller than the line and
        // this together. At the accessibility sizes the line is the taller, and without it
        // the flame stood past the capsule's edge.
        .padding(.vertical, 6)
        .frame(minHeight: 36)
        .liquidGlass(in: Capsule(), density: .frosted, elevation: .resting)
        .fixedSize()
    }
```

- [ ] **Step 4: Run both green, and the header's other tests.**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' -only-testing:WaterBuddyUITests/GoalSetupUITests/testTheTitleKeepsItsSizeBesideTheStreak -only-testing:WaterBuddyUITests/GoalSetupUITests/testTheChipSpeaksItsNounAtTheLargestTextSize -only-testing:WaterBuddyUITests/GoalSetupUITests/testTheTitleHoldsItsPlaceOnEveryTab -only-testing:WaterBuddyUITests/GoalSetupUITests/testTheTitleHoldsItsPlaceWhereItsAccessoryIsTaller -only-testing:WaterBuddyUITests/GoalSetupUITests/testHomeIsHeadedTodayOnce -parallel-testing-enabled NO -collect-test-diagnostics never
```

  Expected: `Executed 5 tests, with 0 failures` — never report a run that executed fewer tests than it
  named.

- [ ] **Step 5: Stage.**

```bash
git add WaterBuddy/HomeView.swift WaterBuddyUITests/GoalSetupUITests.swift
```

---

### Task 7: The strip's count

**Files:**
- Modify: `WaterBuddy/HistoryView.swift` (`DayStrip`, 1031–1112)
- Test: `WaterBuddyUITests/GoalSetupUITests.swift` (`testTheStripIsOneHeadingOverADaysServings`, 505;
  one new test)

**Interfaces:**
- Consumes: `Bundle.localized(_:_:locale:)`, the key `%1$d servings` (Task 2).

- [ ] **Step 1: Write the failing tests.** At the end of `testTheStripIsOneHeadingOverADaysServings`:

```swift
        assertTheStripHeadingSpeaksItsCount(in: app)
```

  And beside it:

```swift
    /// The strip's heading carries the day's count of servings as its value, with the noun in that
    /// count's form, and the drawn count is not a second element (spec 2026-10-16 §3.5).
    @MainActor
    private func assertTheStripHeadingSpeaksItsCount(in app: XCUIApplication) {
        let heading = app.descendants(matching: .any).matching(identifier: "When you drank").firstMatch
        let value = heading.value as? String ?? ""
        let count = Int(value.split(separator: " ").first?.filter(\.isNumber) ?? "") ?? 0
        XCTAssertGreaterThan(count, 0, "the strip's heading carries no count: \"\(value)\"")
        XCTAssertEqual(value, "\(count.formatted(.number)) \(count == 1 ? "serving" : "servings")",
                       "the strip's heading does not speak its count with its noun")
        XCTAssertFalse(app.staticTexts[value].exists, "the drawn count is a second element")
    }

    /// At the largest text size the count may move under the heading; the heading is still one
    /// element, and still speaks it (rule `65-accessibility`).
    @MainActor
    func testTheStripSpeaksItsCountAtTheLargestTextSize() throws {
        let setup = launchedOnHome()
        setup.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass,")).firstMatch.tap()
        setup.terminate()

        let app = XCUIApplication()
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5), "the app did not open on Home")

        app.buttons["History"].tap()
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 5))
        // At this size the header and the week card fill the screen, and a lazy list builds only what
        // is on it.
        let heading = app.descendants(matching: .any).matching(identifier: "When you drank").firstMatch
        var swipes = 0
        while !heading.exists && swipes < 3 {
            app.swipeUp()
            swipes += 1
        }
        XCTAssertTrue(heading.waitForExistence(timeout: 5), "a day with a serving draws no strip")
        XCTAssertEqual(app.descendants(matching: .any).matching(identifier: "When you drank").count, 1,
                       "the strip's heading must resolve to exactly one element")
        assertTheStripHeadingSpeaksItsCount(in: app)
    }
```

- [ ] **Step 2: Run both and verify red.**

```bash
uptime
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' -only-testing:WaterBuddyUITests/GoalSetupUITests/testTheStripIsOneHeadingOverADaysServings -only-testing:WaterBuddyUITests/GoalSetupUITests/testTheStripSpeaksItsCountAtTheLargestTextSize -parallel-testing-enabled NO -collect-test-diagnostics never
```

  Expected: both fail on the heading's value, which is empty.

- [ ] **Step 3: Implement.** In `DayStrip`, add under `@Environment(\.strings)`:

```swift
    @Environment(\.locale) private var locale
```

  The struct's DocC paragraph *"VoiceOver hears the title, as a heading, and nothing else."*
  becomes:

```swift
/// **VoiceOver hears the title, as a heading, with the count of servings as its value, and nothing
/// else.** The bars repeat the rows under this card, each of which speaks its own amount and time;
/// the reminder's mark repeats Home's line; the drawn count repeats the heading's value
/// (rule `65-accessibility`).
```

  In `body`, the heading's `Text` (`HistoryView.swift:1095`–`1101`) becomes `heading`, and these join
  the struct:

```swift
    /// *When you drank*, and how many times. The count trails the heading, and moves under it where the
    /// two do not fit on one line at the text size in use (spec 2026-10-16 §3.5).
    private var heading: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                title
                    .fixedSize()
                Spacer(minLength: 0)
                count
                    .fixedSize()
            }
            VStack(alignment: .leading, spacing: 4) {
                title
                count
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var title: some View {
        Text("When you drank", bundle: strings)
            .font(.callout.weight(.semibold))
            // Two lines before a word is cut, as the week card's title has.
            .lineLimit(2)
            .minimumScaleFactor(0.7)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityValue(servings)
            .accessibilityAddTraits(.isHeader)
    }

    /// In the week card's label style, white at 0.9 on this pane — the pair the strip's hour labels
    /// measure (`docs/DESIGN.md`, *Strip: hour label*). Hidden: the heading speaks it.
    private var count: some View {
        Text(servings)
            .font(.footnote.weight(.medium))
            .foregroundStyle(.white.opacity(0.9))
            .accessibilityHidden(true)
    }

    /// *5 servings*, *5 порций*, *5 porsiya*. The rows the bars are drawn from; the card is drawn
    /// only for a day that has one (`HistoryView`'s `if shownLogs.isEmpty`), so never *0*.
    private var servings: String {
        strings.localized("%1$d servings", logs.count, locale: locale)
    }
```

- [ ] **Step 4: Run both green, and History's other strip and heading tests.**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' -only-testing:WaterBuddyUITests/GoalSetupUITests/testTheStripIsOneHeadingOverADaysServings -only-testing:WaterBuddyUITests/GoalSetupUITests/testTheStripSpeaksItsCountAtTheLargestTextSize -parallel-testing-enabled NO -collect-test-diagnostics never
```

  Expected: `Executed 2 tests, with 0 failures`.

- [ ] **Step 5: Stage.**

```bash
git add WaterBuddy/HistoryView.swift WaterBuddyUITests/GoalSetupUITests.swift
```

---

### Task 8: Verification

- [ ] **Step 1: The gate, on the staged tree.** Copy the index out and run rule `85-testing`'s five
  invocations against the copy, so what is gated is what the owner will commit:

  `G` is a new directory named for the time, e.g. `G="$S/gate-1530"`; every command below names the
  copy's project by path rather than changing directory:

```bash
git checkout-index -a --prefix="$G/"
uptime
xcodebuild test -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests -parallel-testing-enabled NO -derivedDataPath "$G-dd"
```

  The UI class in chunks of ten by name on *WaterBuddy Gate 27*, then the other classes; then all of
  it again on *WaterBuddy Gate 26.5*. `GoalSetupUITests` holds 38 tests after Tasks 6 and 7. The list
  goes to the scratchpad, never into the tree:

```bash
grep -oE 'func test[A-Za-z0-9]+' "$G/WaterBuddyUITests/GoalSetupUITests.swift" | sed 's/func //' | sort > "$S/goalsetup-tests.txt"
FLAGS=$(sed -n '1,10p' "$S/goalsetup-tests.txt" | sed 's|^|-only-testing:WaterBuddyUITests/GoalSetupUITests/|' | tr '\n' ' ')
xcodebuild test -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' ${=FLAGS} -parallel-testing-enabled NO -collect-test-diagnostics never -derivedDataPath "$G-dd"
```

  — `${=FLAGS}`, because zsh does not split an unquoted variable, and `$FLAGS` runs nothing and still
  says `TEST SUCCEEDED`. Then lines 11–20, 21–30 and 31–38, one call each, then:

```bash
xcodebuild test -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' -only-testing:WaterBuddyUITests -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests -skip-testing:WaterBuddyUITests/GoalSetupUITests -parallel-testing-enabled NO -collect-test-diagnostics never -derivedDataPath "$G-dd"
```

  — and the same five calls with `OS=26.5,name=WaterBuddy Gate 26.5`. Then:

```bash
xcodebuild test -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddyWatch -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO -derivedDataPath "$G-dd"
xcodebuild build -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddyWidgetExtension -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -derivedDataPath "$G-dd"
xcodebuild build -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddyWatchWidget -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' -derivedDataPath "$G-dd"
```

  Expected: unit `✔ Test run with 621 tests` (re-derive with the attribute grep); `GoalSetupUITests`
  38 executed, 1 skipped by design (`testTheBarsCaptionsShareALine`), 0 failures, on each system; the
  other classes `Executed 31 tests, with 0 failures`; watch `✔ Test run with 57 tests in 6 suites
  passed`; both builds `** BUILD SUCCEEDED **`. Read each run's executed count. Do not start a UI run
  that would cross midnight.

- [ ] **Step 2: Warnings.** A clean `build-for-testing` of the `WaterBuddy` scheme, then a widget
  `build` into the same folder, for HEAD and for the index, each into an empty folder; compare the
  unique lines by file and message; then the two watch schemes the same way:

  `H` is another new directory named for the time, e.g. `H="$S/head-1600"`; the copy's own path is
  taken off each warning, and its line and column, so the two lists compare by file and message:

```bash
mkdir -p "$H" && git archive HEAD | tar -x -C "$H"
xcodebuild build-for-testing -project "$H/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -derivedDataPath "$H-clean" 2>&1 | grep -E 'warning:' | sed -E "s|$H/||; s/:[0-9]+:[0-9]+:/:/" | sort -u > "$S/head-warnings.txt"
xcodebuild build-for-testing -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -derivedDataPath "$G-clean" 2>&1 | grep -E 'warning:' | sed -E "s|$G/||; s/:[0-9]+:[0-9]+:/:/" | sort -u > "$S/index-warnings.txt"
comm -13 "$S/head-warnings.txt" "$S/index-warnings.txt"
```

  Then the widget `build` into the same two folders, and the two watch schemes into two more, each
  list compared the same way. Expected: `comm -13` prints nothing, and the app's list holds the 29
  unique lines `CLAUDE.md` names. A new line is a failure, fixed before Step 3.

- [ ] **Step 3: Renders** (spec §7.3), on *WaterBuddy Probe 27*, *WaterBuddy Probe 26.5* and
  *WaterBuddy Small 26.5* — never a Gate device — by a throwaway XCUITest probe that adds
  `XCTAttachment(screenshot:)` shots, run with `-resultBundlePath` and exported with
  `xcrun xcresulttool export attachments`, deleted before staging (the method of
  `docs/AI_CONTEXT.md`'s earlier renders). The streaks of 1, 2, 5 and 21 days come from a scratch copy
  (`git checkout-index -a --prefix="$S/look/"`) whose `WaterBuddyApp.freshStartManager` seeds that many
  goal days, built with its own `-derivedDataPath` and launched with `-WaterBuddyFreshStart` — nothing
  in the repository is written. In English, Russian and Uzbek:
  - Home's chip at a streak of 1, 2, 5 and 21, at the default size and at
    `UICTContentSizeCategoryAccessibilityXXXL`, on *Small 26.5* and *Probe 27* — the noun drawn where
    it fits, the count alone where it does not, never cut; the title the size it was;
  - History's strip with 1, 2 and 5 servings at the same sizes — the count beside the heading, or
    under it, never cut;
  - the Home Screen widget, small and medium, light, dark and tinted, at a total of 1,300 and of
    12,500 (Review Focus 3); the Lock Screen widget's three shapes, with *Allow Access When Locked →
    Lock Screen Widgets* on and off (Review Focus 4); the watch app's serving rows with a vessel of
    1,000 or more;
  - with Home and History drawn, the language switched to Русский in Settings: the chip, the status
    line and the strip redraw in Russian without a relaunch (Review Focus 5).

  Put the app's language back to its earlier value and the Home Screen as it was, and say so.

- [ ] **Step 4: The count's contrast.** Measure the strip count's composite off the render — the
  method of `docs/DESIGN.md`'s *Strip: hour label* row, the same white 0.9 on `.frosted` + `.raised`
  — and record it in `docs/DESIGN.md` beside that row, with the device, system and date. It must hold
  4.5:1 (rule `65-accessibility`). A figure below is a stop, not a retune.

---

### Task 9: Records, and staging for the owner

- [ ] **Step 1:** `HISTORY.md` checkpoint (`## [YYYY-MM-DD] — Roadmap item 1.2.6: Russian plural
  forms`), with the gate as run, the warnings comparison, the renders and the contrast figure.
- [ ] **Step 2:** `docs/AI_CONTEXT.md`: a *Current state* block; known issues **#40 and #39 closed**,
  each with a dated note naming what fixed it, only once the fix is on disk and gated (rule
  `99-docs-cascade`); the file rows of every Swift file changed, re-counted with `wc -l`; the test
  counts.
- [ ] **Step 2b:** What only a device shows (spec §7.4) joins roadmap item 1.2.7's sweep in
  `docs/ROADMAP.md`: VoiceOver
  reading a grouped figure — *2 000* in Russian and Uzbek — as one number, and the chip and the strip
  in Russian on the owner's iPhone.
- [ ] **Step 3:** `docs/STATE.md`'s language section (*Only sites that format against the locale
  honour this* — it lists both widgets and the watch's rows as ungrouped, and says spoken strings keep
  `%d`); `docs/WIDGET.md`'s formats paragraph and its strings table; `docs/ROADMAP.md` 1.2.6 and §8.
  `CLAUDE.md` is read for anything the change made false.
- [ ] **Step 4:** Stage every file by name, the rule wording with them once the owner approved it:

```bash
git add .claude/rules/50-views.md .claude/rules/65-accessibility.md .claude/rules/70-privacy.md HISTORY.md docs/AI_CONTEXT.md docs/ROADMAP.md docs/STATE.md docs/WIDGET.md docs/DESIGN.md docs/superpowers/plans/2026-10-17-plural-forms.md
git diff --cached --name-status
git diff --name-status
```

- [ ] **Step 5:** Two fresh read-only readers on the records before the closing report; save their
  reports; then `/doc_sync` is the owner's. Stop — the owner runs `/commit`.
