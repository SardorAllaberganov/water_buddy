# The Premium Redesign, Stage 5 (the Welcome) — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: `superpowers:executing-plans`, **in this session** —
> `CLAUDE.md` allows no implementation subagent. Steps use checkbox (`- [ ]`) syntax. **No step
> commits:** each task stages its own paths by name, and nothing is committed until the owner runs
> `/commit`.

**Goal:** The first-run screen becomes four steps — Hello, Daily goal, Vessels, Reminders — with an
optional goal calculator in the goal step, replacing `GoalSetupView`; reminder permission moves
into one place both Settings and the welcome call, and is re-read on every return to the
foreground.

**Architecture:** Four new app-only files — `WelcomeView.swift` (the screen, its steps and the
finishing order), `GoalSuggestion.swift` (the calculator's integer arithmetic),
`ReminderPermission.swift` (asking and re-reading permission), `VesselSliders.swift` (the vessel
rows lifted out of Settings). `GoalSetupView.swift` is deleted. `WaterBuddyApp.swift` shows the
welcome, re-reads permission on the foreground, and gains a DEBUG-only fresh start for the
welcome's UI tests. No stored key, no `DataManager` API, no shared, widget or watch file changes
beyond comments.

**Tech Stack:** Swift (language mode 5; the app and test targets default to main-actor isolation),
SwiftUI (iOS 17 floor; Apple's glass on iOS 26 and later through `.liquidGlass`), swift-testing,
XCTest, Xcode 27.0, Python 3 + Pillow for measuring (scratch only).

**Spec:** `docs/superpowers/specs/2026-10-14-welcome-design.md` (approved 2026-10-14, "ok"), and
the canvas <https://claude.ai/artifact/ACaiHVsHL7pXhKuFdGGb65>, whose five boards' source is in this
session's scratchpad at `…/6e5ac781-…/scratchpad/welcome-canvas/project/*.dc.html`. Every canvas value
below was read from that source.

**Ledger:** `.superpowers/sdd/2026-10-14-premium-redesign-stage-5/progress.md` (git-ignored).

## Decisions this plan takes

The spec leaves these open or says them loosely. Each is this session's, and the owner's to
overturn when reviewing the plan.

- **P1 — the four steps stand side by side and move together.** `WelcomeStep.offset(shown:across:
  slides:)` puts each step `(its index − the shown one's) × width` across, and one
  `.animation(_:value: step)` moves them all. The direction comes from the order. `PageTurn` is
  not generalised: it is `AppTab`'s, and it keeps two pages at most because a tab page is rebuilt
  each time it is shown. The welcome keeps all four, so *Back* returns to the step as it was left.
- **P2 — only Hello settles in.** Spec §6 says "each step's cards rise in as they arrive (`Arrival`,
  the stagger Settings uses)". Settings' stagger runs only on the page the app opens on: a page
  that slides in is whole as it comes (`Arrival`'s DocC, the owner's 2026-10-12 ruling). So Hello's
  vessel and greeting rise in as the app opens, and the steps that slide in are whole.
- **P3 — the bar's buttons are rounded rectangles at `LiquidGlass.cornerRadius`.** At 56 pt that
  is the canvas's capsule. A label that wraps at the largest sizes keeps a 28-pt corner instead of
  becoming a stadium.
- **P4 — one key beyond spec §8: `now`.** It is the corner of the notification preview, as on
  the canvas.
- **P5 — the scroll that brings the opened calculator into view runs inside
  `withTransaction(\.animation, Motion.settle)`.** It is the app's first programmatic scroll. A scroll
  position is not view state that `.animation(_:value:)` can scope. Rule `50-views` bans a bare
  `withAnimation`, and this is the same mechanism under another name — so it is named here rather
  than slipped in. The alternative is an unanimated jump.
- **P6 — the welcome is seeded from the model through `init`** —
  `WelcomeView(goal: manager.dailyGoal, amounts: manager.servings)`. Rule `50-views` asks for this,
  rather than for `DataManager`'s defaults. On a fresh install the two give the same values.
- **P7 — the fresh start is passed with a value: `-WaterBuddyFreshStart YES`.** A `-key` argument
  takes the next argument as its value. On its own it would swallow the
  `-UIPreferredContentSizeCategoryName` that follows it in the large-text test.
- **P8 — the welcome's UI tests include two vessel round trips:** one set in the welcome, one set in
  Settings, each read back on Home. The Settings one guards the extraction (P9). It lives in
  `WelcomeUITests` because that is the only class allowed the fresh start, and the fresh start is
  what lets it edit a vessel without changing a gate device's own amounts.
- **P9 — the calculator's unpicked choices draw no fill.** The canvas gives them white 0.05. Rule
  `60-design-system` wants every selection mark drawn from `LiquidGlass.Selection`, present at
  zero when nothing is picked.
- **P10 — the bells' times are drawn as hours** in the phone's own 12- or 24-hour form: *9 AM*, or
  *9*. Their type is capped at `.xxxLarge`. The row is one element to VoiceOver, so nothing is lost
  to the cap.

## Global Constraints

- iOS floor **17.0**. No `#available` added or changed.
- Every colour from `Aurora` and white opacities. Every pane goes through `.liquidGlass(…)`, and every
  card is `.frosted` + `.raised`, Settings' pair. The one main action of a step goes through
  `.primarySurface(in:)`. No corner-radius literal: `LiquidGlass.cornerRadius` for a pane,
  `LiquidGlass.innerCornerRadius` for an element inside one (rule `60-design-system`).
- Volumes are `Int`. A visible volume is grouped with `strings.figure("%1$@ ml", …, locale:)`. A
  spoken volume keeps a `%1$d … millilitres` key (rule `50-views`). No `Double` holds a volume
  outside a `Slider` binding that rounds back to `Int`.
- Every scaled size is a real magnitude with a ceiling at its use site. Every tap target has a
  `minHeight` of at least 44. A row of controls that cannot fit stacks through `ViewThatFits`, and
  is never shrunk below 44 (rule `65-accessibility`).
- Haptics go through `Haptics` only, each driven by a counter the user's own touch bumps:
  - `select` for a step, a slider step, or a pick;
  - `confirm` for *Use* and for finishing.
- Motion uses `Motion.page`, `Motion.pageFade`, `Motion.settle` and `Motion.land`, each scoped with
  `.animation(_:value:)`. Under Reduce Motion nothing travels, and the Hello waves stand at their
  resting frame.
- Every user-visible string is in `WaterBuddy/Localizable.xcstrings` with explicit `en`, `ru` and `uz`
  values, `"extractionState": "manual"`, and positional specifiers. The file's existing JSON shape and
  key order are kept: code-point sorted, `"key": {`. The welcome draws nothing in the widget or the
  watch, so `sharedKeys` gains nothing.
- Reminder authorization is asked only from a tap that asks for reminders, and `ReminderScheduler.live()`
  is built inside the `Task` that uses it (rule `80-notifications`).
- The weight, its unit and the activity are `@State`, written nowhere (rule `70-privacy`).
- Tests come first: write, run, **see RED**, implement, run GREEN. Never narrow an assertion.
- **No new warning** against the clean baseline of HEAD `1438122` (Task 0), compared per file and message.
- Edit with `Edit`/`Write` only: no `sed -i`, no heredoc into the tree. Scratch work goes in this
  session's scratchpad.
- Simulators:
  - Unit tests run on the stock iOS 27.0 *iPhone 17*.
  - UI tests run on *WaterBuddy Gate 27* and *Gate 26.5*.
  - Renders run on the *Probe*, *Fallback* and *Small* devices.
  - Run `uptime` before each run. Shut down **by UDID**, never `shutdown all`.
  - Every test run takes `-parallel-testing-enabled NO` and `-collect-test-diagnostics never`, and
    runs in the foreground.
  - No UI run may cross midnight.
- Never write the real App Group suite or `UserDefaults.standard`. The fresh start writes only its own
  throwaway suite.
- Never commit. Stage explicit paths. The rule files stay unstaged for the owner's yes.

## Review Focus

These five inputs are the ones a person will meet that the spec does not test. Each is pinned by the
test named here, in the task that owns the code.

1. **Use, then the slider moved.** A user takes the suggestion, then drags the goal elsewhere. The *Use*
   button must come back, and say the same figure. → `testUseComesBackWhenTheGoalIsMovedAway`
   (Task 6).
2. **Back after the calculator was used.** Open it, pick *Active*, continue, come back: the panel,
   the pick and the goal stand as they were left. → `testAStepIsAsItWasLeftWhenBackReturnsToIt`
   (Task 6).
3. **The largest text on the smallest phone.** The bar stacks and grows. Each step's content must
   still be reachable by scrolling above it, and every control must still answer a tap.
   → `testTheWelcomeIsWalkableAtTheLargestTextSize` (Task 4), and a render on *WaterBuddy Small 26.5*
   (Task 7).
4. **A fresh start is only ever a throwaway.** It is absent without the argument, writes its own
   suite and never the App Group's, and is cleared at each launch.
   → `FreshStartTests` (Task 4).
5. **Permission withdrawn in iOS Settings while the app was away** (#100(d)). The re-read clears the
   flag on `.denied`, asks nothing, and leaves every other status alone.
   → `ReminderPermissionTests`' reconcile tests (Task 1). The foreground wiring is two lines, read
   in review; no simulator switch withdraws a notification permission, so its end-to-end proof is a
   device check, recorded as such.

## File structure

| File | Change |
|---|---|
| `WaterBuddy/ReminderPermission.swift` | **new** — `enable(on:using:)`, `reconcile(_:using:)` |
| `WaterBuddy/VesselSliders.swift` | **new** — the three vessel rows, from `ServingsCard` |
| `WaterBuddy/WelcomeView.swift` | **new** — `WelcomeStep`, `WelcomeView`, `HelloVessel`, `NotificationPreview`, `ReminderBells`, `CalculatorPanel`, `WelcomeStyle` |
| `WaterBuddy/GoalSuggestion.swift` | **new** — `GoalSuggestion`, `.Unit`, `.Activity` |
| `WaterBuddy/GoalSetupView.swift` | **deleted** (`git rm`) |
| `WaterBuddy/WaterBuddyApp.swift` | `RootView` shows `WelcomeView`; the foreground reconcile; the DEBUG fresh start |
| `WaterBuddy/SettingsView.swift` | permission through `ReminderPermission`; `ServingsCard` draws `VesselSliders`; `GoalCard` reads `WelcomeView`'s menu |
| `WaterBuddy/Localizable.xcstrings` | 28 new keys |
| `WaterBuddy/AuroraBackground.swift`, `DataManager.swift`, `HistoryView.swift`, `HomeView.swift` | comments naming `GoalSetupView` |
| `WaterBuddyTests/WelcomeTests.swift` | **new** — `ReminderPermissionTests`, `WelcomeStepTests`, `WelcomeFinishTests`, `FreshStartTests` |
| `WaterBuddyTests/GoalSuggestionTests.swift` | **new** — `GoalSuggestionTests` |
| `WaterBuddyTests/LocalizationTests.swift` | `welcomeKeys`, `WelcomeStringTests` |
| `WaterBuddyTests/DataManagerTests.swift`, `HistoryViewTests.swift` | `WelcomeView.goalRange`; comments |
| `WaterBuddyUITests/WelcomeUITests.swift` | **new** — `completeWelcomeIfShown(_:)`, `WelcomeUITests` |
| `WaterBuddyUITests/GoalSetupUITests.swift` | eleven preambles → `completeWelcomeIfShown(app)`; DocC |
| `WaterBuddyUITests/AppStoreScreenshotUITests.swift` | walks the welcome |
| `Tools/CaptureScreenshots.sh`, `Tools/CaptureFullCensus.sh` | comments naming `GoalSetupView` |
| `.claude/rules/10-architecture.md`, `43-concurrency.md`, `50-views.md`, `70-privacy.md`, `80-notifications.md`, `85-testing.md` | spec §11's wording — **unstaged** |
| `docs/DESIGN.md`, `docs/AI_CONTEXT.md`, `docs/STATE.md`, `docs/ROADMAP.md`, `CLAUDE.md`, `HISTORY.md`, `tasks/lessons.md` | records (Task 10) |

All four new Swift files are app-only. The app's synchronized folder gives them membership; no
`project.pbxproj` edit and no exception set changes.

## Commands used below

Shorthand, expanded in full wherever a step runs it:

```bash
# UNIT <filter>: one swift-testing suite on the stock iOS 27.0 iPhone 17
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/<filter> -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Test run with|✘|error:" | tail -20

# UI <class or class/test>: on WaterBuddy Gate 27
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' -only-testing:WaterBuddyUITests/<class or class/test> -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Executed|error:|Failing|failed" | tail -10
```

Run `uptime` first. If the 1-minute load is above 6, wait for it to fall before a UI run (known
issue #122).

---

### Task 0: The ledger and the baseline

**Files:** the ledger; scratch.

- [ ] **Step 1:** `git status --short`. Expect: `A  docs/superpowers/specs/2026-10-14-welcome-design.md`,
  this plan once it is staged, the six long-standing modified paths, and `Screenshots/census/`
  untracked. None of the last seven is this stage's. Write them into the ledger as the
  starting state.
- [ ] **Step 2: The warnings baseline.** Export HEAD and build it clean:

```bash
mkdir -p "$SCRATCH/base" && git archive HEAD | tar -x -C "$SCRATCH/base"
xcodebuild build-for-testing -project "$SCRATCH/base/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -derivedDataPath "$SCRATCH/base-dd" > "$SCRATCH/base-app.log" 2>&1; echo "exit $?"
xcodebuild build -project "$SCRATCH/base/WaterBuddy.xcodeproj" -scheme WaterBuddyWidgetExtension -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -derivedDataPath "$SCRATCH/base-dd" > "$SCRATCH/base-widget.log" 2>&1; echo "exit $?"
cat "$SCRATCH"/base-*.log | grep -E "warning:" | sed -E 's#^.*/base/##; s/:[0-9]+:[0-9]+:/:/' | sort -u > "$SCRATCH/base-warnings.txt"; wc -l < "$SCRATCH/base-warnings.txt"
```

  `$SCRATCH` is this session's scratchpad. Expect both builds to exit 0 and about 31 unique lines,
  the count `CLAUDE.md` records. The count goes in the ledger.

---

### Task 1: `ReminderPermission` — one way to ask, one way to re-read

**Files:**
- Create: `WaterBuddy/ReminderPermission.swift`
- Create: `WaterBuddyTests/WelcomeTests.swift` (this task writes its fixtures and `ReminderPermissionTests`)
- Modify: `WaterBuddy/SettingsView.swift:225-257` (`enableReminders()`, `readSystemState()`)
- Modify: `WaterBuddy/WaterBuddyApp.swift:54-61` (the foreground)

**Interfaces:**
- Consumes: `ReminderScheduler` (`NotificationManager.swift:34`) — `authorizationStatus: () async ->
  UNAuthorizationStatus`, `requestAuthorization: () async throws -> Bool`; `DataManager.remindersEnabled`.
- Produces: `@MainActor enum ReminderPermission` with
  `static func enable(on manager: DataManager, using scheduler: ReminderScheduler) async` and
  `@discardableResult static func reconcile(_ manager: DataManager, using scheduler: ReminderScheduler) async -> UNAuthorizationStatus`.
  The test file's private fixtures `withWelcomeSuite(_:)`, `welcomeManager(_:)`, `PermissionSpy` and
  `RequestFailed`, which Tasks 3 and 4 reuse.

- [ ] **Step 1: Check the fixture names are free.**

```bash
grep -rnE "withWelcomeSuite|welcomeManager|PermissionSpy|RequestFailed|ReminderPermissionTests|WelcomeStepTests|WelcomeFinishTests|FreshStartTests|GoalSuggestionTests|WelcomeStringTests" WaterBuddyTests/ WaterBuddy/
```

  Expect no output.

- [ ] **Step 2: Write the failing tests** — `WaterBuddyTests/WelcomeTests.swift`:

```swift
//
//  WelcomeTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 14/10/26.
//

import Foundation
import SwiftData
import Testing
import UserNotifications
@testable import WaterBuddy

// MARK: - Fixtures

/// A UUID-named throwaway suite, removed when `body` returns — never the App Group's, never
/// `.standard`'s (rule `85-testing`).
@MainActor
private func withWelcomeSuite(_ body: (UserDefaults) async throws -> Void) async rethrows {
    let name = "test.waterbuddy.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    try await body(defaults)
}

/// A manager on `defaults` and an in-memory store, its calendar and clock pinned, every side effect
/// a no-op. `rescheduleReminders` above all: its production default builds a real
/// `UNUserNotificationCenter`, and `init` reschedules (rule `85-testing`).
@MainActor
private func welcomeManager(_ defaults: UserDefaults) -> DataManager {
    var utc = Calendar(identifier: .gregorian)
    utc.timeZone = TimeZone(identifier: "UTC")!
    return DataManager(
        defaults: defaults,
        modelContainer: try! ModelContainer(
            for: WaterLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ),
        calendar: utc,
        // 2026-10-14, 12:00 UTC.
        now: { Date(timeIntervalSince1970: 1_791_979_200) },
        reloadWidgets: {},
        rescheduleReminders: { _ in },
        publishWrist: { _ in }
    )
}

/// What a refused request can throw.
private struct RequestFailed: Error {}

/// A notification centre that is only the two closures permission uses, and counts them.
///
/// The other four never run here; they are inert so a stray call files nothing anywhere. Never a
/// real centre: `UNUserNotificationCenter` cannot be faked, which is why `ReminderScheduler` is a
/// struct of closures (`NotificationManagerTests`' `SchedulerSpy` says the same).
@MainActor
private final class PermissionSpy {

    var status: UNAuthorizationStatus
    var answer: Result<Bool, RequestFailed>

    /// Run as the request is made, before it is answered — where a test looks at the model.
    var onRequest: () -> Void = {}

    private(set) var statusReads = 0
    private(set) var requests = 0

    init(status: UNAuthorizationStatus, answer: Result<Bool, RequestFailed> = .success(true)) {
        self.status = status
        self.answer = answer
    }

    func scheduler() -> ReminderScheduler {
        ReminderScheduler(
            pendingIdentifiers: { [] },
            add: { _ in },
            removePending: { _ in },
            removeDelivered: { _ in },
            authorizationStatus: { [self] in
                statusReads += 1
                return status
            },
            requestAuthorization: { [self] in
                requests += 1
                onRequest()
                return try answer.get()
            }
        )
    }
}

// MARK: - Permission

/// Asking for reminders and re-reading what iOS says — one implementation for Settings' switch and
/// the welcome's *Turn on reminders* (spec 2026-10-14 §6).
@MainActor
struct ReminderPermissionTests {

    @Test func aGrantIsStored() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            let spy = PermissionSpy(status: .notDetermined, answer: .success(true))

            await ReminderPermission.enable(on: manager, using: spy.scheduler())

            #expect(spy.requests == 1)
            #expect(manager.remindersEnabled)
        }
    }

    @Test func aRefusalIsStoredAsOff() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            let spy = PermissionSpy(status: .notDetermined, answer: .success(false))

            await ReminderPermission.enable(on: manager, using: spy.scheduler())

            #expect(spy.requests == 1)
            #expect(manager.remindersEnabled == false, "a refusal stored as on is a switch that lies")
        }
    }

    @Test func aRequestThatFailsIsStoredAsOff() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            let spy = PermissionSpy(status: .notDetermined, answer: .failure(RequestFailed()))

            await ReminderPermission.enable(on: manager, using: spy.scheduler())

            #expect(manager.remindersEnabled == false)
        }
    }

    @Test func aPhoneAlreadyAllowedIsNotAskedAgain() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            let spy = PermissionSpy(status: .authorized)

            await ReminderPermission.enable(on: manager, using: spy.scheduler())

            #expect(spy.requests == 0, "iOS asks once; a second request shows nothing and answers the old answer")
            #expect(manager.remindersEnabled)
        }
    }

    @Test func aPhoneThatRefusedIsNotAskedAndStaysOff() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            let spy = PermissionSpy(status: .denied)

            await ReminderPermission.enable(on: manager, using: spy.scheduler())

            #expect(spy.requests == 0)
            #expect(manager.remindersEnabled == false)
        }
    }

    /// Withdrawn in iOS Settings while the app was away (#100(d)).
    @Test func aReReadTurnsRemindersOffWhenTheyAreRefused() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            manager.remindersEnabled = true
            let spy = PermissionSpy(status: .denied)

            let status = await ReminderPermission.reconcile(manager, using: spy.scheduler())

            #expect(status == .denied)
            #expect(manager.remindersEnabled == false)
            #expect(spy.requests == 0, "a re-read never asks")
        }
    }

    @Test(arguments: [UNAuthorizationStatus.authorized, .notDetermined, .provisional, .ephemeral])
    func aReReadLeavesTheSwitchAloneOtherwise(status: UNAuthorizationStatus) async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            manager.remindersEnabled = true
            let spy = PermissionSpy(status: status)

            let read = await ReminderPermission.reconcile(manager, using: spy.scheduler())

            #expect(read == status, "Settings draws its refused state from what this returns")
            #expect(manager.remindersEnabled)
            #expect(spy.requests == 0)
        }
    }
}
```

- [ ] **Step 3: RED.** Run `uptime`, then
  `UNIT ReminderPermissionTests` (expanded:
  `xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/ReminderPermissionTests -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Test run with|✘|error:" | tail -20`).
  Expected: `error: cannot find 'ReminderPermission' in scope`. Any other error — a warning about
  the spy's closures, for instance — goes in the ledger and is fixed in the test before Step 4.

- [ ] **Step 4: Implement** — `WaterBuddy/ReminderPermission.swift`:

```swift
//
//  ReminderPermission.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 14/10/26.
//

import UserNotifications

/// Asking iOS for reminders, and re-reading what it says.
///
/// **Two taps ask, and both run ``enable(on:using:)``**: Settings' switch turning on, and *Turn on
/// reminders* on the welcome's last step — the moment the user has just asked for reminders, and no
/// other (rule `70-privacy`). It asks only when iOS has not been asked yet. For any other status it
/// stores what iOS already says, because iOS asks once and a second request shows nothing.
///
/// **A refusal is stored as off.** A switch that reads "on" while every reminder is silently
/// dropped is worse than no switch at all — so a refusal, or a request that fails, leaves
/// ``DataManager/remindersEnabled`` `false` rather than storing an intent iOS will never honour.
///
/// **And the answer is re-read, because it can be withdrawn.** iOS Settings can turn notifications
/// off while this app is in the background. ``reconcile(_:using:)`` notices, and clears the flag
/// through the model's own setter, which clears the schedule still filed. It runs whenever the app
/// comes forward and whenever Settings is shown, so Home stops promising a *Next reminder* that
/// cannot fire (known issue #100(d)).
///
/// It decides nothing about *when* to remind — that is ``ReminderPlan``'s — and it takes the
/// scheduler as a parameter, built by the caller inside the task that uses it
/// (rule `80-notifications`).
@MainActor
enum ReminderPermission {

    /// Asks if iOS has not been asked, and stores the answer; stores what iOS says otherwise.
    static func enable(on manager: DataManager, using scheduler: ReminderScheduler) async {
        let status = await scheduler.authorizationStatus()

        if status == .notDetermined {
            let granted = (try? await scheduler.requestAuthorization()) ?? false
            manager.remindersEnabled = granted
        } else {
            manager.remindersEnabled = status != .denied
        }
    }

    /// Reads what iOS says, turns reminders off if it refuses them, and returns what it read. Never
    /// asks.
    @discardableResult
    static func reconcile(_ manager: DataManager, using scheduler: ReminderScheduler) async -> UNAuthorizationStatus {
        let status = await scheduler.authorizationStatus()

        if status == .denied, manager.remindersEnabled {
            manager.remindersEnabled = false
        }

        return status
    }
}
```

- [ ] **Step 5: Settings goes through it.** In `WaterBuddy/SettingsView.swift`, replace
  `enableReminders()` and `readSystemState()` (lines 225–257) with:

```swift
    // MARK: - Permission

    /// Asks once, then records the answer — through ``ReminderPermission``, which the welcome's
    /// *Turn on reminders* runs too, so the two taps that ask cannot disagree about what a refusal
    /// stores.
    private func enableReminders() async {
        await ReminderPermission.enable(on: manager, using: scheduler)
        await readSystemState()
    }

    /// What iOS says now: the permission, re-read through ``ReminderPermission`` — which turns the
    /// switch off if it was withdrawn while the app was away — and the notification summary, which
    /// is not a permission and stays this screen's own question.
    private func readSystemState() async {
        authorization = await ReminderPermission.reconcile(manager, using: scheduler)

        deliveryIsBatched = await UNUserNotificationCenter.current()
            .notificationSettings()
            .scheduledDeliverySetting == .enabled
    }
```

- [ ] **Step 6: The foreground re-reads it.** In `WaterBuddy/WaterBuddyApp.swift`, replace the
  `.onChange(of: scenePhase)` block (lines 54–61) with:

```swift
        .onChange(of: scenePhase) { _, phase in
            // Another process may have written while we were away — the widget's `AddWaterIntent`
            // runs in the extension, not here — and the day may have turned over. `refresh()` is
            // idempotent, so an extra call costs nothing.
            if phase == .active {
                manager.refresh()

                // And notifications may have been turned off in iOS Settings meanwhile. Noticed
                // here, every screen stops promising a reminder that cannot fire (known issue
                // #100(d)). The scheduler is built inside the task and never stored
                // (rule `80-notifications`).
                Task { await ReminderPermission.reconcile(manager, using: ReminderScheduler.live()) }
            }
        }
```

- [ ] **Step 7: GREEN.** Run `UNIT ReminderPermissionTests` again. Expect every test to pass: seven
  test functions, one of them run over four statuses. Write the count the output prints into the
  ledger, as printed. Then
  run the Settings UI guards on *Gate 27*:
  `UI GoalSetupUITests/testSettingsIsReachableFromHomeAsATab` and
  `UI GoalSetupUITests/testEverySettingsControlIsOneElement` (one invocation with both
  `-only-testing:` flags). Expect `Executed 2 tests, with 0 failures`.
- [ ] **Step 8: Stage**:
  `git add WaterBuddy/ReminderPermission.swift WaterBuddyTests/WelcomeTests.swift WaterBuddy/SettingsView.swift WaterBuddy/WaterBuddyApp.swift`.

---

### Task 2: `VesselSliders` — the vessel rows, lifted out of Settings

A refactor with no change in behaviour. It has no RED of its own. The guards are Settings' existing
UI tests, run before and after. The save round trip is `testAVesselEditedInSettingsIsSavedAsBefore`,
which needs the fresh start and arrives in Task 4.

**Files:**
- Create: `WaterBuddy/VesselSliders.swift`
- Modify: `WaterBuddy/SettingsView.swift:563-767` (`ServingsCard`)

**Interfaces:**
- Consumes: `vesselSlots` (`WaterSurface.swift:168`), `HistoryView.servingRange` / `.servingStep`,
  `Bundle.figure(_:_:locale:)`, `Haptics.select`, `Motion.land`.
- Produces: `struct VesselSliders: View` — `init(amounts: Binding<[Int]>, onDrag: @escaping (Bool) -> Void = { _ in })`
  (the memberwise init of `@Binding var amounts` and `var onDrag`).

- [ ] **Step 1: Guards before.** Run `uptime`, then on *Gate 27* `UI GoalSetupUITests/testEverySettingsControlIsOneElement` together with
  `GoalSetupUITests/testSettingsSaysWhichVesselTheOneTapDoorsLog` (two `-only-testing:` flags).
  Expect `Executed 2 tests, with 0 failures`, recorded in the ledger as the before.

- [ ] **Step 2: Create `WaterBuddy/VesselSliders.swift`:**

```swift
//
//  VesselSliders.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 14/10/26.
//

import SwiftUI

/// The three quick-add vessels' rows — each one's glyph, name and amount over its slider — for
/// amounts the caller holds.
///
/// **Two screens draw them, and each keeps what is set its own way.** Settings' vessels card saves a
/// change as its slider is let go; the welcome's vessels step keeps the amounts until the welcome
/// ends. So that stays with the caller: this view moves the amounts under a finger, ticks each step,
/// and says when a finger lands and lifts (``onDrag``), and nothing else. It was the inside of
/// `SettingsView`'s `ServingsCard` until the welcome became the second screen to ask; one view is
/// what keeps the two from drifting apart (rule `50-views`).
///
/// Ascent is deliberately **not** enforced. Making an edit to Cup push Glass out of its way would
/// silently change what the widget logs; see ``DataManager/servings``.
struct VesselSliders: View {

    /// Cup, Glass, Bottle — positional and exactly three (``DataManager/servings``).
    @Binding var amounts: [Int]

    /// Told `true` as a finger lands on a slider and `false` as it lifts. Settings saves on the
    /// lift; the welcome does not listen.
    var onDrag: (Bool) -> Void = { _ in }

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    /// Which vessel's slider is held, by slot. Its figure is drawn a little larger meanwhile, and a
    /// step is ticked only while one is.
    @State private var held: Int?

    /// Bumped each time a drag moves a vessel by a step: the tick under the finger. A counter the
    /// slider bumps, not the amount, so an amount the caller takes from a re-read never ticks
    /// (rule `60-design-system`, *Haptics*).
    @State private var steps = 0

    /// The canvas's 26-pt glyph box, scaled with the name beside it and capped at its use site.
    @ScaledMetric(relativeTo: .body) private var glyphBox: CGFloat = 26

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(Array(vesselSlots.enumerated()), id: \.element.nameKey) { index, slot in
                vessel(at: index, slot: slot)
            }
        }
        .sensoryFeedback(Haptics.select, trigger: steps)
    }

    private func vessel(at index: Int, slot: (nameKey: String, symbol: String)) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Side by side while they fit. At the accessibility text sizes on a small phone the
            // amount was cut to "150…" beside its name; there it drops under the name instead
            // (rule `65-accessibility`, *Dynamic Type*).
            //
            // **The side-by-side row is measured at its widest**, every vessel's name and the
            // largest amount the slider reaches, drawn hidden underneath: a fit decided by the
            // amount under the finger flipped the row to two lines as a drag passed 1,000, and
            // left the three rows in different shapes.
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    ZStack(alignment: .leading) {
                        ForEach(vesselSlots, id: \.nameKey) { label(for: $0).hidden() }
                        label(for: slot)
                    }
                    Spacer(minLength: 8)
                    ZStack(alignment: .trailing) {
                        amountText(HistoryView.servingRange.upperBound).hidden()
                        amount(at: index, anchor: .trailing)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    label(for: slot)
                    amount(at: index, anchor: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .foregroundStyle(.white)
            // The slider below speaks the name and the value as one sentence, so this row would be
            // a duplicate stop (rule `65-accessibility`).
            .accessibilityHidden(true)

            Slider(
                value: binding(for: index),
                in: Double(HistoryView.servingRange.lowerBound)...Double(HistoryView.servingRange.upperBound),
                step: Double(HistoryView.servingStep),
                onEditingChanged: { editing in
                    held = editing ? index : nil
                    onDrag(editing)
                }
            )
            .tint(Aurora.cyan)
            // A `Slider`'s stock VoiceOver value is a percentage of its range, which would announce
            // "22%" for a 250 ml glass — a number that appears nowhere in the product.
            // Resolved through the chosen bundle rather than written as `Text(slot.nameKey,
            // bundle:)`: that initialiser takes a `LocalizedStringKey`, which must be a literal,
            // and a runtime key silently becomes the *fallback text* instead of a lookup.
            .accessibilityLabel(strings.localizedString(forKey: slot.nameKey, value: slot.nameKey, table: nil))
            .accessibilityValue(String(format: strings.localizedString(forKey: "%1$d millilitres", value: nil, table: nil), amounts[index]))
        }
    }

    /// A vessel's glyph and name.
    private func label(for slot: (nameKey: String, symbol: String)) -> some View {
        let box = min(glyphBox, 40)

        return HStack(spacing: 12) {
            Image(systemName: slot.symbol)
                .font(.system(size: box * 0.8))
                // Against its 3:1 floor the Cup's, beside the card's sheen, is the tightest:
                // 3.08 / 4.02 / 3.09:1 on iOS 27.0 / 26.5 / 18.6 (`docs/DESIGN.md`, *Settings,
                // measured*).
                .foregroundStyle(Aurora.cyan)
                // One box for all three, so the names beside them start on one line whatever
                // each glyph's own width.
                .frame(width: box, height: box)
                // The name beside it says which vessel this is; the glyph repeating it would be a
                // second stop saying the same thing.
                .accessibilityHidden(true)

            Text(verbatim: strings.localizedString(forKey: slot.nameKey, value: slot.nameKey, table: nil))
                .font(.body.weight(.medium))
        }
    }

    /// A vessel's amount, grouped as every visible volume is (rule `50-views`): a bottle of 1,000
    /// read "1000 ml" here while Home and History drew "1,000 ml".
    private func amountText(_ volume: Int) -> some View {
        Text(strings.figure("%1$@ ml", volume, locale: locale))
            .font(.body.weight(.bold))
            .fontDesign(.rounded)
            .monospacedDigit()
    }

    /// The amount under the finger, a little larger while its slider is held, as the goal's is —
    /// from the edge it is pinned to, so it grows into its row and not into the card's padding.
    private func amount(at index: Int, anchor: UnitPoint) -> some View {
        amountText(amounts[index])
            .scaleEffect(held == index ? 1.06 : 1, anchor: anchor)
            .animation(Motion.land, value: held)
    }

    /// Bridges the `Int` the caller holds to the `BinaryFloatingPoint` a `Slider` requires.
    ///
    /// `rounded()`, never truncation: the `step` already snaps the value, and rounding is what stops
    /// floating-point dust from turning 250 into 249.9999 which truncation would read as 249.
    /// A step is ticked only while a finger holds a slider: a VoiceOver adjustment takes the
    /// caller's own confirmation instead.
    private func binding(for index: Int) -> Binding<Double> {
        Binding(
            get: { Double(amounts[index]) },
            set: { value in
                let stepped = Int(value.rounded())
                guard stepped != amounts[index] else { return }
                amounts[index] = stepped
                if held != nil { steps += 1 }
            }
        )
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var amounts = DataManager.defaultServings

    VesselSliders(amounts: $amounts)
        .padding(20)
        .liquidGlass(density: .frosted, elevation: .raised)
        .padding(24)
        .background { AuroraBackground() }
}
```

  `@Previewable` needs Xcode 16 or later; the toolchain is Xcode 27.0. `DataManager.defaultServings`
  is `nonisolated static` (`DataManager.swift:73`).

- [ ] **Step 3: `ServingsCard` draws it.** In `WaterBuddy/SettingsView.swift`, replace the whole
  `ServingsCard` struct (from `/// The three amounts the Home tab's quick-add row logs.` at line 565
  to its closing brace at line 767) with:

```swift
/// The three amounts the Home tab's quick-add row logs.
///
/// **The Glass is also what the widget's button, Siri's phrase and the Control Center control
/// log**, which is the one thing about this card a user could not otherwise discover — so it is
/// stated on the card rather than left to be found by arithmetic, and by the vessel's name, which
/// is what the row above it says. That sentence is the replacement for what used to be a
/// compile-time guarantee: the amount was a constant both front doors spelled, and it is now a
/// stored value every one-tap door reads (``DataManager/usualServing(in:)``).
///
/// **The rows are ``VesselSliders``**, which the welcome's vessels step draws too. This card keeps
/// what is Settings' own: the title, the note, the save as a slider is let go, the re-read, and the
/// saved tick.
///
/// Three sliders stacked is affordable here only because `SettingsView` wraps its content in the
/// `GeometryReader`/`ScrollView`/`minHeight` shape rule `65-accessibility` prescribes — at the
/// accessibility sizes the card grows and the screen scrolls, rather than the stack compressing and
/// its text truncating, which is exactly how the week card shipped a bug earlier in this session.
private struct ServingsCard: View {

    @Environment(\.strings) private var strings
    @Environment(DataManager.self) private var manager

    /// The three amounts under the finger. Seeded through `init` rather than in `.task` or
    /// `.onAppear`, and re-seeded from a re-read, for the reasons ``GoalCard`` is (rule `50-views`).
    @State private var amounts: [Int]

    /// Whether a drag is in flight — what makes one gesture one write. See ``commitIfChanged()``.
    @State private var isDragging = false

    /// Bumped on a committed change, so the haptic fires on the change rather than on the touch.
    @State private var commits = 0

    init(current: [Int]) {
        _amounts = State(initialValue: current)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Quick-add vessels", bundle: strings)
                .cardTitle()
                // Drawn when a vessel's new amount has been saved (``SavedTick``).
                .savedTick(commits)

            VesselSliders(amounts: $amounts) { editing in
                isDragging = editing
                if !editing { commitIfChanged() }
            }

            VStack(alignment: .leading, spacing: 16) {
                Hairline()
                Text("The Glass is the one your widget, Siri and Control Center log.", bundle: strings)
                    .cardNote()
            }
        }
        .settingsCard()
        .sensoryFeedback(Haptics.confirm, trigger: commits)
        .onChange(of: manager.servings) { _, stored in
            guard !isDragging else { return }
            amounts = stored
        }
        .onChange(of: amounts) { _, _ in
            // A VoiceOver adjustment is not a drag, so a change arriving with no drag in flight
            // commits here — otherwise a vessel could only be edited by dragging, which a VoiceOver
            // user cannot do. The guard keeps a whole drag to one write (rule `50-views`); a re-read
            // arrives here too, and finds the model already holding it.
            guard !isDragging else { return }
            commitIfChanged()
        }
    }

    /// One call into the model, only when something actually moved.
    ///
    /// The setter clamps each vessel, guards on equality, writes through and rings the widget
    /// doorbell — none of which is this view's to repeat (rule `20-state`). The guard here keeps the
    /// *haptic* honest: it fires on a change, not on a touch that ended where it started.
    private func commitIfChanged() {
        guard amounts != manager.servings else { return }
        manager.servings = amounts
        commits += 1
    }
}
```

- [ ] **Step 4: Build and the guards after.** `UNIT LocalizationTests` (it compiles everything, and
  the vessel names' keys are read there). Expect it to pass. Then rerun Step 1's UI command and
  expect `Executed 2 tests, with 0 failures`.
- [ ] **Step 5: Stage**: `git add WaterBuddy/VesselSliders.swift WaterBuddy/SettingsView.swift`.

---

### Task 3: `WelcomeView` replaces `GoalSetupView`

The four steps, the bar, the slide, the finishing order, and the goal's menu moving across. The
calculator comes in Task 6 and the fresh start in Task 4.

**Files:**
- Create: `WaterBuddy/WelcomeView.swift`
- Delete: `WaterBuddy/GoalSetupView.swift` (`git rm`)
- Modify:
  - `WaterBuddy/WaterBuddyApp.swift:65-107` (`RootView`)
  - `WaterBuddy/SettingsView.swift:13-22, 364-376, 483-504` (`GoalCard`'s menu and DocC)
  - `WaterBuddy/Localizable.xcstrings` (11 keys)
  - comments in `AuroraBackground.swift:14`, `DataManager.swift:1117,1133`, `HistoryView.swift:55,1349`
    and `HomeView.swift:50`
- Test:
  - `WaterBuddyTests/WelcomeTests.swift` (adds `WelcomeStepTests` and `WelcomeFinishTests`)
  - `WaterBuddyTests/DataManagerTests.swift:905,1131,1294-1330`
  - `WaterBuddyTests/HistoryViewTests.swift:67`
  - `WaterBuddyTests/LocalizationTests.swift` (adds `welcomeKeys` and `WelcomeStringTests`)

**Interfaces:**
- Consumes: Task 1's `ReminderPermission.enable(on:using:)`; Task 2's `VesselSliders(amounts:)`;
  `DataManager.servings` / `.saveDailyGoal(ml:)` / `.dailyGoal`; `ReminderPlan.hours`;
  `Arrival.hiddenOpacity`, `.arrives(_:order:)`, `.tracksArrival(_:)`, `\.pageSettlesIn`; `Motion`;
  `ScreenMetrics`; `.legibleOnBackdrop()`; `WaterSurface(level:phase:amplitude:)`.
- Produces:
  - `nonisolated enum WelcomeStep: Int, CaseIterable, Sendable { case hello, goal, vessels, reminders }`
    with `next`, `previous`, `number`, `offset(shown:across:slides:) -> CGFloat` and
    `opacity(shown:slides:) -> Double`.
  - `struct WelcomeView: View` with `init(goal: Int, amounts: [Int])`,
    `nonisolated static let goalRange: ClosedRange<Int>`, `nonisolated static let goalStep: Int`,
    `nonisolated static func bellTimes(in calendar: Calendar) -> [Date]`, and
    `static func finish(goal: Int, amounts: [Int], asksForReminders: Bool, on manager: DataManager, using scheduler: ReminderScheduler) async`.
  - The private `stepPage(_:title:subtitle:content:)`, which Task 6 changes.

- [ ] **Step 1: The failing unit tests.** Append to `WaterBuddyTests/WelcomeTests.swift`:

```swift
// MARK: - The steps

/// The welcome's steps as a value (spec 2026-10-14 §§5–6). Not `@MainActor`: ``WelcomeStep`` sits at
/// file scope, `nonisolated`, as ``AppTab`` does, and this suite is the canary that keeps it there
/// (rule `43-concurrency`).
struct WelcomeStepTests {

    @Test func theStepsComeInTheOrderTheyAreWalked() {
        #expect(WelcomeStep.allCases == [.hello, .goal, .vessels, .reminders])
    }

    @Test func theFirstStepHasNoBackAndTheLastNoContinue() {
        #expect(WelcomeStep.hello.previous == nil)
        #expect(WelcomeStep.reminders.next == nil)
    }

    @Test(arguments: WelcomeStep.allCases.dropLast())
    func continueBringsTheStepAfterAndBackReturns(step: WelcomeStep) throws {
        let next = try #require(step.next)
        #expect(next.rawValue == step.rawValue + 1)
        #expect(next.previous == step)
    }

    @Test func theDotsCountFromOne() {
        #expect(WelcomeStep.allCases.map(\.number) == [1, 2, 3, 4])
    }

    /// *Continue* brings the next step in from the trailing edge, *Back* from the leading.
    @Test func theNextStepWaitsOnTheTrailingSideAndThePreviousOnTheLeading() {
        #expect(WelcomeStep.vessels.offset(shown: .goal, across: 390, slides: true) == 390)
        #expect(WelcomeStep.hello.offset(shown: .goal, across: 390, slides: true) == -390)
        #expect(WelcomeStep.goal.offset(shown: .goal, across: 390, slides: true) == 0)
    }

    @Test func aStepThatSlidesIsSeenAllTheWayOut() {
        for step in WelcomeStep.allCases {
            #expect(step.opacity(shown: .hello, slides: true) == 1)
        }
    }

    /// Under Reduce Motion nothing travels, and the change is a cross-fade (rule `65-accessibility`).
    @Test func underReduceMotionNothingTravelsAndOnlyTheShownStepIsSeen() {
        for step in WelcomeStep.allCases {
            #expect(step.offset(shown: .vessels, across: 390, slides: false) == 0)
        }
        #expect(WelcomeStep.vessels.opacity(shown: .vessels, slides: false) == 1)

        let hidden = WelcomeStep.goal.opacity(shown: .vessels, slides: false)
        #expect(hidden > 0, "a step at exactly nothing has not always been given back to a finger")
        #expect(hidden < 1.0 / 255, "a step that is not shown is drawn")
    }

    /// The bells are the plan's own hours, so the row cannot show a time the plan does not keep.
    @Test func theBellsRingAtTheReminderHours() {
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!

        let hours = WelcomeView.bellTimes(in: utc).map { utc.component(.hour, from: $0) }

        #expect(hours == ReminderPlan.hours)
    }
}

// MARK: - Finishing

/// The welcome's end, without a screen: the vessels, then reminders if asked, then the goal — which
/// is what closes it (spec 2026-10-14 §5).
@MainActor
struct WelcomeFinishTests {

    @Test func vesselsLeftAsTheyWereStoreNothing() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            let spy = PermissionSpy(status: .notDetermined)

            await WelcomeView.finish(goal: 2_000, amounts: manager.servings, asksForReminders: false,
                                     on: manager, using: spy.scheduler())

            #expect(defaults.object(forKey: DataManager.Key.servings) == nil,
                    "an untouched row of vessels was stored, pinning today's defaults for good")
        }
    }

    @Test func vesselsSetInTheWelcomeAreStored() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            let spy = PermissionSpy(status: .notDetermined)

            await WelcomeView.finish(goal: 2_000, amounts: [200, 300, 750], asksForReminders: false,
                                     on: manager, using: spy.scheduler())

            #expect(manager.servings == [200, 300, 750])
            #expect(defaults.array(forKey: DataManager.Key.servings) as? [Int] == [200, 300, 750])
        }
    }

    @Test func finishingSavesTheGoalAndClosesTheWelcome() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            let spy = PermissionSpy(status: .notDetermined)
            #expect(manager.isGoalSet == false)

            await WelcomeView.finish(goal: 2_500, amounts: manager.servings, asksForReminders: false,
                                     on: manager, using: spy.scheduler())

            #expect(manager.dailyGoal == 2_500)
            #expect(manager.isGoalSet, "the root would stay on the welcome")
        }
    }

    /// The order, proved: iOS's question is answered while the welcome is still on screen, and only
    /// then does the goal close it.
    @Test func remindersAreAskedForBeforeTheWelcomeCloses() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            let spy = PermissionSpy(status: .notDetermined, answer: .success(true))
            var closedWhenAsked: Bool?
            spy.onRequest = { closedWhenAsked = manager.isGoalSet }

            await WelcomeView.finish(goal: 2_000, amounts: manager.servings, asksForReminders: true,
                                     on: manager, using: spy.scheduler())

            #expect(closedWhenAsked == false, "the welcome closed before iOS's question was answered")
            #expect(manager.remindersEnabled)
            #expect(manager.isGoalSet)
        }
    }

    @Test func aRefusalStillOpensTheAppWithRemindersOff() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            let spy = PermissionSpy(status: .notDetermined, answer: .success(false))

            await WelcomeView.finish(goal: 2_000, amounts: manager.servings, asksForReminders: true,
                                     on: manager, using: spy.scheduler())

            #expect(manager.remindersEnabled == false)
            #expect(manager.isGoalSet)
        }
    }

    /// *Not now* asks nothing — not even what iOS thinks.
    @Test func notNowAsksNothing() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            let spy = PermissionSpy(status: .notDetermined)

            await WelcomeView.finish(goal: 2_000, amounts: manager.servings, asksForReminders: false,
                                     on: manager, using: spy.scheduler())

            #expect(spy.statusReads == 0)
            #expect(spy.requests == 0)
            #expect(manager.remindersEnabled == false)
        }
    }
}
```

- [ ] **Step 2: The menu's tests read `WelcomeView`.** In `WaterBuddyTests/DataManagerTests.swift`:
  - Replace every `GoalSetupView.goalRange` with `WelcomeView.goalRange`, and every
    `GoalSetupView.goalStep` with `WelcomeView.goalStep`. That is lines 1302, 1307, 1308, 1313, 1314
    and 1321; Edit them one by one, and `grep -n GoalSetupView` afterwards should show only the
    comments.
  - Replace the comment at lines 1296–1299 with:

```swift
    // The welcome's goal step offers a narrower range than the store clamps to, which is the right
    // shape — 1 ml and 100,000 ml are legal to store and absurd to offer. But the two numbers
    // are declared in different files, and nothing in the compiler notices when one moves.
    // These four pin the seams between them. (They read `GoalSetupView`'s until stage 5.)
```

  - At line 905, `accepts `GoalSetupView`'s slider **unchanged**` → `accepts the first-run goal
    **unchanged**`.
  - At line 1131, `from `GoalSetupView`, which` → `from the first-run screen (`GoalSetupView` then,
    `WelcomeView` now), which`.
  - In `WaterBuddyTests/HistoryViewTests.swift:67`, `for `GoalSetupView.goalRange`` → `for
    `WelcomeView.goalRange``.

- [ ] **Step 3: The failing string test.** In `WaterBuddyTests/LocalizationTests.swift`, after
  `historyKeys` (line ~119), add:

```swift
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
]
```

  and after `HistoryStringTests`:

```swift
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
```

- [ ] **Step 4: RED.** `UNIT WelcomeStepTests`. Expected: errors `cannot find 'WelcomeStep' in
  scope` and `cannot find 'WelcomeView' in scope`. The target does not compile, which stops every
  suite in it; that is the RED for the three new suites and the moved menu.

- [ ] **Step 5: Create `WaterBuddy/WelcomeView.swift`:**

```swift
//
//  WelcomeView.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 14/10/26.
//

import SwiftData
import SwiftUI

// MARK: - The steps

/// The welcome's four steps, in the order they are walked.
///
/// A **top-level** enum, as ``AppTab`` is beside ``RootTabView``: `View` is `@MainActor`, and a type
/// nested in one would need `await` from `WelcomeStepTests`, which reads it off the main actor
/// (rule `43-concurrency`).
///
/// **The steps stand side by side in this order, and a change of step moves them all together.**
/// The step after the one shown waits a screen's width out on the trailing side, the step before it
/// on the leading side — so *Continue* brings its step in from the trailing edge and *Back* from the
/// leading edge, and nothing but the order decides the direction. ``PageTurn`` does the same for
/// the tabs with two pages at most, because a tab's page is rebuilt each time it is shown; the
/// welcome keeps all four, so a step *Back* returns to is the step as it was left.
nonisolated enum WelcomeStep: Int, CaseIterable, Sendable {

    case hello
    case goal
    case vessels
    case reminders

    /// The step *Continue* brings in; `nil` on the last, where the welcome ends instead.
    var next: WelcomeStep? { WelcomeStep(rawValue: rawValue + 1) }

    /// The step *Back* returns to; `nil` on the first, which has no *Back*.
    var previous: WelcomeStep? { WelcomeStep(rawValue: rawValue - 1) }

    /// Counted from one, as the dots are read: *Step 2 of 4*.
    var number: Int { rawValue + 1 }

    /// Where this step stands while `shown` is on screen, across a screen `width` wide. Under
    /// Reduce Motion (`slides` false) every step stands in place, and the change is a cross-fade
    /// (rule `65-accessibility`).
    func offset(shown: WelcomeStep, across width: CGFloat, slides: Bool) -> CGFloat {
        slides ? CGFloat(rawValue - shown.rawValue) * width : 0
    }

    /// What this step is drawn at. A step that slides is seen all the way out. Under Reduce Motion
    /// the steps stand on one another and only the one shown is seen — the rest at
    /// ``Arrival/hiddenOpacity``, never at exactly nothing, for the reason given there: a view at
    /// zero has not always been given back to a finger and to VoiceOver when it returned.
    func opacity(shown: WelcomeStep, slides: Bool) -> Double {
        slides || self == shown ? 1 : Arrival.hiddenOpacity
    }
}

// MARK: - The welcome

/// The first-run screen: four steps — hello, the daily goal, the quick-add vessels, reminders — and
/// then the app (spec `docs/superpowers/specs/2026-10-14-welcome-design.md`, the canvas
/// *WaterBuddy welcome*).
///
/// Shown instead of ``RootTabView`` while ``DataManager/isGoalSet`` is `false` — a state that exists
/// once per install, because the flag is never unset. Nobody who finished setup before stage 5 ever
/// sees it. It replaced `GoalSetupView`, the one-screen setup every install had shown since 1.0.
///
/// **Nothing is stored until the end.** The goal and the three amounts are this view's own state
/// while the steps are walked (rule `50-views`), so *Back* is free and a welcome left half-way
/// leaves nothing behind. Finishing is one call,
/// ``finish(goal:amounts:asksForReminders:on:using:)``, so its order is tested without a screen.
///
/// **A pinned bar.** The dots, *Back* and the step's main action stand at the foot of the screen
/// whatever the step's height, and the step scrolls above them: *Continue* is always under the
/// thumb (decision W5).
///
/// It stands its own ``AuroraBackground`` and declares the dark appearance itself, because it is a
/// root screen and not a page of ``RootTabView`` (rule `50-views`). Every backdrop reads one clock,
/// so `RootView`'s cross-fade to the tabs is still one surface.
struct WelcomeView: View {

    // MARK: The goal's menu

    /// The range the goal slider offers, which is intentionally *narrower* than what the store
    /// accepts.
    ///
    /// ``DataManager`` clamps a goal to `1...maximumDailyIntake` because a corrupt suite must not
    /// be able to divide by zero or overflow the total. That is a floor against corruption, not a
    /// menu: 1 ml and 100,000 ml are both legal to store and absurd to offer. These two numbers are
    /// the offer, and they live on a screen rather than on `DataManager` because the widget has no
    /// goal picker and nothing in the extension needs to agree about them.
    ///
    /// **Two screens ask** — this one and `SettingsView`'s `GoalCard`, which reads this same
    /// declaration rather than declaring its own: a range narrower in Settings than here would
    /// strand a user at a goal they had already chosen, and one wider there would offer an amount
    /// this screen called absurd. ``GoalSuggestion`` reads it too, so a suggestion always lands on
    /// the slider.
    ///
    /// The seams that *are* load-bearing — that ``DataManager/defaultDailyGoal`` sits inside this
    /// range, lands on a step, and that neither end is rewritten by the store's clamp — are pinned
    /// by `DailyGoalSetupTests`. They lived on `GoalSetupView` until stage 5. `nonisolated`, because
    /// suites off the main actor read them (rule `43-concurrency`).
    nonisolated static let goalRange = 1_000...4_000

    /// The slider's increment. 100 ml is roughly half a glass — fine enough to feel like a choice,
    /// coarse enough that a drag lands on a round number the user can hold in their head.
    nonisolated static let goalStep = 100

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The step on screen. Presentation state, and only the user's taps change it.
    @State private var step = WelcomeStep.hello

    /// The goal under the finger, in millilitres — an `Int`, as every volume in this product is. The
    /// `Double` a `Slider` demands exists only inside ``goalValue``.
    @State private var goal: Int

    /// Cup, Glass, Bottle (``DataManager/servings``), as the vessels step sets them.
    @State private var amounts: [Int]

    /// Whether a finger is on the goal slider: a step under a finger ticks.
    @State private var isDraggingGoal = false

    /// Set by the first tap of either finishing button and never cleared: the welcome finishes once,
    /// whatever iOS's question does meanwhile (decision W10).
    @State private var finishing = false

    /// Bumped by a step of the goal slider under a finger: the tick.
    @State private var goalSteps = 0

    /// Bumped by a finishing tap: the confirmation.
    @State private var finishes = 0

    /// Whether the welcome has arrived (``Arrival``). Hello settles in as the app opens; the steps
    /// that slide in after it are whole as they come.
    @State private var arrived = false

    /// The title VoiceOver is moved to when the step changes.
    @AccessibilityFocusState private var focusedTitle: WelcomeStep?

    /// The canvas's 60-pt goal figure, scaled as a large title is and capped at its use site.
    @ScaledMetric(relativeTo: .largeTitle) private var figureSize: CGFloat = 60

    /// The canvas's 42-pt *WaterBuddy*, scaled the same way.
    @ScaledMetric(relativeTo: .largeTitle) private var nameSize: CGFloat = 42

    /// Seeded from the model through `init`, never in `.task` (rule `50-views`). On a fresh install
    /// these are ``DataManager/defaultDailyGoal`` and ``DataManager/defaultServings``. The goal is
    /// kept on the slider, which offers nothing outside ``goalRange``.
    init(goal: Int, amounts: [Int]) {
        _goal = State(initialValue: min(max(goal, Self.goalRange.lowerBound), Self.goalRange.upperBound))
        _amounts = State(initialValue: amounts)
    }

    /// Whether a change of step carries the steps across the screen, or cross-fades them.
    private var slides: Bool { !reduceMotion }

    var body: some View {
        ZStack {
            AuroraBackground()

            VStack(spacing: 0) {
                steps
                bar
            }
        }
        // A root screen, so the status bar hangs over it: only the preference travels *up* to the
        // hosting controller and turns the clock and battery white (`RootTabView`'s note).
        .preferredColorScheme(.dark)
        // Ticks off the view's own state, which only the user's taps change (rule
        // `60-design-system`).
        .sensoryFeedback(Haptics.select, trigger: step)
        .sensoryFeedback(Haptics.select, trigger: goalSteps)
        .sensoryFeedback(Haptics.confirm, trigger: finishes)
        .tracksArrival($arrived)
        // VoiceOver starts the new step at its title, as a new screen would.
        .onChange(of: step) { _, shown in focusedTitle = shown }
    }

    // MARK: - The steps

    private var steps: some View {
        GeometryReader { proxy in
            // The whole screen's width, as `RootTabView` measures it.
            let width = proxy.size.width + proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing

            ZStack {
                ForEach(WelcomeStep.allCases, id: \.self) { page in
                    content(of: page)
                        // Hello settles in as the app opens; a step that slides in is whole as it
                        // comes (``Arrival``).
                        .environment(\.pageSettlesIn, page == .hello)
                        .offset(x: page.offset(shown: step, across: width, slides: slides))
                        .opacity(page.opacity(shown: step, slides: slides))
                        // Four steps exist; VoiceOver and a finger get the one shown.
                        .accessibilityHidden(page != step)
                        .allowsHitTesting(page == step)
                }
            }
            // Scoped to the step, never a bare `withAnimation` (rule `50-views`).
            .animation(slides ? Motion.page : Motion.pageFade, value: step)
        }
        // One point clear of the status bar — History's remedy (#108) — so a step scrolled up is
        // clipped under the clock rather than drawn across it (#89). Each step's inset gives the
        // point back, so its title stands where the tabs' titles do.
        .padding(.top, 1)
    }

    @ViewBuilder
    private func content(of page: WelcomeStep) -> some View {
        switch page {
        case .hello:
            hello
        case .goal:
            stepPage(
                .goal,
                title: Text("Daily goal", bundle: strings),
                subtitle: Text("How much water do you want to drink each day?", bundle: strings)
            ) {
                goalPage
            }
        case .vessels:
            stepPage(
                .vessels,
                title: Text("Quick-add vessels", bundle: strings),
                subtitle: Text("Home pours these in one tap. Set each to what yours holds.", bundle: strings)
            ) {
                vesselsStep
            }
        case .reminders:
            stepPage(
                .reminders,
                title: Text("Reminders", bundle: strings),
                subtitle: Text("A gentle nudge when it has been a while.", bundle: strings)
            ) {
                remindersStep
            }
        }
    }

    /// A step after the first: its title where the tabs' titles stand, a line under it, and what it
    /// asks — all of it scrolling above the bar (rule `65-accessibility`).
    private func stepPage<Content: View>(
        _ page: WelcomeStep,
        title: Text,
        subtitle: Text,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                title
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                    // It wraps rather than shrinking out of sight: *Tez qo‘shish idishlari* is a long
                    // title at the ordinary size, and the largest sizes are larger still.
                    .fixedSize(horizontal: false, vertical: true)
                    // The tabs' title line, so the title stands where theirs does
                    // (`testAStepsTitleStandsWhereATabsTitleDoes`).
                    .frame(maxWidth: .infinity, minHeight: ScreenMetrics.titleLine, alignment: .leading)
                    .legibleOnBackdrop()
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityFocused($focusedTitle, equals: page)

                subtitle
                    .font(.body)
                    .foregroundStyle(.white.opacity(WelcomeStyle.textOpacity))
                    .fixedSize(horizontal: false, vertical: true)
                    .legibleOnBackdrop()
                    .padding(.top, WelcomeStyle.subtitleGap)

                content()
                    .padding(.top, WelcomeStyle.contentGap)
            }
            .padding(.horizontal, ScreenMetrics.margin)
            // Every tab's inset, less the point the steps stand off the safe area (above).
            .padding(.top, ScreenMetrics.topInset - 1)
            .padding(.bottom, WelcomeStyle.contentGap)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    // MARK: - Hello

    /// The canvas's first board: the vessel, the name and one line, centred while they fit and
    /// scrolling at the largest sizes (rule `65-accessibility`).
    private var hello: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: WelcomeStyle.contentGap)

                    HelloVessel(isShown: step == .hello)
                        .arrives(arrived, order: 0)

                    greeting
                        .padding(.top, WelcomeStyle.helloGap)
                        .arrives(arrived, order: 1)

                    Spacer(minLength: WelcomeStyle.contentGap)
                }
                .padding(.horizontal, ScreenMetrics.margin)
                .frame(maxWidth: .infinity)
                .frame(minHeight: proxy.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    private var greeting: some View {
        VStack(spacing: 0) {
            // Two lines, split by hand, because the name must never share a line box with the words
            // before it: left as one string the layout hyphenated it, "WaterBud-dy", at the
            // accessibility sizes. Each line's own `lineLimit(1)` is what turns "does not fit"
            // into "scale down" instead of "break". *WaterBuddy* is the larger: the name is the
            // point of the line (decision W8).
            VStack(spacing: 0) {
                Text("Welcome to", bundle: strings)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white.opacity(WelcomeStyle.textOpacity))
                Text("WaterBuddy", bundle: strings)
                    .font(.system(size: min(nameSize, WelcomeStyle.nameCeiling), weight: .heavy))
                    .tracking(WelcomeStyle.nameTracking)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            // One greeting, one stop — and the step's heading.
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
            .accessibilityFocused($focusedTitle, equals: .hello)

            Text("One tap logs a glass. Watch your day fill up.", bundle: strings)
                .font(.body)
                .foregroundStyle(.white.opacity(WelcomeStyle.textOpacity))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, WelcomeStyle.helloLineGap)
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(.white)
        .legibleOnBackdrop()
    }

    // MARK: - The daily goal

    private var goalPage: some View {
        VStack(spacing: 0) {
            goalCard
            footnote(Text("You can change this later in Settings.", bundle: strings))
        }
    }

    private var goalCard: some View {
        VStack(spacing: WelcomeStyle.cardGap) {
            goalFigure
            goalSlider
        }
        .welcomeCard()
    }

    private var goalFigure: some View {
        let size = min(figureSize, WelcomeStyle.figureCeiling)

        return HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(goal, format: .number)
                .font(.system(size: size, weight: .bold, design: .rounded))
                .tracking(WelcomeStyle.figureTracking)
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(goal)))

            // Sized as a ratio of the figure it annotates, never with its own text style: a fixed
            // style and a scaled figure cross over at the accessibility sizes (rule
            // `65-accessibility`).
            Text("ml", bundle: strings)
                .font(.system(size: size * WelcomeStyle.unitRatio, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(WelcomeStyle.unitOpacity))
        }
        .foregroundStyle(.white)
        .lineLimit(1)
        .minimumScaleFactor(0.4)
        .frame(maxWidth: .infinity)
        .shadow(color: .black.opacity(0.3), radius: 10, y: 2)
        .animation(Motion.settle, value: goal)
        // One idea, one element, as `GoalSetupView` read it: *Daily goal*, *N millilitres*.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Daily goal", bundle: strings))
        .accessibilityValue(spokenMillilitres(goal))
    }

    private var goalSlider: some View {
        VStack(spacing: 8) {
            Slider(
                value: goalValue,
                in: Double(Self.goalRange.lowerBound)...Double(Self.goalRange.upperBound),
                step: Double(Self.goalStep),
                onEditingChanged: { isDraggingGoal = $0 }
            )
            .tint(Aurora.cyan)
            // A `Slider`'s stock VoiceOver value is a percentage of its range, which would announce
            // "33%" for 2,000 ml — a number that appears nowhere in the product.
            .accessibilityLabel(Text("Daily water goal", bundle: strings))
            .accessibilityValue(spokenMillilitres(goal))

            HStack {
                Text(Self.goalRange.lowerBound, format: .number)
                Spacer()
                Text(Self.goalRange.upperBound, format: .number)
            }
            .font(.footnote.weight(.semibold))
            .monospacedDigit()
            .foregroundStyle(.white.opacity(WelcomeStyle.footnoteOpacity))
            // The slider already says where it is and what it can reach (rule `65-accessibility`).
            .accessibilityHidden(true)
        }
    }

    /// Bridges the `Int` this view holds to the `Double` a `Slider` requires. `rounded()`, never
    /// truncation, so floating-point dust cannot turn 2,000 into 1,999. A step is ticked only under
    /// a finger.
    private var goalValue: Binding<Double> {
        Binding(
            get: { Double(goal) },
            set: { value in
                let stepped = Int(value.rounded())
                guard stepped != goal else { return }
                goal = stepped
                if isDraggingGoal { goalSteps += 1 }
            }
        )
    }

    // MARK: - The vessels

    private var vesselsStep: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: WelcomeStyle.vesselGap) {
                // Settings' rows, the same view (``VesselSliders``). Nothing is saved here until the
                // welcome ends, so the drag is not listened to.
                VesselSliders(amounts: $amounts)

                VStack(alignment: .leading, spacing: WelcomeStyle.cardGap) {
                    Rectangle()
                        .fill(.white.opacity(WelcomeStyle.hairlineOpacity))
                        .frame(height: 1)
                        .accessibilityHidden(true)
                    Text("The Glass is the one your widget, Siri and Control Center log.", bundle: strings)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(WelcomeStyle.textOpacity))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .welcomeCard(alignment: .leading)

            footnote(Text("You can change these later in Settings.", bundle: strings))
        }
    }

    // MARK: - Reminders

    private var remindersStep: some View {
        VStack(spacing: WelcomeStyle.cardGap) {
            NotificationPreview()
            schedule
        }
    }

    private var schedule: some View {
        VStack(alignment: .leading, spacing: WelcomeStyle.cardGap) {
            Text("Smart reminders", bundle: strings)
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)

            ReminderBells()

            Text("A nudge every two hours from 9 AM to 9 PM, skipped if you drank in the hour before it. Reaching your goal silences the rest of the day.", bundle: strings)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(WelcomeStyle.textOpacity))
                .fixedSize(horizontal: false, vertical: true)
        }
        .welcomeCard(alignment: .leading)
    }

    /// ``ReminderPlan/hours`` as instants on one fixed day, for drawing only. A time of day is
    /// formatted from a date, and a fixed one keeps the clock out of it.
    nonisolated static func bellTimes(in calendar: Calendar) -> [Date] {
        ReminderPlan.hours.compactMap {
            calendar.date(from: DateComponents(year: 2026, month: 1, day: 15, hour: $0))
        }
    }

    // MARK: - The bar

    private var bar: some View {
        VStack(spacing: 0) {
            dots
            buttons
                .padding(.top, WelcomeStyle.dotsGap)
            if step == .reminders {
                notNow
                    .padding(.top, WelcomeStyle.notNowGap)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, ScreenMetrics.margin)
        .padding(.top, WelcomeStyle.barTop)
        .padding(.bottom, WelcomeStyle.barBottom)
        // *Back* arriving, *Not now* arriving, the dots moving on: a state that changes.
        .animation(Motion.settle, value: step)
    }

    private var dots: some View {
        HStack(spacing: WelcomeStyle.dotGap) {
            ForEach(WelcomeStep.allCases, id: \.self) { page in
                Capsule()
                    .fill(.white.opacity(page == step ? 1 : WelcomeStyle.dotOpacity))
                    .frame(width: page == step ? WelcomeStyle.currentDot : WelcomeStyle.dot,
                           height: WelcomeStyle.dot)
            }
        }
        // One element: *Step 2 of 4*.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(format: strings.localizedString(forKey: "Step %1$d of %2$d", value: nil, table: nil),
                                   step.number, WelcomeStep.allCases.count))
    }

    /// *Back* and the step's main action side by side while both fit on one line. At the largest
    /// sizes the main action stands over *Back*, each as wide as the bar — never a label cut short
    /// and never a control under 44 pt (rule `65-accessibility`).
    private var buttons: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: WelcomeStyle.buttonGap) {
                if step.previous != nil { backButton(oneLine: true) }
                primaryButton(oneLine: true)
            }
            VStack(spacing: WelcomeStyle.buttonGap) {
                primaryButton(oneLine: false)
                if step.previous != nil { backButton(oneLine: false) }
            }
        }
        .frame(maxWidth: .infinity)
    }

    /// The step's one main action, on the primary surface (rule `60-design-system`). At 56 pt its
    /// corner is a capsule's; a label wrapped at the largest sizes keeps the corner (decision P3).
    private func primaryButton(oneLine: Bool) -> some View {
        Button(action: advance) {
            primaryLabel
                .font(.headline.weight(.bold))
                .lineLimit(oneLine ? 1 : nil)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: oneLine, vertical: true)
                .padding(.horizontal, WelcomeStyle.buttonInset)
                .frame(maxWidth: .infinity, minHeight: WelcomeStyle.buttonHeight)
                .primarySurface(in: RoundedRectangle(cornerRadius: LiquidGlass.cornerRadius, style: .continuous))
        }
        .buttonStyle(PressStyle())
        .disabled(finishing)
    }

    @ViewBuilder
    private var primaryLabel: some View {
        switch step {
        case .hello: Text("Get Started", bundle: strings)
        case .goal, .vessels: Text("Continue", bundle: strings)
        case .reminders: Text("Turn on reminders", bundle: strings)
        }
    }

    private func backButton(oneLine: Bool) -> some View {
        Button {
            if let previous = step.previous { step = previous }
        } label: {
            Text("Back", bundle: strings)
                .font(.headline)
                .foregroundStyle(.white)
                .lineLimit(oneLine ? 1 : nil)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: oneLine, vertical: true)
                .padding(.horizontal, WelcomeStyle.buttonInset)
                .frame(minWidth: WelcomeStyle.backWidth, maxWidth: oneLine ? nil : .infinity,
                       minHeight: WelcomeStyle.buttonHeight)
                // A short label on a control, so `.sheer`; the glass itself is what is pressed
                // (rule `60-design-system`).
                .liquidGlass(in: RoundedRectangle(cornerRadius: LiquidGlass.cornerRadius, style: .continuous),
                             density: .sheer, elevation: .raised, interactive: true)
        }
        .buttonStyle(PressStyle())
        .disabled(finishing)
    }

    /// Ends the welcome and asks nothing: reminders stay off, as a fresh install has them.
    private var notNow: some View {
        Button {
            finish(askingForReminders: false)
        } label: {
            Text("Not now", bundle: strings)
                .font(.headline)
                .foregroundStyle(.white.opacity(WelcomeStyle.textOpacity))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 44)
                .contentShape(Rectangle())
                .legibleOnBackdrop()
        }
        .buttonStyle(PressStyle())
        .disabled(finishing)
    }

    /// *Continue*, or — on the last step, where it reads *Turn on reminders* — the welcome's end
    /// with reminders asked for.
    private func advance() {
        if let next = step.next {
            step = next
        } else {
            finish(askingForReminders: true)
        }
    }

    // MARK: - Finishing

    /// The welcome's end, from a tap. Once: both finishing buttons are disabled from the first tap.
    private func finish(askingForReminders: Bool) {
        guard !finishing else { return }
        finishing = true
        finishes += 1

        let goal = goal
        let amounts = amounts
        Task {
            // The scheduler is built here, inside the task, and never stored (rule
            // `80-notifications`).
            await Self.finish(goal: goal, amounts: amounts, asksForReminders: askingForReminders,
                              on: manager, using: ReminderScheduler.live())
        }
    }

    /// Ends the welcome: the vessels, then — if asked — reminders, then the goal.
    ///
    /// **The goal is last because it is what closes the welcome.** ``DataManager/saveDailyGoal(ml:)``
    /// flips ``DataManager/isGoalSet`` and `RootView` moves on to the tabs, so iOS's question about
    /// reminders is asked, and answered, over the welcome that asked it (spec 2026-10-09 §4.2). A
    /// refusal stores reminders off and the app still opens (``ReminderPermission``).
    ///
    /// Vessels left as they were store nothing: ``DataManager/servings``' setter guards on equality,
    /// so the defaults are not pinned into the suite for good.
    static func finish(goal: Int, amounts: [Int], asksForReminders: Bool,
                       on manager: DataManager, using scheduler: ReminderScheduler) async {
        manager.servings = amounts
        if asksForReminders {
            await ReminderPermission.enable(on: manager, using: scheduler)
        }
        manager.saveDailyGoal(ml: goal)
    }

    // MARK: - Parts

    /// A line under a card, on the aurora itself.
    private func footnote(_ text: Text) -> some View {
        text
            .font(.footnote)
            .foregroundStyle(.white.opacity(WelcomeStyle.footnoteOpacity))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .legibleOnBackdrop()
            .padding(.top, WelcomeStyle.footnoteGap)
    }

    /// A volume as VoiceOver reads it: a `%1$d` key, never the grouped figure (rule `50-views`).
    private func spokenMillilitres(_ volume: Int) -> String {
        String(format: strings.localizedString(forKey: "%1$d millilitres", value: nil, table: nil), volume)
    }
}

// MARK: - Hello's vessel

/// Half a glass of water, its waves moving: the first thing a new user sees.
///
/// Drawn from ``WaterSurface``'s waves in a sheer glass circle — the parts Home's vessel is built
/// from — and not from Home's own vessel, which brings a readout, a scrim, a slosh tied to pours and
/// an accessibility element that a decoration needs none of (decision W9). Hidden from VoiceOver.
///
/// The waves travel on a `TimelineView` clock that pauses while its step is not shown, and stand at
/// their resting frame under Reduce Motion: a perpetual animation resolves to nothing, never to a
/// gentler one (rule `65-accessibility`).
private struct HelloVessel: View {

    /// Whether Hello is the step on screen.
    let isShown: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Half full: the app's promise, drawn.
    private static let level = 0.5

    var body: some View {
        Group {
            if reduceMotion {
                waves(phase: 0)
            } else {
                TimelineView(.animation(minimumInterval: nil, paused: !isShown)) { context in
                    waves(phase: context.date.timeIntervalSinceReferenceDate * 1.1)
                }
            }
        }
        .frame(width: WelcomeStyle.vessel, height: WelcomeStyle.vessel)
        .liquidGlass(in: Circle(), density: .sheer, elevation: .floating)
        .accessibilityHidden(true)
    }

    /// Home's water at Home's proportions: the same amplitude for the diameter, inset 10 pt so it
    /// sits in a well and never covers the lit rim.
    private func waves(phase: Double) -> some View {
        WaterSurface(level: Self.level, phase: phase, amplitude: WelcomeStyle.vessel * 0.018)
            .clipShape(Circle())
            .padding(10)
    }
}

// MARK: - The reminder, previewed

/// What a reminder looks like, drawn from the real one's two strings, so the step shows exactly what
/// the user is agreeing to before iOS asks (decision W6). One element to VoiceOver.
private struct NotificationPreview: View {

    @Environment(\.strings) private var strings

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "drop.fill")
                .font(.system(size: WelcomeStyle.tileGlyph))
                .foregroundStyle(Aurora.cyan)
                .frame(width: WelcomeStyle.tile, height: WelcomeStyle.tile)
                .background(Aurora.gradient,
                            in: RoundedRectangle(cornerRadius: LiquidGlass.innerCornerRadius, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text("WaterBuddy", bundle: strings)
                    Spacer(minLength: 0)
                    Text("now", bundle: strings)
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(WelcomeStyle.footnoteOpacity))

                Text("Time for water", bundle: strings)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)

                Text("A glass now keeps you on track for the day.", bundle: strings)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(WelcomeStyle.textOpacity))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, WelcomeStyle.previewInset)
        .padding(.horizontal, WelcomeStyle.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlass(density: .frosted, elevation: .raised)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - The bells

/// The day's seven reminders as a row of bells, each over its time.
///
/// The times are ``ReminderPlan/hours`` — the schedule itself — drawn as hours in the phone's own
/// 12- or 24-hour form (decision P10). One element to VoiceOver, speaking the seven as a sentence;
/// the bells are decoration, so their type is capped where seven columns run out of room.
private struct ReminderBells: View {

    @Environment(\.calendar) private var calendar
    @Environment(\.locale) private var locale

    private static let hour = Date.FormatStyle.dateTime.hour(.defaultDigits(amPM: .abbreviated))

    var body: some View {
        let times = WelcomeView.bellTimes(in: calendar)

        HStack(spacing: 0) {
            ForEach(times, id: \.self) { time in
                VStack(spacing: 6) {
                    Image(systemName: "bell")
                        .font(.system(size: WelcomeStyle.bellGlyph, weight: .semibold))
                        .foregroundStyle(Aurora.cyan)
                        .frame(width: WelcomeStyle.bell, height: WelcomeStyle.bell)
                        .liquidGlass(in: Circle(), density: .sheer, elevation: .resting)

                    Text(time, format: Self.hour)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(WelcomeStyle.textOpacity))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                .frame(maxWidth: .infinity)
            }
        }
        // Seven discs side by side (rule `60-design-system`).
        .glassGroup()
        .background(alignment: .top) {
            // The line the bells sit on: from the first one's centre to the last one's, six of the
            // seven columns.
            GeometryReader { proxy in
                Rectangle()
                    .fill(.white.opacity(WelcomeStyle.bellLineOpacity))
                    .frame(width: proxy.size.width * CGFloat(max(times.count - 1, 0)) / CGFloat(max(times.count, 1)),
                           height: WelcomeStyle.bellLine)
                    .position(x: proxy.size.width / 2, y: WelcomeStyle.bell / 2)
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(times.map { $0.formatted(Self.hour.locale(locale)) }
            .formatted(.list(type: .and).locale(locale)))
    }
}

// MARK: - The canvas's figures

/// The welcome's figures, read from the canvas's five boards' source (spec 2026-10-14 §3). They are
/// starting values. Every text pair on glass or on the aurora is measured off a render before it is
/// kept (`docs/DESIGN.md`, *Welcome, measured*).
private enum WelcomeStyle {

    // Type
    static let textOpacity = 0.92
    static let footnoteOpacity = 0.88
    static let unitOpacity = 0.9

    // A step
    static let subtitleGap: CGFloat = 6
    static let contentGap: CGFloat = 18
    static let cardPadding: CGFloat = 20
    static let cardGap: CGFloat = 16
    static let footnoteGap: CGFloat = 10
    static let vesselGap: CGFloat = 20
    static let hairlineOpacity = 0.16

    // Hello
    static let vessel: CGFloat = 232
    static let helloGap: CGFloat = 52
    static let helloLineGap: CGFloat = 14
    static let nameCeiling: CGFloat = 64
    static let nameTracking: CGFloat = -0.8

    // The goal
    static let figureCeiling: CGFloat = 80
    static let figureTracking: CGFloat = -1.4
    static let unitRatio: CGFloat = 22 / 60

    // Reminders
    static let previewInset: CGFloat = 14
    static let tile: CGFloat = 38
    static let tileGlyph: CGFloat = 20
    static let bell: CGFloat = 34
    static let bellGlyph: CGFloat = 15
    static let bellLine: CGFloat = 2
    static let bellLineOpacity = 0.22

    // The bar
    static let barTop: CGFloat = 12
    static let barBottom: CGFloat = 8
    static let dot: CGFloat = 8
    static let currentDot: CGFloat = 22
    static let dotGap: CGFloat = 8
    static let dotOpacity = 0.35
    static let dotsGap: CGFloat = 16
    static let buttonHeight: CGFloat = 56
    static let buttonGap: CGFloat = 12
    static let buttonInset: CGFloat = 20
    static let backWidth: CGFloat = 112
    static let notNowGap: CGFloat = 6
}

private extension View {

    /// A card on a step: the canvas's padding, the full width, and the welcome's one glass —
    /// `.frosted` + `.raised` on every card, Settings' pair, because every card carries
    /// sentence-length text (rule `60-design-system`).
    func welcomeCard(alignment: Alignment = .center) -> some View {
        padding(WelcomeStyle.cardPadding)
            .frame(maxWidth: .infinity, alignment: alignment)
            .liquidGlass(density: .frosted, elevation: .raised)
    }
}

// MARK: - Preview

#Preview {
    // A throwaway suite *and* an in-memory store, so finishing the welcome on the canvas writes
    // nothing real, rings no real widget doorbell and reconciles no real reminders (rule `50-views`).
    let defaults = UserDefaults(suiteName: "preview.waterbuddy.welcome")!
    defaults.removePersistentDomain(forName: "preview.waterbuddy.welcome")

    let manager = DataManager(
        defaults: defaults,
        modelContainer: try! ModelContainer(
            for: WaterLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ),
        reloadWidgets: {},
        rescheduleReminders: { _ in },
        publishWrist: { _ in }
    )

    return WelcomeView(goal: manager.dailyGoal, amounts: manager.servings).environment(manager)
}
```

- [ ] **Step 6: `RootView` shows it.** In `WaterBuddy/WaterBuddyApp.swift`:
  - Replace `GoalSetupView()` (line 84) with `WelcomeView(goal: manager.dailyGoal, amounts: manager.servings)`.
  - In the DocC at line 67, `Chooses the app's first screen: setup until` → `Chooses the app's
    first screen: the welcome until`.
  - In the comment at line 89, `and so `GoalSetupView` outlives the tap long enough to play its
    haptic` → `and so the welcome outlives its last tap long enough to play its haptic`.
  - At line 73, `the first thing the user sees after tapping *Get Started* is the setup screen they
    just finished` → `the first thing the user sees after finishing the welcome is the welcome`.
- [ ] **Step 7: `GoalCard` reads the welcome's menu.** In `WaterBuddy/SettingsView.swift`, replace
  `GoalSetupView.goalRange` with `WelcomeView.goalRange` and `GoalSetupView.goalStep` with
  `WelcomeView.goalStep`, at lines 487, 488, 501 and 503. Then the DocC:
  - Line 20, `from `GoalSetupView`, leaving` → `from the one-screen setup (`GoalSetupView`, which
    the welcome replaced in stage 5), leaving`.
  - Line 368, `It offers ``GoalSetupView/goalRange`` — the same 1,000–4,000, in the same 100 ml
    steps, that setup offers.` → `It offers ``WelcomeView/goalRange`` — the same 1,000–4,000, in the
    same 100 ml steps, that the welcome offers.`
  - Lines 374–375, `because on `GoalSetupView` that card is the whole page` → `because on the
    welcome's goal step that card is the whole page`.
- [ ] **Step 8: The other comments.**
  - `AuroraBackground.swift:14`, `all three tabs and `GoalSetupView` stand glass on it` → `all three
    tabs and the welcome stand glass on it`.
  - `HomeView.swift:50`, ```GoalSetupView/goalRange``` → ```WelcomeView/goalRange```.
  - `HistoryView.swift:55`, ```GoalSetupView/goalRange``` → ```WelcomeView/goalRange```.
  - `HistoryView.swift:1349`, `the same lockup as `GoalSetupView`'s goal card` → `the same lockup as
    the welcome's goal card`.
  - `DataManager.swift:1117`, `from `GoalSetupView`, which is` → `from the first-run screen
    (`GoalSetupView` then, `WelcomeView` now), which is`.
  - `DataManager.swift:1133`, `accepts `GoalSetupView`'s slider unchanged` → `accepts the first-run
    goal unchanged`.

  `DataManager.swift` is compiled into the widget and both watch targets. These are comment-only
  edits, and the gate's two widget builds still cover them.

- [ ] **Step 9: Delete the old screen:** `git rm WaterBuddy/GoalSetupView.swift`.
- [ ] **Step 10: The strings.** Add these eleven entries to `WaterBuddy/Localizable.xcstrings`, each
  with `Edit`, at its code-point sorted position among the keys. Each takes the shape the file
  already uses:

```json
    "Continue": {
      "extractionState": "manual",
      "localizations": {
        "en": {
          "stringUnit": {
            "state": "translated",
            "value": "Continue"
          }
        },
        "ru": {
          "stringUnit": {
            "state": "translated",
            "value": "Продолжить"
          }
        },
        "uz": {
          "stringUnit": {
            "state": "translated",
            "value": "Davom etish"
          }
        }
      }
    },
```

| Key (= `en`) | `ru` | `uz` |
|---|---|---|
| `A gentle nudge when it has been a while.` | `Мягкое напоминание, если вы давно не пили.` | `Anchadan beri suv ichmagan bo‘lsangiz, yumshoq eslatma.` |
| `Back` | `Назад` | `Orqaga` |
| `Continue` | `Продолжить` | `Davom etish` |
| `Home pours these in one tap. Set each to what yours holds.` | `На Главной они наливаются одним касанием. Укажите, сколько вмещает каждая.` | `Bosh sahifa ularni bir teginishda quyadi. Har birini o‘z idishingiz hajmiga sozlang.` |
| `Not now` | `Не сейчас` | `Hozir emas` |
| `One tap logs a glass. Watch your day fill up.` | `Одно касание — и стакан записан. Смотрите, как наполняется ваш день.` | `Bir teginish — va stakan qayd etildi. Kuningiz qanday to‘layotganini kuzating.` |
| `Reminders` | `Напоминания` | `Eslatmalar` |
| `Step %1$d of %2$d` | `Шаг %1$d из %2$d` | `%1$d-qadam, jami %2$d` |
| `Turn on reminders` | `Включить напоминания` | `Eslatmalarni yoqish` |
| `You can change these later in Settings.` | `Их можно изменить позже в настройках.` | `Ularni keyinroq Sozlamalarda o‘zgartirishingiz mumkin.` |
| `now` | `сейчас` | `hozir` |

  The Russian and Uzbek values are this session's, unread by a native speaker (spec §8). Uzbek uses
  `‘` (U+2018) in *o‘*, as the file does. Then check, read-only, that the file still parses and is in
  order:

```bash
python3 -I -c 'import json; s=json.load(open("WaterBuddy/Localizable.xcstrings"))["strings"]; k=list(s); print(len(k), k==sorted(k))'
```

  Expect `86 True` (75 keys before, plus 11).

- [ ] **Step 11: GREEN.** Run, in this order:
  - `UNIT WelcomeStepTests`
  - `UNIT WelcomeFinishTests`
  - `UNIT DailyGoalSetupTests`
  - `UNIT WelcomeStringTests`
  - `UNIT LocalizationTests`, which catches a key the build extracted that has no translation.

  Every one passes. The counts by the attribute grep go in the ledger.
- [ ] **Step 12: Nothing still names it.**
  `grep -rn "GoalSetupView" WaterBuddy/ WaterBuddyTests/ WaterBuddyWidget/ WaterBuddyWatch/ WaterBuddyWatchWidget/`.
  Expect only historical comments that say "`GoalSetupView` then" or "which the welcome replaced".
  The UI tests and `Tools/` are Task 4's.
- [ ] **Step 13: Stage**:
  `git add WaterBuddy/WelcomeView.swift WaterBuddy/WaterBuddyApp.swift WaterBuddy/SettingsView.swift WaterBuddy/Localizable.xcstrings WaterBuddy/AuroraBackground.swift WaterBuddy/HomeView.swift WaterBuddy/HistoryView.swift WaterBuddy/DataManager.swift WaterBuddyTests/WelcomeTests.swift WaterBuddyTests/DataManagerTests.swift WaterBuddyTests/HistoryViewTests.swift WaterBuddyTests/LocalizationTests.swift`
  (`git rm` has already staged the deletion).

---

### Task 4: The DEBUG fresh start, and the welcome's UI tests

**Files:**
- Modify: `WaterBuddy/WaterBuddyApp.swift:8-47` (imports, `init`, the fresh start)
- Create: `WaterBuddyUITests/WelcomeUITests.swift`
- Modify:
  - `WaterBuddyUITests/GoalSetupUITests.swift` (the eleven preambles, at lines 39, 73, 108, 357, 399,
    431, 496, 747, 1122, 1144 and 1226; DocC at lines 10–20)
  - `WaterBuddyUITests/AppStoreScreenshotUITests.swift` (lines 23, 37, 77–86, 180, 203–229)
  - `Tools/CaptureScreenshots.sh:19,75`
  - `Tools/CaptureFullCensus.sh:52,74`
- Test: `WaterBuddyTests/WelcomeTests.swift` (adds `FreshStartTests`)

**Interfaces:**
- Consumes: Task 3's `WelcomeView` and its labels — the buttons *Get Started*, *Continue*, *Back*,
  *Turn on reminders* and *Not now*; the sliders *Daily water goal*, *Cup*, *Glass* and *Bottle*; the
  element *Step N of 4*.
- Produces:
  - `WaterBuddyApp.freshStartManager(arguments: [String]) -> DataManager?`,
    `WaterBuddyApp.freshStartArgument` and `WaterBuddyApp.freshStartSuite`, all inside `#if DEBUG`.
  - The free function `completeWelcomeIfShown(_ app: XCUIApplication)` in the UI-test target.

- [ ] **Step 1: The failing unit test.** Append to `WaterBuddyTests/WelcomeTests.swift`:

```swift
// MARK: - The fresh start

#if DEBUG
/// The welcome's UI tests launch a DEBUG build with `-WaterBuddyFreshStart` (spec 2026-10-14 §9).
/// What they get must be a throwaway: absent without the argument, writing its own suite and never
/// the App Group's, and cleared at each launch (Review Focus 4).
@MainActor
struct FreshStartTests {

    @Test func withoutTheArgumentThereIsNoFreshStart() {
        #expect(WaterBuddyApp.freshStartManager(arguments: ["WaterBuddy"]) == nil)
    }

    @Test func aFreshStartIsAThrowawayClearedAtEachLaunch() throws {
        let arguments = ["WaterBuddy", WaterBuddyApp.freshStartArgument, "YES"]
        let suite = try #require(UserDefaults(suiteName: WaterBuddyApp.freshStartSuite))
        defer { suite.removePersistentDomain(forName: WaterBuddyApp.freshStartSuite) }

        let first = try #require(WaterBuddyApp.freshStartManager(arguments: arguments))
        #expect(first.isGoalSet == false, "a fresh start opened past the welcome")
        first.saveDailyGoal(ml: 3_000)
        #expect(suite.integer(forKey: DataManager.Key.dailyGoal) == 3_000,
                "the fresh start wrote somewhere other than its own suite")

        let second = try #require(WaterBuddyApp.freshStartManager(arguments: arguments))
        #expect(second.isGoalSet == false, "the next launch found the last one's welcome finished")
        #expect(second.dailyGoal == DataManager.defaultDailyGoal)
    }
}
#endif
```

- [ ] **Step 2: The failing UI tests** — `WaterBuddyUITests/WelcomeUITests.swift`:

```swift
//
//  WelcomeUITests.swift
//  WaterBuddyUITests
//
//  Created by Sardor Allaberganov on 14/10/26.
//

import XCTest

/// Walks the welcome to Home if it is showing, choosing *Not now*.
///
/// Every UI test but the welcome's own runs against the device as it is. A gate simulator finished
/// its welcome long ago, so this does nothing there; a fresh one is walked with the welcome's
/// defaults and asks for nothing, so no permission prompt appears in a run (rule `85-testing`). It
/// replaced eleven copies of a *Get Started* tap, one per test, when the welcome grew from one
/// screen to four.
@MainActor
func completeWelcomeIfShown(_ app: XCUIApplication) {
    let getStarted = app.buttons["Get Started"]
    guard getStarted.waitForExistence(timeout: 5) else { return }
    getStarted.tap()

    for _ in 0..<2 {
        let next = app.buttons["Continue"]
        XCTAssertTrue(next.waitForExistence(timeout: 5), "the welcome's Continue did not appear")
        next.tap()
    }

    let notNow = app.buttons["Not now"]
    XCTAssertTrue(notNow.waitForExistence(timeout: 5), "the welcome's last step did not appear")
    notNow.tap()
}

/// The welcome, from outside the process (spec 2026-10-14 §10).
///
/// **The only class that launches with the fresh start.** A DEBUG build given
/// `-WaterBuddyFreshStart` runs on a throwaway suite, cleared as it launches, and an in-memory store
/// (`WaterBuddyApp.freshStartManager(arguments:)`). Every test here sees a new install, and none of
/// them touches the device's own state. Nothing here taps *Turn on reminders*: on a simulator its
/// answer is whatever the device last gave, so the prompt is a device check.
final class WelcomeUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    /// A new install, on the welcome's first step.
    ///
    /// The flag is followed by a value: a `-key` argument takes the next one as its value, and
    /// alone it would swallow whatever argument came after it (decision P7).
    @MainActor
    private func launchedFresh(_ more: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-WaterBuddyFreshStart", "YES"] + more
        app.launch()
        XCTAssertTrue(
            app.buttons["Get Started"].waitForExistence(timeout: 10),
            "the fresh start did not open on the welcome"
        )
        return app
    }

    @MainActor
    private func step(_ number: Int, of app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)["Step \(number) of 4"]
    }

    /// Forward and back through every step, and *Not now* opens the app on Home.
    @MainActor
    func testTheWelcomeWalksForwardAndBack() throws {
        let app = launchedFresh()
        XCTAssertTrue(step(1, of: app).exists, "the dots do not say which step this is")

        app.buttons["Get Started"].tap()
        XCTAssertTrue(app.sliders["Daily water goal"].waitForExistence(timeout: 5), "Get Started did not bring the goal step")
        XCTAssertTrue(step(2, of: app).exists)

        app.buttons["Back"].tap()
        XCTAssertTrue(app.buttons["Get Started"].waitForExistence(timeout: 5), "Back did not return to the first step")
        XCTAssertFalse(app.buttons["Back"].exists, "the first step offers Back")

        app.buttons["Get Started"].tap()
        app.buttons["Continue"].tap()
        XCTAssertTrue(app.sliders["Bottle"].waitForExistence(timeout: 5), "Continue did not bring the vessels step")
        XCTAssertTrue(step(3, of: app).exists)

        app.buttons["Back"].tap()
        XCTAssertTrue(app.sliders["Daily water goal"].waitForExistence(timeout: 5), "Back did not return to the goal step")

        app.buttons["Continue"].tap()
        app.buttons["Continue"].tap()
        XCTAssertTrue(app.buttons["Turn on reminders"].waitForExistence(timeout: 5), "the last step did not appear")
        XCTAssertTrue(app.buttons["Not now"].exists)
        XCTAssertTrue(step(4, of: app).exists)

        app.buttons["Not now"].tap()
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5), "Not now did not open the app on Home")
        XCTAssertFalse(app.buttons["Get Started"].exists, "the welcome is still in the tree")
    }

    /// Each control is one element, by the label VoiceOver speaks, on every step — and a step that is
    /// not shown is not in the tree (rule `65-accessibility`, *Proving it*).
    @MainActor
    func testEveryWelcomeControlIsOneElement() throws {
        let app = launchedFresh()
        XCTAssertEqual(app.buttons.matching(identifier: "Get Started").count, 1)
        XCTAssertEqual(app.sliders.count, 0, "a step that is not shown is in the tree")

        app.buttons["Get Started"].tap()
        XCTAssertTrue(app.sliders["Daily water goal"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.sliders.matching(identifier: "Daily water goal").count, 1)
        XCTAssertEqual(app.buttons.matching(identifier: "Continue").count, 1)
        XCTAssertEqual(app.buttons.matching(identifier: "Back").count, 1)

        app.buttons["Continue"].tap()
        XCTAssertTrue(app.sliders["Bottle"].waitForExistence(timeout: 5))
        for name in ["Cup", "Glass", "Bottle"] {
            XCTAssertEqual(app.sliders.matching(identifier: name).count, 1, "\(name) is not one slider")
        }
        XCTAssertEqual(app.sliders.matching(identifier: "Daily water goal").count, 0, "the goal step is still in the tree")

        app.buttons["Continue"].tap()
        XCTAssertTrue(app.buttons["Turn on reminders"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons.matching(identifier: "Turn on reminders").count, 1)
        XCTAssertEqual(app.buttons.matching(identifier: "Not now").count, 1)
        XCTAssertEqual(app.buttons.matching(identifier: "Back").count, 1)
    }

    /// At the largest text size every step can still be walked: the bar's controls answer a tap,
    /// and what a step asks can be scrolled to above the bar (Review Focus 3).
    @MainActor
    func testTheWelcomeIsWalkableAtTheLargestTextSize() throws {
        // The category's real name: an unknown one is ignored without a word (rule `65-accessibility`).
        let app = launchedFresh(["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"])
        XCTAssertTrue(app.buttons["Get Started"].isHittable)
        app.buttons["Get Started"].tap()

        XCTAssertTrue(app.buttons["Continue"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Continue"].isHittable, "Continue is out of reach on the goal step")
        XCTAssertTrue(app.buttons["Back"].isHittable)
        app.buttons["Continue"].tap()

        let bottle = app.sliders["Bottle"]
        XCTAssertTrue(bottle.waitForExistence(timeout: 5))
        for _ in 0..<4 where !bottle.isHittable { app.swipeUp() }
        XCTAssertTrue(bottle.isHittable, "the last vessel cannot be scrolled out from under the bar")
        app.buttons["Continue"].tap()

        XCTAssertTrue(app.buttons["Turn on reminders"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Turn on reminders"].isHittable)
        XCTAssertTrue(app.buttons["Not now"].isHittable, "Not now is out of reach at the largest size")
        app.buttons["Not now"].tap()
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5))
    }

    /// The walk every other test makes lands on Home.
    @MainActor
    func testTheWalkEveryOtherTestMakesLandsOnHome() throws {
        let app = launchedFresh()
        completeWelcomeIfShown(app)
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5), "the helper did not finish the welcome")
    }

    /// A vessel set in the welcome is the one Home pours.
    @MainActor
    func testAVesselSetInTheWelcomeIsTheOneHomePours() throws {
        let app = launchedFresh()
        app.buttons["Get Started"].tap()
        app.buttons["Continue"].tap()

        let bottle = app.sliders["Bottle"]
        XCTAssertTrue(bottle.waitForExistence(timeout: 5))
        bottle.adjust(toNormalizedSliderPosition: 1)
        XCTAssertEqual(bottle.value as? String, "1000 millilitres")

        app.buttons["Continue"].tap()
        app.buttons["Not now"].tap()
        XCTAssertTrue(
            app.buttons["Bottle, add 1000 millilitres"].waitForExistence(timeout: 5),
            "Home does not pour the bottle the welcome set"
        )
    }

    /// Settings' vessel rows still save as their slider is let go, now that they are
    /// `VesselSliders` (decision P8): a fresh start, so no gate device's own vessels change.
    @MainActor
    func testAVesselEditedInSettingsIsSavedAsBefore() throws {
        let app = launchedFresh()
        completeWelcomeIfShown(app)
        app.buttons["Settings"].tap()

        let bottle = app.sliders["Bottle"]
        XCTAssertTrue(bottle.waitForExistence(timeout: 5), "Settings did not appear")
        for _ in 0..<3 where !bottle.isHittable { app.swipeUp() }
        bottle.adjust(toNormalizedSliderPosition: 1)
        XCTAssertEqual(bottle.value as? String, "1000 millilitres")

        app.buttons["Home"].tap()
        XCTAssertTrue(
            app.buttons["Bottle, add 1000 millilitres"].waitForExistence(timeout: 5),
            "a vessel edited in Settings was not saved"
        )
    }

    /// A step's title stands where a tab's does, read off the tree (`tasks/lessons.md`, 2026-10-11).
    @MainActor
    func testAStepsTitleStandsWhereATabsTitleDoes() throws {
        let app = launchedFresh()
        app.buttons["Get Started"].tap()
        app.buttons["Continue"].tap()
        let title = app.staticTexts["Quick-add vessels"].firstMatch
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        // Let the slide end before reading where it stands.
        Thread.sleep(forTimeInterval: 1)
        let welcomeTop = title.frame.minY

        app.buttons["Continue"].tap()
        app.buttons["Not now"].tap()
        app.buttons["Settings"].tap()
        let settings = app.staticTexts["Settings"].firstMatch
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 1)

        XCTAssertEqual(welcomeTop, settings.frame.minY, accuracy: 0.5,
                       "a step's title stands \(welcomeTop - settings.frame.minY) pt off a tab's")
    }
}
```

  `"Bottle, add 1000 millilitres"` is Home's label from the key `%1$@, add %2$d millilitres`
  (`HomeView.swift:771`).

- [ ] **Step 3: RED.** Run:
  - `UNIT FreshStartTests`. Expected: `type 'WaterBuddyApp' has no member 'freshStartManager'`.
  - `UI WelcomeUITests`, after `uptime`. Expected: every test fails with "the fresh start did not
    open on the welcome". *Gate 27* finished its welcome long ago, and nothing reads the argument
    yet.

- [ ] **Step 4: Implement the fresh start.** In `WaterBuddy/WaterBuddyApp.swift`:
  - Add `import SwiftData` above `import SwiftUI`.
  - Replace `init()` (lines 23–47) with:

```swift
    init() {
        // Resolve the App Group before anything draws, so the container probe and the one-shot
        // migration out of `UserDefaults.standard` both happen here, in the app, at a moment we
        // picked — see `DataManager.prepareSharedStorage()`. If the capability is missing this is
        // also where the DEBUG warning about it fires, instead of somewhere further in. It runs on
        // a fresh start too: it is the app's own bookkeeping on its own group, not test data.
        DataManager.prepareSharedStorage()

        #if DEBUG
        if let fresh = Self.freshStartManager(arguments: ProcessInfo.processInfo.arguments) {
            manager = fresh
            // No watch link: a paired watch's pours belong to the device's own store, which a
            // fresh start never opens.
            return
        }
        #endif

        // Constructing the singleton adopts today, materialises the goal, and rolls the day over
        // if the app was last open yesterday — all against the store resolved on the line above.
        manager = DataManager.shared

        #if canImport(WatchConnectivity)
        // `WristLink.session(_:didReceiveUserInfo:)` posts `didReceiveBatchNotification` rather
        // than calling `WristInbox` directly (see that notification's own DocC in
        // `DataManager.swift`), and `WristInbox.init` is where the observer for it gets
        // registered. Touching the singleton here — before `activate()` below can let anything
        // arrive — is what guarantees an early batch is never dropped for lack of a listener.
        _ = WristInbox.shared

        // Installs `WristLink.live` as the session's delegate and activates it, so a paired watch's
        // wrist pours (and this phone's own mirror, once Task 14/16 send one) have somewhere to
        // land the moment the session comes up.
        WristLink.live.activate()
        #endif
    }

    #if DEBUG
    /// The argument the welcome's UI tests launch with.
    static let freshStartArgument = "-WaterBuddyFreshStart"

    /// The fresh start's one suite, in the app's own preferences — never the App Group. Its name is
    /// fixed, so there is never more than one, and it is cleared at each launch (decision W11).
    static let freshStartSuite = "uitest.waterbuddy.freshstart"

    /// A new install, for the welcome's UI tests, on a device that finished its welcome long ago
    /// (spec 2026-10-14 §9).
    ///
    /// Given ``freshStartArgument``, the app is built on a throwaway suite, cleared first, and an
    /// in-memory store. Every side effect a test fixture turns off is turned off — the widget
    /// doorbell, the reminder reschedule, the wrist publish — the fixture discipline rule
    /// `85-testing` sets, applied to a run of the real app. The App Group's suite and store are
    /// never opened by it. Without the argument this is `nil`, and a Debug build runs exactly what
    /// a Release one does; a Release build does not contain it.
    ///
    /// `nil`, said aloud, if the throwaway cannot be made. The run then opens on the device's own
    /// state, and the welcome's tests fail on their first look rather than writing anywhere they
    /// should not.
    static func freshStartManager(arguments: [String]) -> DataManager? {
        guard arguments.contains(freshStartArgument) else { return nil }

        guard let defaults = UserDefaults(suiteName: freshStartSuite),
              let store = try? ModelContainer(
                  for: WaterLog.self,
                  configurations: ModelConfiguration(isStoredInMemoryOnly: true)
              )
        else {
            print("WaterBuddy: the fresh start's throwaway suite or store could not be made, so this run opens on the device's own state.")
            return nil
        }
        defaults.removePersistentDomain(forName: freshStartSuite)

        return DataManager(
            defaults: defaults,
            modelContainer: store,
            reloadWidgets: {},
            rescheduleReminders: { _ in },
            publishWrist: { _ in }
        )
    }
    #endif
```

  The `print` is inside `#if DEBUG` and names only the failing condition (rule `75-diagnostics`).

- [ ] **Step 5: GREEN for the fresh start.** Run:
  - `UNIT FreshStartTests`. Expect 2 passed.
  - `UI WelcomeUITests`. Expect `Executed 7 tests, with 0 failures`.

  A failure here is read off the test's own message. If Home's labels or the title's frame differ
  from what a test assumed, stop and report it — never narrow the assertion.

- [ ] **Step 6: The eleven preambles.** In `WaterBuddyUITests/GoalSetupUITests.swift`, replace each
  of the eleven blocks below with `completeWelcomeIfShown(app)`. Each block reads:

```swift
        let getStarted = app.buttons["Get Started"]
        if getStarted.waitForExistence(timeout: 5) {
            getStarted.tap()
        }
```

  The blocks start at lines 39, 73, 108, 357, 399, 431, 496, 747, 1122, 1144 and 1226. Edit from the
  bottom up so the line numbers hold. At line 39 the block carries two comment lines inside the `if`.
  Replace the whole block with:

```swift
        // The welcome's goal opens on the default, so walking it commits 2,000 ml — the amount
        // the screen was already showing.
        completeWelcomeIfShown(app)
```

  Then the class DocC at lines 10–20:

```swift
/// The one seam the unit suite structurally cannot reach: that walking the welcome actually swaps
/// the app's root from `WelcomeView` to `HomeView`.
///
/// `DailyGoalSetupTests` and `WelcomeFinishTests` already prove the model half — that finishing
/// flips `isGoalSet` and invalidates its observers. What no injected `UserDefaults` can show is
/// whether SwiftUI re-evaluates `RootView` off that invalidation and renders the other branch. That
/// needs the real app, which is what this target is for (rule `85-testing`).
///
/// Deliberately idempotent rather than assuming a fresh install: the welcome is a state that exists
/// once per install, so a test that *required* it would pass once and fail on every run after. Each
/// test walks the welcome if it is showing (`completeWelcomeIfShown(_:)`), and either way asserts
/// the app proper is on screen. The welcome itself is `WelcomeUITests`', on a fresh start.
```

  Afterwards, `grep -c 'app.buttons\["Get Started"\]' WaterBuddyUITests/GoalSetupUITests.swift`
  should print `0`.

- [ ] **Step 7: The capture harness walks the welcome.** In
  `WaterBuddyUITests/AppStoreScreenshotUITests.swift`:
  - In `testCaptureAppStoreScreenshots`, replace lines 77–86 (from `let getStarted` through
    `getStarted.tap()`) with:

```swift
        let getStarted = app.buttons["Get Started"]
        XCTAssertTrue(
            getStarted.waitForExistence(timeout: 10),
            "the welcome is not showing — the device was not erased before this run, so the "
                + "captured totals would be whatever the last run left behind"
        )
        // The shot is the goal step: the number the rest of the product is measured against.
        getStarted.tap()
        XCTAssertTrue(app.sliders["Daily water goal"].waitForExistence(timeout: 10), "the goal step did not appear")
        Thread.sleep(forTimeInterval: settle)
        capture("04-goal-setup")

        // On through the vessels and past reminders without asking, as a new user might.
        app.buttons["Continue"].tap()
        app.buttons["Continue"].tap()
        XCTAssertTrue(app.buttons["Not now"].waitForExistence(timeout: 10), "the welcome's last step did not appear")
        app.buttons["Not now"].tap()
```

  - In `testCaptureFullScreenCensus`, after the `XCTAssertTrue(getStarted.waitForExistence…)` at
    lines 204–208, insert:

```swift
        getStarted.tap()
        XCTAssertTrue(goalSlider.waitForExistence(timeout: 10), "the goal step did not appear")
```

  - Then replace the `getStarted.tap()` at line 229 with:

```swift
        app.buttons["Continue"].tap()
        app.buttons["Continue"].tap()
        XCTAssertTrue(app.buttons["Not now"].waitForExistence(timeout: 10), "the welcome's last step did not appear")
        app.buttons["Not now"].tap()
```

  - In the comments and messages at lines 23, 37, 80, 180 and 203–207, `GoalSetupView` →
    `the welcome` (the line-180 table row becomes
    `| *Not now* tapped | the welcome — `Key.isGoalSet` is never unset |`), and line 203's heading
    becomes `// ── 01–03 · the welcome's goal step, before the one-way door ──…`.
  - At line 37, `GoalSetupView exists only until the first goal is committed, so it is shot
    **first**` → `The welcome exists only until the first goal is committed, so its goal step is
    shot **first**`.

  The harness is compiled and not run. It needs an erased device, which only the owner can make
  (#82).
- [ ] **Step 8: The scripts' comments.** In `Tools/CaptureScreenshots.sh:19,75` and
  `Tools/CaptureFullCensus.sh:52,74`, `GoalSetupView` → `the welcome`. At `CaptureFullCensus.sh:74`
  the phrase is `GoalSetupView for setup`, and it becomes `WelcomeView for setup`.
- [ ] **Step 9: GREEN for the whole UI class that changed.** `GoalSetupUITests` is 36 tests. Run it in
  four chunks of nine named tests, as follows:
  - Build the sorted list with `grep -oE "func test[A-Za-z0-9]+" WaterBuddyUITests/GoalSetupUITests.swift | sed 's/func //' | sort`.
  - Give each chunk its `-only-testing:WaterBuddyUITests/GoalSetupUITests/<name>` flags in a
    variable, expanded as `${=FLAGS}`.
  - Read the **executed** count of each chunk.

  Expect 36 executed, 0 failures, on *Gate 27*. Then run `UI WelcomeUITests` once more.
- [ ] **Step 10: Stage**:
  `git add WaterBuddy/WaterBuddyApp.swift WaterBuddyTests/WelcomeTests.swift WaterBuddyUITests/WelcomeUITests.swift WaterBuddyUITests/GoalSetupUITests.swift WaterBuddyUITests/AppStoreScreenshotUITests.swift Tools/CaptureScreenshots.sh Tools/CaptureFullCensus.sh`.

---

### Task 5: `GoalSuggestion` — the calculator's arithmetic

**Files:**
- Create: `WaterBuddy/GoalSuggestion.swift`
- Test: `WaterBuddyTests/GoalSuggestionTests.swift`

**Interfaces:**
- Consumes: `WelcomeView.goalRange`, `WelcomeView.goalStep` (Task 3, `nonisolated`).
- Produces:
  - `nonisolated enum GoalSuggestion`, with
    `static func goal(weight: Int, unit: Unit, activity: Activity) -> Int`.
  - `nonisolated enum Unit: CaseIterable, Sendable { case kilograms, pounds }`, with
    `range: ClosedRange<Int>`, `start: Int`,
    `static func starting(for: Locale.MeasurementSystem) -> Unit` and
    `func convert(_ weight: Int, to unit: Unit) -> Int`.
  - `nonisolated enum Activity: CaseIterable, Sendable { case light, moderate, active }`, with
    `millilitres: Int`.

- [ ] **Step 1: The failing tests** — `WaterBuddyTests/GoalSuggestionTests.swift`:

```swift
//
//  GoalSuggestionTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 14/10/26.
//

import Foundation
import Testing
@testable import WaterBuddy

/// The welcome's goal calculator (spec 2026-10-14 §4).
///
/// Not `@MainActor`: ``GoalSuggestion`` is a plain value, and this suite is the canary that keeps it
/// — and the menu it reads, ``WelcomeView/goalRange`` — off the main actor (rule `43-concurrency`).
struct GoalSuggestionTests {

    /// The owner's approved table, cell by cell (spec §4).
    @Test(arguments: [
        (50, GoalSuggestion.Activity.light, 1_500), (50, .moderate, 1_900), (50, .active, 2_200),
        (60, .light, 1_800), (60, .moderate, 2_200), (60, .active, 2_500),
        (70, .light, 2_100), (70, .moderate, 2_500), (70, .active, 2_800),
        (85, .light, 2_600), (85, .moderate, 2_900), (85, .active, 3_300),
        (100, .light, 3_000), (100, .moderate, 3_400), (100, .active, 3_700),
    ])
    func theApprovedTableHolds(kilograms: Int, activity: GoalSuggestion.Activity, goal: Int) {
        #expect(GoalSuggestion.goal(weight: kilograms, unit: .kilograms, activity: activity) == goal)
    }

    /// The pound's starting weight at the starting activity, beside the kilogram's: 155 lb gives
    /// 2,109 ml, plus 350, rounded to 2,500.
    @Test func aHundredAndFiftyFivePoundsAtModerateIsTwoAndAHalfLitres() {
        #expect(GoalSuggestion.goal(weight: 155, unit: .pounds, activity: .moderate) == 2_500)
    }

    @Test func aLightWeightIsLiftedToTheSlidersFloor() {
        // 30 kg × 30 = 900 ml, under the slider.
        #expect(GoalSuggestion.goal(weight: 30, unit: .kilograms, activity: .light) == WelcomeView.goalRange.lowerBound)
    }

    @Test func aHeavyWeightIsHeldToTheSlidersCeiling() {
        // 200 kg × 30 + 700 = 6,700 ml, over it.
        #expect(GoalSuggestion.goal(weight: 200, unit: .kilograms, activity: .active) == WelcomeView.goalRange.upperBound)
    }

    @Test func exactlyHalfAStepRoundsUp() {
        // 85 × 30 = 2,550: halfway between 2,500 and 2,600.
        #expect(GoalSuggestion.goal(weight: 85, unit: .kilograms, activity: .light) == 2_600)
    }

    /// The region's unit, not the app's language (spec §4, the owner's ruling).
    @Test(arguments: [
        (Locale.MeasurementSystem.us, GoalSuggestion.Unit.pounds),
        (.metric, .kilograms),
        (.uk, .kilograms),
    ])
    func theWeightStartsInTheRegionsUnit(system: Locale.MeasurementSystem, unit: GoalSuggestion.Unit) {
        #expect(GoalSuggestion.Unit.starting(for: system) == unit)
    }

    @Test(arguments: GoalSuggestion.Unit.allCases)
    func eachUnitStartsOnItsOwnWheel(unit: GoalSuggestion.Unit) {
        #expect(unit.range.contains(unit.start))
    }

    @Test func seventyKilogramsReadsAsAHundredAndFiftyFourPoundsAndBack() {
        #expect(GoalSuggestion.Unit.kilograms.convert(70, to: .pounds) == 154)
        #expect(GoalSuggestion.Unit.pounds.convert(154, to: .kilograms) == 70)
    }

    /// The switch, flicked there and back, returns the weight the wheel showed — on every weight it
    /// offers.
    @Test func everyKilogramSurvivesATripThroughPounds() {
        for kilograms in GoalSuggestion.Unit.kilograms.range {
            let pounds = GoalSuggestion.Unit.kilograms.convert(kilograms, to: .pounds)
            #expect(GoalSuggestion.Unit.pounds.range.contains(pounds), "\(kilograms) kg left the pound wheel")
            #expect(GoalSuggestion.Unit.pounds.convert(pounds, to: .kilograms) == kilograms,
                    "\(kilograms) kg came back as \(GoalSuggestion.Unit.pounds.convert(pounds, to: .kilograms))")
        }
    }

    @Test(arguments: GoalSuggestion.Unit.allCases)
    func aWeightConvertedToItsOwnUnitIsUnchanged(unit: GoalSuggestion.Unit) {
        for weight in unit.range {
            #expect(unit.convert(weight, to: unit) == weight)
        }
    }

    /// Every weight on either wheel, at every level: on the slider, on a step, and never less for
    /// someone heavier.
    @Test(arguments: GoalSuggestion.Unit.allCases)
    func everySuggestionLandsOnTheSliderAndRisesWithWeight(unit: GoalSuggestion.Unit) {
        for activity in GoalSuggestion.Activity.allCases {
            var previous = 0
            for weight in unit.range {
                let goal = GoalSuggestion.goal(weight: weight, unit: unit, activity: activity)
                #expect(WelcomeView.goalRange.contains(goal), "\(weight) \(unit) suggested \(goal)")
                #expect((goal - WelcomeView.goalRange.lowerBound) % WelcomeView.goalStep == 0,
                        "\(weight) \(unit) suggested \(goal), between two steps")
                #expect(goal >= previous, "\(weight) \(unit) suggested less than the weight under it")
                previous = goal
            }
        }
    }

    @Test(arguments: GoalSuggestion.Unit.allCases)
    func moreActivityNeverSuggestsLess(unit: GoalSuggestion.Unit) {
        for weight in unit.range {
            let goals = GoalSuggestion.Activity.allCases.map {
                GoalSuggestion.goal(weight: weight, unit: unit, activity: $0)
            }
            #expect(goals == goals.sorted(), "\(weight) \(unit): \(goals)")
        }
    }
}
```

- [ ] **Step 2: RED.** `UNIT GoalSuggestionTests`. Expected: `cannot find 'GoalSuggestion' in scope`.
- [ ] **Step 3: Implement** — `WaterBuddy/GoalSuggestion.swift`:

```swift
//
//  GoalSuggestion.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 14/10/26.
//

import Foundation

/// A daily goal worked out from a weight and how active someone is — the welcome's *Work it out for
/// me* (spec 2026-10-14 §4).
///
/// **30 ml for each kilogram, and 0, 350 or 700 ml more for a light, moderate or active day**,
/// rounded half-up to the slider's step and kept on the slider (``WelcomeView/goalRange``). The
/// owner ruled the formula and approved its table on 2026-10-14; `GoalSuggestionTests` holds the
/// table cell by cell. It is an estimate for a hydration app's daily target, not advice about
/// anyone's health, and the screen says so under it.
///
/// **In whole numbers only.** A pound is exactly 0.45359237 kg, so a weight in pounds becomes
/// millilitres as a fraction of integers, rounded once to the whole millilitre. No `Double` ever
/// holds a volume (`CLAUDE.md`, *No floating-point millilitres*).
///
/// **It keeps nothing.** A weight goes in and a goal comes out. Neither the weight nor its unit is
/// stored anywhere (rule `70-privacy`).
///
/// A plain value at file scope and `nonisolated`, so its suite reads it off the main actor (rule
/// `43-concurrency`).
nonisolated enum GoalSuggestion {

    /// What each kilogram adds.
    static let millilitresPerKilogram = 30

    /// A pound is `poundNumerator / poundDenominator` kilograms — 0.45359237, the international
    /// pound, exactly.
    static let poundNumerator = 45_359_237
    static let poundDenominator = 100_000_000

    /// The goal for `weight` in `unit` at `activity`, on the slider's step and inside its range.
    static func goal(weight: Int, unit: Unit, activity: Activity) -> Int {
        let step = WelcomeView.goalStep
        let total = millilitres(for: weight, in: unit) + activity.millilitres
        // Half-up to the nearest step: a total exactly between two takes the higher.
        let rounded = (total + step / 2) / step * step
        return min(max(rounded, WelcomeView.goalRange.lowerBound), WelcomeView.goalRange.upperBound)
    }

    /// What `weight` contributes, to the nearest whole millilitre.
    private static func millilitres(for weight: Int, in unit: Unit) -> Int {
        switch unit {
        case .kilograms:
            weight * millilitresPerKilogram
        case .pounds:
            // 13.6077711 ml a pound, rounded once: (lb × 30 × 45,359,237 + 50,000,000) ÷ 100,000,000.
            (weight * millilitresPerKilogram * poundNumerator + poundDenominator / 2) / poundDenominator
        }
    }

    /// The unit a weight is entered in.
    nonisolated enum Unit: CaseIterable, Sendable {

        case kilograms
        case pounds

        /// What the wheel offers: thirty kilograms to two hundred, and about the same span in whole
        /// pounds.
        var range: ClosedRange<Int> {
            switch self {
            case .kilograms: 30...200
            case .pounds: 66...440
            }
        }

        /// Where the wheel starts: round figures, close to one another (decision W2).
        var start: Int {
            switch self {
            case .kilograms: 70
            case .pounds: 155
            }
        }

        /// The unit a phone's region weighs in: pounds where it measures in US units, kilograms
        /// everywhere else. The region, deliberately not the app's language — choosing English in
        /// the app must not make an Uzbek user weigh in pounds (spec §4, the owner's ruling).
        static func starting(for system: Locale.MeasurementSystem) -> Unit {
            system == .us ? .pounds : .kilograms
        }

        /// `weight` in this unit as the nearest whole `unit`, kept on that unit's wheel: 70 kg is
        /// 154 lb, and 154 lb is 70 kg.
        func convert(_ weight: Int, to unit: Unit) -> Int {
            let converted: Int
            switch (self, unit) {
            case (.kilograms, .pounds):
                // kg ÷ 0.45359237, half-up: (2 × kg × 10⁸ + 45,359,237) ÷ (2 × 45,359,237).
                converted = (2 * weight * GoalSuggestion.poundDenominator + GoalSuggestion.poundNumerator)
                    / (2 * GoalSuggestion.poundNumerator)
            case (.pounds, .kilograms):
                converted = (weight * GoalSuggestion.poundNumerator + GoalSuggestion.poundDenominator / 2)
                    / GoalSuggestion.poundDenominator
            default:
                converted = weight
            }
            return min(max(converted, unit.range.lowerBound), unit.range.upperBound)
        }
    }

    /// How active a day is.
    nonisolated enum Activity: CaseIterable, Sendable {

        case light
        case moderate
        case active

        /// What a day like this adds.
        var millilitres: Int {
            switch self {
            case .light: 0
            case .moderate: 350
            case .active: 700
            }
        }
    }
}
```

- [ ] **Step 4: GREEN.** `UNIT GoalSuggestionTests`. Every test passes. Record the count. A failing
  table cell is reported to the owner, never adjusted: it means the formula and the approved table
  disagree.
- [ ] **Step 5: Stage**:
  `git add WaterBuddy/GoalSuggestion.swift WaterBuddyTests/GoalSuggestionTests.swift`.

---

### Task 6: The calculator in the goal step

**Files:**
- Modify: `WaterBuddy/WelcomeView.swift` (new state, `init`, `stepPage`, `goalPage`, the
  `CalculatorPanel` struct, `WelcomeStyle`)
- Modify: `WaterBuddy/Localizable.xcstrings` (17 keys)
- Test:
  - `WaterBuddyTests/LocalizationTests.swift` (the calculator's keys join `welcomeKeys`)
  - `WaterBuddyUITests/WelcomeUITests.swift` (four tests)

**Interfaces:**
- Consumes: Task 5's `GoalSuggestion.goal(weight:unit:activity:)`, `.Unit.starting(for:)`,
  `.Unit.convert(_:to:)`, `.Unit.range`, `.Unit.start`, `.Activity.allCases`.
- Produces: the labels the UI tests query:
  - the button *Work it out for me*;
  - the buttons *Light, Mostly sitting*, *Moderate, Exercise some days* and *Active, Exercise most
    days*;
  - the buttons *kg* and *lb*;
  - the wheel *Your weight*;
  - the button `Use %1$d millilitres`, spoken.

- [ ] **Step 1: The failing string test.** Add the calculator's keys to `welcomeKeys` in
  `WaterBuddyTests/LocalizationTests.swift`:

```swift
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
```

- [ ] **Step 2: The failing UI tests.** Append to `WelcomeUITests` in
  `WaterBuddyUITests/WelcomeUITests.swift`:

```swift
    // MARK: The calculator

    /// On the goal step, the calculator open.
    @MainActor
    private func calculatorOpen() -> XCUIApplication {
        let app = launchedFresh()
        app.buttons["Get Started"].tap()
        let row = app.buttons["Work it out for me"]
        XCTAssertTrue(row.waitForExistence(timeout: 5), "the goal step has no calculator")
        XCTAssertEqual(app.buttons.matching(identifier: "Work it out for me").count, 1)
        row.tap()
        return app
    }

    /// *Use* moves the goal to the suggestion, and then says so instead of offering it again. At
    /// the starting 70 kg or 155 lb and *Moderate*, both units suggest 2,500.
    @MainActor
    func testUseSetsTheGoalItSuggests() throws {
        let app = calculatorOpen()
        let use = app.buttons["Use 2500 millilitres"]
        XCTAssertTrue(use.waitForExistence(timeout: 5), "the calculator did not suggest 2,500 at its starting weight")
        XCTAssertEqual(app.sliders["Daily water goal"].value as? String, "2000 millilitres", "the goal moved before Use was tapped")

        use.tap()

        XCTAssertEqual(app.sliders["Daily water goal"].value as? String, "2500 millilitres")
        XCTAssertFalse(app.buttons["Use 2500 millilitres"].exists, "Use is still offered for the goal it already set")
    }

    /// The activity moves the suggestion, and nothing else (decision W1). Both units' starts agree
    /// at every level: 2,100 light, 2,800 active.
    @MainActor
    func testTheActivityMovesOnlyTheSuggestion() throws {
        let app = calculatorOpen()
        let moderate = app.buttons["Moderate, Exercise some days"]
        XCTAssertTrue(moderate.waitForExistence(timeout: 5))
        XCTAssertTrue(moderate.isSelected, "the calculator does not start at Moderate")

        app.buttons["Active, Exercise most days"].tap()
        XCTAssertTrue(app.buttons["Use 2800 millilitres"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Active, Exercise most days"].isSelected)

        app.buttons["Light, Mostly sitting"].tap()
        XCTAssertTrue(app.buttons["Use 2100 millilitres"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.sliders["Daily water goal"].value as? String, "2000 millilitres", "picking an activity moved the goal")
    }

    /// The unit switch converts the weight shown, whichever unit the region started in: kilograms
    /// give 70, pounds give 154 — and 154 lb at *Moderate* suggests 2,400.
    @MainActor
    func testTheUnitSwitchConvertsTheWeight() throws {
        let app = calculatorOpen()
        let wheel = app.pickerWheels.firstMatch
        XCTAssertTrue(wheel.waitForExistence(timeout: 5), "the calculator has no weight wheel")

        app.buttons["kg"].tap()
        XCTAssertEqual(wheel.value as? String, "70 kg")
        XCTAssertTrue(app.buttons["kg"].isSelected)

        app.buttons["lb"].tap()
        XCTAssertEqual(app.pickerWheels.firstMatch.value as? String, "154 lb")
        XCTAssertTrue(app.buttons["Use 2400 millilitres"].waitForExistence(timeout: 5))
    }

    /// Use, then the goal moved away: *Use* comes back with the same figure (Review Focus 1).
    @MainActor
    func testUseComesBackWhenTheGoalIsMovedAway() throws {
        let app = calculatorOpen()
        app.buttons["Use 2500 millilitres"].tap()
        XCTAssertFalse(app.buttons["Use 2500 millilitres"].exists)

        app.sliders["Daily water goal"].adjust(toNormalizedSliderPosition: 1)
        XCTAssertEqual(app.sliders["Daily water goal"].value as? String, "4000 millilitres")
        XCTAssertTrue(app.buttons["Use 2500 millilitres"].waitForExistence(timeout: 5), "Use did not come back")
    }

    /// Continue and Back keep a step as it was left: the panel open, the pick, the goal
    /// (Review Focus 2).
    @MainActor
    func testAStepIsAsItWasLeftWhenBackReturnsToIt() throws {
        let app = calculatorOpen()
        app.buttons["Active, Exercise most days"].tap()
        app.buttons["Use 2800 millilitres"].tap()

        app.buttons["Continue"].tap()
        XCTAssertTrue(app.sliders["Bottle"].waitForExistence(timeout: 5))
        app.buttons["Back"].tap()

        XCTAssertTrue(app.sliders["Daily water goal"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.sliders["Daily water goal"].value as? String, "2800 millilitres")
        XCTAssertTrue(app.buttons["Active, Exercise most days"].isSelected, "the pick was lost")
    }
```

  `testEveryWelcomeControlIsOneElement` already has the goal step on screen; add these lines after
  its `Back` count on that step:

```swift
        XCTAssertEqual(app.buttons.matching(identifier: "Work it out for me").count, 1)
        app.buttons["Work it out for me"].tap()
        for name in ["Light, Mostly sitting", "Moderate, Exercise some days", "Active, Exercise most days", "kg", "lb"] {
            XCTAssertEqual(app.buttons.matching(identifier: name).count, 1, "\(name) is not one button")
        }
        XCTAssertEqual(app.pickerWheels.count, 1, "the weight wheel is not one element")
```

- [ ] **Step 3: RED.** Run `UNIT WelcomeStringTests`. Expected: 17 keys missing in `en`, `ru` and
  `uz`. Then run, on *Gate 27*, the four new tests and `testEveryWelcomeControlIsOneElement` (five
  `-only-testing:` flags). Expected: each fails with "the goal step has no calculator".

- [ ] **Step 4: The state and the seed.** In `WaterBuddy/WelcomeView.swift`, after
  `@State private var finishes = 0`, add:

```swift
    /// The calculator's weight, in ``unit`` — written nowhere, and gone with the welcome
    /// (rule `70-privacy`).
    @State private var weight: Int

    /// The weight's unit: the device region's to start with (spec §4).
    @State private var unit: GoalSuggestion.Unit

    /// How active a day is: *Moderate* to start with (decision W2).
    @State private var activity = GoalSuggestion.Activity.moderate

    /// Whether *Work it out for me* is open.
    @State private var calculatorOpen = false

    /// Bumped by *Use*: the confirmation, and the slider's glide to the suggestion. A drag moves
    /// the slider without it, and does not glide.
    @State private var uses = 0
```

  In `init(goal:amounts:)`, after the two existing lines, add:

```swift
        // The device's region, deliberately not the app's language (spec §4, the owner's ruling).
        let unit = GoalSuggestion.Unit.starting(for: Locale.current.measurementSystem)
        _unit = State(initialValue: unit)
        _weight = State(initialValue: unit.start)
```

  In `body`, after `.sensoryFeedback(Haptics.confirm, trigger: finishes)`, add
  `.sensoryFeedback(Haptics.confirm, trigger: uses)`. On the `Slider` in `goalSlider`, after
  `.tint(Aurora.cyan)`, add:

```swift
            // Glides when *Use* sets it, and only then: keyed to the tap, not to the goal, so a
            // drag is never chased by its own animation.
            .animation(Motion.settle, value: uses)
```

- [ ] **Step 5: The step scrolls to the panel.** Replace `stepPage` with a version that hands its
  content the scroll view's proxy:

```swift
    /// A step after the first: its title where the tabs' titles stand, a line under it, and what it
    /// asks — all of it scrolling above the bar (rule `65-accessibility`). The content is handed the
    /// scroll view's proxy, for the goal step's calculator.
    private func stepPage<Content: View>(
        _ page: WelcomeStep,
        title: Text,
        subtitle: Text,
        @ViewBuilder content: @escaping (ScrollViewProxy) -> Content
    ) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    title
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.white)
                        // It wraps rather than shrinking out of sight: *Tez qo‘shish idishlari* is a
                        // long title at the ordinary size, and the largest sizes are larger still.
                        .fixedSize(horizontal: false, vertical: true)
                        // The tabs' title line, so the title stands where theirs does
                        // (`testAStepsTitleStandsWhereATabsTitleDoes`).
                        .frame(maxWidth: .infinity, minHeight: ScreenMetrics.titleLine, alignment: .leading)
                        .legibleOnBackdrop()
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityFocused($focusedTitle, equals: page)

                    subtitle
                        .font(.body)
                        .foregroundStyle(.white.opacity(WelcomeStyle.textOpacity))
                        .fixedSize(horizontal: false, vertical: true)
                        .legibleOnBackdrop()
                        .padding(.top, WelcomeStyle.subtitleGap)

                    content(proxy)
                        .padding(.top, WelcomeStyle.contentGap)
                }
                .padding(.horizontal, ScreenMetrics.margin)
                // Every tab's inset, less the point the steps stand off the safe area.
                .padding(.top, ScreenMetrics.topInset - 1)
                .padding(.bottom, WelcomeStyle.contentGap)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }
```

  In `content(of:)`, the three trailing closures become `{ proxy in goalPage(scrolling: proxy) }`,
  `{ _ in vesselsStep }` and `{ _ in remindersStep }`.

- [ ] **Step 6: The calculator row and the panel.** Replace `goalPage` with:

```swift
    /// Where the calculator is scrolled to when it opens.
    private static let calculatorID = "calculator"

    private func goalPage(scrolling proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 0) {
            goalCard
            footnote(Text("You can change this later in Settings.", bundle: strings))
            calculator
                .padding(.top, WelcomeStyle.cardGap)
                .id(Self.calculatorID)
        }
        .onChange(of: calculatorOpen) { _, open in
            guard open else { return }
            // Opening the row brings the panel into view (spec §4). A scroll position is not view
            // state that `.animation(_:value:)` can scope, so this one scroll runs in a transaction
            // of its own — decision P5, put to the owner with the plan.
            withTransaction(\.animation, Motion.settle) {
                proxy.scrollTo(Self.calculatorID, anchor: .bottom)
            }
        }
    }

    /// *Work it out for me*: a row that opens into the calculator, on the goal card's glass.
    private var calculator: some View {
        VStack(spacing: 0) {
            Button {
                calculatorOpen.toggle()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Aurora.cyan)
                        .accessibilityHidden(true)
                    Text("Work it out for me", bundle: strings)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.down")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white.opacity(WelcomeStyle.textOpacity))
                        .rotationEffect(.degrees(calculatorOpen ? 180 : 0))
                        .accessibilityHidden(true)
                }
                .padding(.horizontal, WelcomeStyle.cardPadding)
                .frame(minHeight: WelcomeStyle.rowHeight)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressStyle())

            if calculatorOpen {
                CalculatorPanel(weight: $weight, unit: $unit, activity: $activity, goal: goal) { suggestion in
                    goal = suggestion
                    uses += 1
                }
                .padding(.horizontal, WelcomeStyle.panelInset)
                .padding(.bottom, WelcomeStyle.panelBottom)
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity)
        .liquidGlass(density: .frosted, elevation: .raised)
        .animation(Motion.settle, value: calculatorOpen)
    }
```

  Add to `WelcomeStyle`, under `// The goal`:

```swift
    static let rowHeight: CGFloat = 56
    static let panelInset: CGFloat = 16
    static let panelBottom: CGFloat = 18
    static let weightColumn: CGFloat = 124
    static let wheelHeight: CGFloat = 160
    static let choiceHeight: CGFloat = 50
    static let useHeight: CGFloat = 50
```

  Add the panel, after `HelloVessel`:

```swift
// MARK: - The calculator

/// The calculator under *Work it out for me*: a weight on a wheel, its unit, how active, and the
/// suggestion they make (spec 2026-10-14 §4).
///
/// **Nothing above it moves until *Use* is tapped** (decision W1). The wheel, the unit and the
/// activity change only the figure on the button, and *Use* hands it to the goal. While the goal
/// already is the suggestion, the button says so and does nothing; it comes back as soon as either
/// moves.
///
/// It holds nothing of its own but a haptic counter. The weight, unit and activity are the welcome's
/// state, bound here, and go with it — written nowhere (rule `70-privacy`).
private struct CalculatorPanel: View {

    @Binding var weight: Int
    @Binding var unit: GoalSuggestion.Unit
    @Binding var activity: GoalSuggestion.Activity

    /// The goal step's goal, to tell whether the suggestion is already it.
    let goal: Int

    /// *Use*, with the suggestion.
    let onUse: (Int) -> Void

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    /// Bumped by a unit or an activity picked: the tick. The wheel plays the system's own.
    @State private var picks = 0

    private var suggestion: Int {
        GoalSuggestion.goal(weight: weight, unit: unit, activity: activity)
    }

    var body: some View {
        VStack(spacing: 0) {
            // The weight beside the activity while both fit; one over the other at the largest
            // sizes (rule `65-accessibility`).
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 12) {
                    weightColumn
                        .frame(width: WelcomeStyle.weightColumn)
                    activityColumn
                }
                VStack(alignment: .leading, spacing: WelcomeStyle.cardGap) {
                    weightColumn
                    activityColumn
                }
            }

            useRow
                .padding(.top, WelcomeStyle.cardGap)

            Text("A starting point, not medical advice.", bundle: strings)
                .font(.footnote)
                .foregroundStyle(.white.opacity(WelcomeStyle.footnoteOpacity))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
        }
        .sensoryFeedback(Haptics.select, trigger: picks)
    }

    // MARK: The weight

    private var weightColumn: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your weight", bundle: strings)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 4)
                // The wheel below carries the same words as its label.
                .accessibilityHidden(true)

            Picker(selection: $weight) {
                ForEach(Array(unit.range), id: \.self) { value in
                    Text(verbatim: weightText(value))
                        .font(.title3.weight(.semibold))
                        .fontDesign(.rounded)
                        .tag(value)
                }
            } label: {
                Text("Your weight", bundle: strings)
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .frame(height: WelcomeStyle.wheelHeight)
            .clipShape(RoundedRectangle(cornerRadius: LiquidGlass.innerCornerRadius, style: .continuous))
            // A wheel built anew for the other unit, rather than one range swapped under a wheel
            // mid-turn.
            .id(unit)
            .accessibilityLabel(Text("Your weight", bundle: strings))

            unitSwitch
        }
    }

    /// *70 kg*, *154 lb*. A weight, not a volume, and never above three digits, so a `%1$d` key.
    private func weightText(_ value: Int) -> String {
        let key = switch unit {
        case .kilograms: "%1$d kg"
        case .pounds: "%1$d lb"
        }
        return String(format: strings.localizedString(forKey: key, value: nil, table: nil), value)
    }

    private var unitSwitch: some View {
        HStack(spacing: 2) {
            ForEach(GoalSuggestion.Unit.allCases, id: \.self) { choice in
                let isSelected = choice == unit

                Button {
                    guard !isSelected else { return }
                    // The weight shown, converted: 70 kg becomes 154 lb, and back.
                    weight = unit.convert(weight, to: choice)
                    unit = choice
                    picks += 1
                } label: {
                    unitName(choice)
                        .font(.subheadline.weight(isSelected ? .bold : .semibold))
                        .foregroundStyle(.white.opacity(isSelected ? 1 : WelcomeStyle.footnoteOpacity))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background { selectionMark(isSelected, in: Capsule()) }
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressStyle())
                .accessibilityAddTraits(isSelected ? [.isSelected] : [])
            }
        }
    }

    private func unitName(_ choice: GoalSuggestion.Unit) -> Text {
        switch choice {
        case .kilograms: Text("kg", bundle: strings)
        case .pounds: Text("lb", bundle: strings)
        }
    }

    // MARK: The activity

    private var activityColumn: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How active are you?", bundle: strings)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 4)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 6) {
                ForEach(GoalSuggestion.Activity.allCases, id: \.self) { level in
                    activityButton(level)
                }
            }
        }
    }

    /// One level: its name over what it means. One button whose label is both — *Moderate, Exercise
    /// some days* — with the selected trait on the one picked (rule `65-accessibility`).
    private func activityButton(_ level: GoalSuggestion.Activity) -> some View {
        let isSelected = level == activity

        return Button {
            guard !isSelected else { return }
            activity = level
            picks += 1
        } label: {
            VStack(alignment: .leading, spacing: 1) {
                activityName(level)
                    .font(.subheadline.weight(isSelected ? .bold : .semibold))
                    .foregroundStyle(.white)
                activityLine(level)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(isSelected ? WelcomeStyle.textOpacity : WelcomeStyle.footnoteOpacity))
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: WelcomeStyle.choiceHeight, alignment: .leading)
            .background {
                selectionMark(isSelected, in: RoundedRectangle(cornerRadius: LiquidGlass.innerCornerRadius, style: .continuous))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressStyle())
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private func activityName(_ level: GoalSuggestion.Activity) -> Text {
        switch level {
        case .light: Text("Light", bundle: strings)
        case .moderate: Text("Moderate", bundle: strings)
        case .active: Text("Active", bundle: strings)
        }
    }

    /// What a level means, in a line short enough for the narrow column (decision W3).
    private func activityLine(_ level: GoalSuggestion.Activity) -> Text {
        switch level {
        case .light: Text("Mostly sitting", bundle: strings)
        case .moderate: Text("Exercise some days", bundle: strings)
        case .active: Text("Exercise most days", bundle: strings)
        }
    }

    // MARK: Use

    /// *Use 2,500 ml* — or, once the goal is that, *✓ Your goal is 2,500 ml*. The button draws a
    /// grouped figure and speaks a `%1$d` one (rule `50-views`).
    @ViewBuilder
    private var useRow: some View {
        if goal == suggestion {
            HStack(spacing: 8) {
                Image(systemName: "checkmark")
                    .font(.body.weight(.bold))
                    .foregroundStyle(Aurora.cyan)
                    .accessibilityHidden(true)
                Text(strings.figure("Your goal is %1$@ ml", suggestion, locale: locale))
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white.opacity(WelcomeStyle.textOpacity))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: WelcomeStyle.useHeight)
            .accessibilityElement(children: .combine)
        } else {
            Button {
                onUse(suggestion)
            } label: {
                Text(strings.figure("Use %1$@ ml", suggestion, locale: locale))
                    .font(.body.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, WelcomeStyle.buttonInset)
                    .frame(maxWidth: .infinity, minHeight: WelcomeStyle.useHeight)
                    .liquidGlass(in: RoundedRectangle(cornerRadius: LiquidGlass.cornerRadius, style: .continuous),
                                 density: .sheer, elevation: .resting, interactive: true)
            }
            .buttonStyle(PressStyle())
            .accessibilityLabel(String(format: strings.localizedString(forKey: "Use %1$d millilitres", value: nil, table: nil), suggestion))
        }
    }

    /// ``LiquidGlass/Selection``'s fill and rim, present at nothing when not picked, and landing on
    /// the one that is (rule `60-design-system`, decision P9).
    private func selectionMark<S: InsettableShape>(_ isSelected: Bool, in shape: S) -> some View {
        shape
            .fill(.white.opacity(isSelected ? LiquidGlass.Selection.fillOpacity : 0))
            .strokeBorder(.white.opacity(isSelected ? LiquidGlass.Selection.rimOpacity : 0), lineWidth: 1)
            .scaleEffect(isSelected ? 1 : 0.9)
            .animation(Motion.land, value: isSelected)
    }
}
```

  `let key = switch …` is an `if`/`switch` expression; Swift 5.9 and later accept it at language mode
  5. History's shortcuts chain `.fill(_:)` and `.strokeBorder(_:lineWidth:)` on a `Capsule` in the
  same way. If the generic `InsettableShape` form does not compile on the iOS 17 SDK surface, write
  `selectionMark` twice, once per concrete shape, and say so in the ledger.

- [ ] **Step 7: The strings.** Add these seventeen entries, in Task 3 Step 10's shape and order:

| Key (= `en`) | `ru` | `uz` |
|---|---|---|
| `%1$d kg` | `%1$d кг` | `%1$d kg` |
| `%1$d lb` | `%1$d фнт` | `%1$d funt` |
| `A starting point, not medical advice.` | `Это ориентир, а не медицинская рекомендация.` | `Bu boshlang‘ich mo‘ljal, tibbiy maslahat emas.` |
| `Active` | `Высокая` | `Yuqori` |
| `Exercise most days` | `Тренируюсь почти каждый день` | `Deyarli har kuni mashq qilaman` |
| `Exercise some days` | `Тренируюсь иногда` | `Ba’zan mashq qilaman` |
| `How active are you?` | `Насколько вы активны?` | `Qanchalik faolsiz?` |
| `Light` | `Низкая` | `Past` |
| `Moderate` | `Средняя` | `O‘rtacha` |
| `Mostly sitting` | `В основном сижу` | `Asosan o‘tiraman` |
| `Use %1$@ ml` | `Выбрать %1$@ мл` | `Tanlash: %1$@ ml` |
| `Use %1$d millilitres` | `Выбрать %1$d миллилитров` | `Tanlash: %1$d millilitr` |
| `Work it out for me` | `Рассчитать за меня` | `Men uchun hisoblang` |
| `Your goal is %1$@ ml` | `Ваша цель — %1$@ мл` | `Maqsadingiz — %1$@ ml` |
| `Your weight` | `Ваш вес` | `Vazningiz` |
| `kg` | `кг` | `kg` |
| `lb` | `фнт` | `funt` |

  The plural forms `миллилитров` and `фнт` are uninflected, as the catalogue's existing
  `%1$d миллилитров` is (#40). Afterwards the read-only check should print `103 True`.

- [ ] **Step 8: GREEN.** Run:
  - `UNIT WelcomeStringTests`, then `UNIT LocalizationTests`.
  - `UI WelcomeUITests`. Expect `Executed 12 tests, with 0 failures`.
  - The welcome's own unit suites again: `UNIT WelcomeStepTests`, `UNIT WelcomeFinishTests`.
- [ ] **Step 9: Stage**:
  `git add WaterBuddy/WelcomeView.swift WaterBuddy/Localizable.xcstrings WaterBuddyTests/LocalizationTests.swift WaterBuddyUITests/WelcomeUITests.swift`.

---

### Task 7: On the simulator — render, measure, record the slide

**Files:** scratch only. A green suite cannot see a step that renders wrong.

- [ ] **Step 1: A scratch copy with a probe.**
  - Make the copy with `git checkout-index -a --prefix="$SCRATCH/look/"`, which takes the index, so
    every task's staged work is in it.
  - Add a throwaway `ZZWelcomeProbe.swift` to the copy's `WaterBuddyUITests/`. It launches with
    `-WaterBuddyFreshStart YES`, `sleep(2)`, and captures `XCTAttachment(screenshot:)` frames named
    by step:
    - Hello;
    - the goal step at rest;
    - the goal step with the calculator open and scrolled into view;
    - *Use* tapped (the ✓ line);
    - Vessels;
    - Reminders;
    - then, after `completeWelcomeIfShown`, Settings at its top and scrolled to the vessels card.
  - Each shot is taken `WB_COUNT` times, `WB_GAP` seconds apart, and the probe also writes the
    labelled elements' frames as a text attachment.
  - Variants arrive as `TEST_RUNNER_WB_VARIANT`: `axxxl` adds the largest category.
  - Build it into its own DerivedData.
- [ ] **Step 2: The devices.**
  - *WaterBuddy Probe 27* (iOS 27.0, Apple's glass), *Probe 26.5* (Apple's glass on 26) and
    *Fallback 18.6* (the hand-made stack), at rest. A minute's sweep runs on each
    (`WB_COUNT=20 WB_GAP=3`).
  - *WaterBuddy Small 26.5* (375 × 667) at the ordinary size and at `axxxl`, which takes the measure
    spec §7 left **unrendered**: the bar's height at the largest size, in points, against the
    screen's.
  - *Probe 27* under Increase Contrast (`xcrun simctl ui <udid> increase_contrast enabled`, then
    `disabled`).
  - *Probe 27* under Reduce Motion, switched through the Settings app by a throwaway XCUITest, then
    back. The Hello waves must stand still, and a step change must cross-fade.
  - *Probe 27* under Reduce Transparency, by the same route (*Accessibility → Display & Text Size*).
    If that switch cannot be driven, record "not rendered" and say so in the report.
  - The app in Russian and in Uzbek, once each at rest on *Probe 27*: `-AppleLanguages (ru)` in the
    probe's launch arguments, since the fresh start follows the device.
- [ ] **Step 3: The measured set**, by `docs/DESIGN.md`'s method: the lightest pixel of clean ground
  beside each text, and the text's own white composited over it. Draw every box on an annotated
  capture and look at it before keeping its figure. Floors are 4.5:1 for text and 3:1 for a glyph or
  a mark.
  - Hello: *Welcome to*, *WaterBuddy*, the line.
  - Each step's title and subtitle, on the aurora.
  - The goal step: the figure, *ml*, the range labels, the footnote, the row's label and its
    sparkle.
  - The calculator: *Your weight*, *How active are you?*, each name and line picked and unpicked,
    the unit labels, *Use*, the ✓ line, the disclaimer.
  - Vessels: the rows, the note, the footnote.
  - Reminders: the preview's three lines, *Smart reminders*, the bell times, the sentence.
  - The bar: the current dot and an inactive dot (3:1), *Back*, *Not now*.
  - Settings' vessel rows, re-read against *Settings, measured*.

  Any pair under its floor stops the stage and goes to the owner with the figure and its capture. No
  value is moved by eye.
- [ ] **Step 4: The slide.**
  - On *Probe 27*: `simctl boot`, `bootstatus -b`, then `xcrun simctl io <udid> recordVideo` in the
    background of the same foreground command as a probe that taps *Continue* once and *Back* once.
  - End the recording with `kill -INT`.
  - Pull frames with a short `swift` script over `AVAssetImageGenerator`.
  - State the travel in points and seconds: a whole width, `Motion.pageDuration` (0.45 s).
- [ ] **Step 5: Shut every device down by UDID.** Log every figure with its device, its frames and its
  box in the ledger. Make a side-by-side sheet of the canvas's five boards beside the build on 27.0,
  26.5 and 18.6.

---

### Task 8: The rules — written, left unstaged

Spec §11's wording, typed in with `Edit`, **not staged**, recorded in the ledger as waiting for the
owner.

- [ ] `70-privacy`, *The lock screen is a public surface*: replace "Ask for authorization only from
  the `set` branch of the reminders toggle, where the user has just asked for reminders. Never at
  launch, never from the setup screen, never from a `.task`" with:
  > Ask for authorization only in answer to the user's own tap asking for reminders: the `set` branch
  > of the Settings toggle, or *Turn on reminders* on the welcome's last step. Never at launch, never
  > when a screen or a step appears, never from a `.task`. Both taps run one implementation,
  > `ReminderPermission.enable(on:using:)`
- [ ] `70-privacy`, *The user's data is theirs*: add spec §11's calculator bullet, verbatim.
- [ ] `80-notifications`, *Authorization*: replace both bullets with spec §11's two, verbatim.
- [ ] `50-views`: under *Composition*, `GoalSetupView.goalRange`/`goalStep` →
  `WelcomeView.goalRange`/`goalStep`, and "its range still lives on `GoalSetupView`" → "its range
  still lives on `WelcomeView`". Under *Previews*, drop `GoalSetupView` from the list of previews
  that omit `rescheduleReminders`.
- [ ] `43-concurrency`, *`View` is `@MainActor`*: drop `GoalSetupView.goalRange` / `.goalStep` from
  the latent warnings. They now sit on `WelcomeView`, carry `nonisolated`, and are read off the main
  actor by `GoalSuggestionTests`.
- [ ] `10-architecture`: the diagram's `SettingsView · GoalSetupView` → `SettingsView · WelcomeView`.
- [ ] `85-testing`, *A fixture may never reach real data*: add spec §11's fresh-start bullet,
  verbatim.
- [ ] `git status --short .claude/` shows the six files modified and unstaged.

---

### Task 9: The review, the gate, the warning comparison

- [ ] **Step 1: A fresh reviewer.** A read-only subagent reviews the staged diff
  (`git diff --cached`) against the spec, this plan's decisions, the rules and the DocC of the types
  changed. Save its report to the ledger folder as it arrives. Check every finding against the code
  before acting on it; a fix goes through the task that owns the file, tests first.
- [ ] **Step 2: The gate.** Rule `85-testing`'s invocations, on this machine's destinations. Run
  `uptime` before each one, and shut down by UDID between systems.
  1. Unit tests on the stock iOS 27.0 *iPhone 17*:
     `xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests -parallel-testing-enabled NO -collect-test-diagnostics never`.
  2. The UI suite on *WaterBuddy Gate 27*:
     - `GoalSetupUITests` in four chunks of nine, as in Task 4 Step 9;
     - then `-only-testing:WaterBuddyUITests -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests -skip-testing:WaterBuddyUITests/GoalSetupUITests`,
       which runs `WelcomeUITests` and the template classes.

     Read each run's **executed** count.
  3. The same UI runs on *WaterBuddy Gate 26.5*.
  4. Watch tests on *WaterBuddy Watch 27*:
     `xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO -collect-test-diagnostics never`.
  5. `xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17'`.
  6. `xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27'`.
- [ ] **Step 3: The warning comparison.**
  - Export the index with `git checkout-index -a --prefix="$SCRATCH/head/"`.
  - Build it exactly as Task 0 Step 2 built HEAD: an empty DerivedData folder, `build-for-testing`
    and then the widget `build`.
  - Count the warnings the same way, then `diff "$SCRATCH/base-warnings.txt" "$SCRATCH/head-warnings.txt"`.
  - Expected: no line the base file lacks.
  - A new line is fixed before reporting, or, if it cannot be, reported as a failure.

---

### Task 10: Records, docs — then stop

- [ ] `docs/DESIGN.md`: a *Welcome, measured* section. It holds:
  - the canvas values;
  - the measured table from Task 7;
  - the bar's height at the largest size on the small phone;
  - the slide's travel;
  - the haptics table's rows for a step, a pick, *Use* and finishing.

  Older rows are marked as superseded, never rewritten.
- [ ] `docs/AI_CONTEXT.md`:
  - a stage 5 block at the head of *Current state*;
  - the files on disk, with `GoalSetupView.swift` gone and four files new;
  - the gate's counts, by the attribute grep;
  - #100(d) retired only if Task 1's wiring is on disk, with the device check named as still to do;
  - new known issues from #130 for anything left: the Russian and Uzbek values unread by a native
    speaker; the harness not run (#82); the permission prompt as a device check; anything Task 7
    could not render.
- [ ] `docs/STATE.md:415,1058`: the present-tense `GoalSetupView` sentences gain "(now `WelcomeView`)",
  and history is left as history.
- [ ] `docs/ROADMAP.md`: item 1.2.3 marked shipped in the tree, awaiting `/commit`.
- [ ] `CLAUDE.md`'s target table: `WaterBuddyUITests` gains `WelcomeUITests`.
- [ ] `tasks/lessons.md` and `HISTORY.md`: appended with `Edit`, anchored on their last lines.
- [ ] Before reporting:
  - Search every sheet for what this stage replaced: `GoalSetupView` in present tense, "eight
    times", "setup screen", "from the `set` branch".
  - Check every `File.swift:N` the sheets cite against the tree.
- [ ] **Two fresh readers** (read-only subagents) on the records. Brief them by line range, and point
  them at the ledger, the gate logs and the saved review. Save each report as it arrives, and check
  its findings against their primary source. Fix by deleting or by quoting the source.
- [ ] Stage the code, this plan and the docs by explicit path; the rule files stay unstaged. Write the
  git block last, from `git status --short` and `git diff --cached --name-status` run at that moment.
- [ ] **Stop.** Report:
  - what was built;
  - the side-by-side sheet;
  - every measured figure that is tight or not taken;
  - the translations to check;
  - the rule wording waiting;
  - the commit order: the code and the plan as `feat(app)`, the docs as `docs`, and the rules as
    `chore(claude)` once approved.
