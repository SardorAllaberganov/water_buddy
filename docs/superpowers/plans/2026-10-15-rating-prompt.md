# The Rating Prompt — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: `superpowers:executing-plans`, **in this session** —
> `CLAUDE.md` allows no implementation subagent. Steps use checkbox (`- [ ]`) syntax. **No step
> commits:** nothing is staged until Task 6, which stages by explicit path, and nothing is committed
> until the owner runs `/commit`.

**Goal:** Apple's own request for a rating, asked about 2.2 seconds after the user's own pour on Home
reaches the goal on the third day in a row, at most once per app version.

**Architecture:** `DataManager.swift` (shared by all four targets, importing nothing new) gains one
key, `Key.reviewRequestedVersion`, a pure `nonisolated static` decision and one mutation,
`claimReviewRequest(version:)`, which decides and records in one call. A new app-only
`ReviewPrompt.swift` holds the DEBUG opt-in, the pause and the version. `HomeView.swift` — the only
file that imports `StoreKit` — bumps a counter when its own pour crosses the goal, waits on it with
`.task(id:)`, re-checks, claims and calls `requestReview()`.

**Tech Stack:** Swift (language mode 5; the app and test targets default to main-actor isolation,
with approachable concurrency), SwiftUI, StoreKit's `RequestReviewAction`, swift-testing, XCTest,
Xcode 27.0.

**Spec:** `docs/superpowers/specs/2026-10-15-rating-prompt-design.md` (approved 2026-10-15, "ok", D5
included). Roadmap item **1.2.5**.

**Ledger:** `.superpowers/sdd/2026-10-15-rating-prompt/progress.md` (git-ignored).

**After execution (2026-10-15).** Two corrections, recorded rather than rewritten into the tasks:
- **The final review's fix pass touched two files this plan does not list.** `WaterBuddy/RootTabView.swift`
  gained `EnvironmentValues.pageIsShown`, because a page that is left stays in the tree for its
  slide. `WaterBuddy/WaterBuddyApp.swift` had a DocC sentence that this change made untrue.
- **The *Tech Stack* line is wrong about the test target.** Only the app target sets
  `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. The tests' fixtures are explicitly `@MainActor`, so
  nothing depended on it.

The ledger has the rest.

## Decisions this plan takes

- **P1 — the key is read with `defaults.object(forKey:) as? String`, not `string(forKey:)`.**
  `string(forKey:)` hands back a stored *number* as a string (**inferred** from its documented
  behaviour, not re-read this session), so a stored `1.2` would read as `"1.2"` and version 1.2 would
  count as asked. The cast reads anything but a string as absent, which is what spec §3.4 says it
  means. `aStoredNumberCountsAsNeverAsked` pins it, and Task 1 proves it with a stated mutation.
  This is how rule `25-shared-storage` reads the goal (`object(forKey:) as? Int`).
- **P2 — the wait's "still active" check is a `@State`, `ratingWait`, which Home's existing
  `.onChange(of: scenePhase)` clears whenever the phase leaves `.active`.** It is not a read of
  `scenePhase` after the sleep: the task runs on the copy of the view taken when the wait began, and
  whether an `@Environment` value read through that copy is current is **unconfirmed**. A `@State`
  reads through its storage — the way `expire(_:)` re-checks `undoOffer` after its own sleep
  (`HomeView.swift:591–597`).
- **P3 — `ReviewPrompt.pause` and `ReviewPrompt.isEnabledHere` are computed `static var`s.** A stored
  `static let` whose initializer reads another main-actor static (`Confetti.duration`) or calls a
  main-actor function risks an initializer-isolation warning (**inferred**). `version` stays a
  `static let`, which reads only `Bundle.main`. Task 5's warning comparison is the check.
- **P4 — RED by two stubs, never by a compile failure.** Task 1 first lands the API with bodies
  that always answer `false` — every test expecting a request goes RED — then with bodies that
  always answer `true` and write — every test expecting none goes RED. Only then the real bodies.
- **P5 — `everyKeyTheProductWritesIsOnTheRoster` expects the claim's own key among the live keys.**
  Its count guard (`>= 8`) cannot see the new writer: the writers it already drives land nine keys by
  the plan's reading (`dailyGoal`, `isGoalSet`, `servings`, `language`, `remindersEnabled`,
  `currentWater`, `wristApplied`, `lastActiveDay`, `didMigrateFromStandard`), so a raised floor of 9
  would pass on the `false` stub. An expectation naming `Key.reviewRequestedVersion` goes RED there,
  and the guard stays as it is.

## Global Constraints

- iOS floor **17.0**. `RequestReviewAction` is `@available(iOS 16.0, *)`, so no `#available`.
- **`StoreKit` is imported by `WaterBuddy/HomeView.swift` alone.** Never by `DataManager.swift`,
  never under `WaterBuddyWidget/`, `WaterBuddyWatch/` or `WaterBuddyWatchWidget/`. Only
  `requestReview` — no product, purchase or transaction API (rule `70-privacy`, *The review request
  is the one use of StoreKit*).
- One new key, `Key.reviewRequestedVersion = prefix + "reviewRequestedVersion"`, a `String`, never
  materialised, in `Key.all`. The phone's suite holds **ten** keys after this.
- `DataManager.reviewStreak = 3`. `mayRequestReview(reachedToday:streak:askedVersion:version:)` is
  `true` only when `reachedToday && streak >= reviewStreak && !version.isEmpty && askedVersion != version`.
- `claimReviewRequest(version:)` writes the version **before** returning `true`, writes nothing when
  it returns `false`, touches no row, rings no doorbell and reschedules nothing.
- `ReviewPrompt.launchArgument == "-WaterBuddyReviewPrompt"`. A DEBUG build asks only when launched
  with it; a Release build always may.
- `ReviewPrompt.pause` is `.seconds(Confetti.duration + 0.4)`.
- Only `HomeView.pour(_:)` can start a request. No other surface asks.
- **No new string, entitlement, Info.plist key, privacy manifest change or `project.pbxproj` line.**
  `ReviewPrompt.swift` joins the app through its synchronized folder; no exception set changes.
- Tests come first: write, run, **see RED**, implement, run GREEN. Never narrow an assertion.
- **No new warning** against Task 0's clean baseline of HEAD `450d76f`, compared per file and message.
- Edit with `Edit`/`Write` only: no `sed -i`, no heredoc or script into the tree. Scratch work goes
  in this session's scratchpad (`$SCRATCH`).
- Simulators:
  - Unit tests run on the stock iOS 27.0 *iPhone 17*.
  - UI tests run on *WaterBuddy Gate 27* and *WaterBuddy Gate 26.5*.
  - The probe runs on *WaterBuddy Probe 27* (`43E0B902-C6D5-48DD-B513-F22AF3BE9BEA`) only, on the
    DEBUG fresh start, so it writes only a throwaway suite and an in-memory store.
  - Run `uptime` before each run; if the 1-minute load is above 6, wait. Shut down **by UDID**,
    never `shutdown all`.
  - Every test run takes `-parallel-testing-enabled NO` and `-collect-test-diagnostics never`, and
    runs in the foreground. No UI run may cross midnight.
- Never write the real App Group suite or `UserDefaults.standard` from a test or a script.
- Never commit. Stage explicit paths. The five rule files stay unstaged for the owner.

## Review Focus

Five inputs a person will meet that the spec's unit tests do not reach. Each is pinned by the test
named here, in the task that owns it.

1. **A UI test pouring across the goal on the long-gated simulator.** It must never meet a system
   alert. → `aDebugBuildAsksOnlyWhenLaunchedToAsk`, `theTestRunItselfIsNotLaunchedToAsk` (Task 2),
   `RatingProbe.testEWithoutTheArgumentADebugBuildNeverAsks` (Task 4), and the gate's UI runs (Task 5).
2. **An *Undo* inside the pause.** No request, and the version is not used up: the next crossing
   asks. → `RatingProbe.testBAnUndoInsideThePauseAsksNothing` (Task 4).
3. **Leaving inside the pause** — another tab, or the Home Screen and back. No request, now or on
   return. → `RatingProbe.testCLeavingHomeInsideThePauseAsksNothing`,
   `RatingProbe.testDGoingToTheHomeScreenInsideThePauseAsksNothing` (Task 4).
4. **The goal reached somewhere other than Home's pour** (D5). → `RatingProbe.testFTheGoalReachedFromHistoryAsksNothing`
   (Task 4). The widget, Siri and the control cannot be driven on a fresh start; they never reach
   `pour(_:)`, which is the only place `goalPours` moves — checked by the reviewer (Task 5).
5. **The goal crossed again the same day, in the same version.** No second request. →
   `aClaimOnTheThirdGoalDayRecordsTheVersionBeforeAnswering` (Task 1),
   `RatingProbe.testAThirdGoalDayAsksOnceInAVersion` (Task 4).

## File structure

| File | Target(s) | Change |
|---|---|---|
| `WaterBuddy/DataManager.swift` | app, phone widget, watch, watch widget | `Key.reviewRequestedVersion` + `Key.all`; `reviewStreak`, `mayRequestReview(…)`, `claimReviewRequest(version:)` in a new `// MARK: - The rating request` |
| `WaterBuddy/ReviewPrompt.swift` | app — **new** | the DEBUG opt-in, the pause, the version |
| `WaterBuddy/HomeView.swift` | app | `import StoreKit`; `requestReview`; `goalPours`, `ratingWait`; the task; `pour(_:)`'s two reads; `askForARating(after:)` |
| `WaterBuddyTests/ReviewRequestTests.swift` | tests — **new** | `ReviewRequestTests` (8), `ReviewPromptTests` (4) |
| `WaterBuddyTests/DataManagerTests.swift` | tests | `everyKeyTheProductWritesIsOnTheRoster` drives the claim and expects its key |
| `WaterBuddyUITests/RatingProbe.swift` | UI tests — **throwaway** | created in Task 4, deleted before staging |
| `docs/superpowers/specs/2026-10-15-rating-prompt-design.md` | — | amended for P1–P3 (Task 0) |
| `.claude/rules/70-privacy.md`, `20-state.md`, `25-shared-storage.md`, `10-architecture.md`, `85-testing.md` | — | spec §5's wording, **typed and unstaged** before this plan |
| `CLAUDE.md`, `docs/AI_CONTEXT.md`, `docs/STATE.md`, `docs/ROADMAP.md`, `HISTORY.md` (and `tasks/lessons.md` if a lesson is earned) | — | records (Task 6) |

## Commands used below

`$SCRATCH` is this session's scratchpad directory. Shorthand, expanded in full wherever a step runs
it:

```bash
# UNIT <filters>: swift-testing on the stock iOS 27.0 iPhone 17
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' <-only-testing:…> -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Test run with|✘|error:" | tail -30
```

The three filters Task 1 and Task 2 use:
`-only-testing:WaterBuddyTests/ReviewRequestTests -only-testing:WaterBuddyTests/ReviewPromptTests -only-testing:'WaterBuddyTests/DataManagerTests/everyKeyTheProductWritesIsOnTheRoster()'`.

Read a run's **executed** count, never its last line.

---

### Task 0: The ledger, the baseline, the spec's amendments

**Files:** the ledger; the spec; scratch.

- [ ] **Step 1: The starting state.** `git status --short`. Expect, besides this plan and the spec
  (both untracked): the five rule files and `CLAUDE.md` modified (the approved amendment, typed); the
  six long-standing modified paths (`.claude/settings.json`, the two watch schemes,
  `WaterBuddy/AppShortcuts.xcstrings`, `WaterBuddyWatch/Localizable.xcstrings`,
  `WaterBuddyWatchWidget/Localizable.xcstrings`); `Screenshots/census/` untracked. Write them into
  the ledger as the starting state, with P1–P5.
- [ ] **Step 2: The warnings baseline** — a clean `build-for-testing` of HEAD into an empty folder,
  then the widget's `build` into the same folder.

```bash
mkdir -p "$SCRATCH/base" && git archive HEAD | tar -x -C "$SCRATCH/base"
xcodebuild build-for-testing -project "$SCRATCH/base/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'generic/platform=iOS Simulator' -derivedDataPath "$SCRATCH/base-dd" > "$SCRATCH/base-app.log" 2>&1; echo "exit $?"
xcodebuild build -project "$SCRATCH/base/WaterBuddy.xcodeproj" -scheme WaterBuddyWidgetExtension -destination 'generic/platform=iOS Simulator' -derivedDataPath "$SCRATCH/base-dd" > "$SCRATCH/base-widget.log" 2>&1; echo "exit $?"
cat "$SCRATCH"/base-app.log "$SCRATCH"/base-widget.log | grep -E ': warning: ' | sed -E 's#^.*/base/##' | sort -u > "$SCRATCH/base-lines.txt"; wc -l < "$SCRATCH/base-lines.txt"
cat "$SCRATCH"/base-app.log "$SCRATCH"/base-widget.log | grep -E ': warning: ' | sed -E 's#^.*/base/##; s#^(Water[^:]+):[0-9]+:[0-9]+: #\1: #' | sort -u > "$SCRATCH/base-messages.txt"; wc -l < "$SCRATCH/base-messages.txt"
```

  Expect both builds to exit 0. The counts go in the ledger as they come; `CLAUDE.md` says 29 unique
  shipping lines. A different figure is recorded as it is, not reconciled.

- [ ] **Step 3: Amend the spec for P1–P3**, with `Edit`:
  - *Provenance*: append "Amended on 2026-10-15 by the plan's decisions
    (`docs/superpowers/plans/2026-10-15-rating-prompt.md`, P1–P3); each amendment says so."
  - §3.3, point 3: "the scene is `.active`" → "the app stayed active throughout — a `@State` wait
    Home clears whenever the scene leaves `.active`, never a read of `scenePhase` after the sleep
    (plan P2)".
  - §3.4, the read bullet: "Read with `defaults.string(forKey:)`. A stored value that is not a string
    reads as absent" → "Read with `defaults.object(forKey:) as? String` (plan P1) — not
    `string(forKey:)`, which hands back a stored number as a string. A stored value that is not a
    string reads as absent".
  - §3.6, first bullet: "Resolved once from `ProcessInfo.processInfo.arguments`." → "Read for this
    process by a computed `isEnabledHere`." Second bullet: append "— computed, like `isEnabledHere`
    (plan P3)".
  - §6: "**A stored non-string counts as never asked.**" → "**A stored number counts as never asked**
    (plan P1)."

---

### Task 1: The decision, the key and the claim

**Files:**
- Create: `WaterBuddyTests/ReviewRequestTests.swift`
- Modify: `WaterBuddy/DataManager.swift` (`Key`, `:129` and `:159–163`; a new section before
  `// MARK: - Reminders`, `:1253`)
- Modify: `WaterBuddyTests/DataManagerTests.swift:127–162`

**Interfaces:**
- Produces: `DataManager.Key.reviewRequestedVersion: String`; `nonisolated static let
  reviewStreak: Int`; `nonisolated static func mayRequestReview(reachedToday: Bool, streak: Int,
  askedVersion: String?, version: String) -> Bool`; `func claimReviewRequest(version: String) -> Bool`
  (main actor, `@discardableResult` not used — every caller acts on it).

- [ ] **Step 1: Write the tests.** Create `WaterBuddyTests/ReviewRequestTests.swift` with the
  fixtures and `ReviewRequestTests` below. (`ReviewPromptTests` joins the file in Task 2.)

```swift
//
//  ReviewRequestTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 15/10/26.
//

import Foundation
import SwiftData
import Testing
@testable import WaterBuddy

// MARK: - Fixtures

/// A Gregorian/UTC day, so a run cannot flake on a machine sitting near local midnight.
private let utcDay: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar
}()

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
}

/// Noon on the day every fixture here calls today.
private let today = utc(2026, 10, 15)

/// A manager on its own UUID-named suite and in-memory store, every side effect off, its clock
/// pinned to ``today`` and its goal at 1,000 (rule `85-testing`).
@MainActor
private func withManager(_ body: (DataManager, UserDefaults) throws -> Void) rethrows {
    let name = "test.waterbuddy.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    let manager = DataManager(
        defaults: defaults,
        // Never the default: that resolves the live App Group store (rule `85-testing`).
        modelContainer: try! ModelContainer(
            for: WaterLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ),
        calendar: utcDay,
        now: { today },
        reloadWidgets: {},
        rescheduleReminders: { _ in },
        publishWrist: { _ in }
    )
    manager.saveDailyGoal(ml: 1_000)
    try body(manager, defaults)
}

/// The goal reached on each of the `days` days before today, then `todayAmount` today.
@MainActor
private func pour(goalDays days: Int, today todayAmount: Int, into manager: DataManager) {
    for back in stride(from: days, through: 1, by: -1) {
        manager.addLog(amount: 1_000, at: utcDay.date(byAdding: .day, value: -back, to: today)!)
    }
    if todayAmount > 0 { manager.addLog(amount: todayAmount) }
}

// MARK: - The decision and its record

/// Whether the app may ask iOS for a rating, and the record that it did
/// (`docs/superpowers/specs/2026-10-15-rating-prompt-design.md`, roadmap 1.2.5).
@MainActor
struct ReviewRequestTests {

    /// D1: the third goal day in a row asks; the second does not.
    @Test func theRequestWaitsForTheThirdGoalDayInARow() {
        #expect(DataManager.reviewStreak == 3)
        #expect(!DataManager.mayRequestReview(reachedToday: true, streak: 2, askedVersion: nil, version: "1.2"))
        #expect(DataManager.mayRequestReview(reachedToday: true, streak: 3, askedVersion: nil, version: "1.2"))
        #expect(DataManager.mayRequestReview(reachedToday: true, streak: 40, askedVersion: nil, version: "1.2"))
    }

    /// A run of three can end yesterday while today is still short. The request belongs to the day
    /// that completed the run.
    @Test func aRunThatEndedYesterdayIsNotAskedAbout() {
        #expect(!DataManager.mayRequestReview(reachedToday: false, streak: 3, askedVersion: nil, version: "1.2"))
    }

    /// D2: once per version, as Apple's own sample asks.
    @Test func aVersionAlreadyAskedInIsNotAskedAgain() {
        #expect(!DataManager.mayRequestReview(reachedToday: true, streak: 3, askedVersion: "1.2", version: "1.2"))
        #expect(DataManager.mayRequestReview(reachedToday: true, streak: 3, askedVersion: "1.1", version: "1.2"))
    }

    /// An empty version could never be told from the next one, so it is never asked in.
    @Test func anUnknownVersionIsNeverAskedIn() {
        #expect(!DataManager.mayRequestReview(reachedToday: true, streak: 3, askedVersion: nil, version: ""))
    }

    /// The claim records before it answers, and answers once per version.
    @Test func aClaimOnTheThirdGoalDayRecordsTheVersionBeforeAnswering() throws {
        try withManager { manager, defaults in
            pour(goalDays: 2, today: 1_000, into: manager)
            try #require(manager.streak == 3, "the fixture did not make a three-day run")
            try #require(manager.hasReachedGoal)

            #expect(manager.claimReviewRequest(version: "1.2"))
            #expect(defaults.object(forKey: DataManager.Key.reviewRequestedVersion) as? String == "1.2")

            #expect(!manager.claimReviewRequest(version: "1.2"), "asked twice in one version")
            #expect(manager.claimReviewRequest(version: "1.3"), "a new version was not asked")
            #expect(defaults.object(forKey: DataManager.Key.reviewRequestedVersion) as? String == "1.3")
        }
    }

    /// The second goal day in a row is refused, and a refusal writes nothing.
    @Test func aClaimOnTheSecondGoalDayWritesNothing() throws {
        try withManager { manager, defaults in
            pour(goalDays: 1, today: 1_000, into: manager)
            try #require(manager.streak == 2, "the fixture did not make a two-day run")

            #expect(!manager.claimReviewRequest(version: "1.2"))
            #expect(defaults.object(forKey: DataManager.Key.reviewRequestedVersion) == nil)
        }
    }

    /// Three goal days ending yesterday, today short: refused, nothing written.
    @Test func aClaimWithTodayShortWritesNothing() throws {
        try withManager { manager, defaults in
            pour(goalDays: 3, today: 500, into: manager)
            try #require(manager.streak == 3, "three goal days ending yesterday did not count as a run of three")
            try #require(!manager.hasReachedGoal)

            #expect(!manager.claimReviewRequest(version: "1.2"))
            #expect(defaults.object(forKey: DataManager.Key.reviewRequestedVersion) == nil)
        }
    }

    /// Plan P1. `string(forKey:)` would hand back a stored number `1.2` as `"1.2"` and call version
    /// 1.2 asked; the key is read with `object(forKey:) as? String`, so anything but a string is
    /// absent.
    @Test func aStoredNumberCountsAsNeverAsked() throws {
        try withManager { manager, defaults in
            defaults.set(1.2, forKey: DataManager.Key.reviewRequestedVersion)
            pour(goalDays: 2, today: 1_000, into: manager)

            #expect(manager.claimReviewRequest(version: "1.2"))
            #expect(defaults.object(forKey: DataManager.Key.reviewRequestedVersion) as? String == "1.2")
        }
    }
}
```

- [ ] **Step 2: Widen the roster test.** In `DataManagerTests.swift`, `everyKeyTheProductWritesIsOnTheRoster`,
  after `manager.addLog(amount: 250)               // currentWater` insert:

```swift
            // Two goal days behind today and the goal reached today: the claim's own moment.
            manager.addLog(amount: 2_500, at: utc(2026, 8, 26))
            manager.addLog(amount: 2_500, at: utc(2026, 8, 27))
            manager.addLog(amount: 2_500)
            _ = manager.claimReviewRequest(version: "1.2")   // reviewRequestedVersion
```

  and, after the existing `#expect(live.count >= 8, …)` guard, add (P5):

```swift
            // The claim is a writer the count above cannot see: the others already land nine.
            #expect(
                live.contains(DataManager.Key.reviewRequestedVersion),
                "the claim wrote nothing, so the roster's check never saw its key"
            )
```

- [ ] **Step 3: The `false` stub (P4).** In `DataManager.swift`:
  - `Key`, after `static let servings = prefix + "servings"`:

```swift
        /// The app's version — its `CFBundleShortVersionString`, e.g. `"1.2"` — the last time it
        /// asked iOS for a rating. **Absent means never asked**, so nothing materialises it, like
        /// ``remindersEnabled`` and ``language``. Written only by
        /// ``DataManager/claimReviewRequest(version:)``; no snapshot, mirror or notification reads it.
        static let reviewRequestedVersion = prefix + "reviewRequestedVersion"
```

  - `Key.all`: `didMigrateFromStandard, remindersEnabled, language, servings,` →
    `didMigrateFromStandard, remindersEnabled, language, servings, reviewRequestedVersion,`.
  - Before `    // MARK: - Reminders`, temporarily:

```swift
    // MARK: - The rating request

    nonisolated static let reviewStreak = 0

    nonisolated static func mayRequestReview(
        reachedToday: Bool,
        streak: Int,
        askedVersion: String?,
        version: String
    ) -> Bool {
        false
    }

    func claimReviewRequest(version: String) -> Bool {
        false
    }

```

- [ ] **Step 4: Run, and see the requests RED.**
  `UNIT -only-testing:WaterBuddyTests/ReviewRequestTests -only-testing:'WaterBuddyTests/DataManagerTests/everyKeyTheProductWritesIsOnTheRoster()'`.
  Expect it to build, and to fail: `theRequestWaitsForTheThirdGoalDayInARow`,
  `aVersionAlreadyAskedInIsNotAskedAgain`, `aClaimOnTheThirdGoalDayRecordsTheVersionBeforeAnswering`,
  `aStoredNumberCountsAsNeverAsked`, `everyKeyTheProductWritesIsOnTheRoster`. The three that expect a
  refusal pass on this stub, which proves nothing about them yet. Record the run in the ledger.

- [ ] **Step 5: The `true` stub (P4).** Replace the three stub bodies: `reviewStreak = 3`;
  `mayRequestReview` → `true`; `claimReviewRequest` →
  `defaults.set(version, forKey: Key.reviewRequestedVersion); return true`.

- [ ] **Step 6: Run, and see the refusals RED.** Same command. Expect to fail:
  `theRequestWaitsForTheThirdGoalDayInARow` (its streak-2 line), `aRunThatEndedYesterdayIsNotAskedAbout`,
  `aVersionAlreadyAskedInIsNotAskedAgain` (its first line), `anUnknownVersionIsNeverAskedIn`,
  `aClaimOnTheThirdGoalDayRecordsTheVersionBeforeAnswering` (its second claim),
  `aClaimOnTheSecondGoalDayWritesNothing`, `aClaimWithTodayShortWritesNothing`. Record it.

- [ ] **Step 7: The real section.** Replace the stub section with:

```swift
    // MARK: - The rating request

    /// How many goal days in a row, today the last of them, before the app may ask iOS for a
    /// rating (`docs/superpowers/specs/2026-10-15-rating-prompt-design.md`, D1).
    ///
    /// Three: the request can then never fall in the first session or on the first day, and it
    /// comes to someone the app is plainly working for. It reads ``streak``, so it costs no count
    /// of its own.
    nonisolated static let reviewStreak = 3

    /// Whether the app may ask for a rating now — the whole decision, pure, so a test can hold it.
    ///
    /// All four must hold:
    /// - `reachedToday`: a run of three can end yesterday while today is still short, and the
    ///   request belongs to the day that completed the run;
    /// - `streak` is at least ``reviewStreak``;
    /// - `version` is not empty: an empty version could never be told from the next one;
    /// - `askedVersion` is not `version`: at most once per version, as Apple's own sample asks
    ///   (spec §3.2). Apple's cap of three requests a year applies on top.
    nonisolated static func mayRequestReview(
        reachedToday: Bool,
        streak: Int,
        askedVersion: String?,
        version: String
    ) -> Bool {
        reachedToday && streak >= reviewStreak && !version.isEmpty && askedVersion != version
    }

    /// Decides whether to ask for a rating now and, if so, records that it did — one call, so
    /// nothing can ask without recording it.
    ///
    /// **The version is written before this answers `true`.** The caller then asks iOS, which may
    /// show nothing and never says whether it did. Recording first is what Apple's own sample does,
    /// and it is what keeps "once per version" true whatever iOS chose.
    ///
    /// It writes ``Key/reviewRequestedVersion`` and nothing else: no row, no doorbell — no widget
    /// reads the key — and no reschedule. No ``refresh()`` first, unlike ``addLog(amount:at:)``:
    /// only this method writes the key, so no other process holds a newer figure for a stale
    /// instance to overwrite.
    ///
    /// No ``role`` guard: ``streak`` is zero wherever ``Role/drawsHistory`` is `false`, so the
    /// decision already answers `false` in every process but the phone app. `HomeView` is its one
    /// caller (rule `70-privacy`, *The review request is the one use of StoreKit*).
    ///
    /// - Parameter version: the app's `CFBundleShortVersionString` (`ReviewPrompt.version`).
    /// - Returns: whether the caller should ask iOS now.
    func claimReviewRequest(version: String) -> Bool {
        // `object(forKey:) as? String`, never `string(forKey:)`, which hands back a stored number
        // as a string: anything but a string reads as never asked (plan P1).
        let asked = defaults.object(forKey: Key.reviewRequestedVersion) as? String
        guard Self.mayRequestReview(
            reachedToday: hasReachedGoal,
            streak: streak,
            askedVersion: asked,
            version: version
        ) else { return false }

        defaults.set(version, forKey: Key.reviewRequestedVersion)
        return true
    }

```

- [ ] **Step 8: Run GREEN.** Same command. Expect `✔ Test run with 9 tests passed` (8 in
  `ReviewRequestTests`, the roster test).

- [ ] **Step 9: P1's stated mutation.** Change the read to `defaults.string(forKey: Key.reviewRequestedVersion)`,
  run `UNIT -only-testing:'WaterBuddyTests/ReviewRequestTests/aStoredNumberCountsAsNeverAsked()'`, and
  expect it to **fail**. If it passes, `string(forKey:)` does not convert a number on this system:
  record that, and correct P1's reasoning in the plan and the spec — the cast stays either way. Revert
  the read, run again, expect it to pass. Record both runs.

---

### Task 2: `ReviewPrompt` — the opt-in, the pause, the version

**Files:**
- Create: `WaterBuddy/ReviewPrompt.swift`
- Modify: `WaterBuddyTests/ReviewRequestTests.swift` (append `ReviewPromptTests`)

**Interfaces:**
- Consumes: `Confetti.duration: Double` (`Celebration.swift`).
- Produces: `ReviewPrompt.launchArgument: String`, `ReviewPrompt.isEnabled(arguments: [String]) -> Bool`,
  `ReviewPrompt.isEnabledHere: Bool`, `ReviewPrompt.pause: Duration`, `ReviewPrompt.version: String`.

- [ ] **Step 1: Write the tests.** Append to `ReviewRequestTests.swift`:

```swift

// MARK: - The app's side

/// When the app may ask at all, how long Home waits, and which version it records.
@MainActor
struct ReviewPromptTests {

    /// D4. The test host is a DEBUG build, so this holds the DEBUG branch. The Release branch,
    /// which always answers `true`, is not compiled by the gate (spec §6).
    @Test func aDebugBuildAsksOnlyWhenLaunchedToAsk() {
        #expect(ReviewPrompt.launchArgument == "-WaterBuddyReviewPrompt")
        #if DEBUG
        #expect(!ReviewPrompt.isEnabled(arguments: []))
        #expect(!ReviewPrompt.isEnabled(arguments: ["-WaterBuddyFreshStart", "YES"]))
        #expect(ReviewPrompt.isEnabled(arguments: ["-WaterBuddyReviewPrompt", "YES"]))
        #endif
    }

    /// The gate's own runs launch without the argument, so nothing in them can meet the request.
    @Test func theTestRunItselfIsNotLaunchedToAsk() {
        #if DEBUG
        #expect(!ReviewPrompt.isEnabledHere)
        #endif
    }

    /// The request meets a screen at rest: the confetti has landed first.
    @Test func theRequestWaitsForTheConfettiToLand() {
        #expect(ReviewPrompt.pause > .seconds(Confetti.duration))
    }

    /// The version is the bundle's own, and the app has one.
    @Test func theVersionIsTheBundlesOwn() {
        #expect(!ReviewPrompt.version.isEmpty)
        #expect(ReviewPrompt.version == Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
    }
}
```

- [ ] **Step 2: The stub.** Create `WaterBuddy/ReviewPrompt.swift`:

```swift
import Foundation

enum ReviewPrompt {
    static let launchArgument = "-WaterBuddyReviewPrompt"
    static func isEnabled(arguments: [String]) -> Bool { true }
    static var isEnabledHere: Bool { true }
    static var pause: Duration { .zero }
    static let version = ""
}
```

- [ ] **Step 3: Run, and see it RED.** `UNIT -only-testing:WaterBuddyTests/ReviewPromptTests`. Expect
  `aDebugBuildAsksOnlyWhenLaunchedToAsk`, `theTestRunItselfIsNotLaunchedToAsk`,
  `theRequestWaitsForTheConfettiToLand` and `theVersionIsTheBundlesOwn` to fail. Record it.

- [ ] **Step 4: The real file.** Replace `WaterBuddy/ReviewPrompt.swift` with:

```swift
//
//  ReviewPrompt.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 15/10/26.
//

import Foundation

/// The app's side of asking iOS for a rating: whether this run may ask at all, how long Home waits,
/// and the version a request is recorded under
/// (`docs/superpowers/specs/2026-10-15-rating-prompt-design.md` §3.6).
///
/// **Whether to ask is not decided here.** That is ``DataManager/claimReviewRequest(version:)``'s,
/// so the decision and its record are one call. Nor is `StoreKit` imported here: only
/// `HomeView.swift` imports it (rule `70-privacy`). App-only — no exception set lists this file.
enum ReviewPrompt {

    /// A DEBUG build's opt-in. Followed by a value, as `-WaterBuddyFreshStart` is: a `-key`
    /// argument takes the next one as its value.
    static let launchArgument = "-WaterBuddyReviewPrompt"

    /// Whether a run launched with `arguments` may ask for a rating.
    ///
    /// **A DEBUG build asks only when launched with ``launchArgument``.** StoreKit shows the request
    /// every time in development, and the UI suite pours on a simulator whose streak may already be
    /// three: a crossing there would meet a system alert. Off, Home never claims, so a DEBUG run
    /// without the argument writes nothing and shows nothing (rule `85-testing`). A Release build
    /// always may; TestFlight shows nothing whatever the app asks.
    static func isEnabled(arguments: [String]) -> Bool {
        #if DEBUG
        arguments.contains(launchArgument)
        #else
        true
        #endif
    }

    /// ``isEnabled(arguments:)`` for this process. Computed, not stored: a stored static's
    /// initializer calling a main-actor function is a warning waiting to happen (plan P3).
    static var isEnabledHere: Bool {
        isEnabled(arguments: ProcessInfo.processInfo.arguments)
    }

    /// How long Home waits after the pour that reached the goal: until the confetti has landed and
    /// gone — the overlay keeps its burst for ``Confetti/duration`` and 0.4 s more — so the request
    /// meets a screen at rest, as Apple's sample waits on its completed scene.
    static var pause: Duration {
        .seconds(Confetti.duration + 0.4)
    }

    /// The version a request is recorded under: the bundle's `CFBundleShortVersionString`, or `""`
    /// when it has none, which ``DataManager/mayRequestReview(reachedToday:streak:askedVersion:version:)``
    /// never asks in. A version is not copy, so reading `Bundle.main` here is outside the strings
    /// rule (rule `70-privacy`, *Localization*).
    static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
}
```

- [ ] **Step 5: Run GREEN.** The three filters from *Commands used below*. Expect
  `✔ Test run with 13 tests passed`.

---

### Task 3: Home asks

**Files:**
- Modify: `WaterBuddy/HomeView.swift` (imports `:8–9`; environment `:189–194`; state after `:213`;
  body modifiers `:276–284`; `pour(_:)` `:819–835`; a new section before the struct's closing brace
  `:836`)

**Interfaces:**
- Consumes: `manager.hasReachedGoal`, `manager.claimReviewRequest(version:)` (Task 1);
  `ReviewPrompt.isEnabledHere`, `.pause`, `.version` (Task 2); StoreKit's
  `@Environment(\.requestReview)`.

No unit seam reaches a view's timing; Task 4's probe is this task's test, and it is written before
this task runs only in the sense that its expectations are fixed here: a crossing pour asks after
the pause; an *Undo*, a tab change or the Home Screen inside the pause asks nothing; History's **+**
never asks.

- [ ] **Step 1: Imports.** `import SwiftData` / `import SwiftUI` become:

```swift
import StoreKit
import SwiftData
import SwiftUI
```

- [ ] **Step 2: The environment.** After `@Environment(\.scenePhase) private var scenePhase`:

```swift
    /// StoreKit's rating request — the one use of StoreKit in the product (rule `70-privacy`).
    @Environment(\.requestReview) private var requestReview
```

- [ ] **Step 3: The state.** After `@State private var goalBursts = 0`:

```swift
    /// Bumped when a pour **on this screen** takes today across the goal — and only then. A crossing
    /// `refresh()` picks up as the app comes forward is right after launch, which is no time to ask
    /// for a rating (spec D5). Keys the wait before the request (``askForARating(after:)``).
    @State private var goalPours = 0
    /// The crossing whose rating request is still waiting; `nil` once it has asked, or once the app
    /// stopped being active during the wait (plan P2).
    @State private var ratingWait: Int?
```

- [ ] **Step 4: The task and the phase.** After `.task(id: undoClock) { await expire(undoClock) }`:

```swift
        .task(id: goalPours) { await askForARating(after: goalPours) }
```

  and the scene-phase handler becomes:

```swift
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { undoOffer = nil }
            // Any leaving ends a rating's wait, Control Center included: the request would
            // otherwise meet the user on their way back.
            if phase != .active { ratingWait = nil }
        }
```

  (its comment block above stays as it is).

- [ ] **Step 5: The pour.** `pour(_:)` becomes:

```swift
    /// One call into the model, and the offer to take it back (rule `50-views`).
    private func pour(_ serving: Serving) {
        let wasReached = manager.hasReachedGoal
        let id = manager.addLog(amount: serving.amount)
        undoOffer = id.map { UndoOffer(id: $0, amount: serving.amount) }
        pours += 1
        poured[serving.id, default: 0] += 1
        // Two reads around the one call, not a second call: the pour that reached the goal is the
        // one moment a rating may be asked for.
        if !wasReached, manager.hasReachedGoal {
            goalPours += 1
            ratingWait = goalPours
        }
        // A drop for a pour that was logged, and none under Reduce Motion: it is travel across
        // the screen (rule `65-accessibility`). The serving is in the store already; the drop
        // only shows where it went.
        if id != nil, !reduceMotion {
            // The surface surges when the drop lands (``land(_:)``), not now: water that was
            // already sloshing before anything reached it gave the drop nothing to do, and the
            // waves, half died down by then, jumped back to full as it arrived.
            flights.append(PourFlight(id: pours, slot: serving.id))
        } else {
            lastPour = Date()
        }
    }

    // MARK: - Rating

    /// Asks iOS for a rating once the confetti of the pour that reached the goal has landed — if the
    /// model says this is the moment (rule `70-privacy`, *The review request is the one use of
    /// StoreKit*).
    ///
    /// Keyed on ``goalPours``: SwiftUI cancels the wait when Home leaves the screen, and starts it
    /// again on the next crossing. After the pause it asks only if the wait still stands — the app
    /// stayed active — and today is still at the goal, so an *Undo* inside the pause asks nothing.
    /// The model then decides and records in one call, and StoreKit decides whether anything shows.
    private func askForARating(after crossing: Int) async {
        guard crossing > 0, ReviewPrompt.isEnabledHere else { return }
        do { try await Task.sleep(for: ReviewPrompt.pause) } catch { return }
        // Re-checked after the sleep, as `expire(_:)` does (rule `43-concurrency`).
        guard ratingWait == crossing else { return }
        ratingWait = nil
        guard manager.hasReachedGoal,
              manager.claimReviewRequest(version: ReviewPrompt.version)
        else { return }
        requestReview()
    }
```

  `lastPour = Date()` is the existing line, unchanged.

- [ ] **Step 6: Build the app, the widget and the watch, and read their links.**

```bash
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'generic/platform=iOS Simulator' -derivedDataPath "$SCRATCH/link-dd" 2>&1 | grep -E "error:|warning: .*(HomeView|ReviewPrompt|DataManager)|BUILD" | tail -10
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension -destination 'generic/platform=iOS Simulator' -derivedDataPath "$SCRATCH/link-dd" 2>&1 | grep -E "error:|BUILD" | tail -3
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch -destination 'generic/platform=watchOS Simulator' -derivedDataPath "$SCRATCH/link-dd" 2>&1 | grep -E "error:|BUILD" | tail -3
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget -destination 'generic/platform=watchOS Simulator' -derivedDataPath "$SCRATCH/link-dd" 2>&1 | grep -E "error:|BUILD" | tail -3
find "$SCRATCH/link-dd/Build/Products" -type f \( -perm -111 -o -name '*.dylib' \) -print0 | xargs -0 -I{} sh -c 'otool -L "{}" 2>/dev/null | grep -q StoreKit && echo "links StoreKit: {}"'
```

  Expect four `BUILD SUCCEEDED`. In the build output, any warning naming `HomeView.swift`,
  `ReviewPrompt.swift` or the new section of `DataManager.swift` is compared against Task 0's
  baseline before going on. The last line must name only the app's own binary (and its
  `WaterBuddy.debug.dylib`, if the Debug build splits one out) — never anything under
  `WaterBuddyWidgetExtension.appex`, `WaterBuddyWatch.app` or `WaterBuddyWatchWidget.appex`. Record
  the list in the ledger.

- [ ] **Step 7: The unit suite still builds and passes the three filters** (*Commands used below*):
  expect `✔ Test run with 13 tests passed`.

---

### Task 4: On the simulator — the probe

**Files:** Create, then delete: `WaterBuddyUITests/RatingProbe.swift`. Results under `$SCRATCH`.

The probe runs the DEBUG fresh start: a throwaway suite cleared at launch and an in-memory store,
so the request's record is gone at every launch and *WaterBuddy Probe 27*'s own data is never
touched. Each test sets the goal to 1,000 in the welcome, logs 1,000 or more on each of the two days
before today from History's **+**, and leaves today at 750 — one Bottle short.

Spec §7.3 ran on a device's own data; the fresh start replaces that, so its steps repeat at every
launch without an uninstall. Its step 6 also asks that the suite hold no key afterwards: the fresh
start clears its suite at launch, so the probe cannot read it. That half rests on
`askForARating(after:)` returning before the claim when `isEnabledHere` is `false` — the reviewer
checks it (Task 5), and the records say so (Task 6).

- [ ] **Step 1: Write the probe.** Create `WaterBuddyUITests/RatingProbe.swift`:

```swift
//
//  RatingProbe.swift — THROWAWAY (plan 2026-10-15-rating-prompt, Task 4). Deleted before staging.
//

import XCTest

/// Drives the rating request on the DEBUG fresh start, which writes only a throwaway suite and an
/// in-memory store.
final class RatingProbe: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: Setup — goal 1,000, two goal days behind today, today at 750

    @MainActor
    private func launchedAtTheBrink(asking: Bool) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-WaterBuddyFreshStart", "YES"]
        if asking { app.launchArguments += ["-WaterBuddyReviewPrompt", "YES"] }
        app.launch()

        let getStarted = app.buttons["Get Started"]
        XCTAssertTrue(getStarted.waitForExistence(timeout: 10), "the fresh start did not open on the welcome")
        getStarted.tap()

        let goal = app.sliders["Daily water goal"]
        XCTAssertTrue(goal.waitForExistence(timeout: 5), "the welcome's goal step did not appear")
        goal.adjust(toNormalizedSliderPosition: 0)
        XCTAssertEqual(goal.value as? String, "1000 millilitres", "the goal did not go to its floor")

        for _ in 0..<2 {
            let next = app.buttons["Continue"]
            XCTAssertTrue(next.waitForExistence(timeout: 5), "the welcome's Continue did not appear")
            tapWhenReady(next)
        }
        let notNow = app.buttons["Not now"]
        XCTAssertTrue(notNow.waitForExistence(timeout: 5), "the welcome's last step did not appear")
        tapWhenReady(notNow)

        pour("Glass", in: app)   // today 250, and the week card drawn

        app.buttons["History"].tap()
        for name in Self.dayNames()[1...2] {
            fill(app.buttons[name], named: name, in: app)
        }

        app.buttons["Home"].tap()
        pour("Bottle", in: app)  // today 750
        return app
    }

    /// Adds the sheet's largest serving to `day` until it holds the goal.
    @MainActor
    private func fill(_ day: XCUIElement, named name: String, in app: XCUIApplication) {
        XCTAssertTrue(day.waitForExistence(timeout: 5), "the week card has no button for \(name)")
        day.tap()
        var adds = 0
        while Self.millilitres(on: day) < 1_000, adds < 4 {
            let before = Self.millilitres(on: day)
            app.buttons["Add a serving"].tap()
            let amount = app.sliders["Serving amount"]
            XCTAssertTrue(amount.waitForExistence(timeout: 5), "the serving sheet did not open")
            amount.adjust(toNormalizedSliderPosition: 1)
            app.buttons["Save"].tap()
            let deadline = Date().addingTimeInterval(5)
            while Self.millilitres(on: day) <= before, Date() < deadline {
                Thread.sleep(forTimeInterval: 0.2)
            }
            adds += 1
        }
        XCTAssertGreaterThanOrEqual(Self.millilitres(on: day), 1_000, "\(name) did not reach the goal")
    }

    @MainActor
    private func pour(_ vessel: String, in app: XCUIApplication) {
        let button = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", vessel + ",")).firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 5), "Home has no \(vessel)")
        button.tap()
    }

    // MARK: The request, wherever iOS draws it

    @MainActor
    private func request(in app: XCUIApplication) -> XCUIElement? {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for root in [app, springboard] {
            let notNow = root.buttons["Not Now"]
            if notNow.exists { return notNow }
        }
        return nil
    }

    @MainActor
    private func waitForRequest(_ app: XCUIApplication, within seconds: TimeInterval) -> XCUIElement? {
        let deadline = Date().addingTimeInterval(seconds)
        repeat {
            if let found = request(in: app) { return found }
            Thread.sleep(forTimeInterval: 0.2)
        } while Date() < deadline
        return nil
    }

    @MainActor
    private func shot(_ name: String, _ app: XCUIApplication) {
        let screen = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        screen.name = name
        screen.lifetime = .keepAlways
        add(screen)
        let tree = XCTAttachment(string: app.debugDescription
            + "\n\n--- SpringBoard ---\n\n"
            + XCUIApplication(bundleIdentifier: "com.apple.springboard").debugDescription)
        tree.name = name + "-tree"
        tree.lifetime = .keepAlways
        add(tree)
    }

    // MARK: The cases

    /// The pour that makes the third goal day asks, after the confetti; the same version is not
    /// asked again.
    @MainActor
    func testAThirdGoalDayAsksOnceInAVersion() {
        let app = launchedAtTheBrink(asking: true)
        let poured = Date()
        pour("Bottle", in: app)
        let found = waitForRequest(app, within: 8)
        shot("A-asked", app)
        guard let notNow = found else { return XCTFail("no rating request after the third goal day's pour") }
        XCTAssertGreaterThanOrEqual(Date().timeIntervalSince(poured), 2.0, "the request did not wait for the confetti")
        notNow.tap()

        let undo = app.buttons["Undo"]
        XCTAssertTrue(undo.waitForExistence(timeout: 2), "the Undo offer was gone before the second crossing")
        undo.tap()
        pour("Bottle", in: app)
        XCTAssertNil(waitForRequest(app, within: 5), "asked twice in one version")
        shot("A-not-again", app)
    }

    /// An *Undo* inside the pause asks nothing, and leaves the version's request for the next
    /// crossing.
    @MainActor
    func testBAnUndoInsideThePauseAsksNothing() {
        let app = launchedAtTheBrink(asking: true)
        let poured = Date()
        pour("Bottle", in: app)
        app.buttons["Undo"].tap()
        XCTAssertLessThan(Date().timeIntervalSince(poured), 2.0, "the Undo landed after the pause; this proves nothing")
        XCTAssertNil(waitForRequest(app, within: 5), "asked after the pour that reached the goal was taken back")
        shot("B-undone", app)

        pour("Bottle", in: app)
        XCTAssertNotNil(waitForRequest(app, within: 8), "the taken-back crossing used up the version's request")
        shot("B-asked", app)
    }

    /// Another tab inside the pause asks nothing.
    @MainActor
    func testCLeavingHomeInsideThePauseAsksNothing() {
        let app = launchedAtTheBrink(asking: true)
        let poured = Date()
        pour("Bottle", in: app)
        app.buttons["History"].tap()
        XCTAssertLessThan(Date().timeIntervalSince(poured), 2.0, "the tab changed after the pause; this proves nothing")
        XCTAssertNil(waitForRequest(app, within: 5), "asked after Home was left")
        shot("C-left", app)
    }

    /// The Home Screen inside the pause, and back: nothing asks, then or on return.
    @MainActor
    func testDGoingToTheHomeScreenInsideThePauseAsksNothing() {
        let app = launchedAtTheBrink(asking: true)
        pour("Bottle", in: app)
        XCUIDevice.shared.press(.home)
        Thread.sleep(forTimeInterval: 3)
        app.activate()
        XCTAssertNil(waitForRequest(app, within: 5), "the request met the user on their way back")
        shot("D-back", app)
    }

    /// A DEBUG build launched without the argument never asks.
    @MainActor
    func testEWithoutTheArgumentADebugBuildNeverAsks() {
        let app = launchedAtTheBrink(asking: false)
        pour("Bottle", in: app)
        XCTAssertNil(waitForRequest(app, within: 6), "a DEBUG build asked without being launched to")
        shot("E-unasked", app)
    }

    /// The goal reached from History's **+** for today asks nothing, on History or back on Home.
    @MainActor
    func testFTheGoalReachedFromHistoryAsksNothing() {
        let app = launchedAtTheBrink(asking: true)
        app.buttons["History"].tap()
        fill(app.buttons["Today"], named: "Today", in: app)
        XCTAssertNil(waitForRequest(app, within: 4), "History's + asked")
        app.buttons["Home"].tap()
        XCTAssertNil(waitForRequest(app, within: 4), "Home asked for a crossing it did not pour")
        shot("F-history", app)
    }

    // MARK: Helpers copied from GoalSetupUITests

    private static func dayNames() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("EEEE")
        let calendar = Calendar.autoupdatingCurrent
        let past = (1...6).compactMap { calendar.date(byAdding: .day, value: -$0, to: Date()) }
        return ["Today"] + past.map(formatter.string(from:))
    }

    @MainActor
    private static func millilitres(on day: XCUIElement) -> Int {
        Int((day.value as? String ?? "").split(separator: " ").first ?? "") ?? -1
    }
}
```

- [ ] **Step 2: Run the first half.** `uptime` first. Then:

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Probe 27' -only-testing:WaterBuddyUITests/RatingProbe/testAThirdGoalDayAsksOnceInAVersion -only-testing:WaterBuddyUITests/RatingProbe/testBAnUndoInsideThePauseAsksNothing -only-testing:WaterBuddyUITests/RatingProbe/testCLeavingHomeInsideThePauseAsksNothing -parallel-testing-enabled NO -collect-test-diagnostics never -resultBundlePath "$SCRATCH/probe-1.xcresult" 2>&1 | grep -E "Executed|error:|failed|passed" | tail -12
xcrun xcresulttool export attachments --path "$SCRATCH/probe-1.xcresult" --output-path "$SCRATCH/probe-1-shots"
```

  Open each screenshot with `Read` (`manifest.json` names them).

- [ ] **Step 3: If a finder missed** — the screenshot shows the request but `request(in:)` returned
  `nil`, or a setup step found nothing — read that step's `-tree` attachment, change only the
  **finder or the gesture**, never what the test expects, and re-run the failing test alone
  (`tasks/lessons.md`, 2026-10-15). If the screenshot shows **no** request where one was expected,
  that is a finding: stop and diagnose with `superpowers:systematic-debugging` before changing code.

- [ ] **Step 4: Run the second half** — the same command with `testD…`, `testE…`, `testF…` and
  `probe-2`. Read its shots.

- [ ] **Step 5: Record and delete.** Write each test's result, its timing line and its shots' names
  into the ledger. Then `rm WaterBuddyUITests/RatingProbe.swift` and `git status --short
  WaterBuddyUITests` (expect nothing). Shut *WaterBuddy Probe 27* down by UDID:
  `xcrun simctl shutdown 43E0B902-C6D5-48DD-B513-F22AF3BE9BEA`.

---

### Task 5: The review, the gate, the warning comparison

- [ ] **Step 1: A fresh reviewer.** Stage the code and tests by explicit path first
  (`WaterBuddy/DataManager.swift`, `WaterBuddy/ReviewPrompt.swift`, `WaterBuddy/HomeView.swift`,
  `WaterBuddyTests/ReviewRequestTests.swift`, `WaterBuddyTests/DataManagerTests.swift`), so the
  review reads `git diff --cached`. A read-only subagent reviews it against the spec, P1–P5, the
  rules (`70-privacy`, `20-state`, `25-shared-storage`, `50-views`, `43-concurrency`, `85-testing`
  — the five amended ones in the working tree) and the DocC of the types changed. Its brief includes:
  confirm that only `pour(_:)` moves `goalPours` (Review Focus 4). Save its report to the ledger
  folder as it arrives. Check every finding against the code before acting on it; a fix goes
  through the task that owns the file, tests first.
- [ ] **Step 2: The gate.** Rule `85-testing`'s invocations on this machine's destinations. `uptime`
  before each; shut down by UDID between systems.
  1. Unit tests on the stock iOS 27.0 *iPhone 17*:
     `xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Test run with|✘" | tail -20`.
     Expect 616 tests (604 + 12).
  2. The UI suite on *WaterBuddy Gate 27*. `GoalSetupUITests` (36 tests) in four chunks of nine:

```zsh
grep -oE "func test[A-Za-z0-9]+" WaterBuddyUITests/GoalSetupUITests.swift | sed 's/^func //' | sort > "$SCRATCH/goalsetup.txt"; wc -l < "$SCRATCH/goalsetup.txt"
FLAGS=$(sed -n '1,9p' "$SCRATCH/goalsetup.txt" | sed 's#^#-only-testing:WaterBuddyUITests/GoalSetupUITests/#' | tr '\n' ' '); xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' ${=FLAGS} -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Executed|error:|failed" | tail -8
```

     then the same with `'10,18p'`, `'19,27p'` and `'28,36p'`, then
     `-only-testing:WaterBuddyUITests -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests -skip-testing:WaterBuddyUITests/GoalSetupUITests`.
     Read each run's **executed** count.
  3. The same five UI runs on *WaterBuddy Gate 26.5* (`OS=26.5`).
  4. Watch tests on *WaterBuddy Watch 27*:
     `xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Test run with|✘" | tail -10`.
  5. `xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' 2>&1 | grep -E "error:|BUILD" | tail -3`.
  6. `xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' 2>&1 | grep -E "error:|BUILD" | tail -3`.
- [ ] **Step 3: The warning comparison**, from the staged index:

```bash
git checkout-index -a --prefix="$SCRATCH/after/"
xcodebuild build-for-testing -project "$SCRATCH/after/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'generic/platform=iOS Simulator' -derivedDataPath "$SCRATCH/after-dd" > "$SCRATCH/after-app.log" 2>&1; echo "exit $?"
xcodebuild build -project "$SCRATCH/after/WaterBuddy.xcodeproj" -scheme WaterBuddyWidgetExtension -destination 'generic/platform=iOS Simulator' -derivedDataPath "$SCRATCH/after-dd" > "$SCRATCH/after-widget.log" 2>&1; echo "exit $?"
cat "$SCRATCH"/after-app.log "$SCRATCH"/after-widget.log | grep -E ': warning: ' | sed -E 's#^.*/after/##; s#^(Water[^:]+):[0-9]+:[0-9]+: #\1: #' | sort -u > "$SCRATCH/after-messages.txt"; wc -l < "$SCRATCH/after-messages.txt"
comm -13 "$SCRATCH/base-messages.txt" "$SCRATCH/after-messages.txt"
comm -23 "$SCRATCH/base-messages.txt" "$SCRATCH/after-messages.txt"
```

  Expected: both `comm`s print nothing. A new line is fixed before reporting, or, if it cannot be,
  reported as a failure.

---

### Task 6: Records, docs — then stop

- [ ] `docs/STATE.md`: a row for `Key.reviewRequestedVersion` — `String`, absent = never asked, never
  materialised, written only by `claimReviewRequest(version:)`, read with `object(forKey:) as? String`,
  not migrated, not in the snapshot or the mirror; every "nine keys" naming the phone's suite
  becomes "ten" (`:89`, `:219`, `:315`, `:328`, `:381`, `:550` at planning — re-grep, and change only
  the ones that count the phone's suite); its *Last updated* line.
- [ ] `docs/AI_CONTEXT.md`:
  - a block at the head of *Current state* for 1.2.5, and a *Last updated* paragraph;
  - *Files on disk*: `ReviewPrompt.swift` and `ReviewRequestTests.swift` new; `DataManager.swift`'s,
    `HomeView.swift`'s and `DataManagerTests.swift`'s line counts and descriptions;
  - the gate's results and counts from Task 5, by the attribute grep, and the warning comparison;
  - a new known issue for the device sweep (1.2.7): an Xcode build with `-WaterBuddyReviewPrompt YES`
    on the owner's iPhone, §7.3's steps 2–3 there, and the first App Store release watched for the
    request — TestFlight never shows it (spec §7.4); and anything Task 4 could not prove.
- [ ] `CLAUDE.md`: its two lines are already typed (spec §5); check them again and leave them.
- [ ] `docs/ROADMAP.md`: item 1.2.5 marked built in the tree, awaiting `/commit` and the device
  sweep; §8's `StoreKit` row noted as approved for 1.2.5 only (D3), 1.4.1 to amend again.
- [ ] `HISTORY.md` appended with `Edit`, anchored on its last lines. `tasks/lessons.md` only if the
  work earned a lesson; never one written for the sake of it.
- [ ] Before the readers, search every sheet and the known issues for the subject in plain words —
  "rating", "review", "StoreKit", "nine keys", "9 keys", "eight" — and the string catalogues for
  "rate" and "review" (`tasks/lessons.md`, 2026-10-15); retire what this fixed, open an issue for
  copy it made incomplete. Check every `File.swift:N` the sheets cite against the tree.
- [ ] **Two fresh readers** (read-only subagents) on the records. Brief them by line range, and point
  them at the ledger, the gate's output, the probe's shots and the saved review. Save each report as
  it arrives, check its findings against their primary source, and fix by deleting or by quoting the
  source.
- [ ] Stage by explicit path: `WaterBuddy/DataManager.swift`, `WaterBuddy/ReviewPrompt.swift`,
  `WaterBuddy/HomeView.swift`, `WaterBuddyTests/ReviewRequestTests.swift`,
  `WaterBuddyTests/DataManagerTests.swift`, the spec, this plan, `CLAUDE.md`, `docs/AI_CONTEXT.md`,
  `docs/STATE.md`, `docs/ROADMAP.md`, `HISTORY.md` (and `tasks/lessons.md` if touched). The five
  rule files stay unstaged. Write the git block last, from `git status --short` and
  `git diff --cached --name-status` run at that moment.
- [ ] **Stop.** Report:
  - what was built;
  - what the probe proved, with its shots, and what it could not;
  - the gate's counts and the warning comparison;
  - the rule wording waiting, unstaged;
  - the commit order: the spec and plan as `docs`, the code as `feat(app)`, the records as `docs`,
    and the rules as `chore(claude)`.
