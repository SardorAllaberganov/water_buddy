# Log from a Reminder — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: `superpowers:executing-plans`, **in this session** —
> `CLAUDE.md` allows no implementation subagent. Steps use checkbox (`- [ ]`) syntax. **No step
> commits:** each task stages nothing until Task 8, which stages by explicit path, and nothing is
> committed until the owner runs `/commit`.

**Goal:** A *Log a Glass* button on the reminder notification that logs the user's Glass without
opening the app, and pending reminders filed again whenever their wording — the button included —
differs from what would be filed now.

**Architecture:** `NotificationManager.swift` (shared with the widget) gains the category, its two
identifiers, a `PendingReminder` value the seam now reads back, and a reconcile that re-files a
pending reminder in other words. `DataManager.requestReminderReschedule` registers the category in
its queued operation, and the `language` setter re-plans. A new app-only `ReminderResponder` is the
notification centre's main-actor delegate, installed in `WaterBuddyApp.init()`, and runs
`LogServingIntent.logTheGlassInTheBackground()` — the Siri phrase's three steps, moved into one
function both doors call.

**Tech Stack:** Swift (language mode 5; the app and test targets default to main-actor isolation,
with approachable concurrency), UserNotifications, App Intents, swift-testing, XCTest, Xcode 27.0.

**Spec:** `docs/superpowers/specs/2026-10-15-log-from-a-reminder-design.md` (approved 2026-10-15,
"ok"). Roadmap item **1.2.4**.

**Ledger:** `.superpowers/sdd/2026-10-15-log-from-a-reminder/progress.md` (git-ignored).

## Decisions this plan takes

Measured while planning, on 2026-10-15, against an export of HEAD `6010e25` in this session's
scratchpad (`$SCRATCH/head`, itself a git repository whose one commit is HEAD, so
`git -C "$SCRATCH/head" diff` shows the prototype). Each build was `build-for-testing` of the
`WaterBuddy` scheme for `generic/platform=iOS Simulator`.

- **P1 — `ReminderScheduler` becomes `nonisolated struct`.** At HEAD, `reconcile`'s two
  *synchronous* seam calls warn — `main actor-isolated property 'removePending' cannot be accessed
  from outside of the actor`, and the same for `removeDelivered` — while the *awaited* ones
  (`pendingIdentifiers`, `add`) do not: the struct takes the app target's default main-actor
  isolation. The spec's `setCategories` is synchronous and is called from the nonisolated queue, so
  it would add a third. With `nonisolated` on the struct, a clean build of the prototype printed
  **52** unique warning lines against HEAD's **54**: the two above gone, none new, by file and
  message, tests and macro expansions included (`$SCRATCH/build-head.log`,
  `$SCRATCH/build-proto-clean.log`).
- **P2 — `AppLanguage.bundle` becomes `nonisolated`.** The queued operation reads the bundle once,
  synchronously, so the button and the copy are in one language (spec §3.5). Measured: without the
  keyword that read warns, `main actor-isolated property 'bundle' cannot be accessed from outside of
  the actor` (`$SCRATCH/build-proto-nobundle.log`); with it, nothing. The property is pure — it
  reads `Bundle.main` and `code`, which is already `nonisolated` for the same kind of reason.
- **P3 — `PendingReminder.init(_:)` is `nonisolated`, in an extension.** In an extension the
  initializer took the main actor even though the struct is `nonisolated`, and
  `.map(PendingReminder.init)` warned: `converting function value of type '@MainActor @Sendable
  (UNNotificationRequest) -> PendingReminder' … loses global actor`. In an extension, not the body,
  so the memberwise initializer the tests write survives.
- **P4 — `ReminderResponder` is written `@MainActor` (as `DataManager` is: the target's default,
  stated), with `private static let shared` and `static func install()`.** It compiled in the real
  app target with no diagnostic: this re-proves spec §3.6's isolation claim on the real target, which
  §9 asked to happen first.
- **P5 — two re-file tests, split by when each can fail.** A pending reminder in other *words* (title
  or body) can fail as soon as the seam reads wording back (Task 1). One with no *category* — the
  upgrade from 1.1 — can only fail once reminders carry a category (Task 2).
- **P6 — the simulator proof** is a throwaway XCUITest class, `ReminderButtonProbe`, on *WaterBuddy
  Probe 27*. The host pushes a reminder-shaped notification with `xcrun simctl push` from a
  background `sleep` in the same command as the run, and the probe waits for it in Notification
  Center, so the timing needs no handshake (Task 6).

Every Swift block in Tasks 1–4 and Task 6's probe was compiled in that prototype before this plan
was written: the last `build-for-testing` (`$SCRATCH/build-proto4.log`) succeeded and printed no
warning, by file and message, that HEAD's build lacks. Nothing in it was *run*: RED and GREEN happen
in the repository, task by task. The prototype's comments are thinner than the plan's; the plan's
code is the one to type.

The spec is amended for P1–P4 in Task 0, before any code: the code wins, and the spec changes
(its *Authority* line).

## Global Constraints

- iOS floor **17.0**. `UNNotificationActionIcon` is iOS 15, so no `#available` is added.
- **No new string, key, stored shape, entitlement, Info.plist key, privacy manifest or
  `project.pbxproj` line.** `ReminderResponder.swift` joins the app through its synchronized folder.
  No exception set changes; no seventh shared file; `NotificationManager.swift` stays out of both
  watch targets (rule `40-widget`).
- The category is `NotificationManager.reminderCategoryIdentifier` =
  `"sardor.WaterBuddy.reminderCategory"`, the action `NotificationManager.logTheGlassActionIdentifier`
  = `"sardor.WaterBuddy.logTheGlass"`. Neither is built from `ReminderPlan.identifierPrefix`, and
  neither is spelled as a literal anywhere else.
- The action's options are **empty** (not `.foreground`, `.authenticationRequired` or
  `.destructive`); the category's options are empty; its title is
  `bundle.localizedString(forKey: "Log a Glass", …)` from a bundle that is **never defaulted**; its
  icon is `vesselSlots[DataManager.usualSlot].symbol`.
- The category is registered **only** by the app, inside `requestReminderReschedule`'s queued
  operation, before that operation's reconcile, in the same bundle. Never from
  `NotificationManager.reconcile`, which the widget extension runs.
- No `willPresent`, no `.customDismissAction`.
- `ReminderScheduler.live()` is built **inside** the queued operation; every live closure calls
  `UNUserNotificationCenter.current()` in its own body. Never `removeAllPendingNotificationRequests()`.
- Reminder copy and the button's title carry **no digit**, in `en`, `ru` and `uz`.
- Tests come first: write, run, **see RED**, implement, run GREEN. Never narrow an assertion. A test
  that cannot be RED before the change is proved by a stated mutation instead.
- **No new warning** against Task 0's clean baseline of HEAD `6010e25`, compared per file and message.
- Edit with `Edit`/`Write` only: no `sed -i`, no heredoc or script into the tree. Scratch work goes
  in this session's scratchpad.
- Simulators:
  - Unit tests run on the stock iOS 27.0 *iPhone 17*.
  - UI tests run on *WaterBuddy Gate 27* and *WaterBuddy Gate 26.5*.
  - The probe runs on *WaterBuddy Probe 27* (`43E0B902-C6D5-48DD-B513-F22AF3BE9BEA`) only.
  - Run `uptime` before each run. Shut down **by UDID**, never `shutdown all`.
  - Every test run takes `-parallel-testing-enabled NO` and `-collect-test-diagnostics never`, and
    runs in the foreground.
  - No UI run may cross midnight.
- Never write the real App Group suite or `UserDefaults.standard` from a test or a script. The probe
  drives the real app on a Probe simulator only.
- Never commit. Stage explicit paths. The rule files stay unstaged for the owner's yes.

## Review Focus

Five inputs a person will meet that the spec's own tests do not reach. Each is pinned by the test
named here, in the task that owns the code.

1. **Updating from 1.1 with reminders on.** Up to 28 reminders sit pending with the same words and
   no category. They must all gain the button at the first launch, not over four days.
   → `aReminderFiledBeforeTheButtonIsFiledAgainWithIt` (Task 2).
2. **The app and the widget composing different words.** Both reconcile, and each files again what
   reads differently from its own. Two wordings would re-file each other's reminders on every
   foreground and every widget tap. → `theAppAndTheWidgetFileRemindersInTheSameWords` (Task 2).
3. **A press with the app already open** — Notification Center pulled down over Home. The total on
   Home must rise once, without a relaunch. → `ReminderButtonProbe.testFAPressWithTheAppOpenRaisesHomeOnce`
   (Task 6).
4. **A tap on the reminder itself, or any response but the button.** It must open the app and log
   nothing. → `onlyTheButtonLogsTheGlass` (Task 4), and `ReminderButtonProbe.testEATapOnTheReminderOpensTheAppAndLogsNothing` (Task 6).
5. **The language changed with reminders pending.** Every pending reminder, and the button, must
   follow. → `aReconcileInAnotherLanguageFilesEveryPendingReminderAgainInIt` (Task 1),
   `changingTheLanguageRePlans` (Task 3), `ReminderButtonProbe.testDTheButtonSpeaksTheAppsLanguage` (Task 6).

## File structure

| File | Target(s) | Change |
|---|---|---|
| `WaterBuddy/NotificationManager.swift` | app, phone widget | `ReminderScheduler` `nonisolated`, `pending`, `setCategories`; `PendingReminder`; the two identifiers; `reminderCategory(in:)`; `reminderContent(in:)` sets the category; `reconcile` re-files in other words |
| `WaterBuddy/DataManager.swift` | app, phone widget, watch, watch widget | the `language` setter re-plans; `requestReminderReschedule` registers the category; `AppLanguage.bundle` `nonisolated` |
| `WaterBuddy/LogServingIntent.swift` | app | `logTheGlassInTheBackground()`; `perform()` calls it |
| `WaterBuddy/ReminderResponder.swift` | app — **new** | the centre's delegate |
| `WaterBuddy/WaterBuddyApp.swift` | app | `ReminderResponder.install()` in `init()` |
| `WaterBuddyTests/NotificationManagerTests.swift` | tests | both spies; eight new tests, `theReminderCopyCarriesNoUserValues` widened, `reconcileNeverTouchesRequestsItDoesNotOwn`'s fixture re-written for the new spy |
| `WaterBuddyTests/WelcomeTests.swift` | tests | `PermissionSpy.scheduler()` |
| `WaterBuddyTests/LocalizationTests.swift` | tests | the button's digit check; one new test |
| `WaterBuddyTests/DataManagerTests.swift` | tests | two tests in `ReminderSeamTests` |
| `WaterBuddyUITests/ReminderButtonProbe.swift` | UI tests — **throwaway** | created in Task 6, deleted before staging |
| `docs/superpowers/specs/2026-10-15-log-from-a-reminder-design.md` | — | amended for P1–P4 (Task 0) |
| `.claude/rules/80-notifications.md`, `70-privacy.md`, `43-concurrency.md`, `85-testing.md` | — | spec §5's wording — **unstaged** (Task 5) |
| `CLAUDE.md`, `docs/AI_CONTEXT.md`, `docs/STATE.md`, `docs/WIDGET.md`, `docs/ROADMAP.md`, `HISTORY.md`, `tasks/lessons.md` | — | records (Task 8) |

## Commands used below

`$SCRATCH` is this session's scratchpad directory. Shorthand, expanded in full wherever a step runs it:

```bash
# UNIT <filters>: swift-testing suites on the stock iOS 27.0 iPhone 17
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' <-only-testing:WaterBuddyTests/Suite …> -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Test run with|✘|error:" | tail -30
```

Run `uptime` first. If the 1-minute load is above 6, wait for it to fall before a UI run (known
issue #122). Read a run's **executed** count, never its last line.

---

### Task 0: The ledger, the baseline, the spec's amendments

**Files:** the ledger; `docs/superpowers/specs/2026-10-15-log-from-a-reminder-design.md`; scratch.

- [ ] **Step 1: The starting state.** `git status --short`. Expect: this plan and the spec untracked
  (`?? docs/superpowers/…`), the six long-standing modified paths (`.claude/settings.json`, the two
  watch schemes, `WaterBuddy/AppShortcuts.xcstrings`, `WaterBuddyWatch/Localizable.xcstrings`,
  `WaterBuddyWatchWidget/Localizable.xcstrings`) and `Screenshots/census/` untracked. None of the
  last seven is this change's. Write them into the ledger as the starting state, with P1–P6.
- [ ] **Step 2: The warnings baseline**, the way the last three stages measured it: a clean
  `build-for-testing` into an empty folder, then the widget's `build` into the same folder.

```bash
mkdir -p "$SCRATCH/base" && git archive HEAD | tar -x -C "$SCRATCH/base"
xcodebuild build-for-testing -project "$SCRATCH/base/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'generic/platform=iOS Simulator' -derivedDataPath "$SCRATCH/base-dd" > "$SCRATCH/base-app.log" 2>&1; echo "exit $?"
xcodebuild build -project "$SCRATCH/base/WaterBuddy.xcodeproj" -scheme WaterBuddyWidgetExtension -destination 'generic/platform=iOS Simulator' -derivedDataPath "$SCRATCH/base-dd" > "$SCRATCH/base-widget.log" 2>&1; echo "exit $?"
cat "$SCRATCH"/base-app.log "$SCRATCH"/base-widget.log | grep -E ': warning: ' | sed -E 's#^.*/base/##' | sort -u > "$SCRATCH/base-lines.txt"; wc -l < "$SCRATCH/base-lines.txt"
cat "$SCRATCH"/base-app.log "$SCRATCH"/base-widget.log | grep -E ': warning: ' | sed -E 's#^.*/base/##; s#^(Water[^:]+):[0-9]+:[0-9]+: #\1: #' | sort -u > "$SCRATCH/base-messages.txt"; wc -l < "$SCRATCH/base-messages.txt"
```

  Expect both builds to exit 0. Planning's app build of the same commit gave **54** unique whole
  lines: 31 in shipping sources (`DataManager.swift` 21, `NotificationManager.swift` 8,
  `WristView.swift` 2 — `CLAUDE.md`'s 31), 6 in tests, 17 in macro expansions. The counts go in the
  ledger. A different figure is recorded as it is, not reconciled to this one.

- [ ] **Step 3: Amend the spec for P1–P4**, with `Edit`:
  - *Provenance*: add the sentence "Amended on 2026-10-15 by the plan's measurements
    (`docs/superpowers/plans/2026-10-15-log-from-a-reminder.md`, P1–P4); each amendment says so."
  - §3.3's `DataManager.swift` row: append "; `AppLanguage.bundle` becomes `nonisolated` (plan P2)".
  - §3.5, after the `ReminderScheduler gains` bullet, a new bullet:
    > - **`ReminderScheduler` becomes `nonisolated`** (plan P1, **measured**). It took the app
    >   target's default main-actor isolation, so a synchronous closure read off it from the
    >   nonisolated queue warns — `removePending` and `removeDelivered` already did — while an awaited
    >   one does not. `setCategories` is synchronous. With the keyword, a clean build has those two
    >   warnings fewer and none new. `AppLanguage.bundle` becomes `nonisolated` too (plan P2,
    >   **measured**), so the queued operation can read it once.
  - §3.6, first bullet: "The class carries the target's default isolation." → "The class is declared
    `@MainActor`, as `DataManager` is — the target's default, written out." Append to the bullet:
    "Re-proved in the real app target while planning: no diagnostic (plan P4)."
  - §3.6, third bullet: "**Held by `static let shared`.**" → "**Held by a `private static let shared`,
    which `static func install()` hands the centre.**"
  - §3.7, *The seam* bullet: after "built from a `UNNotificationRequest` by `init(_:)` in `live()`",
    insert "— an initializer marked `nonisolated` in an extension, which otherwise took the main
    actor (plan P3, **measured**) —".
  - §5, the `80-notifications` paragraph: append "*The applier holds no policy*'s `ReminderScheduler`
    bullet gains: \"It is `nonisolated`: `reconcile` and the app's queue call its closures off the
    main actor, and a synchronous closure read off a main-actor struct warns.\" *Who reschedules*'
    `LogServingIntent` bullet reads \"`LogServingIntent.logTheGlassInTheBackground()` — what
    `perform()` and the reminder's button both run — holds the app process open …\"."

---

### Task 1: The seam reads wording back, and a reminder in other words is filed again

**Files:**
- Modify: `WaterBuddy/NotificationManager.swift:11-78` (the seam), `:138-202` (`reconcile`)
- Test: `WaterBuddyTests/NotificationManagerTests.swift`, `WaterBuddyTests/WelcomeTests.swift:76-93`

**Interfaces:**
- Produces: `nonisolated struct ReminderScheduler` with, in this order, `pending: () async ->
  [PendingReminder]`, `add`, `removePending`, `removeDelivered`, `setCategories:
  (Set<UNNotificationCategory>) -> Void`, `authorizationStatus`, `requestAuthorization`.
  `nonisolated struct PendingReminder: Equatable, Sendable { identifier, title, body, category:
  String }`, its memberwise init, `nonisolated init(_ request: UNNotificationRequest)` and
  `func isWorded(like content: UNNotificationContent) -> Bool`. `SchedulerSpy.held:
  [PendingReminder]` and `SchedulerSpy.pending: [String]` (computed).

- [ ] **Step 1: Re-shape the two spies in `NotificationManagerTests.swift`.** Replace `SchedulerSpy`
  (lines 34–64) with:

```swift
private final class SchedulerSpy {
    /// What the centre holds, as the seam reads it back: each request with the words it was filed in.
    var held: [PendingReminder] = []
    /// The identifiers in ``held``, for the tests that only ask what is filed.
    var pending: [String] { held.map(\.identifier) }
    var added: [String] = []
    var removedPending: [String] = []
    var removedDelivered: [String] = []
    var pendingReads = 0
    var status: UNAuthorizationStatus = .authorized
    /// Identifiers whose `add` should fail, and with what.
    var failures: [String: Error] = [:]

    func scheduler() -> ReminderScheduler {
        ReminderScheduler(
            pending: { [self] in
                pendingReads += 1
                return held
            },
            add: { [self] request in
                if let error = failures[request.identifier] { throw error }
                added.append(request.identifier)
                // As the centre does: a request under an identifier already pending replaces it.
                held.removeAll { $0.identifier == request.identifier }
                held.append(PendingReminder(request))
            },
            removePending: { [self] ids in
                removedPending.append(contentsOf: ids)
                held.removeAll { ids.contains($0.identifier) }
            },
            removeDelivered: { [self] ids in removedDelivered.append(contentsOf: ids) },
            setCategories: { _ in },
            authorizationStatus: { [self] in status },
            requestAuthorization: { true }
        )
    }
}
```

  In `SharedCentre` (lines 84–115): `private var pending: [String] = []` → `private var pending:
  [PendingReminder] = []`; `var pendingNow: [String] { lock.withLock { pending } }` →
  `var pendingNow: [String] { lock.withLock { pending.map(\.identifier) } }`; and its `scheduler`'s
  closures become:

```swift
            pending: { [self] in
                if readDelay > .zero { try? await Task.sleep(for: readDelay) }
                return lock.withLock { pending }
            },
            add: { [self] request in
                lock.withLock {
                    added.append(request.identifier)
                    pending.removeAll { $0.identifier == request.identifier }
                    pending.append(PendingReminder(request))
                }
            },
            removePending: { [self] identifiers in
                lock.withLock { pending.removeAll { identifiers.contains($0.identifier) } }
            },
            removeDelivered: { _ in },
            setCategories: { _ in },
            authorizationStatus: { .authorized },
            requestAuthorization: { true }
```

  In `reconcileNeverTouchesRequestsItDoesNotOwn`, replace
  `spy.pending = ["com.someone.else.request", "\(ReminderPlan.identifierPrefix)19990101.09"]` with:

```swift
        spy.held = [
            PendingReminder(identifier: "com.someone.else.request", title: "", body: "", category: ""),
            PendingReminder(identifier: "\(ReminderPlan.identifierPrefix)19990101.09", title: "", body: "", category: ""),
        ]
```

  In `WelcomeTests.swift`, `PermissionSpy.scheduler()`: `pendingIdentifiers: { [] },` →
  `pending: { [] },`, and after `removeDelivered: { _ in },` add `setCategories: { _ in },`.

- [ ] **Step 2: Write the three tests.** In `NotificationManagerTests`, after
  `theReminderCopyCarriesNoUserValues`, add:

```swift
    // MARK: Wording

    /// What the seam reads back: the identifier and the three things a reminder shows.
    @Test func aPendingReminderIsReadOffItsRequest() {
        let identifier = "\(ReminderPlan.identifierPrefix)20260828.09"
        let content = UNMutableNotificationContent()
        content.title = "Title"
        content.body = "Body"
        content.categoryIdentifier = "category"

        let read = PendingReminder(UNNotificationRequest(identifier: identifier, content: content, trigger: nil))

        #expect(read == PendingReminder(identifier: identifier, title: "Title", body: "Body", category: "category"))
        #expect(read.isWorded(like: content))
        content.body = "Other"
        #expect(!read.isWorded(like: content), "a reminder in other words must not read as filed")
        content.body = "Body"
        content.categoryIdentifier = ""
        #expect(!read.isWorded(like: content), "a reminder under another category must not read as filed")
    }

    /// A reminder pending in other words is filed again under its own identifier — which replaces
    /// it — rather than skipped because its identifier is pending. Nothing is removed and no slot
    /// moves (spec 2026-10-15 §3.7).
    @Test func aPendingReminderInOtherWordsIsFiledAgainInPlace() async throws {
        let spy = SchedulerSpy()
        let slots = plan()
        _ = await NotificationManager.reconcile(slots, calendar: utcDay, strings: .main, using: spy.scheduler())
        let filed = spy.pending
        try #require(spy.held.count >= 2)
        let otherTitle = spy.held[0].identifier
        let otherBody = spy.held[1].identifier
        spy.held[0].title = "Old words"
        spy.held[1].body = "Old words"
        spy.added.removeAll()

        let outcome = await NotificationManager.reconcile(slots, calendar: utcDay, strings: .main, using: spy.scheduler())

        #expect(spy.added.sorted() == [otherTitle, otherBody].sorted())
        #expect(outcome.added.sorted() == [otherTitle, otherBody].sorted())
        #expect(spy.removedPending.isEmpty, "a re-file replaces; it never removes")
        #expect(spy.pending.sorted() == filed.sorted(), "no slot moved")
        let content = NotificationManager.reminderContent(in: .main)
        #expect(spy.held.allSatisfy { $0.isWorded(like: content) })
    }

    /// What the language setter's re-plan does (Task 3): every pending reminder, filed in English,
    /// is filed again in Russian.
    @Test func aReconcileInAnotherLanguageFilesEveryPendingReminderAgainInIt() async throws {
        let english = try #require(Bundle.main.url(forResource: "en", withExtension: "lproj").flatMap(Bundle.init(url:)))
        let russian = try #require(Bundle.main.url(forResource: "ru", withExtension: "lproj").flatMap(Bundle.init(url:)))
        let inRussian = NotificationManager.reminderContent(in: russian)
        try #require(
            inRussian.title != NotificationManager.reminderContent(in: english).title,
            "the two languages must differ, or this proves nothing"
        )
        let spy = SchedulerSpy()
        let slots = plan()
        _ = await NotificationManager.reconcile(slots, calendar: utcDay, strings: english, using: spy.scheduler())
        let filed = spy.pending
        spy.added.removeAll()

        _ = await NotificationManager.reconcile(slots, calendar: utcDay, strings: russian, using: spy.scheduler())

        #expect(spy.added.sorted() == filed.sorted())
        #expect(spy.removedPending.isEmpty)
        #expect(spy.held.allSatisfy { $0.isWorded(like: inRussian) })
    }
```

  The tests read each slot's identifier off what the spy filed, never off a `ReminderPlan.Slot`: a
  `Slot`'s members are main-actor-isolated in the app target and this suite is not (the comment in
  `anOlderPlanCannotRefileTheSlotANewerPlanDropped` says the same).

- [ ] **Step 3: Run RED.**
  `UNIT -only-testing:WaterBuddyTests/NotificationManagerTests`. Expected: the build fails —
  `cannot find 'PendingReminder' in scope`, and errors at the spies' `pending:` and
  `setCategories:` labels. Record the first error lines in the ledger.

- [ ] **Step 4: The seam, and nothing more.** In `NotificationManager.swift`, the DocC heading
  "## Three details that are Swift 6 requirements, not taste" becomes "## Four details …", and after
  item 3 add:

```swift
/// 4. The struct is **`nonisolated`**, stated outright. This file also compiles into the app, whose
///    default isolation is the main actor, and nothing that calls a closure here is on it —
///    ``NotificationManager/reconcile(_:calendar:strings:using:)`` and the app's reminder queue are
///    both `nonisolated`. An awaited closure would hop and say nothing; a synchronous one read off a
///    main-actor struct warns, as ``removePending`` and ``removeDelivered`` did until 2026-10-15, and
///    ``setCategories`` is synchronous.
```

  Then replace the struct's head and its first live closures (lines 34–56) with:

```swift
nonisolated struct ReminderScheduler {

    /// Every pending request, read back with the words it was filed in — what
    /// ``NotificationManager/reconcile(_:calendar:strings:using:)`` compares to decide whether a
    /// reminder is already filed as it would be now.
    var pending: () async -> [PendingReminder]
    var add: (UNNotificationRequest) async throws -> Void
    var removePending: ([String]) -> Void
    var removeDelivered: ([String]) -> Void
    /// Replaces **every** category the app has registered (`setNotificationCategories`). Only the
    /// app calls it, and only from `DataManager.requestReminderReschedule` — see
    /// ``NotificationManager/reminderCategory(in:)``.
    var setCategories: (Set<UNNotificationCategory>) -> Void
    var authorizationStatus: () async -> UNAuthorizationStatus
    var requestAuthorization: () async throws -> Bool

    static func live() -> ReminderScheduler {
        ReminderScheduler(
            pending: {
                await UNUserNotificationCenter.current().pendingNotificationRequests().map(PendingReminder.init)
            },
            add: { request in
                try await UNUserNotificationCenter.current().add(request)
            },
            removePending: { identifiers in
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
            },
            removeDelivered: { identifiers in
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
            },
            setCategories: { categories in
                UNUserNotificationCenter.current().setNotificationCategories(categories)
            },
```

  (`authorizationStatus` and `requestAuthorization` below stay as they are.) After the struct's
  closing brace, before `ReconcileOutcome`, add:

```swift
/// A pending request as ``NotificationManager`` reads it back: its identifier, and the words it was
/// filed in.
///
/// The words are what tell a reminder filed before an update — with no button — or before a change
/// of language apart from one filed now.
/// ``NotificationManager/reconcile(_:calendar:strings:using:)`` files such a reminder again under its
/// own identifier, which replaces it (spec 2026-10-15 §3.7).
///
/// A plain value rather than the `UNNotificationRequest`, so a test can write one down, and
/// `Sendable`, so it can come back from the centre. `nonisolated` stated outright, as on
/// ``ReminderScheduler``: nothing that reads one is on the main actor. In this file rather than one of
/// its own for ``ReconcileQueue``'s reason — a file of its own would have to join the widget's
/// exception set, and rule `40-widget` forbids a seventh.
nonisolated struct PendingReminder: Equatable, Sendable {
    var identifier: String
    var title: String
    var body: String
    var category: String

    /// Whether this reminder already reads as `content` would: the same title, body and category.
    /// Sound and interruption level are not compared — they are the same in every build so far, and
    /// a reminder is filed again only for what the user sees.
    func isWorded(like content: UNNotificationContent) -> Bool {
        title == content.title && body == content.body && category == content.categoryIdentifier
    }
}

extension PendingReminder {
    /// Read off a request the centre holds.
    ///
    /// `nonisolated` here as well as on the type: in an extension this initializer otherwise took the
    /// main actor, and ``ReminderScheduler/live()`` hands it to `map` off it (measured, 2026-10-15).
    /// In an extension rather than the body, so the memberwise initializer a test writes survives.
    nonisolated init(_ request: UNNotificationRequest) {
        self.init(
            identifier: request.identifier,
            title: request.content.title,
            body: request.content.body,
            category: request.content.categoryIdentifier
        )
    }
}
```

  In `reconcile`, replace

```swift
        let pending = await scheduler.pendingIdentifiers()
        let ours = pending.filter { $0.hasPrefix(ReminderPlan.identifierPrefix) }
        let wanted = Set(slots.map(\.identifier))

        let stale = ours.filter { !wanted.contains($0) }
```

  with

```swift
        let pending = await scheduler.pending()
        let ours = pending.filter { $0.identifier.hasPrefix(ReminderPlan.identifierPrefix) }
        let wanted = Set(slots.map(\.identifier))

        let stale = ours.map(\.identifier).filter { !wanted.contains($0) }
```

  `let alreadyPending = Set(ours)` → `let alreadyPending = Set(ours.map(\.identifier))` — the skip
  is still by identifier alone in this step — and the trailing round trip's
  `_ = await scheduler.pendingIdentifiers()` → `_ = await scheduler.pending()`.

- [ ] **Step 5: Run — the proper RED.**
  `UNIT -only-testing:WaterBuddyTests/NotificationManagerTests -only-testing:WaterBuddyTests/ReconcileQueueTests -only-testing:WaterBuddyTests/ReminderPermissionTests`.
  Expected: it builds; `aPendingReminderIsReadOffItsRequest` passes; **two fail at run time** —
  `aPendingReminderInOtherWordsIsFiledAgainInPlace` (`spy.added` is empty) and
  `aReconcileInAnotherLanguageFilesEveryPendingReminderAgainInIt`. Every other test passes. Record
  the two failures in the ledger.

- [ ] **Step 6: The re-file.** In `reconcile`, replace

```swift
        // An identifier already pending is already correct: a slot's fire time is a function of the
        // day and hour its identifier names, so it cannot have moved. Skipping it is what makes
        // this safe to call on every foreground.
        let alreadyPending = Set(ours.map(\.identifier))
        for slot in slots where !alreadyPending.contains(slot.identifier) {
```

  with

```swift
        // A reminder already pending in the words it would be filed in now is already correct: a
        // slot's fire time is a function of the day and hour its identifier names, so it cannot
        // have moved. Skipping it is what makes this safe to call on every foreground. One in other
        // words — filed before the button existed, or before a change of language — is filed again
        // under its own identifier, which replaces it: nothing is removed, and no slot moves.
        let current = reminderContent(in: strings)
        let alreadyFiled = Set(ours.filter { $0.isWorded(like: current) }.map(\.identifier))
        for slot in slots where !alreadyFiled.contains(slot.identifier) {
```

- [ ] **Step 7: Run GREEN.** The Step 5 command. Expected: every test passes; read the count.

- [ ] **Step 8: The other targets still build.** The widget compiles this file:
  `xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' 2>&1 | grep -E "error:|BUILD" | tail -5`.
  Expected `** BUILD SUCCEEDED **`. Note in the ledger any warning printed for
  `NotificationManager.swift` whose message is not in `$SCRATCH/base-messages.txt`.

---

### Task 2: The button, and who registers it

**Files:**
- Modify: `WaterBuddy/NotificationManager.swift` (inside `enum NotificationManager`),
  `WaterBuddy/DataManager.swift:1328-1346` (`requestReminderReschedule`), `:1918` (`AppLanguage.bundle`)
- Test: `WaterBuddyTests/NotificationManagerTests.swift`, `WaterBuddyTests/LocalizationTests.swift:270-283`

**Interfaces:**
- Consumes: `ReminderScheduler.setCategories`, `PendingReminder`, `SchedulerSpy.held` (Task 1).
- Produces: `NotificationManager.reminderCategoryIdentifier: String`,
  `NotificationManager.logTheGlassActionIdentifier: String` (both `nonisolated static let`),
  `nonisolated static func reminderCategory(in bundle: Bundle) -> UNNotificationCategory`.

- [ ] **Step 1: Write the tests.** In `NotificationManagerTests`, widen
  `theReminderCopyCarriesNoUserValues`'s text to the button's title:

```swift
    @Test func theReminderCopyCarriesNoUserValues() {
        let content = NotificationManager.reminderContent(in: .main)
        let button = NotificationManager.reminderCategory(in: .main).actions.map(\.title)

        let text = ([content.title, content.body] + button).joined(separator: " ")
        let carriesAFigure = text.contains { $0.isNumber }
        #expect(!carriesAFigure, "reminder copy must not carry a figure: \(text)")
        #expect(content.interruptionLevel == .active, ".timeSensitive would need an entitlement")
    }
```

  and after it add:

```swift
    /// So a reminder the widget extension files carries the button too: iOS looks the category up
    /// among the app's registered ones when it shows the notification.
    @Test func theReminderCarriesTheButtonsCategory() {
        let content = NotificationManager.reminderContent(in: .main)

        #expect(content.categoryIdentifier == NotificationManager.reminderCategoryIdentifier)
    }

    /// One button, and a press that runs where the user is: not `.foreground`, which would open the
    /// app; not `.authenticationRequired`, which would ask for the passcode (rule `70-privacy`); not
    /// `.destructive`.
    @Test func theCategoryOffersOneButtonThatLogsWithoutOpeningTheApp() throws {
        let category = NotificationManager.reminderCategory(in: .main)

        #expect(category.identifier == NotificationManager.reminderCategoryIdentifier)
        #expect(category.options.isEmpty, "no category option — a dismissal must not reach the app")
        #expect(category.actions.count == 1)
        let action = try #require(category.actions.first)
        #expect(action.identifier == NotificationManager.logTheGlassActionIdentifier)
        #expect(action.options.isEmpty, "not .foreground, .authenticationRequired or .destructive")
        #expect(action.icon != nil, "the Glass's glyph")
    }

    /// The title follows the bundle passed — never `Bundle.main` — so the button is in the language
    /// the reminder beside it was filed in.
    @Test func theButtonsTitleIsComposedInTheBundlePassed() throws {
        let russian = try #require(Bundle.main.url(forResource: "ru", withExtension: "lproj").flatMap(Bundle.init(url:)))
        let expected = russian.localizedString(forKey: "Log a Glass", value: nil, table: nil)
        try #require(expected != "Log a Glass", "the Russian bundle must translate it, or this proves nothing")

        let action = try #require(NotificationManager.reminderCategory(in: russian).actions.first)

        #expect(action.title == expected)
    }
```

  and, under `// MARK: Wording`, after `aReconcileInAnotherLanguageFilesEveryPendingReminderAgainInIt`:

```swift
    /// The update from 1.1: up to 28 reminders pending in the same words with no category. Skipped
    /// by identifier, they would show no button for up to four days — in the release whose notes
    /// announce it. The first reconcile after the update files every one again, with it.
    @Test func aReminderFiledBeforeTheButtonIsFiledAgainWithIt() async {
        let spy = SchedulerSpy()
        let slots = plan()
        _ = await NotificationManager.reconcile(slots, calendar: utcDay, strings: .main, using: spy.scheduler())
        let filed = spy.pending
        // As 1.1 filed them: the same words, no category.
        for index in spy.held.indices { spy.held[index].category = "" }
        spy.added.removeAll()

        _ = await NotificationManager.reconcile(slots, calendar: utcDay, strings: .main, using: spy.scheduler())

        #expect(spy.added.sorted() == filed.sorted())
        #expect(spy.removedPending.isEmpty)
        #expect(spy.held.allSatisfy { $0.category == NotificationManager.reminderCategoryIdentifier })
    }
```

  In `LocalizationTests.swift`, `theTranslatedReminderCopyStillCarriesNoUserValues` gains, after its
  `for` loop:

```swift
        // The button's title, which only the app resolves (rule `80-notifications`) — so read in the
        // app's bundle alone, and required there: a missing key would pass for a title with no digit.
        let button = value(appBundle, language, "Log a Glass")
        #expect(button != nil, "app: the \(language) catalogue has no \"Log a Glass\"")
        if let button {
            let carriesADigit = button.contains(where: \.isNumber)
            #expect(!carriesADigit, "app: the \(language) reminder button contains a digit — \"\(button)\"")
        }
```

  (The digit test is computed outside `#expect`: inside it, `contains(where: \.isNumber)` failed to
  compile in planning — "call can throw, but it is not marked with 'try'".) After that test, add:

```swift
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
```

  `LocalizationTests.swift` imports `Foundation` and `Testing` only: add `import UserNotifications`
  after `import Testing`, for `UNNotificationRequest`.

- [ ] **Step 2: Run RED.**
  `UNIT -only-testing:WaterBuddyTests/NotificationManagerTests -only-testing:WaterBuddyTests/LocalizationTests`.
  Expected: the build fails — `type 'NotificationManager' has no member 'reminderCategory'` /
  `'reminderCategoryIdentifier'`. Record it.

- [ ] **Step 3: The button.** In `NotificationManager`, `reminderContent(in:)`'s DocC gains, before
  `- Parameter bundle:`:

```swift
    ///
    /// **It names the button's category**, ``reminderCategoryIdentifier``, so a reminder the widget
    /// extension files carries the button too: iOS looks the category up among the app's registered
    /// ones when it shows the notification, and an extension files under the containing app's
    /// identity. The category itself is registered only by the app (``reminderCategory(in:)``).
```

  and its body gains `content.categoryIdentifier = reminderCategoryIdentifier` after
  `content.interruptionLevel = .active`. Between `reminderContent(in:)` and `reconcile`, add:

```swift
    /// The category every reminder names, so iOS draws the button under it.
    ///
    /// **Permanent in practice.** It is stored inside each pending request, so a renamed category
    /// would leave every reminder already filed without its button until each was filed again. Not
    /// built from `ReminderPlan.identifierPrefix`, which names *requests* — ``reconcile(_:calendar:strings:using:)``
    /// filters the pending set by it, and a category is another namespace.
    nonisolated static let reminderCategoryIdentifier = "sardor.WaterBuddy.reminderCategory"

    /// The reminder's one button, *Log a Glass*. `ReminderResponder` logs for this and for nothing else.
    nonisolated static let logTheGlassActionIdentifier = "sardor.WaterBuddy.logTheGlass"

    /// The reminder's category: one button, *Log a Glass*, that logs the Glass without opening the
    /// app (spec 2026-10-15 §3.4).
    ///
    /// - The action's options are **empty**. Not `.foreground` — the point is not opening the app; not
    ///   `.authenticationRequired` — logging water is harmless, and a reminder reaches Apple Watch
    ///   exactly when the phone is locked (rule `70-privacy`); not `.destructive`.
    /// - Its title is the Siri phrase's, *Log a Glass* — the same act in the same words. Only the app
    ///   resolves it, so the widget's catalogue carries no copy.
    /// - Its icon is the Glass's glyph, the one the control draws, through the one name for that slot.
    /// - The category takes no options, so a dismissal never reaches the app.
    ///
    /// **Registered only by the app**, through ``ReminderScheduler/setCategories``, in
    /// `DataManager.requestReminderReschedule`'s queued operation. Never from
    /// ``reconcile(_:calendar:strings:using:)``, which the widget extension runs:
    /// `setNotificationCategories` replaces every category the app has.
    /// - Parameter bundle: the strings to compose the title in. **Not defaulted**, as on
    ///   ``reminderContent(in:)`` and for its reason.
    nonisolated static func reminderCategory(in bundle: Bundle) -> UNNotificationCategory {
        let logTheGlass = UNNotificationAction(
            identifier: logTheGlassActionIdentifier,
            title: bundle.localizedString(forKey: "Log a Glass", value: nil, table: nil),
            options: [],
            icon: UNNotificationActionIcon(systemImageName: vesselSlots[DataManager.usualSlot].symbol)
        )
        return UNNotificationCategory(
            identifier: reminderCategoryIdentifier,
            actions: [logTheGlass],
            intentIdentifiers: [],
            options: []
        )
    }
```

- [ ] **Step 4: Who registers it.** In `DataManager.swift`, `requestReminderReschedule`'s operation
  (lines 1333–1344) becomes:

```swift
        reminderReconciles.enqueue {
            // Built inside the operation: `UNUserNotificationCenter` is not `Sendable` and the
            // scheduler that wraps it must not cross into the queue (rule `43-concurrency`).
            let scheduler = ReminderScheduler.live()
            // Resolved from the suite rather than from `DataManager.shared`: this is `nonisolated`
            // and may not touch the main actor (rule `43-concurrency`). Once, so the button and the
            // copy filed beside it are in one language.
            let strings = resolveLanguage(in: sharedDefaults).bundle
            // The button, registered before the reminders that name it — here and only here: the
            // call replaces every category the app has, and the widget extension, which reconciles
            // too, must never make it (rule `80-notifications`).
            scheduler.setCategories([NotificationManager.reminderCategory(in: strings)])
            await NotificationManager.reconcile(slots, calendar: calendar, strings: strings, using: scheduler)
        }
```

  Its DocC gains, after the paragraph that ends "(``ReconcileQueue``).":

```swift
    ///
    /// **It also registers the reminder's button**, in the same operation and the same bundle, just
    /// before the reconcile — so the button's title is always in the language of the copy filed beside
    /// it, and is registered on every launch (`init` reschedules), as iOS requires. Only the app ever
    /// registers it: `AddWaterIntent` awaits ``NotificationManager/reconcile(_:calendar:strings:using:)``
    /// alone (``NotificationManager/reminderCategory(in:)``).
```

  And `AppLanguage.bundle` (line 1918): `var bundle: Bundle {` → `nonisolated var bundle: Bundle {`,
  with one more paragraph at the end of its DocC:

```swift
    ///
    /// `nonisolated`, as ``code`` is: `DataManager.requestReminderReschedule`'s queued operation reads
    /// it once, off the main actor, for the reminder's button and its copy alike. It reads only
    /// `Bundle.main` and ``code``.
```

- [ ] **Step 5: Run GREEN.** The Step 2 command. Expected: every test passes, including all six
  arguments' cases of the two `LocalizationTests` tests above (three languages each for the new one,
  two for the widened one).

- [ ] **Step 6: Prove the two tests that could not be RED.** Both were green before Step 3 —
  `theTranslatedReminderCopyStillCarriesNoUserValues` reads a key the catalogue already ships for Siri,
  and `theAppAndTheWidgetFileRemindersInTheSameWords` reads two catalogues that already agree.
  - Temporarily change `reminderContent(in:)`'s title line to
    `content.title = bundle.bundlePath`, and run
    `UNIT -only-testing:WaterBuddyTests/LocalizationTests/theAppAndTheWidgetFileRemindersInTheSameWords(language:)`.
    Expected: fails for every language. Revert with `Edit`; `git diff WaterBuddy/NotificationManager.swift`
    shows no `bundlePath`.
  - The digit check is the existing test's own pattern applied to a third key; it is not mutated
    (a catalogue edit to plant a digit is not worth the risk of leaving one). Say so in the ledger.

- [ ] **Step 7: The other targets.** The widget build as in Task 1 Step 8, and the watch widget's —
  `DataManager.swift` changed — :
  `xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' 2>&1 | grep -E "error:|BUILD" | tail -5`.
  Expected `** BUILD SUCCEEDED **` for both.

---

### Task 3: The language setter re-plans

**Files:**
- Modify: `WaterBuddy/DataManager.swift:421-454` (the `language` property)
- Test: `WaterBuddyTests/DataManagerTests.swift` (`ReminderSeamTests`, before
  `aDisabledManagerStillHandsOutAnEmptyPlanRatherThanSkippingTheCall`)

**Interfaces:**
- Consumes: nothing new — `makeManager(_:onReschedule:now:)`, `withTempDefaults`, `utc(…)`.

- [ ] **Step 1: Write the tests.**

```swift
    /// A change of language moves no slot, but every pending reminder — and the button under it —
    /// is in the words of the language it was filed in. The re-plan files them again in the new one
    /// (`aReconcileInAnotherLanguageFilesEveryPendingReminderAgainInIt`).
    @Test func changingTheLanguageRePlans() {
        withTempDefaults { defaults in
            var plans = 0
            var latest: [ReminderPlan.Slot] = []
            let manager = makeManager(defaults, onReschedule: { plans += 1; latest = $0 }) { utc(2026, 8, 28, 12) }
            manager.remindersEnabled = true
            let after = plans

            manager.language = .russian

            #expect(plans == after + 1, "the pending reminders would keep the old language until each fired")
            #expect(!latest.isEmpty)
        }
    }

    @Test func choosingTheSameLanguageAgainDoesNotRePlan() {
        withTempDefaults { defaults in
            var plans = 0
            let manager = makeManager(defaults, onReschedule: { _ in plans += 1 }) { utc(2026, 8, 28, 12) }
            manager.language = .russian
            let after = plans

            manager.language = .russian

            #expect(plans == after, "a no-op write must not re-plan the day")
        }
    }
```

- [ ] **Step 2: Run RED.** `UNIT -only-testing:WaterBuddyTests/ReminderSeamTests`. Expected:
  `changingTheLanguageRePlans` fails at run time (`plans == after`);
  `choosingTheSameLanguageAgainDoesNotRePlan` passes — it pins the guard the new call must sit behind,
  and is proved in Step 5. Record both.

- [ ] **Step 3: The call.** In the `language` setter, after `publishWrist(defaults)`:

```swift
            // Every pending reminder is in the old language, and so is the button under it: the
            // re-plan files them again in the new one (rule `80-notifications`). It moves no slot.
            rescheduleRemindersNow()
```

  And the property's DocC gains, after the *It also publishes to the wrist* paragraph:

```swift
    ///
    /// **And it re-plans the reminders** — not because the plan moves, since a language moves no
    /// slot, but because every pending reminder and the button under it are in the words of the
    /// language they were filed in. The re-plan's reconcile files each one again in the new language
    /// (`NotificationManager.reconcile`, spec 2026-10-15 §3.7).
```

- [ ] **Step 4: Run GREEN.** The Step 2 command. Expected: every test in `ReminderSeamTests` passes.

- [ ] **Step 5: Prove the guard test.** Temporarily move `rescheduleRemindersNow()` to be the
  setter's first line, above `guard newValue != storedLanguage`, and run
  `UNIT -only-testing:WaterBuddyTests/ReminderSeamTests/choosingTheSameLanguageAgainDoesNotRePlan()`.
  Expected: fails. Put it back with `Edit`, run Step 2's command again: all pass.

---

### Task 4: The responder, one function for both doors, and the install

**Files:**
- Create: `WaterBuddy/ReminderResponder.swift`
- Modify: `WaterBuddy/LogServingIntent.swift:48-77`, `WaterBuddy/WaterBuddyApp.swift:41-58`
- Test: `WaterBuddyTests/NotificationManagerTests.swift`

**Interfaces:**
- Consumes: `NotificationManager.logTheGlassActionIdentifier` (Task 2).
- Produces: `@MainActor final class ReminderResponder: NSObject, UNUserNotificationCenterDelegate`
  with `static func install()` and `nonisolated static func logsTheGlass(for actionIdentifier:
  String) -> Bool`; `@MainActor static func logTheGlassInTheBackground() async` on
  `LogServingIntent`.

- [ ] **Step 1: Write the test.** In `NotificationManagerTests`, after
  `theButtonsTitleIsComposedInTheBundlePassed`:

```swift
    /// Only the button logs. A tap on the reminder itself opens the app, as it always did, and logs
    /// nothing; a dismissal never reaches the app, but would log nothing either.
    @Test func onlyTheButtonLogsTheGlass() {
        #expect(ReminderResponder.logsTheGlass(for: NotificationManager.logTheGlassActionIdentifier))
        #expect(!ReminderResponder.logsTheGlass(for: UNNotificationDefaultActionIdentifier))
        #expect(!ReminderResponder.logsTheGlass(for: UNNotificationDismissActionIdentifier))
    }
```

- [ ] **Step 2: Run RED.** `UNIT -only-testing:WaterBuddyTests/NotificationManagerTests`. Expected:
  the build fails — `cannot find 'ReminderResponder' in scope`.

- [ ] **Step 3: One function for both doors.** In `LogServingIntent.swift`, `logTheGlass`'s DocC
  first line "What `perform()` does between its two waits: …" → "What ``logTheGlassInTheBackground()``
  does between its two waits: log the Glass once, on the day it is now." Replace `perform()`
  (lines 62–77) with:

```swift
    /// Everything a one-tap log from the app's own process does: wait for the watch link, log the
    /// Glass once, and wait for the re-plan to reach the notification centre. Siri's ``perform()``
    /// and the reminder's *Log a Glass* (`ReminderResponder`) both run it, so the two doors log the
    /// same Glass the same way.
    ///
    /// Both launch the app in the background, and iOS may suspend it once they return — so this
    /// returns only after both waits (rule `80-notifications`).
    @MainActor
    static func logTheGlassInTheBackground() async {
        // The watch link first: this launch started activating it in `WaterBuddyApp.init()`, and a
        // publish before it is up is dropped.
        await WristLink.waitUntilActivated()

        logTheGlass(into: .shared, from: DataManager.sharedDefaults)

        // The re-plan `addWater` queued must reach the notification centre before the system can
        // suspend this background launch (rule `80-notifications`).
        await DataManager.remindersSettled()
    }

    /// `@MainActor` on a `nonisolated` requirement, as on `AddWaterIntent`, so the body reaches
    /// ``DataManager/shared`` directly.
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        await Self.logTheGlassInTheBackground()
        return .result(dialog: IntentDialog(Self.reply))
    }
```

- [ ] **Step 4: The responder.** Create `WaterBuddy/ReminderResponder.swift`:

```swift
//
//  ReminderResponder.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 15/10/26.
//

import UserNotifications

/// Answers a press of a reminder's *Log a Glass* — the notification centre's delegate. App-only.
///
/// **Main-actor, the opposite of `WristLink` for the opposite reason.** `WCSession` calls its
/// delegate on "a non-main serial queue"; `UNUserNotificationCenter` calls this one on the main
/// thread. The `async` form of `userNotificationCenter(_:didReceive:)` is a main-actor method here:
/// under this target's approachable concurrency the conformance is inferred main-actor-isolated and
/// compiles with no diagnostic, and the thunk the system calls hops to the main actor, awaits the
/// body, then completes — so everything a press needs is awaited before iOS is told it is done and
/// may suspend the launch. Never `@preconcurrency` on the conformance (it warns, "has no effect"),
/// and never a `nonisolated` `didReceive`, which completes off the main thread (rule `43-concurrency`).
///
/// **Installed in `WaterBuddyApp.init()`**, which runs before the app finishes launching — the moment
/// iOS requires a delegate by, to hand over the response that launched it. The centre holds its
/// delegate weakly, so ``shared`` keeps this one for the life of the process.
///
/// **No `willPresent`.** Implementing it would start showing reminders while the app is open — a
/// change nobody asked for.
///
/// Design: `docs/superpowers/specs/2026-10-15-log-from-a-reminder-design.md` §3.6.
@MainActor
final class ReminderResponder: NSObject, UNUserNotificationCenterDelegate {

    private static let shared = ReminderResponder()

    /// Makes this the centre's delegate. Once per launch, from `WaterBuddyApp.init()`.
    static func install() {
        UNUserNotificationCenter.current().delegate = shared
    }

    /// Whether a response is a press of the reminder's button. Everything else — in practice a tap on
    /// the reminder itself, which opens the app as it always did — logs nothing.
    ///
    /// `nonisolated` so a suite that is not on the main actor can ask it.
    nonisolated static func logsTheGlass(for actionIdentifier: String) -> Bool {
        actionIdentifier == NotificationManager.logTheGlassActionIdentifier
    }

    /// Logs the Glass read **now** — one edited after the reminder was filed logs its new amount — and
    /// returns only once the watch link and the reminder queue have been waited for: returning is the
    /// completion, after which iOS may suspend the launch.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard Self.logsTheGlass(for: response.actionIdentifier) else { return }
        await LogServingIntent.logTheGlassInTheBackground()
    }
}
```

- [ ] **Step 5: The install.** In `WaterBuddyApp.init()`, after the `#if canImport(WatchConnectivity)`
  block's `#endif` (line 57), add:

```swift

        // The reminder's *Log a Glass* launches the app in the background, and iOS hands the press to
        // the centre's delegate only if one is set before the app finishes launching; this runs
        // first. After the fresh start's return, so a UI test's fresh start installs nothing.
        ReminderResponder.install()
```

- [ ] **Step 6: Run GREEN.**
  `UNIT -only-testing:WaterBuddyTests/NotificationManagerTests -only-testing:WaterBuddyTests/LogServingIntentTests -only-testing:WaterBuddyTests/LogTheGlassTests -only-testing:WaterBuddyTests/FreshStartTests`.
  Expected: every test passes. `LogTheGlassTests.anEditedGlassIsLoggedOnceAtItsOwnAmount` and
  `aGlassLoggedAfterMidnightLandsOnTheNewDay` are the unit proof of what a press logs: the responder
  runs the same `logTheGlass(into:from:)`.

- [ ] **Step 7: The whole unit suite once.**
  `UNIT -only-testing:WaterBuddyTests`. Expected: every test passes; record the count. The attribute
  grep (rule `85-testing`) should read **604** — 593 at HEAD, plus three from Task 1, five from Task 2,
  two from Task 3 and one here.

---

### Task 5: The rules — written, left unstaged

Spec §5's wording, as amended in Task 0, typed in with `Edit`, **not staged**, recorded in the ledger
as waiting for the owner.

- [ ] `80-notifications`:
  - *Never clear what you did not name*: "Never operate on the raw result of `pendingIdentifiers()`"
    → "Never operate on the raw result of `pending()`".
  - *The applier holds no policy*: "Skip any slot whose identifier is already pending; never
    unconditionally re-`add` the whole plan" → spec §5's first block, verbatim. The remove-only
    bullet's `scheduler.pendingIdentifiers()` → `scheduler.pending()`. The `ReminderScheduler stays a
    struct of closures` bullet gains: "It is `nonisolated`: `reconcile` and the app's queue call its
    closures off the main actor, and a synchronous closure read off a main-actor struct warns".
  - *Content*: the "both catalogues" bullet gains "— except the button's title, *Log a Glass*, which
    only the app resolves: it is the Siri phrase's title, the same act in the same words".
  - A new `## The button` section after *Content* — spec §5's second block, verbatim.
  - *Who reschedules*: the first bullet's list gains "the `language` setter — which moves no slot,
    but every pending reminder's wording —"; the `LogServingIntent.perform()` bullet begins
    "`LogServingIntent.logTheGlassInTheBackground()` — what `perform()` and the reminder's button
    both run — holds the app process open …".
- [ ] `70-privacy`, *The lock screen is a public surface*: spec §5's button bullet, verbatim, after the
  control's bullet.
- [ ] `43-concurrency`: spec §5's `ReminderResponder` bullet, verbatim, after the two `WristLink`
  bullets.
- [ ] `85-testing`, *A green suite is not proof the product works*: "— and put the control in Control
  Center" → "— put the control in Control Center, and, after a change to reminders, press a
  reminder's *Log a Glass* with the app not running".
- [ ] `git status --short .claude/` shows four rule files modified and unstaged, beside the
  long-standing `.claude/settings.json`.

---

### Task 6: On the simulator — the press, from SpringBoard

**Files:**
- Create (throwaway, **deleted in Step 9**): `WaterBuddyUITests/ReminderButtonProbe.swift`
- Scratch: `$SCRATCH/reminder.apns`, `$SCRATCH/probe-dd/`, `$SCRATCH/probe-*.xcresult`

Spec §7.3, plus Review Focus 3. Every run is on *WaterBuddy Probe 27*
(`43E0B902-C6D5-48DD-B513-F22AF3BE9BEA`), never a gate device: the probe pours water. Record its
goal and vessels before Step 3 and after Step 8 in the ledger.

- [ ] **Step 1: The payload.** Write `$SCRATCH/reminder.apns` with `Write`:

```json
{
  "Simulator Target Bundle": "sardor.WaterBuddy",
  "aps": {
    "alert": {
      "title": "Time for water",
      "body": "A glass now keeps you on track for the day."
    },
    "category": "sardor.WaterBuddy.reminderCategory"
  }
}
```

- [ ] **Step 2: The probe.** Write `WaterBuddyUITests/ReminderButtonProbe.swift`:

```swift
//  THROWAWAY — the reminder button's simulator proof (plan 2026-10-15, Task 6). Deleted before staging.

import XCTest

/// Presses a reminder's *Log a Glass* from SpringBoard. Each test that waits for a reminder is run with
/// `xcrun simctl push` firing from the host while the app is not running; the reminder is then found in
/// Notification Center, whenever it arrived.
final class ReminderButtonProbe: XCTestCase {

    private let app = XCUIApplication()
    private let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: The runs

    /// Spec §7.3 step 1. Allows notifications, then turns reminders off again, so no real reminder
    /// fires during the probe. Run once.
    @MainActor
    func testAAllowNotifications() throws {
        launchOnHome()
        app.buttons["Settings"].tap()
        let toggle = app.switches["Smart reminders"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 10))
        if toggle.value as? String == "0" {
            toggle.tap()
            let allow = springboard.buttons["Allow"]
            if allow.waitForExistence(timeout: 8) { allow.tap() }
        }
        XCTAssertFalse(app.buttons["Open iOS Settings"].waitForExistence(timeout: 3),
                       "notifications are denied on this simulator: allow them in iOS Settings first")
        XCTAssertEqual(toggle.value as? String, "1", "reminders did not turn on")
        toggle.tap()
        XCTAssertEqual(toggle.value as? String, "0")
    }

    /// Spec §7.3 steps 2–3: the cold background launch. The app is not running when the reminder
    /// arrives; the press logs the Glass without bringing it forward.
    @MainActor
    func testBAPressLogsTheGlassWithoutOpeningTheApp() throws {
        launchOnHome()
        let glass = glassAmount()
        app.buttons["Home"].tap()
        let before = total()
        report("before \(before), glass \(glass)")
        app.terminate()

        press(buttonTitled: "Log a Glass", shot: "B-expanded")
        assertLaunchedInTheBackground()

        launchOnHome()
        XCTAssertTrue(waitForTotal(before + glass), "the press did not log the Glass once: \(total()) after \(before)")
    }

    /// Spec §7.3 step 3, second half: the Glass is read when the button is pressed.
    @MainActor
    func testCAGlassEditedBeforeThePressLogsItsNewAmount() throws {
        launchOnHome()
        app.buttons["Settings"].tap()
        let slider = app.sliders["Glass"]
        XCTAssertTrue(slider.waitForExistence(timeout: 10))
        slider.adjust(toNormalizedSliderPosition: 0.6)
        sleep(1)
        let glass = glassAmount()
        app.buttons["Home"].tap()
        let before = total()
        report("before \(before), edited glass \(glass)")
        app.terminate()

        press(buttonTitled: "Log a Glass", shot: "C-expanded")
        assertLaunchedInTheBackground()

        launchOnHome()
        XCTAssertTrue(waitForTotal(before + glass), "the press did not log the edited Glass: \(total()) after \(before)")
    }

    /// Spec §7.3 step 4: the button is in the app's language. Switches to Russian, presses, then
    /// switches back to English.
    @MainActor
    func testDTheButtonSpeaksTheAppsLanguage() throws {
        launchOnHome()
        app.buttons["Settings"].tap()
        tapScrolling(to: app.buttons["Русский"])
        sleep(1)
        app.terminate()

        press(buttonTitled: "Записать стакан", shot: "D-expanded-ru")
        assertLaunchedInTheBackground()

        app.launch()
        sleep(2)
        app.buttons["Настройки"].tap()
        tapScrolling(to: app.buttons["English"])
        XCTAssertTrue(app.buttons["Settings"].waitForExistence(timeout: 5), "the app did not return to English")
    }

    /// Spec §7.3 step 5, Review Focus 4: a tap on the reminder itself opens the app and logs nothing.
    @MainActor
    func testEATapOnTheReminderOpensTheAppAndLogsNothing() throws {
        launchOnHome()
        let before = total()
        report("before \(before)")
        app.terminate()

        let reminder = reminderInNotificationCenter()
        reminder.tap()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15), "a tap on the reminder did not open the app")
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 10))
        sleep(3)
        XCTAssertEqual(total(), before, "a tap on the reminder logged water")
    }

    /// Review Focus 3: the press with the app already open — Notification Center pulled over it.
    /// The total rises once, in the same process.
    @MainActor
    func testFAPressWithTheAppOpenRaisesHomeOnce() throws {
        launchOnHome()
        let glass = glassAmount()
        app.buttons["Home"].tap()
        let before = total()
        report("before \(before), glass \(glass)")
        // To the background, not terminated: a reminder that arrives while the app is in front is
        // not shown at all, since nothing implements `willPresent`.
        XCUIDevice.shared.press(.home)
        // Waits for the reminder to be delivered, then puts the app in front again.
        _ = reminderInNotificationCenter()
        XCUIDevice.shared.press(.home)
        app.activate()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))

        press(buttonTitled: "Log a Glass", shot: "F-expanded-over-app")
        XCTAssertNotEqual(app.state, .notRunning, "the press over the app ended its process")
        XCUIDevice.shared.press(.home)
        app.activate()

        XCTAssertTrue(waitForTotal(before + glass), "Home did not rise by the Glass once: \(total()) after \(before)")
    }

    // MARK: SpringBoard

    /// Opens Notification Center and waits — up to four minutes — for a reminder to be in it.
    @MainActor
    private func reminderInNotificationCenter(timeout: TimeInterval = 240) -> XCUIElement {
        let top = springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.005))
        top.press(forDuration: 0.1, thenDragTo: springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.7)))
        let reminder = springboard.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS %@", "Time for water"))
            .firstMatch
        if !reminder.waitForExistence(timeout: timeout) {
            report(springboard.debugDescription)
            XCTFail("no reminder reached Notification Center")
        }
        return reminder
    }

    /// Expands the newest reminder and presses its button — the one titled `title` — after a shot of it.
    @MainActor
    private func press(buttonTitled title: String, shot: String) {
        let reminder = reminderInNotificationCenter()
        reminder.press(forDuration: 1.5)
        let button = springboard.buttons[title]
        if !button.waitForExistence(timeout: 10) {
            report(springboard.debugDescription)
            XCTFail("the expanded reminder has no \"\(title)\"")
        }
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = shot
        attachment.lifetime = .keepAlways
        add(attachment)
        button.tap()
    }

    /// The press launched the app in the background and did not bring it forward.
    @MainActor
    private func assertLaunchedInTheBackground() {
        var state = app.state
        for _ in 0..<15 where state == .notRunning {
            sleep(1)
            state = app.state
        }
        report("app state after the press: \(state.rawValue)")
        XCTAssertNotEqual(state, .notRunning, "the press did not launch the app")
        XCTAssertNotEqual(state, .runningForeground, "the press brought the app forward")
    }

    // MARK: The app

    @MainActor
    private func launchOnHome() {
        app.launch()
        sleep(2)
        completeWelcomeIfShown(app)
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 10), "the app did not open on Home")
    }

    /// The vessel's value ends "… <total> of <goal> millilitres." (`GoalSetupUITests.total(in:)`).
    @MainActor
    private func total() -> Int {
        let words = (app.otherElements["Today's hydration"].value as? String ?? "").split(separator: " ")
        return words.count > 2 ? Int(words[2]) ?? -1 : -1
    }

    @MainActor
    private func waitForTotal(_ total: Int) -> Bool {
        let spoken = NSPredicate(format: "value CONTAINS %@", " \(total) of ")
        let reached = XCTNSPredicateExpectation(predicate: spoken, object: app.otherElements["Today's hydration"])
        return XCTWaiter().wait(for: [reached], timeout: 10) == .completed
    }

    /// The Glass's amount, off its slider in Settings ("250 millilitres").
    @MainActor
    private func glassAmount() -> Int {
        app.buttons["Settings"].tap()
        let slider = app.sliders["Glass"]
        XCTAssertTrue(slider.waitForExistence(timeout: 10))
        let amount = Int((slider.value as? String ?? "").split(separator: " ").first ?? "") ?? -1
        XCTAssertGreaterThan(amount, 0, "could not read the Glass")
        return amount
    }

    @MainActor
    private func tapScrolling(to element: XCUIElement) {
        for _ in 0..<6 where !element.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(element.isHittable, "\(element) never came into reach")
        element.tap()
    }

    private func report(_ line: String) {
        XCTContext.runActivity(named: "PROBE \(line)") { _ in }
        print("PROBE \(line)")
    }
}
```

  If a query finds nothing, the probe prints SpringBoard's tree into the log once: correct the
  **query**, never an expectation. `testFAPressWithTheAppOpenRaisesHomeOnce` opens Notification
  Center twice — once to wait for the reminder, once over the app — on purpose: the reminder must be
  delivered while the app is in the background.

- [ ] **Step 3: Build once for the probe device.**

```bash
uptime
xcrun simctl boot 43E0B902-C6D5-48DD-B513-F22AF3BE9BEA; xcrun simctl bootstatus 43E0B902-C6D5-48DD-B513-F22AF3BE9BEA -b
xcodebuild build-for-testing -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Probe 27' -derivedDataPath "$SCRATCH/probe-dd" 2>&1 | grep -E "error:|TEST BUILD" | tail -5
```

- [ ] **Step 4: Allow notifications** (no push):

```bash
xcodebuild test-without-building -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Probe 27' -derivedDataPath "$SCRATCH/probe-dd" -only-testing:WaterBuddyUITests/ReminderButtonProbe/testAAllowNotifications -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Executed|error:|failed|PROBE" | tail -10
```

  If it fails on "notifications are denied", stop: the owner allows them in the simulator's iOS
  Settings, and the step runs again.

- [ ] **Step 5: The cold background launch** — the run that proves the install in `init()`
  (spec §3.6). One command: the push fires 75 seconds in, from the background, while the probe waits
  up to four minutes for it.

```bash
( sleep 75; xcrun simctl push 43E0B902-C6D5-48DD-B513-F22AF3BE9BEA sardor.WaterBuddy "$SCRATCH/reminder.apns" ) & xcodebuild test-without-building -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Probe 27' -derivedDataPath "$SCRATCH/probe-dd" -only-testing:WaterBuddyUITests/ReminderButtonProbe/testBAPressLogsTheGlassWithoutOpeningTheApp -parallel-testing-enabled NO -collect-test-diagnostics never -resultBundlePath "$SCRATCH/probe-B.xcresult" 2>&1 | grep -E "Executed|error:|failed|PROBE" | tail -10
xcrun xcresulttool export attachments --path "$SCRATCH/probe-B.xcresult" --output-path "$SCRATCH/probe-B-shots"
```

  Expected: `Executed 1 test, with 0 failures`; the log's `PROBE app state after the press:` reads 2
  or 3 (`.runningBackgroundSuspended` / `.runningBackground`), not 1 (`.notRunning`) or 4
  (`.runningForeground`); the shot shows one button, *Log a Glass*, with the Glass's glyph. Look at
  the shot (`Read`) and record what it shows.

  **If it fails:**
  - The button is pressed but the state stays 1 and the total does not move: either `simctl push`
    does not deliver a background action's response (spec §7.3's unconfirmed), or the delegate was
    installed too late. Tell them apart with the fallback below, which uses a real local
    notification. If the fallback passes, `simctl push` was the cause; record it.
  - If the fallback fails the same way, `init()` is too late: move the install to
    `application(_:willFinishLaunchingWithOptions:)` behind a `@UIApplicationDelegateAdaptor`, amend
    spec §3.6 and Task 4's comment, and run this step again.
  - **The fallback** — throwaway, never staged: in `WaterBuddyApp.init()`, after
    `ReminderResponder.install()`, add the block below. Then in the probe replace `app.terminate()` in
    `testBAPressLogsTheGlassWithoutOpeningTheApp` with `app.terminate(); app.launchArguments =
    ["-WaterBuddyProbeReminder"]; app.launch(); sleep(2); app.terminate()`. Build as in Step 3, and run
    Step 5's command without the `( sleep …; … ) &` part.

```swift
        #if DEBUG
        // THROWAWAY (plan 2026-10-15, Task 6): files one reminder 20 seconds ahead, for the probe.
        if ProcessInfo.processInfo.arguments.contains("-WaterBuddyProbeReminder") {
            let content = NotificationManager.reminderContent(in: manager.language.bundle)
            Task {
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 20, repeats: false)
                try? await UNUserNotificationCenter.current().add(
                    UNNotificationRequest(identifier: "probe.reminder", content: content, trigger: trigger)
                )
            }
        }
        #endif
```

  (`import UserNotifications` at the top of `WaterBuddyApp.swift`, also throwaway. The identifier is
  outside `identifierPrefix`, so no reconcile touches it.)

- [ ] **Step 6: The edited Glass, the language, the tap on the body.** Each the Step 5 command with
  its own test name and result bundle — `testCAGlassEditedBeforeThePressLogsItsNewAmount` →
  `probe-C`, `testDTheButtonSpeaksTheAppsLanguage` → `probe-D`,
  `testEATapOnTheReminderOpensTheAppAndLogsNothing` → `probe-E`. Export and read each one's shots.
  Expected: each `Executed 1 test, with 0 failures`; D's shot shows *Записать стакан*.

- [ ] **Step 7: The press with the app open** — `testFAPressWithTheAppOpenRaisesHomeOnce` →
  `probe-F`, the Step 5 command with `sleep 45` (the push must land while the app is in the
  background, which this test reaches sooner).

- [ ] **Step 8: Shut the probe device down** —
  `xcrun simctl shutdown 43E0B902-C6D5-48DD-B513-F22AF3BE9BEA`. Write into the ledger, for each run:
  the `PROBE` lines, the executed count, the app state after the press, and what the shots show.

- [ ] **Step 9: Delete the probe**, and the fallback block if it was used. `rm` with the literal path
  `WaterBuddyUITests/ReminderButtonProbe.swift`; if the harness refuses it, give the owner the one
  `!` line and wait. Then `git status --short WaterBuddyUITests/ WaterBuddy/WaterBuddyApp.swift`
  shows no probe file, and `git diff WaterBuddy/WaterBuddyApp.swift` shows only Task 4's lines.

---

### Task 7: The review, the gate, the warning comparison

- [ ] **Step 1: A fresh reviewer.** Stage the code and tests by explicit path first (Task 8's list,
  code half), so the review reads `git diff --cached`. A read-only subagent reviews it against the
  spec, this plan's decisions P1–P6, the rules (`80-notifications`, `70-privacy`, `43-concurrency`,
  `40-widget`, `20-state`) and the DocC of the types changed. Save its report to the ledger folder as
  it arrives. Check every finding against the code before acting on it; a fix goes through the task
  that owns the file, tests first.
- [ ] **Step 2: The gate.** Rule `85-testing`'s invocations on this machine's destinations. `uptime`
  before each; shut down by UDID between systems.
  1. Unit tests on the stock iOS 27.0 *iPhone 17*:
     `xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Test run with|✘" | tail -20`.
  2. The UI suite on *WaterBuddy Gate 27*. `GoalSetupUITests` (36 tests) in four chunks of nine:

```zsh
grep -oE "func test[A-Za-z0-9]+" WaterBuddyUITests/GoalSetupUITests.swift | sed 's/^func //' | sort > "$SCRATCH/goalsetup.txt"; wc -l < "$SCRATCH/goalsetup.txt"
FLAGS=$(sed -n '1,9p' "$SCRATCH/goalsetup.txt" | sed 's#^#-only-testing:WaterBuddyUITests/GoalSetupUITests/#' | tr '\n' ' '); xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' ${=FLAGS} -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Executed|error:|failed" | tail -8
```

     then the same with `'10,18p'`, `'19,27p'` and `'28,36p'`, then
     `-only-testing:WaterBuddyUITests -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests -skip-testing:WaterBuddyUITests/GoalSetupUITests`,
     which runs `WelcomeUITests` and the template classes. Read each run's **executed** count, and
     set the five beside stage 5's in `docs/AI_CONTEXT.md` — the launch test runs once per UI
     configuration, so the last run's count is not the number of its `func test` lines.
  3. The same five UI runs on *WaterBuddy Gate 26.5* (`OS=26.5`).
  4. Watch tests on *WaterBuddy Watch 27*:
     `xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Test run with|✘" | tail -10`.
  5. `xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' 2>&1 | grep -E "error:|BUILD" | tail -3`.
  6. `xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' 2>&1 | grep -E "error:|BUILD" | tail -3`.
- [ ] **Step 3: The warning comparison.**

```bash
git checkout-index -a --prefix="$SCRATCH/after/"
xcodebuild build-for-testing -project "$SCRATCH/after/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'generic/platform=iOS Simulator' -derivedDataPath "$SCRATCH/after-dd" > "$SCRATCH/after-app.log" 2>&1; echo "exit $?"
xcodebuild build -project "$SCRATCH/after/WaterBuddy.xcodeproj" -scheme WaterBuddyWidgetExtension -destination 'generic/platform=iOS Simulator' -derivedDataPath "$SCRATCH/after-dd" > "$SCRATCH/after-widget.log" 2>&1; echo "exit $?"
cat "$SCRATCH"/after-app.log "$SCRATCH"/after-widget.log | grep -E ': warning: ' | sed -E 's#^.*/after/##; s#^(Water[^:]+):[0-9]+:[0-9]+: #\1: #' | sort -u > "$SCRATCH/after-messages.txt"; wc -l < "$SCRATCH/after-messages.txt"
comm -13 "$SCRATCH/base-messages.txt" "$SCRATCH/after-messages.txt"
comm -23 "$SCRATCH/base-messages.txt" "$SCRATCH/after-messages.txt"
```

  Expected: the first `comm` prints nothing (no new line). The second prints the two
  `removePending` / `removeDelivered` lines (P1). Anything else in either is recorded as it stands.
  A new line is fixed before reporting, or, if it cannot be, reported as a failure.

---

### Task 8: Records, docs — then stop

- [ ] `CLAUDE.md`, *Two front doors, one serving*: after the Control Center sentence, add "**A
  reminder's *Log a Glass* is a fifth:** pressed on the notification — on the iPhone, or on Apple
  Watch — it runs `LogServingIntent.logTheGlassInTheBackground()` in the app's own process through
  `ReminderResponder`, without opening the app
  (`docs/superpowers/specs/2026-10-15-log-from-a-reminder-design.md`)". The architecture bullet
  *Reminders are scheduled from a pure plan* is unchanged.
- [ ] `docs/STATE.md`, *The sixth key, and the seam that reads it*: "Fired from **six** places" →
  "**seven**", and the table gains `| the \`language\` setter | it moves no slot, but every pending
  reminder is in the old words — the reconcile files each again (2026-10-15) |`. Add a short
  paragraph on the seam: `pending()` reads back each request's wording as a `PendingReminder`;
  `setCategories` is the app's alone; a pending reminder in other words is filed again in place.
- [ ] `docs/WIDGET.md`, the `AddWaterIntent` section: one sentence — the reminders the extension files
  now name the button's category, which only the app registers, and its reconcile files again any
  reminder in other words; `perform()`'s code is unchanged.
- [ ] `docs/AI_CONTEXT.md`:
  - a block at the head of *Current state* for 1.2.4;
  - *Files on disk*: `ReminderResponder.swift` new, `NotificationManager.swift`'s line count and
    description, `LogServingIntent.swift`'s;
  - the gate's results and counts from Task 7, by the attribute grep, and the warning comparison;
  - known issue **#72** widened: a reminder's button reaches the same before-first-unlock risk, from
    the app's own process, `prepareSharedStorage()` included;
  - new known issues from **#133**: the device sweep's eight steps (spec §7.4) not yet run; the button
    exists only once the app has run since the update (spec §8); anything Task 6 could not prove, and
    whether `simctl push` drove the background action.
- [ ] `docs/ROADMAP.md`: item 1.2.4 marked built in the tree, awaiting `/commit` and the device sweep.
- [ ] `tasks/lessons.md` and `HISTORY.md`: appended with `Edit`, anchored on their last lines. The
  lesson: on this toolchain a **synchronous** closure stored on a struct that takes the target's
  default main-actor isolation warns when read from nonisolated code, and an **awaited** one does not —
  so a new synchronous member on a shared seam is a new warning until the type is `nonisolated`.
- [ ] Before the readers: search every sheet for what this change replaced — `pendingIdentifiers`,
  "Fired from **six**", "six places", "skips any slot whose identifier is already pending" — and check
  every `File.swift:N` the sheets cite against the tree.
- [ ] **Two fresh readers** (read-only subagents) on the records. Brief them by line range, and point
  them at the ledger, the gate's logs, the probe's results and the saved review. Save each report as
  it arrives, check its findings against their primary source, and fix by deleting or by quoting the
  source.
- [ ] Stage by explicit path: `WaterBuddy/NotificationManager.swift`, `WaterBuddy/DataManager.swift`,
  `WaterBuddy/LogServingIntent.swift`, `WaterBuddy/ReminderResponder.swift`,
  `WaterBuddy/WaterBuddyApp.swift`, the four test files, the spec, this plan, `CLAUDE.md`, the five
  `docs/` sheets, `HISTORY.md`, `tasks/lessons.md`. The rule files stay unstaged. Write the git block
  last, from `git status --short` and `git diff --cached --name-status` run at that moment.
- [ ] **Stop.** Report:
  - what was built;
  - what the probe proved, with its shots, and what it could not;
  - the gate's counts and the warning comparison;
  - the rule wording waiting;
  - the commit order: the spec and plan as `docs`, the code as `feat(app)`, the records as `docs`,
    and the rules as `chore(claude)` once approved.
