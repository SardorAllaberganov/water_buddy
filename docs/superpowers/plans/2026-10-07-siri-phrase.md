# Log a Glass by Voice — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: `superpowers:executing-plans`, **in this session** —
> `CLAUDE.md` allows no implementation subagent ("Planning, test authorship, implementation and review
> all happen in the main loop"). Steps use checkbox (`- [ ]`) syntax for tracking. **No step commits:**
> each task ends by staging its paths, and nothing is committed until the owner runs `/commit`.

**Goal:** "Log water in WaterBuddy" logs the user's Glass by Siri, Spotlight or the Shortcuts app,
without opening the app and without saying anything private back.

**Architecture:** A new app-only `LogServingIntent` and `WaterBuddyShortcuts` provider, with phrases in
a new `AppShortcuts.xcstrings`. Siri launches the app in the background; the intent waits briefly for
the watch link, logs `DataManager.usualServing(in:)` through the existing `addWater(amount:)`, waits for
the reminder queue to drain (`ReconcileQueue.settled()`), and replies with one fixed, digit-free line.

**Tech Stack:** Swift (language mode 5, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`), SwiftUI, App
Intents (App Shortcuts), WatchConnectivity, swift-testing, XCTest (one throwaway probe), Xcode 27.0.

**Spec:** `docs/superpowers/specs/2026-10-07-siri-phrase-design.md` — read it first; this plan argues
from it.

## Global Constraints

- Deployment floor **iOS 17.0**: use `AppShortcut(intent:phrases:shortTitle:systemImageName:)`, the
  non-optional overload (iOS 17.0); nothing newer without `#available`.
- **App-only files:** `WaterBuddy/LogServingIntent.swift`, `WaterBuddy/WaterBuddyShortcuts.swift`,
  `WaterBuddy/AppShortcuts.xcstrings`. No exception-set change, no `project.pbxproj` edit.
- **`AddWaterIntent` is untouched.**
- **Strings exactly as spec §3.1/§3.2:** title and tile `Log a Glass`; description `Adds your Glass to
  today's total in WaterBuddy.`; reply `Water logged.`; phrases *Log water in*, *Add water in*, *Log a
  glass in* `${applicationName}` (en) and *Запиши воду в*, *Добавь воду в*, *Запиши стакан в*
  `${applicationName}` (ru). Phrases en + ru only; every other string en/ru/uz.
- **Privacy:** reply digit-free in every language; `authenticationPolicy = .alwaysAllowed`;
  `openAppWhenRun = false`. **No new entitlement and no `NS*UsageDescription`** — if Siri turns out to
  need either, STOP and ask the owner (rule `70-privacy`).
- No dependency; `AppIntents` enters only as an `import` (rule `95-dependencies`).
- Tests: swift-testing; a UUID-named throwaway suite per test that touches defaults; **no real
  `WCSession`, no real notification centre** (rule `85-testing`).
- Every `xcodebuild` in the foreground, `-parallel-testing-enabled NO`, destination
  `'platform=iOS Simulator,OS=26.5,name=iPhone 17'`. Run `xcrun simctl shutdown all` before a test run
  **only if no other `xcodebuild` is running** (`pgrep -x xcodebuild`) — another session's simulator may
  be mid-run.
- **Edits with `Edit`/`Write` only** — `Bash(sed -i:*)` is on the deny list (`tasks/lessons.md`,
  2026-09-02 and 2026-10-07). Never write into `group.sardor.WaterBuddy` or `UserDefaults.standard`.
- No new warning against a clean build of HEAD (Task 5).

## Review Focus

Conditions the spec implies that no unit test can drive end to end, most likely to bite first:

1. **The app already open (or suspended) when Siri runs** — `DataManager.shared` is live with
   observers; the Glass must be logged exactly once and Home must show it. → the probe's
   `testTheTileWhileTheAppIsSuspended` (Task 6).
2. **Midnight crossed since the app last ran** — Siri at 00:05 must log into the new day. → already
   pinned by `rollsOverMidSessionOnAddWater` (`DataManagerTests.swift:316`): `addWater` refreshes and
   rolls over first. Task 3 must call `addWater`, never write a row another way.
3. **No watch, or a link that never activates** — Siri's reply must not hang. → `poll`'s bound and
   cancellation are pinned by `waitingGivesUpAfterItsLastCheck` and `waitingEndsWhenTheTaskIsCancelled`
   (`WaterBuddyWatchTests/WristLinkDeliveryTests.swift`); Task 3 uses `poll` with `atMost: 10`.
4. **A corrupt, short or duplicate-valued triple in the suite** — log the default Glass for a corrupt
   one, the stored middle for `[100, 100, 100]`. → Task 1's `aMalformedTripleFallsBackToTheDefaultGlass`
   and `theWidgetDrawsTheServingSiriLogs`.
5. **Reminders on, one due within the hour** — Siri's drink must drop it, and the change must reach the
   centre before the background launch is suspended. → the drop is pinned by
   `aDrinkSilencesASlotDueWithinTheHour` (`ReminderPlanTests.swift:125`); reaching the centre by Task 2's
   settle test and the owner's device check (spec §8.3).

---

## File structure

| File | Change | Responsibility |
|---|---|---|
| `WaterBuddy/DataManager.swift` | modify | `usualServing(in:)` (one definition of the Glass); `snapshot` uses it; `remindersSettled()`; `WristLink.waitUntilActivated()` |
| `WaterBuddy/NotificationManager.swift` | modify | `ReconcileQueue.settled()` |
| `WaterBuddy/LogServingIntent.swift` | create | the intent: wait for the link, log the Glass, wait for the queue, reply |
| `WaterBuddy/WaterBuddyShortcuts.swift` | create | the one `AppShortcutsProvider` |
| `WaterBuddy/AppShortcuts.xcstrings` | create | the phrases, en + ru |
| `WaterBuddy/Localizable.xcstrings` | modify | `Log a Glass`, the description, `Water logged.` — en/ru/uz |
| `WaterBuddyTests/SiriPhraseTests.swift` | create | `UsualServingTests`, `ReconcileQueueSettledTests`, `LogServingIntentTests`, `AppShortcutPhraseTests` |
| `WaterBuddyUITests/SiriShortcutProbe.swift` | create, then **delete** | throwaway screenshots for spec §8.3 |

Shell variable used below — set it once per shell to **your session's** scratchpad:

```bash
SP=/private/tmp/claude-501/-Users-sardorallaberganov-Desktop-Projects-MobileApps-WaterBuddy/<session>/scratchpad
```

The unit-test command, used by every task with its own `-only-testing:` filter:

```bash
pgrep -x xcodebuild >/dev/null || xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -parallel-testing-enabled NO -only-testing:<FILTER> > $SP/run.log 2>&1; echo "exit $?"
grep -E '✔ Test run|✘ Test run|Expectation failed|\*\* TEST' $SP/run.log | cut -c1-220
```

---

### Task 1: One definition of the Glass — `DataManager.usualServing(in:)`

**Files:**
- Create: `WaterBuddyTests/SiriPhraseTests.swift`
- Modify: `WaterBuddy/DataManager.swift` — after `resolveServings(in:)` (ends ≈ line 1260); `snapshot`'s
  `serving:` argument (≈ line 2441)

**Interfaces:**
- Produces: `nonisolated static func usualServing(in defaults: UserDefaults) -> Int` on `DataManager`.

- [ ] **Step 1: Create the test file with its fixtures and `UsualServingTests`**

```swift
//
//  SiriPhraseTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 07/10/26.
//

import Foundation
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
    let name = "test.waterbuddy.siri.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    return try body(defaults)
}

// MARK: - The serving Siri logs

/// ``DataManager/usualServing(in:)`` — the one definition of the serving the one-tap doors log.
///
/// Not `@MainActor`, like `WaterSnapshotTests`: the widget's timeline provider reaches it from no
/// isolation, so a main-actor member would fail to compile here first (rule `43-concurrency`).
struct UsualServingTests {

    @Test func nothingStoredLogsTheDefaultGlass() {
        withTempDefaults { defaults in
            #expect(DataManager.usualServing(in: defaults) == DataManager.defaultServing)
        }
    }

    @Test func anEditedGlassIsWhatSiriLogs() {
        withTempDefaults { defaults in
            defaults.set([200, 330, 750], forKey: DataManager.Key.servings)
            #expect(DataManager.usualServing(in: defaults) == 330)
        }
    }

    /// `resolveServings(in:)` discards the whole triple on any anomaly, so a corrupt suite logs the
    /// default Glass rather than a repaired element nobody chose.
    @Test func aMalformedTripleFallsBackToTheDefaultGlass() {
        let malformed: [[Any]] = [[330, 750], [200, 0, 750], [200, "330", 750]]
        for stored in malformed {
            withTempDefaults { defaults in
                defaults.set(stored, forKey: DataManager.Key.servings)
                #expect(DataManager.usualServing(in: defaults) == DataManager.defaultServing,
                        "stored \(String(describing: stored))")
            }
        }
    }

    /// The widget and Siri log one serving: the snapshot's `serving` is this, whatever is stored —
    /// including three equal vessels, a state the user is allowed to choose.
    @Test func theWidgetDrawsTheServingSiriLogs() {
        let stored: [[Int]?] = [nil, [200, 330, 750], [100, 100, 100], [330, 750]]
        for triple in stored {
            withTempDefaults { defaults in
                if let triple { defaults.set(triple, forKey: DataManager.Key.servings) }
                let snapshot = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 10, 7))
                #expect(snapshot.serving == DataManager.usualServing(in: defaults),
                        "stored \(String(describing: triple))")
            }
        }
    }
}
```

- [ ] **Step 2: Add the seam — present, compiling, deliberately wrong (the Cup, not the Glass)**

In `WaterBuddy/DataManager.swift`, directly after the closing brace of `resolveServings(in:)`:

```swift

    nonisolated static func usualServing(in defaults: UserDefaults) -> Int {
        resolveServings(in: defaults)[0]
    }
```

- [ ] **Step 3: Run RED**

`<FILTER>` = `WaterBuddyTests/UsualServingTests`. Expected: `✘ Test run with 4 tests … failed`, each
test on its own expectation — `150 == 250`, `200 == 330`, `150 == 250` (three sub-cases), and
`250 == 150` / `330 == 200` in `theWidgetDrawsTheServingSiriLogs` (its `[100, 100, 100]` sub-case
passes by itself; the test fails on the others).

- [ ] **Step 4: Implement — the Glass, with its DocC, and the snapshot reading it**

Replace the seam with:

```swift

    /// The serving every one-tap door logs: the middle quick-add vessel, the Glass.
    ///
    /// **One definition, so the widget's button and the Siri shortcut cannot read different slots.**
    /// Each used to need "index 1" spelled where it read the triple; a `[1]` drifting in one place
    /// would make two front doors log different amounts, with nothing to show it but arithmetic.
    /// ``snapshot(defaults:calendar:now:)`` and `LogServingIntent` both call this.
    ///
    /// `nonisolated static` for the reason ``resolveServings(in:)`` is: the widget's timeline provider
    /// carries no isolation and reaches it through `snapshot`.
    nonisolated static func usualServing(in defaults: UserDefaults) -> Int {
        resolveServings(in: defaults)[1]
    }
```

In `snapshot(defaults:calendar:now:)`, replace

```swift
            // Index 1 is the middle vessel — the one the widget's single button logs and draws.
            serving: resolveServings(in: defaults)[1]
```

with

```swift
            // The middle vessel — the one the widget's single button logs and draws, and the one the
            // Siri shortcut logs.
            serving: usualServing(in: defaults)
```

- [ ] **Step 5: Run GREEN**

`<FILTER>` = `WaterBuddyTests/UsualServingTests` then `WaterBuddyTests/WaterSnapshotTests`. Expected:
`✔ Test run with 4 tests …passed`, then the snapshot suite passing unchanged
(`theWidgetsServingIsTheAppsMiddleVessel` included).

- [ ] **Step 6: Stage**

```bash
git add -- WaterBuddy/DataManager.swift WaterBuddyTests/SiriPhraseTests.swift
```

---

### Task 2: Waiting for the reminder queue — `ReconcileQueue.settled()`

**Files:**
- Modify: `WaterBuddy/NotificationManager.swift` — `ReconcileQueue`, after `enqueue(_:)` (≈ line 270)
- Modify: `WaterBuddy/DataManager.swift` — after `requestReminderReschedule(_:)` (ends ≈ line 1176)
- Test: `WaterBuddyTests/SiriPhraseTests.swift`

**Interfaces:**
- Produces: `func settled() async` on `ReconcileQueue`; `nonisolated static func remindersSettled()
  async` on `DataManager`, compiled out on watchOS.

- [ ] **Step 1: Append `ReconcileQueueSettledTests` to `SiriPhraseTests.swift`**

```swift

// MARK: - Waiting for the reminder queue

/// ``ReconcileQueue/settled()`` — what `LogServingIntent` awaits so a background launch outlives its
/// own re-plan.
///
/// Not `@MainActor`, and time-limited, for `ReconcileQueueTests`' reasons: the queue's callers are
/// `nonisolated`, and a settle that never returns should fail the gate in a minute rather than hang
/// it. The `Task.sleep`s only give work asked for later the time to overtake work asked for earlier;
/// a settle that keeps its place spends that time waiting.
@Suite(.timeLimit(.minutes(1)))
struct ReconcileQueueSettledTests {

    /// The settle waits for what was asked before it, and not for what came after: a later
    /// mutation's re-plan must not hold Siri's reply.
    @Test func aSettleWaitsForEarlierWorkButNotForLaterWork() async {
        let queue = ReconcileQueue()
        let (events, event) = AsyncStream<String>.makeStream()

        queue.enqueue {
            try? await Task.sleep(for: .milliseconds(100))
            event.yield("earlier work")
        }
        let settling = Task {
            await queue.settled()
            event.yield("settled")
        }
        // Time for the settle to take its place in line before the later work asks for one.
        try? await Task.sleep(for: .milliseconds(50))
        queue.enqueue {
            try? await Task.sleep(for: .milliseconds(300))
            event.yield("later work")
        }

        let order = await events.prefix(3).reduce(into: [String]()) { $0.append($1) }
        await settling.value
        #expect(order == ["earlier work", "settled", "later work"])
    }

    /// Nothing queued, nothing to wait for — measured rather than merely reached, so a settle that
    /// stalls fails here and not only at the suite's time limit.
    @Test func settlingAnIdleQueueReturnsPromptly() async {
        let queue = ReconcileQueue()
        let elapsed = await ContinuousClock().measure { await queue.settled() }
        #expect(elapsed < .seconds(1))
    }
}
```

- [ ] **Step 2: Add the seam — returns at once**

In `ReconcileQueue`, after `enqueue(_:)`:

```swift

    func settled() async {}
```

- [ ] **Step 3: Run RED**

`<FILTER>` = `WaterBuddyTests/ReconcileQueueSettledTests`. Expected: `aSettleWaitsForEarlierWorkButNotForLaterWork`
fails with `["settled", "earlier work", "later work"]`; `settlingAnIdleQueueReturnsPromptly` passes
against this seam — it is proven by mutation in Step 6.

- [ ] **Step 4: Implement**

Replace the seam in `NotificationManager.swift` with:

```swift

    /// Returns once every operation enqueued before this call has run.
    ///
    /// It enqueues an operation of its own that does nothing but resume the caller, so it rides the
    /// same worker: it cannot overtake work asked for earlier, and work asked for after it does not
    /// hold it. ``DataManager/remindersSettled()`` is its one production caller.
    func settled() async {
        await withCheckedContinuation { (resumed: CheckedContinuation<Void, Never>) in
            enqueue { resumed.resume() }
        }
    }
```

In `DataManager.swift`, directly after the closing brace of `requestReminderReschedule(_:)`:

```swift

    #if !os(watchOS)
    /// Returns once every reminder plan asked for before the call has reached the notification centre.
    ///
    /// **What `LogServingIntent` awaits before Siri's reply.** Siri launches the app in the background
    /// to run the intent, and the system may suspend it as soon as `perform()` returns — before the
    /// re-plan the intent's own mutation queued has run. Waiting on the queue rather than calling
    /// ``NotificationManager/reconcile(_:calendar:strings:using:)`` directly keeps every plan in call
    /// order: a reconcile run beside the queue is how known issue #46 raced (rule `80-notifications`).
    ///
    /// Compiled out on watchOS with ``reminderReconciles`` itself: `ReconcileQueue` is not in the watch
    /// targets.
    nonisolated static func remindersSettled() async {
        await reminderReconciles.settled()
    }
    #endif
```

- [ ] **Step 5: Run GREEN**

`<FILTER>` = `WaterBuddyTests/ReconcileQueueSettledTests` then `WaterBuddyTests/ReconcileQueueTests`.
Expected: both suites pass.

- [ ] **Step 6: Prove the idle test by mutation, then restore**

```bash
cp WaterBuddy/NotificationManager.swift $SP/NotificationManager.swift.saved
```

With `Edit`, replace the body of `settled()` with `try? await Task.sleep(for: .seconds(2))`. Run
`<FILTER>` = `WaterBuddyTests/ReconcileQueueSettledTests`. Expected: **both** tests fail —
`elapsed < .seconds(1)` false, and the order `["earlier work", "later work", "settled"]` (the second
test's other mutation proof: a settle that waits for later work). Then restore and prove it:

```bash
cp $SP/NotificationManager.swift.saved WaterBuddy/NotificationManager.swift
cmp WaterBuddy/NotificationManager.swift $SP/NotificationManager.swift.saved && echo restored
grep -n 'Task.sleep(for: .seconds(2))' WaterBuddy/NotificationManager.swift || echo 'no mutation left'
```

- [ ] **Step 7: Build the watch widget** — `DataManager.swift` compiles into it, and `remindersSettled()`
  must be compiled out there:

```bash
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' > $SP/ww.log 2>&1; echo "exit $?"
grep -E '\*\* BUILD|error:' $SP/ww.log | tail -3
```

Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 8: Stage**

```bash
git add -- WaterBuddy/NotificationManager.swift WaterBuddy/DataManager.swift WaterBuddyTests/SiriPhraseTests.swift
```

---

### Task 3: The intent, its reply, and the wait for the watch link

**Files:**
- Create: `WaterBuddy/LogServingIntent.swift`
- Modify: `WaterBuddy/DataManager.swift` — `WristLink`, after `waitForPendingDelivery()` (≈ line 2185)
- Modify: `WaterBuddy/Localizable.xcstrings` — three keys
- Test: `WaterBuddyTests/SiriPhraseTests.swift`

**Interfaces:**
- Consumes: `DataManager.usualServing(in:)` (Task 1), `DataManager.remindersSettled()` (Task 2),
  `DataManager.shared`, `DataManager.sharedDefaults`, `WristLink.poll(until:every:atMost:)`.
- Produces: `struct LogServingIntent: AppIntent` with `static let reply: LocalizedStringResource`;
  `nonisolated static func waitUntilActivated() async` on `WristLink`.

- [ ] **Step 1: Append the language helper and `LogServingIntentTests` to `SiriPhraseTests.swift`**

Add to the `// MARK: - Fixtures` section:

```swift

/// One language's `.lproj` inside the app, or `nil` if it did not ship.
private func lproj(_ language: String) -> Bundle? {
    Bundle.main.url(forResource: language, withExtension: "lproj").flatMap(Bundle.init(url:))
}

/// What no translation could be, so a missing key is told apart from one translated to itself.
private let missingKey = "\u{0}__missing__\u{0}"
```

And at the end of the file:

```swift

// MARK: - The intent's contract

/// `LogServingIntent`'s privacy contract (rule `70-privacy`; spec 2026-10-07-siri-phrase §5): it runs
/// on a locked iPhone, it never opens the app, and its reply carries no figure in any language.
@MainActor
struct LogServingIntentTests {

    @Test func theSiriShortcutRunsOnALockedPhone() {
        #expect(LogServingIntent.authenticationPolicy == .alwaysAllowed)
    }

    @Test func theSiriShortcutNeverOpensTheApp() {
        #expect(LogServingIntent.openAppWhenRun == false)
    }

    /// Spoken aloud and shown on a locked iPhone: no total, no goal, no serving, no digit — the
    /// standard `theReminderCopyCarriesNoUserValues` holds the reminders to. Each language's bundle
    /// is proven to resolve first, or every check below would pass vacuously.
    @Test func theSiriReplyCarriesNoUserValues() throws {
        let key = LogServingIntent.reply.key
        for language in ["en", "ru", "uz"] {
            let bundle = try #require(lproj(language), "the app ships no \(language) localization")
            let reply = bundle.localizedString(forKey: key, value: missingKey, table: nil)
            #expect(reply != missingKey, "\(language) has no translation of Siri's reply")
            #expect(!reply.contains { $0.isNumber }, "the \(language) reply carries a figure: \(reply)")
        }
    }
}
```

- [ ] **Step 2: Add the seam — `WaterBuddy/LogServingIntent.swift`, compiling and wrong on purpose**

```swift
import AppIntents

struct LogServingIntent: AppIntent {
    static let title: LocalizedStringResource = "Log a Glass"
    static let openAppWhenRun = true
    static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication
    static let reply: LocalizedStringResource = "Logged 250 ml."

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: IntentDialog(Self.reply))
    }
}
```

- [ ] **Step 3: Run RED**

`<FILTER>` = `WaterBuddyTests/LogServingIntentTests`. Expected: all three fail — `.requiresAuthentication
== .alwaysAllowed`, `true == false`, and for each language "has no translation of Siri's reply"
(`Logged 250 ml.` is in no table, so it resolves to the marker). The figure check cannot fail against a
missing key — the marker has no digit — so it is proven by mutation in Step 9.

- [ ] **Step 4: Add `WristLink.waitUntilActivated()`** in `DataManager.swift`, directly after the closing
  brace of `waitForPendingDelivery()`:

```swift

    /// Returns once `WCSession` has activated, after about a second, at once where `WCSession` is
    /// unsupported, or the moment the task is cancelled.
    ///
    /// **What `LogServingIntent` awaits before it logs.** Siri launches the app in the background just
    /// to run the intent, and `WaterBuddyApp.init()` starts activation on that same launch — so the
    /// intent's mutation could publish before the session is up, and
    /// ``DataManager/requestWristPublish(from:)`` drops a publish that throws `sessionNotActivated`.
    /// Bounded, because a watch that never answers must not hold Siri's reply; the publish on
    /// activation (`activationDidCompleteWith`) still fires later if the process is alive. The pure
    /// half is ``poll(until:every:atMost:)``.
    nonisolated static func waitUntilActivated() async {
        guard WCSession.isSupported() else { return }
        _ = await poll(until: { WCSession.default.activationState == .activated },
                       every: .milliseconds(100), atMost: 10)
    }
```

- [ ] **Step 5: Replace the seam with the intent** — `WaterBuddy/LogServingIntent.swift`:

```swift
//
//  LogServingIntent.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 07/10/26.
//

import AppIntents

/// Logs the user's Glass — the serving the widget's button adds — from Siri, Spotlight or the
/// Shortcuts app, without opening the app.
///
/// **App-only, and a different action from `AddWaterIntent`.** A Siri phrase needs its intent in the
/// target of its `AppShortcutsProvider`, and Siri runs an app-target intent by launching the app in
/// the background — the one process that can also reach the watch (known issue #53).
/// `AddWaterIntent` stays the widget extension's own: it logs whatever amount its caller decoded,
/// which is why it may not re-read the serving at run time (rule `40-widget`). This intent takes no
/// amount at all, so reading the Glass when it runs is its whole job.
///
/// **What Siri may say is fixed.** The reply is ``reply`` — no amount, no total, no digit — because it
/// is spoken aloud and shown on a locked iPhone, the public surface rule `70-privacy` holds the
/// reminders to. `theSiriReplyCarriesNoUserValues` pins it in every shipped language.
///
/// Design: `docs/superpowers/specs/2026-10-07-siri-phrase-design.md`.
struct LogServingIntent: AppIntent {

    // `let`, not `var`, as on `AddWaterIntent`: a `static var` on a `Sendable` type is nonisolated
    // global mutable state.
    static let title: LocalizedStringResource = "Log a Glass"

    static let description = IntentDescription(
        "Adds your Glass to today's total in WaterBuddy.",
        categoryName: "Hydration"
    )

    /// Siri, Spotlight and the Shortcuts app run it where they stand; opening the app would undo the
    /// point of logging by voice.
    static let openAppWhenRun = false

    /// The default, written out so the choice is visible where it is made: logging water on a locked
    /// iPhone is harmless, and the reply says nothing.
    static let authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed

    /// Siri's whole reply. A static rather than an inline literal, so the privacy test reads the key
    /// this intent actually speaks.
    static let reply: LocalizedStringResource = "Water logged."

    /// `@MainActor` on a `nonisolated` requirement, as on `AddWaterIntent`, so the body reaches
    /// ``DataManager/shared`` directly.
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // The watch link first: this launch started activating it in `WaterBuddyApp.init()`, and a
        // publish before it is up is dropped.
        await WristLink.waitUntilActivated()

        // Read when Siri runs, not when anything was built, so a Glass edited a minute ago counts.
        // `addWater` re-reads the store and rolls the day over before it adds.
        DataManager.shared.addWater(amount: DataManager.usualServing(in: DataManager.sharedDefaults))

        // The re-plan `addWater` queued must reach the notification centre before the system can
        // suspend this background launch (rule `80-notifications`).
        await DataManager.remindersSettled()

        return .result(dialog: IntentDialog(Self.reply))
    }
}
```

- [ ] **Step 6: Add the three strings** to `WaterBuddy/Localizable.xcstrings` with `Edit`, keeping the
  file's key order (it is sorted). Insert **before** `    "Average %1$d millilitres. Best %2$d millilitres.": {`:

```json
    "Adds your Glass to today's total in WaterBuddy.": {
      "extractionState": "manual",
      "localizations": {
        "en": {
          "stringUnit": {
            "state": "translated",
            "value": "Adds your Glass to today's total in WaterBuddy."
          }
        },
        "ru": {
          "stringUnit": {
            "state": "translated",
            "value": "Добавляет ваш стакан к сегодняшнему итогу в WaterBuddy."
          }
        },
        "uz": {
          "stringUnit": {
            "state": "translated",
            "value": "WaterBuddy’dagi bugungi umumiy hisobga stakaningizni qo‘shadi."
          }
        }
      }
    },
```

Insert **before** `    "Measured against your current goal": {`:

```json
    "Log a Glass": {
      "extractionState": "manual",
      "localizations": {
        "en": {
          "stringUnit": {
            "state": "translated",
            "value": "Log a Glass"
          }
        },
        "ru": {
          "stringUnit": {
            "state": "translated",
            "value": "Записать стакан"
          }
        },
        "uz": {
          "stringUnit": {
            "state": "translated",
            "value": "Stakanni qayd etish"
          }
        }
      }
    },
```

Insert **before** `    "WaterBuddy": {`:

```json
    "Water logged.": {
      "extractionState": "manual",
      "localizations": {
        "en": {
          "stringUnit": {
            "state": "translated",
            "value": "Water logged."
          }
        },
        "ru": {
          "stringUnit": {
            "state": "translated",
            "value": "Вода записана."
          }
        },
        "uz": {
          "stringUnit": {
            "state": "translated",
            "value": "Suv qayd etildi."
          }
        }
      }
    },
```

Check the file still parses and stays sorted:

```bash
python3 -c "import json;k=list(json.load(open('WaterBuddy/Localizable.xcstrings'))['strings']);print(len(k), k==sorted(k))"
```

Expected: `64 True` (61 keys before).

- [ ] **Step 7: Run GREEN, and check the new code compiled warning-free in that same run**

`<FILTER>` = `WaterBuddyTests/LogServingIntentTests`. Expected: passes. This is the run that compiled
`LogServingIntent.swift` and the new `DataManager.swift` lines, so check its log before running anything
else:

```bash
grep -E '(LogServingIntent|DataManager|NotificationManager)\.swift:[0-9]+:[0-9]+: warning:' $SP/run.log \
  | sed -E 's#^/[^ ]*/##' | sort -u
```

Expected: no line naming `LogServingIntent.swift`, and nothing in `DataManager.swift` or
`NotificationManager.swift` outside the baseline's two families (Task 5 settles that against a clean
build). If an isolation warning names `LogServingIntent` (the app target defaults to `MainActor`),
declare it `nonisolated struct LogServingIntent: AppIntent` — the precedent is `nonisolated final class
WristLink` — re-run this step, and confirm the line is gone.

- [ ] **Step 8: Run the localization suite**

`<FILTER>` = `WaterBuddyTests/LocalizationTests`. Expected: passes —
`everyDrawnStringIsTranslatedUnlessDeliberatelyNot` now sees the three keys, all translated.

- [ ] **Step 9: Prove the figure check by mutation, then restore**

```bash
cp WaterBuddy/Localizable.xcstrings $SP/Localizable.xcstrings.saved
```

With `Edit`, change the `en` value of `"Water logged."` to `"Water logged: 250 ml."`. Run `<FILTER>` =
`WaterBuddyTests/LogServingIntentTests`. Expected: `theSiriReplyCarriesNoUserValues` fails on "the en
reply carries a figure". Then:

```bash
cp $SP/Localizable.xcstrings.saved WaterBuddy/Localizable.xcstrings
cmp WaterBuddy/Localizable.xcstrings $SP/Localizable.xcstrings.saved && echo restored
grep -c 'Water logged: 250 ml.' WaterBuddy/Localizable.xcstrings
```

Expected: `restored`, then `0`.

- [ ] **Step 10: Stage**

```bash
git add -- WaterBuddy/LogServingIntent.swift WaterBuddy/DataManager.swift WaterBuddy/Localizable.xcstrings WaterBuddyTests/SiriPhraseTests.swift
```

---

### Task 4: The shortcut and its phrases

**Files:**
- Create: `WaterBuddy/WaterBuddyShortcuts.swift`, `WaterBuddy/AppShortcuts.xcstrings`
- Test: `WaterBuddyTests/SiriPhraseTests.swift`

**Interfaces:**
- Consumes: `LogServingIntent` (Task 3).
- Produces: `struct WaterBuddyShortcuts: AppShortcutsProvider`.

- [ ] **Step 1: Append `AppShortcutPhraseTests`**

```swift

// MARK: - The phrases

/// Siri's phrases ship in English and Russian — Siri has no Uzbek — and every one names the app,
/// without which Siri cannot tell whose shortcut it is (spec 2026-10-07-siri-phrase §3.2).
struct AppShortcutPhraseTests {

    @Test func everyPhraseNamesTheAppInEnglishAndRussian() throws {
        for language in ["en", "ru"] {
            let path = try #require(
                Bundle.main.path(forResource: "AppShortcuts", ofType: "strings", inDirectory: nil,
                                 forLocalization: language),
                "the app ships no \(language) phrase table"
            )
            let table = try #require(NSDictionary(contentsOfFile: path) as? [String: String])
            #expect(table.count == 3, "\(language) has \(table.count) phrases")
            for phrase in table.values {
                #expect(phrase.contains("${applicationName}"), "a \(language) phrase does not name the app: \(phrase)")
            }
        }
    }
}
```

- [ ] **Step 2: Run RED**

`<FILTER>` = `WaterBuddyTests/AppShortcutPhraseTests`. Expected: fails — "the app ships no en phrase table".

- [ ] **Step 3: Create `WaterBuddy/WaterBuddyShortcuts.swift`**

```swift
//
//  WaterBuddyShortcuts.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 07/10/26.
//

import AppIntents

/// The product's one App Shortcut: "Log water in WaterBuddy" logs the user's Glass by voice, with no
/// setup, and the same action shows as a tile in Spotlight and the Shortcuts app.
///
/// **One provider per app, in the target of the intent it names** — Apple's rule; the build reports an
/// intent that is not. So it lives in the app beside ``LogServingIntent``, never in the widget
/// extension.
///
/// **Phrases are English and Russian only.** Siri has no Uzbek, so `AppShortcuts.xcstrings` ships no
/// `uz` — the one catalogue exempt from shipping all three languages. Every phrase names the app: Siri
/// needs `\(.applicationName)` to know whose shortcut it is.
struct WaterBuddyShortcuts: AppShortcutsProvider {

    // A computed `static var`, unlike the `static let`s elsewhere: the protocol's
    // `@AppShortcutsBuilder` requirement can only be met by one.
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
    }

    static let shortcutTileColor: ShortcutTileColor = .blue
}
```

- [ ] **Step 4: Create `WaterBuddy/AppShortcuts.xcstrings`**

```json
{
  "sourceLanguage": "en",
  "strings": {
    "Add water in ${applicationName}": {
      "localizations": {
        "en": {
          "stringUnit": {
            "state": "translated",
            "value": "Add water in ${applicationName}"
          }
        },
        "ru": {
          "stringUnit": {
            "state": "translated",
            "value": "Добавь воду в ${applicationName}"
          }
        }
      }
    },
    "Log a glass in ${applicationName}": {
      "localizations": {
        "en": {
          "stringUnit": {
            "state": "translated",
            "value": "Log a glass in ${applicationName}"
          }
        },
        "ru": {
          "stringUnit": {
            "state": "translated",
            "value": "Запиши стакан в ${applicationName}"
          }
        }
      }
    },
    "Log water in ${applicationName}": {
      "localizations": {
        "en": {
          "stringUnit": {
            "state": "translated",
            "value": "Log water in ${applicationName}"
          }
        },
        "ru": {
          "stringUnit": {
            "state": "translated",
            "value": "Запиши воду в ${applicationName}"
          }
        }
      }
    }
  },
  "version": "1.0"
}
```

- [ ] **Step 5: Run GREEN**

`<FILTER>` = `WaterBuddyTests/AppShortcutPhraseTests`. Expected: passes. Then confirm the build validated
the phrases:

```bash
grep -iE 'applicationName|AppShortcut|utterance|should be in the same target' $SP/run.log | grep -i warning | sort -u
grep -E 'WaterBuddyShortcuts\.swift:[0-9]+:[0-9]+: warning:' $SP/run.log | sed -E 's#^/[^ ]*/##' | sort -u
```

Expected: nothing from either. An isolation warning on `WaterBuddyShortcuts` gets Task 3 Step 7's remedy:
`nonisolated struct WaterBuddyShortcuts: AppShortcutsProvider`. **If the test still fails** because the build emits no `AppShortcuts.strings` at all,
look for what it does emit — `find ~/Library/Developer/Xcode/DerivedData/WaterBuddy-*/Build/Products/Debug-iphonesimulator/WaterBuddy.app -iname '*shortcut*'`
— and if the phrases are not in a readable table, **delete this test** and record in `HISTORY.md` that the
build's own phrase validation is the check (spec §7). Never weaken it into an expectation that cannot fail.

- [ ] **Step 6: Stage**

```bash
git add -- WaterBuddy/WaterBuddyShortcuts.swift WaterBuddy/AppShortcuts.xcstrings WaterBuddyTests/SiriPhraseTests.swift
```

---

### Task 5: The gate and the warning comparison

**Files:** none changed.

- [ ] **Step 1: The five invocations**, foreground, exactly as rule `85-testing` writes them:

```bash
pgrep -x xcodebuild >/dev/null || xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests -parallel-testing-enabled NO > $SP/g1.log 2>&1; echo "exit $?"
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyUITests -parallel-testing-enabled NO \
  -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests > $SP/g2.log 2>&1; echo "exit $?"
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' \
  -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO > $SP/g3.log 2>&1; echo "exit $?"
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' > $SP/g4.log 2>&1; echo "exit $?"
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' > $SP/g5.log 2>&1; echo "exit $?"
```

Expected: `✔ Test run with 368 tests in 45 suites passed` (358/41 + 10 tests in 4 suites); `Executed 26
tests, with 0 failures`; `✔ Test run with 57 tests in 6 suites passed`; `** BUILD SUCCEEDED **` twice.
A UI run refused as `Busy` (#57): boot the device and wait for it — on this machine
`xcrun simctl bootstatus EE56B958-E33F-40A3-99EA-B14D45963685 -b` (the iOS 26.5 *iPhone 17*; re-read the
UDID with `xcrun simctl list devices` elsewhere) — then run it again, and record both runs.

- [ ] **Step 2: Clean builds of HEAD and of the change, into empty DerivedData, same sequence both sides**

```bash
rm -rf $SP/wc && mkdir -p $SP/wc/base
git archive HEAD | tar -x -C $SP/wc/base
cp -R $SP/wc/base $SP/wc/change
for f in WaterBuddy/DataManager.swift WaterBuddy/NotificationManager.swift WaterBuddy/LogServingIntent.swift \
         WaterBuddy/WaterBuddyShortcuts.swift WaterBuddy/AppShortcuts.xcstrings WaterBuddy/Localizable.xcstrings \
         WaterBuddyTests/SiriPhraseTests.swift; do cp "$f" "$SP/wc/change/$f"; done
for side in base change; do
  xcodebuild build-for-testing -project $SP/wc/$side/WaterBuddy.xcodeproj -scheme WaterBuddy \
    -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' -derivedDataPath $SP/wc/dd-$side > $SP/wc/$side-app.log 2>&1; echo "$side app exit $?"
done
```

Then the other three schemes, each its own foreground invocation — never one loop over all four (the
600 s limit):

```bash
for side in base change; do
  xcodebuild build -project $SP/wc/$side/WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
    -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' -derivedDataPath $SP/wc/dd-$side > $SP/wc/$side-widget.log 2>&1; echo "$side widget exit $?"
done
```

```bash
for side in base change; do
  xcodebuild build -project $SP/wc/$side/WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
    -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' -derivedDataPath $SP/wc/dd-$side > $SP/wc/$side-watch.log 2>&1; echo "$side watch exit $?"
done
```

```bash
for side in base change; do
  xcodebuild build -project $SP/wc/$side/WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget \
    -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' -derivedDataPath $SP/wc/dd-$side > $SP/wc/$side-watchwidget.log 2>&1; echo "$side watchwidget exit $?"
done
```

If one invocation nears the limit, split it into its two sides.

- [ ] **Step 3: Compare per log, per file and message, line numbers stripped**

```bash
for log in app widget watch watchwidget; do
  for side in base change; do
    grep -E ': warning: ' $SP/wc/$side-$log.log | grep -vE '^\s+\|' \
      | sed -E 's#^/[^ ]*/(WaterBuddy[A-Za-z]*/[^:]+):[0-9]+:[0-9]+: #\1: #' | sort | uniq -c > $SP/wc/$side-$log.warn
  done
  echo "== $log"; diff $SP/wc/base-$log.warn $SP/wc/change-$log.warn && echo identical
done
```

Expected: `identical` for every log, except that the app target's `appintentsmetadataprocessor` line may
change — it now has intents to extract. Any other difference is a new warning: fix it before going on.

---

### Task 6: On the simulator — a throwaway probe

**Files:** create `WaterBuddyUITests/SiriShortcutProbe.swift`, then **delete it** before staging
(`tasks/lessons.md`, 2026-10-07, "Renders without a product hook").

- [ ] **Step 1: Write the probe**

```swift
// THROWAWAY — deleted before anything is staged. Screenshots for spec 2026-10-07-siri-phrase §8.3.
import XCTest

final class SiriShortcutProbe: XCTestCase {

    private func shot(_ name: String, _ app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Home's vessel value — "N percent. X of Y millilitres." — or a marker if it never appeared.
    private func total(_ app: XCUIApplication) -> String {
        let vessel = app.descendants(matching: .any)["Today's hydration"].firstMatch
        guard vessel.waitForExistence(timeout: 10) else { return "no vessel" }
        return vessel.value as? String ?? "no value"
    }

    private func openWaterBuddy() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        if app.buttons["Get Started"].waitForExistence(timeout: 3) { app.buttons["Get Started"].tap() }
        return app
    }

    /// Taps the tile in the Shortcuts app. Its layout is Apple's: if the query misses, the printed
    /// tree says what to tap instead — this file is thrown away.
    private func runTheTile() {
        let shortcuts = XCUIApplication(bundleIdentifier: "com.apple.shortcuts")
        shortcuts.launch()
        shot("shortcuts-launched", shortcuts)
        let tile = shortcuts.descendants(matching: .any)["Log a Glass"].firstMatch
        if !tile.waitForExistence(timeout: 10) { print(shortcuts.debugDescription) }
        XCTAssertTrue(tile.exists, "no Log a Glass tile in Shortcuts")
        tile.tap()
        sleep(3)
        shot("shortcuts-after-tap", shortcuts)
    }

    func testTheTileLogsTheGlassFromAColdStart() {
        let app = openWaterBuddy()
        let before = total(app)
        app.terminate()
        runTheTile()
        let after = total(openWaterBuddy())
        print("cold: \(before) -> \(after)")
        XCTAssertNotEqual(before, after, "the total did not move")
    }

    func testTheTileWhileTheAppIsSuspended() {
        let app = openWaterBuddy()
        let before = total(app)
        XCUIDevice.shared.press(.home)
        runTheTile()
        app.activate()
        let after = total(app)
        shot("home-after-suspended-run", app)
        print("suspended: \(before) -> \(after)")
        XCTAssertNotEqual(before, after, "the open app did not show the Glass")
    }

    func testTheTileInRussian() {
        let shortcuts = XCUIApplication(bundleIdentifier: "com.apple.shortcuts")
        shortcuts.launchArguments = ["-AppleLanguages", "(ru)", "-AppleLocale", "ru_RU"]
        shortcuts.launch()
        sleep(3)
        shot("shortcuts-ru", shortcuts)
        print(shortcuts.debugDescription)
    }

    func testSpotlightFindsTheTile() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        XCUIDevice.shared.press(.home)
        springboard.swipeDown()
        let field = springboard.searchFields.firstMatch
        guard field.waitForExistence(timeout: 5) else { return print(springboard.debugDescription) }
        field.typeText("Log a Glass")
        sleep(2)
        shot("spotlight", springboard)
    }

    func testSiriRunsThePhrase() {
        XCUIDevice.shared.siriService.activate(voiceRecognitionText: "Log water in WaterBuddy")
        sleep(6)
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        shot("siri", springboard)
        print(springboard.debugDescription)
    }
}
```

- [ ] **Step 2: Run it and export the screenshots**

```bash
pgrep -x xcodebuild >/dev/null || xcrun simctl shutdown all
rm -rf $SP/probe.xcresult $SP/probe-shots
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' -parallel-testing-enabled NO \
  -only-testing:WaterBuddyUITests/SiriShortcutProbe -resultBundlePath $SP/probe.xcresult > $SP/probe.log 2>&1; echo "exit $?"
grep -E 'cold:|suspended:|Test Case .*(passed|failed)' $SP/probe.log
xcrun xcresulttool export attachments --path $SP/probe.xcresult --output-path $SP/probe-shots
ls $SP/probe-shots
```

Look at every PNG (the `Read` tool shows images). Record: the tile exists and is titled *Log a Glass*;
both runs moved the total by exactly the Glass amount the simulator's app has set; the reply reads *Water logged.*
where the screenshot shows it; the Russian tile reads *Записать стакан*; Spotlight lists the tile;
whether the simulator ran Siri at all. **If Siri or Shortcuts asks for a permission or capability**, STOP
— spec §4's inference is wrong, and that is the owner's call.

- [ ] **Step 3: Delete the probe and prove it is gone**

```bash
rm WaterBuddyUITests/SiriShortcutProbe.swift
git status --short WaterBuddyUITests/
```

Expected: no line for the probe.

**Not re-placed: the Home Screen widget.** Its view tree, timeline and storage are unchanged, and the one
read-path change — `snapshot`'s `serving` now comes from `usualServing(in:)` — is the same value, pinned
by `theWidgetsServingIsTheAppsMiddleVessel` and `theWidgetDrawsTheServingSiriLogs`. The new files join
the app target only, so no extension's membership moved.

---

### Task 7: Records, docs, rules — then stop

- [ ] **Step 1:** `@Test` counts by the attribute (rule `85-testing`):

```bash
grep -chE '^[[:space:]]*@Test' WaterBuddyTests/*.swift | awk '{s+=$1} END {print s}'
```

Expected: `368`.

- [ ] **Step 2: `HISTORY.md` checkpoint**, appended with `Edit` at the end of the file:
  `## [2026-10-07] — "Log water in WaterBuddy" logs the Glass by voice` — what changed, the owner's
  rulings (spec §1), files touched with line counts, RED/GREEN and the mutation proof, the gate's exact
  lines, the warning comparison, the simulator findings, and what was not run (the owner's device check).
- [ ] **Step 3: `/doc_sync`** — `docs/AI_CONTEXT.md` (four new files, counts, gate, known issues: the
  stale "untranslated" section of `docs/WIDGET.md`, and `AddWaterIntent`'s unverified "registers twice"
  claim), `docs/WIDGET.md` (the snapshot's serving source; that stale section), `docs/STATE.md`
  (`usualServing`), `CLAUDE.md` ("Two front doors, one serving" — Siri logs the same serving through
  the app's process), `tasks/lessons.md`.
- [ ] **Step 4: Put spec §5's rule wording to the owner.** Write only what they approve, on its own paths.
- [ ] **Step 5: Stage by explicit path and stop** — `git diff --cached --name-status` against
  `git diff --name-status`; no `git commit` until the owner runs `/commit`. The owner's device check
  (spec §8.3) follows.
