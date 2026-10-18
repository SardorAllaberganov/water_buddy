# Today's Water Implementation Plan

> **For the session that runs it:** executed in the main loop, task by task, tests first — `CLAUDE.md`
> has no implementation subagent. Steps use checkboxes (`- [ ]`). **Nothing is committed**: each task
> ends with its files staged by name, and the owner runs `/commit` (rule `90-git`).

**Goal:** "How much water today in WaterBuddy" — Siri answers with today's total and what is left,
after authentication on a locked iPhone, and the same action is a *Today's Water* tile in Spotlight
and the Shortcuts app.

**Architecture:** one new app-only `AppIntent`, `TodaysWaterIntent`, whose `perform()` reads the
widget's own `DataManager.snapshot()` and hands it to a pure `nonisolated static answer(for:)` that
picks one of three catalogue keys. The resource travels unresolved, so Siri chooses the language, the
plural form and the grouping. `WaterSnapshot` gains `remaining` and `hasReachedGoal`;
`WaterBuddyShortcuts` gains a second `AppShortcut`. No key, no write, no new entitlement.

**Tech Stack:** Swift 5 mode, AppIntents, String Catalogs (`.xcstrings` → `.strings` +
`.stringsdict`), swift-testing, Xcode 27.0.

**Spec:** `docs/superpowers/specs/2026-10-18-todays-water-design.md` — approved by the owner on
2026-10-18. §3.3 holds every string; §7 the tests; §8 the verification. Read it with this plan.

*(2026-10-18, after the run: the code below is the plan as written, and the run departed from it in
three places, each in `HISTORY.md`'s checkpoint. Task 1's two properties needed `nonisolated` — the
GREEN build of Task 2 warned without it (#147). Task 4's warning script needed its path strip to
match `/tmp/…` as `xcodebuild` prints it. After the final review, `TodaysWaterSnapshotTests` became
`async` with its reads in locals, the one shape seen to warn when the keyword is removed; the
`TodaysWaterAnswerTests` DocC says it is not a proven canary. Before Task 2's strings the open Xcode
rewrote the catalogues again, and the owner closed the project and chose to restore them.)*

**What was checked in writing it** (2026-10-18, HEAD `88d694f`): every type, member, key and test name
below was read from the tree; the catalogues' neighbours were found by a sorted search, and both
catalogues round-trip byte-identically through `json.dumps(…, ensure_ascii=False, indent=2)` with their
keys in code-point order. Three throwaway `swiftc` probes on macOS (scratchpad only): a
`LocalizedStringResource` with an **explicit key** and its figures in `defaultValue` resolved, from a
catalogue compiled by `xcrun xcstringstool compile`, to *1,450 millilitres so far today — 1,050
millilitres to go.* in `en`; *Сегодня уже 21 миллилитр — осталось 2 миллилитра.* and *Сегодня уже 5
миллилитров — осталось 22 миллилитра.* in `ru`; the grouping separator in `ru` and `uz` is U+00A0;
`de` gave English words with *1.450*; `ja` gave *1 millilitres*. The `Testing` code was not compiled.

## Global Constraints

- Deployment floors stay `IPHONEOS_DEPLOYMENT_TARGET = 17.0` and `WATCHOS_DEPLOYMENT_TARGET = 26.0`;
  no `#available` is added (rule `15-project`).
- Zero dependencies; `project.pbxproj` does not change; no file joins an exception set — the intent is
  app-only, the two properties go in `DataManager.swift` (rule `15-project`, rule `40-widget`).
- `TodaysWaterIntent.answer(for:)` is `nonisolated static`; `TodaysWaterAnswerTests` is not
  `@MainActor` and must compile without it (rule `43-concurrency`).
- `authenticationPolicy` is `.requiresAuthentication`; `openAppWhenRun` is `false` (spec §3.2).
- The answer carries today's total and what is left — never the goal alone, the percentage or the
  streak (spec §1, rule `20-state`).
- Every key is positional (`%1$lld`, `%2$lld`) and carries plural variations in `en` and `ru`; `uz`
  keeps one value; every new key in the app's catalogue has `"extractionState": "manual"`, as its
  siblings do (rule `70-privacy`).
- Phrases in `WaterBuddy/AppShortcuts.xcstrings`, `en` and `ru` only, each naming
  `${applicationName}` (rule `70-privacy`).
- Never weaken an assertion; a test that disagrees with the code is a stop (rule `85-testing`).
- No new warning against a clean baseline of HEAD, compared per file and message (`CLAUDE.md`: 29
  unique lines on Xcode 27.0).
- The tree is edited with Edit and Write only — no `sed -i`, no heredoc or script writing into it
  (`tasks/lessons.md`). Scripts may *read* the tree and write into the scratchpad.
- `xcodebuild` in the foreground, one simulator, `-parallel-testing-enabled NO`; never
  `xcrun simctl shutdown all` — another project's simulators run on this Mac; shut down by UDID. Run
  `uptime` before a UI run, and put `-collect-test-diagnostics never` on every UI run. Every run whose
  figure goes into a doc writes its own log, named by time (`tasks/lessons.md`, 2026-10-18).
- Devices: unit tests on the stock iOS 27.0 *iPhone 17*; UI tests on *WaterBuddy Gate 27* and
  *WaterBuddy Gate 26.5*; watch tests on *WaterBuddy Watch 27*; the Shortcuts probe on *WaterBuddy
  Probe 27* — never a Gate device.

## Review Focus

The five inputs the spec implies and its section on tests does not name, most likely first, each
pinned in the task that owns it:

1. **Asked after midnight, the app not run since.** The cached total is yesterday's; the snapshot must
   zero it in memory and the answer must be *Nothing logged yet today — 2,000 millilitres to go.*
   Pinned by `aQuestionAfterMidnightHearsANewDay` in Task 2, through a real throwaway suite and
   `DataManager.snapshot(defaults:calendar:now:)`.
2. **A total at the cap.** `maximumDailyIntake` is 100,000: six digits, grouped — *100,000* in English,
   *100 000* in Russian. Pinned by `aTotalAtTheCapIsGrouped` in Task 2.
3. **Siri in a language the app does not ship.** The table falls back to English and the figures take
   that locale's grouping: German gives *1,450* as *1.450*. Pinned by
   `aLanguageTheAppDoesNotShipHearsEnglishWithItsOwnFigures` in Task 2. *Japanese, with one plural
   form, gives "1 millilitres"* (probe); that is recorded as a limitation in Task 5, not pinned — it
   is Foundation's fallback, and the fix is shipping the language.
4. **The smallest figures.** A goal of 1 ml, a first serving of 1 ml, 21 ml in Russian — *millilitre*,
   *миллилитр*, *остался*. Pinned by `theNounsTakeTheirPluralForms` in Task 2.
5. **Nothing logged and the goal already met cannot both hold.** `dailyGoal` is clamped to `1...`, so
   a zero total is never a met goal; the answer tests zero before met. Pinned by
   `nothingLoggedSaysWhatIsLeftOfTheWholeGoal` in Task 2 at a goal of 1.

## Preconditions — before any code

- [ ] **The owner has approved §5's rule wording**, typed unstaged on 2026-10-18 into
  `.claude/rules/70-privacy.md`, `15-project.md`, `20-state.md`, `43-concurrency.md` and
  `85-testing.md`. If the owner changed it, re-read the five files before Task 1.
- [ ] **D1 holds.** This must print nothing:

```bash
git diff --stat -- WaterBuddy/AppShortcuts.xcstrings WaterBuddy/Localizable.xcstrings WaterBuddyWatch/Localizable.xcstrings WaterBuddyWatchWidget/Localizable.xcstrings
```

  If it prints anything, Xcode has rewritten a catalogue again (#50): stop and ask the owner.
- [ ] Read the DocC on `LogServingIntent` (`WaterBuddy/LogServingIntent.swift:10`–`24`),
  `WaterBuddyShortcuts` (`WaterBuddy/WaterBuddyShortcuts.swift:10`–`19`), `WaterSnapshot`
  (`WaterBuddy/DataManager.swift:2331`–`2385`) and `DataManager.snapshot(defaults:calendar:now:)`
  (`DataManager.swift:2873`–`2917`) — rule `00-workspace`.

## Files

| File | Change | Task |
|---|---|---|
| `WaterBuddy/DataManager.swift` | `WaterSnapshot.remaining`, `WaterSnapshot.hasReachedGoal` | 1 |
| `WaterBuddyTests/TodaysWaterTests.swift` | new: three suites | 1, 2, 3 |
| `WaterBuddy/TodaysWaterIntent.swift` | new: the intent | 2 |
| `WaterBuddy/Localizable.xcstrings` | five keys | 2 |
| `WaterBuddyTests/LocalizationTests.swift` | three keys join `countedKeys` and `expected` | 2 |
| `WaterBuddy/WaterBuddyShortcuts.swift` | a second `AppShortcut`; DocC | 3 |
| `WaterBuddy/AppShortcuts.xcstrings` | three phrases, `en` + `ru` | 3 |
| `WaterBuddyTests/SiriPhraseTests.swift` | six phrases per table, not three | 3 |
| `HISTORY.md`, `docs/AI_CONTEXT.md`, `docs/ROADMAP.md`, `docs/WIDGET.md`, `tasks/lessons.md` | records | 5 |

`S` is the session's scratchpad directory, as the environment names it. A shell's variables do not
carry from one call to the next, so every block that uses it sets it first (`S=<that directory>`).

The unit runs below all use this form, changing only the `-only-testing:` list:

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/<Suite> -parallel-testing-enabled NO 2>&1 | tee "$S/<name>-$(date +%H%M%S).log" | grep -E '✔|✘|error:|Test run with|TEST (SUCCEEDED|FAILED)'
```

---

### Task 1: The snapshot says what is left and whether the goal is met

**Files:**
- Create: `WaterBuddyTests/TodaysWaterTests.swift`
- Modify: `WaterBuddy/DataManager.swift` — after `WaterSnapshot.percentage` (`:2381`–`2384`)

**Interfaces:**
- Produces: `WaterSnapshot.remaining: Int` — `max(0, dailyGoal - currentWater)`;
  `WaterSnapshot.hasReachedGoal: Bool` — `currentWater >= dailyGoal`. Both computed, both read
  without the main actor.

- [ ] **Step 1: The seams — present, wrong.** In `DataManager.swift`, after `percentage`'s closing
  brace:

```swift
    var remaining: Int {
        0
    }

    var hasReachedGoal: Bool {
        false
    }
```

- [ ] **Step 2: Write the failing tests.** Create `WaterBuddyTests/TodaysWaterTests.swift`:

```swift
//
//  TodaysWaterTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 18/10/26.
//

import AppIntents
import Foundation
import SwiftData
import Testing
@testable import WaterBuddy

// MARK: - Fixtures

private func gregorian(in timeZone: String) -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: timeZone)!
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar
}

private let utcDay = gregorian(in: "UTC")

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

/// Every test gets its own suite, named once: `UserDefaults` caches domains in-process and `@Test`
/// functions run in parallel (rule `85-testing`).
private func withTempDefaults<T>(_ body: (UserDefaults) throws -> T) rethrows -> T {
    let name = "test.waterbuddy.todayswater.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    return try body(defaults)
}

/// A clock a test can move between mutations.
private final class MovableClock: @unchecked Sendable {
    var now: Date
    init(_ now: Date) { self.now = now }
}

// MARK: - What the snapshot says is left

/// ``WaterSnapshot/remaining`` and ``WaterSnapshot/hasReachedGoal`` — the arithmetic Siri's answer
/// reads (spec 2026-10-18-todays-water §3.5).
///
/// Not `@MainActor`, like `WaterSnapshotTests`: Siri's answer is built off the main actor, and so is
/// the widget's read; if either property ever needed it, this suite would stop compiling.
struct TodaysWaterSnapshotTests {

    @Test(arguments: [
        (water: 0, goal: 2_500, left: 2_500, met: false),
        (water: 1_450, goal: 2_500, left: 1_050, met: false),
        (water: 2_500, goal: 2_500, left: 0, met: true),
        (water: 2_600, goal: 2_500, left: 0, met: true),
    ])
    func theSnapshotSaysWhatIsLeftAndWhetherTheGoalIsMet(
        water: Int, goal: Int, left: Int, met: Bool
    ) {
        let snapshot = WaterSnapshot(currentWater: water, dailyGoal: goal)
        #expect(snapshot.remaining == left)
        #expect(snapshot.hasReachedGoal == met)
    }
}

// MARK: - The snapshot and the manager agree

/// The snapshot's two properties are twins of ``DataManager/remaining`` and
/// ``DataManager/hasReachedGoal``, as `progress` and `percentage` are; this keeps the pairs in step
/// (rule `20-state`, as amended).
@MainActor
struct TodaysWaterAgreementTests {

    @Test func theSnapshotAgreesWithTheManager() throws {
        try withTempDefaults { defaults in
            let clock = MovableClock(utc(2026, 10, 18, 9))
            let container = try ModelContainer(
                for: WaterLog.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            let manager = DataManager(
                defaults: defaults,
                modelContainer: container,
                calendar: utcDay,
                now: { clock.now },
                reloadWidgets: {},
                rescheduleReminders: { _ in },
                publishWrist: { _ in }
            )
            manager.saveDailyGoal(ml: 2_000)

            let agree = {
                let snapshot = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: clock.now)
                #expect(snapshot.currentWater == manager.currentWater)
                #expect(snapshot.remaining == manager.remaining)
                #expect(snapshot.hasReachedGoal == manager.hasReachedGoal)
            }

            agree()                                   // nothing logged
            _ = manager.addLog(amount: 1_500)
            agree()                                   // under the goal
            _ = manager.addLog(amount: 500)
            agree()                                   // exactly at it
            _ = manager.addLog(amount: 300)
            agree()                                   // over it
        }
    }
}
```

- [ ] **Step 3: Run RED.** Run `TodaysWaterSnapshotTests` and `TodaysWaterAgreementTests`
  (`-only-testing:WaterBuddyTests/TodaysWaterSnapshotTests -only-testing:WaterBuddyTests/TodaysWaterAgreementTests`).
  Expected: both suites fail **on their expectations** — `remaining == 2500` against `0`,
  `hasReachedGoal == true` against `false` — not on a build error. A build error is not RED: fix the
  test's compile, never the assertion.

- [ ] **Step 4: Implement.** Replace the two seams with:

```swift
    /// Millilitres still to drink today — zero once the goal is met, never negative.
    ///
    /// The snapshot's twin of ``DataManager/remaining``, for Siri's answer, which reads what the widget
    /// draws rather than the app's observable state (spec 2026-10-18-todays-water §3.5).
    /// `theSnapshotAgreesWithTheManager` keeps the two in step.
    var remaining: Int {
        max(0, dailyGoal - currentWater)
    }

    /// Whether today's water has reached the goal — the snapshot's twin of
    /// ``DataManager/hasReachedGoal``, held to it by the same test.
    var hasReachedGoal: Bool {
        currentWater >= dailyGoal
    }
```

- [ ] **Step 5: Run GREEN.** The same two suites. Expected: every test passes, the arguments run four
  times.

- [ ] **Step 6: Stage.**

```bash
git add WaterBuddy/DataManager.swift WaterBuddyTests/TodaysWaterTests.swift
```

---

### Task 2: The intent and its answer, in three languages

**Files:**
- Create: `WaterBuddy/TodaysWaterIntent.swift`
- Modify: `WaterBuddy/Localizable.xcstrings` — five keys
- Modify: `WaterBuddyTests/TodaysWaterTests.swift` — two suites appended
- Modify: `WaterBuddyTests/LocalizationTests.swift:814`–`828` (`countedKeys`) and `:857`–`921`
  (`expected`) — `everyCountedKeyTakesTheFormItsCountNeeds` reads "every counted key" at twelve counts
  (0 to 1,001), and the three new keys are counted keys

**Interfaces:**
- Consumes: `WaterSnapshot.remaining`, `WaterSnapshot.hasReachedGoal` (Task 1);
  `DataManager.snapshot(defaults:calendar:now:)`, `DataManager.dayOrdinal(for:in:)`,
  `DataManager.Key.currentWater`, `.dailyGoal`, `.lastActiveDay` (existing).
- Produces: `struct TodaysWaterIntent: AppIntent` with `static let title`, `description`,
  `openAppWhenRun`, `authenticationPolicy`, and
  `nonisolated static func answer(for snapshot: WaterSnapshot) -> LocalizedStringResource`.

- [ ] **Step 1: The seam — present, wrong.** Create `WaterBuddy/TodaysWaterIntent.swift`:

```swift
//
//  TodaysWaterIntent.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 18/10/26.
//

import AppIntents

struct TodaysWaterIntent: AppIntent {

    static let title: LocalizedStringResource = "Today's Water"

    static let description = IntentDescription(
        "Tells you how much water you've had today in WaterBuddy, and how much is left.",
        categoryName: "Hydration"
    )

    static let openAppWhenRun = false

    static let authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed

    nonisolated static func answer(for snapshot: WaterSnapshot) -> LocalizedStringResource {
        "Water logged."
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: IntentDialog(Self.answer(for: DataManager.snapshot())))
    }
}
```

- [ ] **Step 2: Write the failing tests.** Append to `WaterBuddyTests/TodaysWaterTests.swift`:

```swift
// MARK: - What Siri says

/// One language's `.lproj` inside the app, or `nil` if it did not ship.
private func lproj(_ language: String) -> Bundle? {
    Bundle.main.url(forResource: language, withExtension: "lproj").flatMap(Bundle.init(url:))
}

/// What no translation could be, so a missing key is told apart from one translated to itself.
private let missingKey = "\u{0}__missing__\u{0}"

/// A resource resolved as Siri resolves it: its own locale chooses the table, the plural form and
/// the grouping (spec 2026-10-18-todays-water §3.4).
private func said(_ resource: LocalizedStringResource, in language: String) -> String {
    var resource = resource
    resource.locale = Locale(identifier: language)
    return String(localized: resource)
}

/// Siri's answer for a total against a goal, in `language`.
private func answer(_ water: Int, of goal: Int, in language: String = "en") -> String {
    said(TodaysWaterIntent.answer(for: WaterSnapshot(currentWater: water, dailyGoal: goal)), in: language)
}

/// Russian and Uzbek group with a no-break space (U+00A0, measured by the plan's probe).
private let nbsp = "\u{00A0}"

/// ``TodaysWaterIntent/answer(for:)`` — the whole of what Siri says, a pure function of the snapshot,
/// resolved in each shipped language (spec §3.2, §3.3).
///
/// Not `@MainActor`: the answer is built in a `nonisolated static`, and this suite is the canary that
/// it stays so (rule `43-concurrency`, as amended).
struct TodaysWaterAnswerTests {

    /// Every line, the title and the description are in every shipped language's table — proven
    /// before any resolved line is read, so a missing table cannot pass as English.
    @Test func everyLineIsTranslatedInEveryLanguage() throws {
        let keys = [
            "%1$lld millilitres so far today — %2$lld millilitres to go.",
            "%1$lld millilitres so far today — you've reached your goal.",
            "Nothing logged yet today — %1$lld millilitres to go.",
            "Today's Water",
            "Tells you how much water you've had today in WaterBuddy, and how much is left.",
        ]
        for language in ["en", "ru", "uz"] {
            let bundle = try #require(lproj(language), "the app ships no \(language) localization")
            for key in keys {
                let value = bundle.localizedString(forKey: key, value: missingKey, table: nil)
                #expect(value != missingKey, "\(language) has no translation of \(key)")
            }
        }
    }

    @Test func nothingLoggedSaysWhatIsLeftOfTheWholeGoal() {
        #expect(answer(0, of: 2_000) == "Nothing logged yet today — 2,000 millilitres to go.")
        #expect(answer(0, of: 1) == "Nothing logged yet today — 1 millilitre to go.")
    }

    @Test func underTheGoalSaysTheTotalAndWhatIsLeft() {
        #expect(answer(1_450, of: 2_500) == "1,450 millilitres so far today — 1,050 millilitres to go.")
    }

    @Test func atOrOverTheGoalSaysItIsReached() {
        #expect(answer(2_500, of: 2_500) == "2,500 millilitres so far today — you've reached your goal.")
        #expect(answer(2_600, of: 2_500) == "2,600 millilitres so far today — you've reached your goal.")
    }

    @Test func theAnswerReadsInRussian() {
        #expect(answer(0, of: 2_000, in: "ru") == "Сегодня ещё ничего не записано — осталось 2\(nbsp)000 миллилитров.")
        #expect(answer(1_450, of: 2_500, in: "ru") == "Сегодня уже 1\(nbsp)450 миллилитров — осталось 1\(nbsp)050 миллилитров.")
        #expect(answer(2_600, of: 2_500, in: "ru") == "Сегодня уже 2\(nbsp)600 миллилитров — цель достигнута.")
    }

    @Test func theAnswerReadsInUzbek() {
        #expect(answer(0, of: 2_000, in: "uz") == "Bugun hali hech narsa qayd etilmagan — 2\(nbsp)000 millilitr qoldi.")
        #expect(answer(1_450, of: 2_500, in: "uz") == "Bugun 1\(nbsp)450 millilitr — 1\(nbsp)050 millilitr qoldi.")
        #expect(answer(2_600, of: 2_500, in: "uz") == "Bugun 2\(nbsp)600 millilitr — maqsadga erishildi.")
    }

    /// English *one*/*other*; Russian *one*/*few*/*many*, and *остался* where the count takes *one*
    /// (1, 21), as the existing *… millilitres to go* key does. Review Focus 4.
    @Test func theNounsTakeTheirPluralForms() {
        #expect(answer(1, of: 2) == "1 millilitre so far today — 1 millilitre to go.")
        #expect(answer(1, of: 1) == "1 millilitre so far today — you've reached your goal.")
        #expect(answer(1, of: 2, in: "ru") == "Сегодня уже 1 миллилитр — остался 1 миллилитр.")
        #expect(answer(2, of: 7, in: "ru") == "Сегодня уже 2 миллилитра — осталось 5 миллилитров.")
        #expect(answer(21, of: 42, in: "ru") == "Сегодня уже 21 миллилитр — остался 21 миллилитр.")
        #expect(answer(22, of: 22, in: "ru") == "Сегодня уже 22 миллилитра — цель достигнута.")
        #expect(answer(0, of: 1, in: "ru") == "Сегодня ещё ничего не записано — остался 1 миллилитр.")
    }

    /// Review Focus 2: six digits, grouped.
    @Test func aTotalAtTheCapIsGrouped() {
        #expect(answer(100_000, of: 2_500) == "100,000 millilitres so far today — you've reached your goal.")
        #expect(answer(100_000, of: 2_500, in: "ru") == "Сегодня уже 100\(nbsp)000 миллилитров — цель достигнута.")
    }

    /// Review Focus 3: Siri in German finds no German table, so the words fall back to English, and
    /// the figures take German's grouping (the plan's probe).
    @Test func aLanguageTheAppDoesNotShipHearsEnglishWithItsOwnFigures() {
        #expect(answer(1_450, of: 2_500, in: "de") == "1.450 millilitres so far today — 1.050 millilitres to go.")
    }

    /// Review Focus 1: the cache still holds yesterday's total and the app has not run since midnight.
    /// The snapshot zeroes it in memory, so the answer is a new day's — and the suite is left as it
    /// was (rule `30-rollover`).
    @Test func aQuestionAfterMidnightHearsANewDay() {
        withTempDefaults { defaults in
            let yesterday = utc(2026, 10, 17, 20)
            defaults.set(1_450, forKey: DataManager.Key.currentWater)
            defaults.set(2_000, forKey: DataManager.Key.dailyGoal)
            defaults.set(DataManager.dayOrdinal(for: yesterday, in: utcDay), forKey: DataManager.Key.lastActiveDay)

            let snapshot = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 10, 18, 9))

            #expect(said(TodaysWaterIntent.answer(for: snapshot), in: "en")
                    == "Nothing logged yet today — 2,000 millilitres to go.")
            #expect(defaults.integer(forKey: DataManager.Key.currentWater) == 1_450)
        }
    }
}

// MARK: - The intent's contract

/// `TodaysWaterIntent`'s privacy contract (rule `70-privacy`, as amended): its answer carries figures,
/// so it waits for authentication; it never opens the app; its name is in every language.
/// `@MainActor`, as `LogServingIntentTests` is: it reads the intent's statics.
@MainActor
struct TodaysWaterIntentTests {

    @Test func theAnswerWaitsForAnUnlock() {
        #expect(TodaysWaterIntent.authenticationPolicy == .requiresAuthentication)
    }

    @Test func askingNeverOpensTheApp() {
        #expect(TodaysWaterIntent.openAppWhenRun == false)
    }

    @Test func theActionIsNamedInEveryLanguage() {
        #expect(said(TodaysWaterIntent.title, in: "en") == "Today's Water")
        #expect(said(TodaysWaterIntent.title, in: "ru") == "Вода за сегодня")
        #expect(said(TodaysWaterIntent.title, in: "uz") == "Bugungi suv")
    }
}
```

  In `LocalizationTests.swift`, the three answer keys join the registry — after
  `CountedKey(key: "%1$d servings", …)`:

```swift
    CountedKey(key: "%1$lld millilitres so far today — %2$lld millilitres to go.", arity: 2,
               counted: [0, 1], bundles: ["app"]),
    CountedKey(key: "%1$lld millilitres so far today — you've reached your goal.", arity: 1,
               counted: [0], bundles: ["app"]),
    CountedKey(key: "Nothing logged yet today — %1$lld millilitres to go.", arity: 1,
               counted: [0], bundles: ["app"]),
```

  — and their sentences join `expected`, before `default: return nil`:

```swift
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
```

  These go through `Bundle.localized(_:_:locale:)`, the app's own helper, not through
  `LocalizedStringResource`: they pin the catalogue's forms at every count; the answer tests above
  pin the path Siri takes.

- [ ] **Step 3: Run RED.** Run `TodaysWaterAnswerTests`, `TodaysWaterIntentTests` and `PluralFormTests`.
  Expected: every new test fails **on an expectation**, except `askingNeverOpensTheApp`, which the
  seam already satisfies — `openAppWhenRun` is final from the start; say so in the record rather than
  calling it red. `everyLineIsTranslatedInEveryLanguage` fails on the missing keys; the answers read
  *Water logged.*; the policy reads `.alwaysAllowed`; the title reads *Today's Water* in Russian;
  `everyCountedKeyTakesTheFormItsCountNeeds` fails on the three new keys only, and passes on the twelve
  it held before. If `TodaysWaterAnswerTests` fails to **compile** for isolation, that is the canary:
  fix the declaration, never the suite.

- [ ] **Step 4: The strings.** With Edit, add five entries to `WaterBuddy/Localizable.xcstrings`, in the
  file's own style (two-space indent, `"key": value`), at the positions the sorted search gave.

  **(a)** After the `"%1$d servings"` entry's closing `},` and before `"+%1$d ml"`, the two `%1$lld`
  keys, in this order:

```json
    "%1$lld millilitres so far today — %2$lld millilitres to go.": {
      "extractionState": "manual",
      "localizations": {
        "en": {
          "stringUnit": {
            "state": "translated",
            "value": "%#@arg1@ so far today — %#@arg2@ to go."
          },
          "substitutions": {
            "arg1": {
              "argNum": 1,
              "formatSpecifier": "lld",
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
            },
            "arg2": {
              "argNum": 2,
              "formatSpecifier": "lld",
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
            "value": "Сегодня уже %#@arg1@ — %#@arg2@."
          },
          "substitutions": {
            "arg1": {
              "argNum": 1,
              "formatSpecifier": "lld",
              "variations": {
                "plural": {
                  "few": {
                    "stringUnit": {
                      "state": "translated",
                      "value": "%arg миллилитра"
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
                      "value": "%arg миллилитр"
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
            },
            "arg2": {
              "argNum": 2,
              "formatSpecifier": "lld",
              "variations": {
                "plural": {
                  "few": {
                    "stringUnit": {
                      "state": "translated",
                      "value": "осталось %arg миллилитра"
                    }
                  },
                  "many": {
                    "stringUnit": {
                      "state": "translated",
                      "value": "осталось %arg миллилитров"
                    }
                  },
                  "one": {
                    "stringUnit": {
                      "state": "translated",
                      "value": "остался %arg миллилитр"
                    }
                  },
                  "other": {
                    "stringUnit": {
                      "state": "translated",
                      "value": "осталось %arg миллилитра"
                    }
                  }
                }
              }
            }
          }
        },
        "uz": {
          "stringUnit": {
            "state": "translated",
            "value": "Bugun %1$lld millilitr — %2$lld millilitr qoldi."
          }
        }
      }
    },
    "%1$lld millilitres so far today — you've reached your goal.": {
      "extractionState": "manual",
      "localizations": {
        "en": {
          "stringUnit": {
            "state": "translated",
            "value": "%#@arg1@ so far today — you've reached your goal."
          },
          "substitutions": {
            "arg1": {
              "argNum": 1,
              "formatSpecifier": "lld",
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
            "value": "Сегодня уже %#@arg1@ — цель достигнута."
          },
          "substitutions": {
            "arg1": {
              "argNum": 1,
              "formatSpecifier": "lld",
              "variations": {
                "plural": {
                  "few": {
                    "stringUnit": {
                      "state": "translated",
                      "value": "%arg миллилитра"
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
                      "value": "%arg миллилитр"
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
        "uz": {
          "stringUnit": {
            "state": "translated",
            "value": "Bugun %1$lld millilitr — maqsadga erishildi."
          }
        }
      }
    },
```

  **(b)** After the `"Nothing logged yet today"` entry and before `"Notifications are turned off …"`:

```json
    "Nothing logged yet today — %1$lld millilitres to go.": {
      "extractionState": "manual",
      "localizations": {
        "en": {
          "stringUnit": {
            "state": "translated",
            "value": "Nothing logged yet today — %#@arg1@ to go."
          },
          "substitutions": {
            "arg1": {
              "argNum": 1,
              "formatSpecifier": "lld",
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
            "value": "Сегодня ещё ничего не записано — %#@arg1@."
          },
          "substitutions": {
            "arg1": {
              "argNum": 1,
              "formatSpecifier": "lld",
              "variations": {
                "plural": {
                  "few": {
                    "stringUnit": {
                      "state": "translated",
                      "value": "осталось %arg миллилитра"
                    }
                  },
                  "many": {
                    "stringUnit": {
                      "state": "translated",
                      "value": "осталось %arg миллилитров"
                    }
                  },
                  "one": {
                    "stringUnit": {
                      "state": "translated",
                      "value": "остался %arg миллилитр"
                    }
                  },
                  "other": {
                    "stringUnit": {
                      "state": "translated",
                      "value": "осталось %arg миллилитра"
                    }
                  }
                }
              }
            }
          }
        },
        "uz": {
          "stringUnit": {
            "state": "translated",
            "value": "Bugun hali hech narsa qayd etilmagan — %1$lld millilitr qoldi."
          }
        }
      }
    },
```

  **(c)** After the `"Tap + to add a serving you forgot."` entry and before `"The Glass is the one …"`:

```json
    "Tells you how much water you've had today in WaterBuddy, and how much is left.": {
      "extractionState": "manual",
      "localizations": {
        "en": {
          "stringUnit": {
            "state": "translated",
            "value": "Tells you how much water you've had today in WaterBuddy, and how much is left."
          }
        },
        "ru": {
          "stringUnit": {
            "state": "translated",
            "value": "Сообщает, сколько воды вы выпили сегодня в WaterBuddy и сколько осталось."
          }
        },
        "uz": {
          "stringUnit": {
            "state": "translated",
            "value": "WaterBuddy’da bugun qancha suv ichganingizni va qancha qolganini aytadi."
          }
        }
      }
    },
```

  **(d)** After the `"Today"` entry and before `"Today's hydration"`:

```json
    "Today's Water": {
      "extractionState": "manual",
      "localizations": {
        "en": {
          "stringUnit": {
            "state": "translated",
            "value": "Today's Water"
          }
        },
        "ru": {
          "stringUnit": {
            "state": "translated",
            "value": "Вода за сегодня"
          }
        },
        "uz": {
          "stringUnit": {
            "state": "translated",
            "value": "Bugungi suv"
          }
        }
      }
    },
```

  Then check, reading only — it must print `True True 110`:

```bash
python3 -I -c "
import json; f='WaterBuddy/Localizable.xcstrings'; raw=open(f,encoding='utf-8').read(); d=json.loads(raw); ks=list(d['strings'])
print(json.dumps(d,ensure_ascii=False,indent=2)+'\n'==raw, ks==sorted(ks), len(ks))"
```

- [ ] **Step 5: The intent.** Replace `WaterBuddy/TodaysWaterIntent.swift`'s body with the finished
  intent:

```swift
//
//  TodaysWaterIntent.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 18/10/26.
//

import AppIntents

/// Tells the user how much water they have had today and how much is left — Siri's answer to "How
/// much water today in WaterBuddy", and a tile in Spotlight and the Shortcuts app.
///
/// **It reads what the widget draws.** ``perform()`` reads
/// ``DataManager/snapshot(defaults:calendar:now:)`` — the widget's own read, which writes no key and
/// applies the midnight rollover to its value only — so asking writes nothing, Siri and the Home
/// Screen cannot disagree, and an answer after midnight is the new day's even if the app has not run
/// since. Not ``DataManager/shared`` after `refresh()`: that re-plans reminders, and a question would
/// then have to hold the process open for them.
///
/// **What it says is the user's own figures, so only after authentication.** *Log a Glass* replies
/// with nothing; this answers with the total and what is left, so ``authenticationPolicy`` keeps it
/// from anyone the system has not authenticated (rule `70-privacy`). Never the streak (rule
/// `20-state`).
///
/// **App-only**, beside ``LogServingIntent``: a provider and its intents share a target (rule
/// `15-project`).
///
/// Design: `docs/superpowers/specs/2026-10-18-todays-water-design.md`.
struct TodaysWaterIntent: AppIntent {

    // `let`, not `var`, as on its siblings: a `static var` on a `Sendable` type is nonisolated
    // global mutable state.
    static let title: LocalizedStringResource = "Today's Water"

    static let description = IntentDescription(
        "Tells you how much water you've had today in WaterBuddy, and how much is left.",
        categoryName: "Hydration"
    )

    /// Answered where the user stands; opening the app would undo the point of asking by voice.
    static let openAppWhenRun = false

    /// The answer carries figures, so a locked iPhone asks for authentication first. Apple documents
    /// the stricter `.requiresLocalDeviceAuthentication` as unlocking the phone "even if the request
    /// originated from an already authenticated Apple Watch or remote device", so this one is inferred
    /// to accept those too; that one is for data unreadable while the phone is locked, and the answer
    /// reads none (spec §3.2). `theAnswerWaitsForAnUnlock` pins it.
    static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    /// Siri's whole answer, from what the widget draws: what is left of the whole goal before the
    /// first serving, the total once the goal is met, and otherwise the total and what is left.
    ///
    /// A pure function of the snapshot, so the part of this intent a test can run is the decision — no
    /// simulator here can run `perform()` (known issue #63). The line is not resolved here: the
    /// resource travels to Siri, which picks the language, the plural form and the grouping.
    ///
    /// Each key is written out rather than left to the interpolation, so the catalogue's key is
    /// positional and Russian can put its figures where its grammar wants them (rule `70-privacy`);
    /// the figures ride in the default value.
    nonisolated static func answer(for snapshot: WaterSnapshot) -> LocalizedStringResource {
        let water = snapshot.currentWater
        let left = snapshot.remaining
        if water == 0 {
            return LocalizedStringResource(
                "Nothing logged yet today — %1$lld millilitres to go.",
                defaultValue: "Nothing logged yet today — \(left) millilitres to go."
            )
        }
        if snapshot.hasReachedGoal {
            return LocalizedStringResource(
                "%1$lld millilitres so far today — you've reached your goal.",
                defaultValue: "\(water) millilitres so far today — you've reached your goal."
            )
        }
        return LocalizedStringResource(
            "%1$lld millilitres so far today — %2$lld millilitres to go.",
            defaultValue: "\(water) millilitres so far today — \(left) millilitres to go."
        )
    }

    /// `@MainActor`, as on both sibling intents, though nothing here needs it — ``answer(for:)`` and
    /// the snapshot are nonisolated — so the three conformances are spelled alike under the app
    /// target's default main-actor isolation. It awaits nothing: it writes nothing, publishes nothing
    /// and re-plans no reminder, so there is nothing to hold the process open for.
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: IntentDialog(Self.answer(for: DataManager.snapshot())))
    }
}
```

- [ ] **Step 6: Run GREEN.** `TodaysWaterAnswerTests`, `TodaysWaterIntentTests` and `PluralFormTests`.
  Expected: all pass.
  If a resolved Russian or Uzbek line comes back in English, the key or the table is wrong — read the
  built app's `ru.lproj/Localizable.stringsdict`; if the figures come back ungrouped, that is the
  spec §3.4 stop: report it to the owner before going on.

- [ ] **Step 7: Stage.**

```bash
git add WaterBuddy/TodaysWaterIntent.swift WaterBuddy/Localizable.xcstrings WaterBuddyTests/TodaysWaterTests.swift WaterBuddyTests/LocalizationTests.swift
```

---

### Task 3: The phrases and the tile

**Files:**
- Modify: `WaterBuddy/WaterBuddyShortcuts.swift:10`–`37`
- Modify: `WaterBuddy/AppShortcuts.xcstrings` — three phrases
- Modify: `WaterBuddyTests/SiriPhraseTests.swift:263`–`275`
- Modify: `WaterBuddyTests/TodaysWaterTests.swift` — one test in `TodaysWaterIntentTests`

**Interfaces:**
- Consumes: `TodaysWaterIntent` (Task 2).
- Produces: `WaterBuddyShortcuts.appShortcuts` with two `AppShortcut`s, *Log a Glass* first.
  `AppShortcut` exposes no public property (SDK), so the order is checked on the simulator, not by a
  test.

- [ ] **Step 1: Write the failing tests.** In `SiriPhraseTests.swift`, the phrase test's count and its
  DocC:

```swift
/// Siri's phrases ship in English and Russian — Siri has no Uzbek — and every one names the app,
/// without which Siri cannot tell whose shortcut it is (spec 2026-10-07-siri-phrase §3.2). Three for
/// *Log a Glass*, three for *Today's Water* (spec 2026-10-18-todays-water §3.2).
struct AppShortcutPhraseTests {
```

```swift
            #expect(table.count == 6, "\(language) has \(table.count) phrases")
```

  In `TodaysWaterTests.swift`, inside `TodaysWaterIntentTests`:

```swift
    /// *Log a Glass* and *Today's Water*: the one provider names both (spec §3.6).
    @Test func theProviderOffersBothShortcuts() {
        #expect(WaterBuddyShortcuts.appShortcuts.count == 2)
    }
```

- [ ] **Step 2: Run RED.** `-only-testing:WaterBuddyTests/AppShortcutPhraseTests -only-testing:WaterBuddyTests/TodaysWaterIntentTests`.
  Expected: `en has 3 phrases`, `ru has 3 phrases`, and `count == 2` against `1`.

- [ ] **Step 3: The phrases.** With Edit, in `WaterBuddy/AppShortcuts.xcstrings`, after the
  `"Add water in ${applicationName}"` entry and before `"Log a glass in ${applicationName}"`:

```json
    "Check my water in ${applicationName}": {
      "localizations": {
        "en": {
          "stringUnit": {
            "state": "translated",
            "value": "Check my water in ${applicationName}"
          }
        },
        "ru": {
          "stringUnit": {
            "state": "translated",
            "value": "Проверь воду в ${applicationName}"
          }
        }
      }
    },
    "How much water have I had in ${applicationName}": {
      "localizations": {
        "en": {
          "stringUnit": {
            "state": "translated",
            "value": "How much water have I had in ${applicationName}"
          }
        },
        "ru": {
          "stringUnit": {
            "state": "translated",
            "value": "Сколько осталось выпить в ${applicationName}"
          }
        }
      }
    },
    "How much water today in ${applicationName}": {
      "localizations": {
        "en": {
          "stringUnit": {
            "state": "translated",
            "value": "How much water today in ${applicationName}"
          }
        },
        "ru": {
          "stringUnit": {
            "state": "translated",
            "value": "Сколько воды сегодня в ${applicationName}"
          }
        }
      }
    },
```

  The same read-only check as Task 2 Step 4, on `WaterBuddy/AppShortcuts.xcstrings`; it must print
  `True True 6`.

- [ ] **Step 4: The provider.** In `WaterBuddyShortcuts.swift`, the DocC's first paragraph becomes:

```swift
/// The product's two App Shortcuts: "Log water in WaterBuddy" logs the user's Glass by voice, and "How
/// much water today in WaterBuddy" answers with today's total and what is left — both with no setup,
/// and each shows as a tile in Spotlight and the Shortcuts app. *Log a Glass* is listed first, so its
/// tile keeps the place it had before the second arrived.
```

  — and `appShortcuts` gains the second shortcut after the first:

```swift
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogServingIntent(),
            phrases: [
                "Log water in \(.applicationName)",
                "Add water in \(.applicationName)",
                "Log a glass in \(.applicationName)",
            ],
            shortTitle: "Log a Glass",
            systemImageName: "mug.fill"
        )
        AppShortcut(
            intent: TodaysWaterIntent(),
            phrases: [
                "How much water today in \(.applicationName)",
                "How much water have I had in \(.applicationName)",
                "Check my water in \(.applicationName)",
            ],
            shortTitle: "Today's Water",
            systemImageName: "drop.fill"
        )
    }
```

- [ ] **Step 5: Run GREEN.** The same two suites, then the whole unit target:
  `-only-testing:WaterBuddyTests`. Expected: all pass; the count is the attribute grep's
  (`grep -chE '^[[:space:]]*@Test' WaterBuddyTests/*.swift | awk '{s+=$1} END {print s}'`), 638 before
  this work plus the new attributes.

- [ ] **Step 6: Stage.**

```bash
git add WaterBuddy/WaterBuddyShortcuts.swift WaterBuddy/AppShortcuts.xcstrings WaterBuddyTests/SiriPhraseTests.swift WaterBuddyTests/TodaysWaterTests.swift
```

---

### Task 4: Verification

- [ ] **Step 1: The gate, on the staged tree.** Copy the index out and run rule `85-testing`'s
  invocations against the copy, so what is gated is what the owner will commit. `G` is a new directory
  named for the time, e.g. `G="$S/gate-1530"`; each run tees to its own timestamped log in `$S`, with
  `uptime` at its start and end:

```bash
git checkout-index -a --prefix="$G/"
uptime
xcodebuild test -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests -parallel-testing-enabled NO -derivedDataPath "$G-dd"
xcodebuild test -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' -only-testing:WaterBuddyUITests -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests -parallel-testing-enabled NO -collect-test-diagnostics never -derivedDataPath "$G-dd"
xcodebuild test -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=26.5,name=WaterBuddy Gate 26.5' -only-testing:WaterBuddyUITests -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests -parallel-testing-enabled NO -collect-test-diagnostics never -derivedDataPath "$G-dd"
xcodebuild test -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddyWatch -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO -derivedDataPath "$G-dd"
xcodebuild build -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddyWidgetExtension -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -derivedDataPath "$G-dd"
xcodebuild build -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddyWatchWidget -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' -derivedDataPath "$G-dd"
```

  If a UI run exceeds the tool's ten-minute foreground limit, run the UI class in chunks by name, as
  the 1.2.6 plan's Task 8 does (`${=FLAGS}` in zsh). Expected: unit `✔ Test run with N tests passed`
  (N from the attribute grep); UI `GoalSetupUITests` 38 executed with 1 skipped by design and the other
  classes 31, 0 failures, on each system; watch `✔ Test run with 57 tests in 6 suites passed`; both
  builds `** BUILD SUCCEEDED **`. Shut each simulator down by UDID after its run. Read each run's
  executed count off its log; write nothing about a run from memory.

- [ ] **Step 2: Warnings.** A clean `build-for-testing` of the `WaterBuddy` scheme for HEAD and for
  the index, each into an empty folder; compare unique lines by file and message; then both widget
  schemes and the watch scheme the same way. `H` is a new directory named for the time:

```bash
mkdir -p "$H" && git archive HEAD | tar -x -C "$H"
xcodebuild build-for-testing -project "$H/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -derivedDataPath "$H-clean" 2>&1 | tee "$S/head-build-$(date +%H%M%S).log" | grep -E 'warning:' | sed -E "s|$H/||; s/:[0-9]+:[0-9]+:/:/" | sort -u > "$S/head-warnings.txt"
xcodebuild build-for-testing -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -derivedDataPath "$G-clean" 2>&1 | tee "$S/index-build-$(date +%H%M%S).log" | grep -E 'warning:' | sed -E "s|$G/||; s/:[0-9]+:[0-9]+:/:/" | sort -u > "$S/index-warnings.txt"
wc -l < "$S/head-warnings.txt"
comm -13 "$S/head-warnings.txt" "$S/index-warnings.txt"
```

  Check the counting first: `wc -l` on HEAD's list must give the 29 unique lines `CLAUDE.md` names
  (lessons, 2026-10-18: a counter is checked against a known count before it is trusted). Expected:
  `comm -13` prints nothing for every scheme. A new line is a failure, fixed before Step 3.

- [ ] **Step 3: The simulator pass** (spec §8.3), on *WaterBuddy Probe 27* only. Install the index
  copy's app, then a **throwaway** XCUITest probe in the copy — never in the tree — that opens the
  Shortcuts app (`XCUIApplication(bundleIdentifier: "com.apple.shortcuts")`), finds WaterBuddy's App
  Shortcuts, and attaches screenshots; then again with the Shortcuts app launched with
  `-AppleLanguages (ru) -AppleLocale ru_RU`. Run with `-resultBundlePath` and export the shots with
  `xcrun xcresulttool export attachments`. Look at each shot before writing anything about it. Expected:
  *Log a Glass* then *Today's Water* (`drop.fill`, blue), and *Вода за сегодня* in Russian. A tap on
  the tile is expected to say *Unable to run App Shortcut* (#63); record what it says.

---

### Task 5: Records, and staging for the owner

- [ ] **Step 1:** `HISTORY.md` checkpoint, `## [2026-10-18] — Roadmap item 1.3.4: Siri answers "how
  much water today"` (or the date it is run), with the gate as run, the warnings comparison, the
  simulator pass and the RED runs as their logs show them.
- [ ] **Step 2:** `docs/AI_CONTEXT.md`: a *Current state* block; rows for the two new files and every
  changed Swift file, re-counted with `wc -l`; the test counts by the attribute grep; known issues —
  open one for the Japanese *1 millilitres* (Review Focus 3) and one for what only a device shows
  (spec §8.3); #63 gains a note: a second intent registered and refused.
- [ ] **Step 3:** `docs/ROADMAP.md`: 1.3.4's entry and §8's row, dated; the device checks join the
  owner's sweep. `docs/WIDGET.md`: the snapshot's two new properties, read by Siri and by no widget.
  `CLAUDE.md` is read for anything the change made false — its *Two front doors* passage, where Siri
  now answers as well as logs, is `/doc_sync`'s.
- [ ] **Step 4:** Stage every file by name, the rule wording with them once the owner approved it:

```bash
git add .claude/rules/70-privacy.md .claude/rules/15-project.md .claude/rules/20-state.md .claude/rules/43-concurrency.md .claude/rules/85-testing.md HISTORY.md docs/AI_CONTEXT.md docs/ROADMAP.md docs/WIDGET.md docs/superpowers/plans/2026-10-18-todays-water.md docs/superpowers/specs/2026-10-18-todays-water-design.md
git diff --cached --name-status
git diff --name-status
```

- [ ] **Step 5:** A fresh read-only reviewer on the whole staged change before the closing report; its
  findings checked at their source. Then `/doc_sync` is the owner's. Stop — the owner runs `/commit`.
