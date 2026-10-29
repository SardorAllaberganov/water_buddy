# Apple Health Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:executing-plans. This project has **no
> implementation subagent** (`CLAUDE.md`, *Implementation — one loop, tests first*): every task is built in
> the main loop, test first, and nothing is committed — each task ends by **staging** its files by name;
> the owner commits with `/commit`. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Copy every WaterBuddy serving into Apple Health as Water — write only, the whole history when the
user turns it on in Settings — and keep Health in step with every edit and delete.

**Architecture:** A pure `HealthPlan` (Foundation only) diffs the log against the samples WaterBuddy already
wrote, keyed by each serving's id as HealthKit's sync identifier; an app-only `HealthMirror` (the one file
that imports HealthKit) carries the answer out through a `ReconcileQueue`, one pass at a time, triggered by
the switch, by every save in the app's process, and by the app coming forward. `DataManager` gains a key, a
switch, an optional-returning read and a notification — and never sees a Health type.

**Tech Stack:** Swift 5 mode, SwiftUI, SwiftData, Observation, HealthKit (iOS 17 floor; `HKSampleQueryDescriptor`
is iOS 15.4), swift-testing, XCTest UI tests.

**Spec:** `docs/superpowers/specs/2026-10-29-apple-health-design.md` — read its §6 *Refinements* first: they
supersede the sentences they name, and this plan follows them.

## Global Constraints

- **Write only, Water only:** `requestAuthorization(toShare: [HKQuantityType(.dietaryWater)], read: [])`.
  No read type, no second type.
- **The log is the source of truth.** No figure, widget, watch, Siri reply or notification reads Health.
- **A failed read writes nothing:** `DataManager.logs(since:)` returns `nil`, never `[]`, on a failed fetch;
  a pass that gets `nil` from either side ends without a write.
- **Turning off deletes nothing** (D4). **A sample deleted in the Health app comes back while its serving
  stands** (D6).
- **`HealthMirror.swift` is the only file that imports HealthKit**; `HealthPlan.swift` imports Foundation alone.
  Both are app-only — in no `PBXFileSystemSynchronizedBuildFileExceptionSet`.
- **`DataManager.swift` names no Health type** — it compiles into the widget and both watch targets.
- **One entitlement, one key:** `com.apple.developer.healthkit` in `Entitlements/WaterBuddy.entitlements`
  alone; `INFOPLIST_KEY_NSHealthUpdateUsageDescription` on the app target's two configurations alone.
- **Volumes stay `Int`;** a `Double` of millilitres exists only inside `HealthMirror.Source.live()`, from an
  `Int` and rounded back.
- **Every string digit-free**, in `en`, `ru` and `uz`. Russian and Uzbek are drafts until the owner's sweep.
- **Tests:** a throwaway UUID-named suite and an in-memory store per fixture; `reloadWidgets: {}`,
  `rescheduleReminders: { _ in }`, `publishWrist: { _ in }`; HealthKit only through `HealthMirror.Source`
  closures, never `.live()`; `HealthPlanTests` is not `@MainActor`.
- **The gate:** the five invocations of rule `85-testing`, plus the UI run on `OS=26.5`; one simulator,
  `-parallel-testing-enabled NO`, foreground; no new warning against a clean build of `main`.
- **Never commit.** Stage by explicit path; the owner runs `/commit`.

## Review Focus

The five failure modes no task's tests reach by construction, most likely first — each line names the check
that pins it and the task that owns it:

1. **An instant HealthKit hands back a hair different** would be written again on every pass, its version
   climbing forever. Expected: written once. Pinned by `anInstantThatComesBackAHairDifferentIsNotWrittenAgain`
   (Task 4) and measured for real in Task 0 (f).
2. **Another `DataManager`'s save** — the widget extension's, a test running beside this one — must not
   start this mirror's pass. Expected: only this manager's saves do. Pinned by
   `comingForwardWritesWhatAnotherProcessLogged` (Task 5), which first proves the other manager's save wrote
   nothing.
3. **The switch turned off while a pass is between its two reads.** Expected: nothing written after the
   off. Pinned by `turningItOffMidPassWritesNothing` (Task 5).
4. **A Health sample WaterBuddy did not write** — no sync identifier — must never be deleted, whatever the
   query returned around it. Pinned by `aSampleWithoutASyncIdentifierIsLeftAlone` (Task 4).
5. **The app asking to read anything.** Expected: the built Info.plist carries no
   `NSHealthShareUsageDescription`. Pinned by `theAppAsksHealthToWriteAndNeverToRead` (Task 6).

## File structure

| File | Responsibility |
|---|---|
| `WaterBuddy/HealthPlan.swift` (new) | Pure: `Serving`, `Sample`, `Save`, `Changes`, `Scope`, `recentDays`, `changes(servings:samples:within:)` |
| `WaterBuddy/HealthMirror.swift` (new) | `@MainActor @Observable`: `Status`, `Source` (+ `silent()`, `live()`), `enable`, `disable`, `readStatus`, `reconcile`, `request`, `settled`, the pass |
| `WaterBuddy/DataManager.swift` | `Key.healthEnabled` (+ `Key.all`), `healthEnabled`, `logs(since:)`, `logsDidSaveNotification` posted by `saveAndRecompute()`, `appliedLedgerRetentionDays` made `nonisolated static let` |
| `WaterBuddy/WaterBuddyApp.swift` | builds the mirror, injects it, reconciles it on coming forward |
| `WaterBuddy/SettingsView.swift`, `WaterBuddy/RootTabView.swift` | the *Apple Health* card; the previews inject a silent mirror |
| `WaterBuddy/Localizable.xcstrings`, `WaterBuddy/InfoPlist.xcstrings` (new) | three keys; the usage description |
| `Entitlements/WaterBuddy.entitlements`, `WaterBuddy.xcodeproj/project.pbxproj` | the entitlement; the usage key |
| `WaterBuddyTests/HealthPlanTests.swift` (new), `WaterBuddyTests/HealthMirrorTests.swift` (new) | the plan; the mirror and `DataManager`'s Health surface |
| `WaterBuddyTests/DataManagerTests.swift`, `WaterBuddyTests/LocalizationTests.swift`, `WaterBuddyUITests/GoalSetupUITests.swift` | the roster; the strings; the switch as one element |
| `PRIVACY.md`, `Tools/PrivacyPolicy.html` | the policy's Apple Health section |
| `.claude/rules/` (eleven files) | the amendments, typed for the owner (Task 1) |

Test invocation used throughout (one suite at a time while building; the whole gate in Task 9):

```bash
xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' \
  -only-testing:WaterBuddyTests/<SuiteName> -parallel-testing-enabled NO
```

---

### Task 0: Measure HealthKit on the simulator — in a scratch worktree, nothing kept

**Files:** none in this repository. A detached worktree in the session's scratchpad (`$SCRATCH`), removed
at the end. The owner's clicks are needed for Health's sheet and the Health app.

**Interfaces:** Produces the facts §4a of the spec records: (a) write-only reads back only WaterBuddy's own
samples; (b) the one usage key suffices; (c) a higher sync version replaces, an equal or lower one does
not; (d) the Settings path for the refusal line; (f) an instant and an amount round-trip exactly.

- [ ] **Step 1: Make the worktree**

```bash
SCRATCH="/private/tmp/claude-501/-Users-sardorallaberganov-Desktop-Projects-MobileApps-Games-WaterBuddy/545ffb2a-aa3a-4172-9213-465467d7b6b5/scratchpad"
git worktree add --detach "$SCRATCH/health-probe" HEAD
```

- [ ] **Step 2: Give the probe its entitlement and its one key** — in `$SCRATCH/health-probe` only.
  `Entitlements/WaterBuddy.entitlements`, inside `<dict>` after the App Group's `</array>`:

```xml
	<key>com.apple.developer.healthkit</key>
	<true/>
```

  `WaterBuddy.xcodeproj/project.pbxproj`, in both of the app target's configurations (`9947C23D3046293F00972CEA`
  Debug and its Release twin), after `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO;`:

```
				INFOPLIST_KEY_NSHealthUpdateUsageDescription = "WaterBuddy saves each serving you log to Apple Health as water. It reads nothing from Health.";
```

- [ ] **Step 3: Write the probe** — `$SCRATCH/health-probe/WaterBuddy/HealthProbe.swift`:

```swift
#if DEBUG
import Foundation
import HealthKit

/// Task 0's measurements — a scratch file in a scratch worktree, never in the repository.
enum HealthProbe {
    static func runIfAsked() {
        guard ProcessInfo.processInfo.arguments.contains("-HealthProbe") else { return }
        Task { @MainActor in await run() }
    }

    @MainActor static func run() async {
        let store = HKHealthStore()
        let water = HKQuantityType(.dietaryWater)
        let ml = HKUnit.literUnit(with: .milli)
        func say(_ line: String) { print("[HealthProbe] \(line)") }

        say("b: available \(HKHealthStore.isHealthDataAvailable()), status before \(store.authorizationStatus(for: water).rawValue)")
        do { try await store.requestAuthorization(toShare: [water], read: []) } catch { say("b: request threw \(error)") }
        say("b: status after \(store.authorizationStatus(for: water).rawValue) (2 is sharingAuthorized)")

        func ours() async -> [HKQuantitySample] {
            let query = HKSampleQueryDescriptor(
                predicates: [.quantitySample(type: water, predicate: HKQuery.predicateForObjects(from: HKSource.default()))],
                sortDescriptors: [])
            do { return try await query.result(for: store) } catch { say("read threw \(error)"); return [] }
        }
        func everyone() async -> Int {
            let query = HKSampleQueryDescriptor(predicates: [.quantitySample(type: water)], sortDescriptors: [])
            do { return try await query.result(for: store).count } catch { say("read-all threw \(error)"); return -1 }
        }

        let id = UUID().uuidString
        let instant = Date(timeIntervalSinceReferenceDate: 815_000_000.123_456)
        func sample(_ amount: Double, version: Int) -> HKQuantitySample {
            HKQuantitySample(
                type: water, quantity: HKQuantity(unit: ml, doubleValue: amount), start: instant, end: instant,
                metadata: [HKMetadataKeySyncIdentifier: id, HKMetadataKeySyncVersion: version, HKMetadataKeyWasUserEntered: true])
        }
        func mine() async -> [HKQuantitySample] {
            await ours().filter { $0.metadata?[HKMetadataKeySyncIdentifier] as? String == id }
        }
        func report(_ step: String) async {
            let found = await mine()
            let shown = found.map { "\($0.quantity.doubleValue(for: ml)) v\(($0.metadata?[HKMetadataKeySyncVersion] as? NSNumber)?.intValue ?? -1)" }
            say("c: \(step) → \(found.count) sample(s) \(shown)")
        }

        say("a: every source visible before writing: \(await everyone())")
        do { try await store.save(sample(250, version: 1)) } catch { say("c: v1 threw \(error)") }
        await report("after v1 250")
        if let first = await mine().first {
            say("f: start drift \(first.startDate.timeIntervalSinceReferenceDate - instant.timeIntervalSinceReferenceDate) s, amount \(first.quantity.doubleValue(for: ml))")
        }
        do { try await store.save(sample(300, version: 2)) } catch { say("c: v2 threw \(error)") }
        await report("after v2 300")
        do { try await store.save(sample(400, version: 2)) } catch { say("c: equal v2 threw \(error)") }
        await report("after equal v2 400")
        do { try await store.save(sample(500, version: 1)) } catch { say("c: lower v1 threw \(error)") }
        await report("after lower v1 500")
        if let object = await mine().first?.uuid {
            do {
                let removed = try await store.deleteObjects(of: water, predicate: HKQuery.predicateForObjects(with: [object]))
                say("delete by object removed \(removed)")
            } catch { say("delete threw \(error)") }
        }
        say("a: every source visible after: \(await everyone()), ours \(await ours().count)")
    }
}
#endif
```

  And one line in `$SCRATCH/health-probe/WaterBuddy/WaterBuddyApp.swift`, first in `init()`:

```swift
        HealthProbe.runIfAsked()
```

- [ ] **Step 4: Before the run, the owner adds one Water entry in the simulator's Health app** (Browse ›
  Nutrition › Water › Add Data, 100 mL) on `iPhone 17`, iOS 27.0 — a sample from another source, for (a).

- [ ] **Step 5: Build, install and run the probe on a fresh start** (the fresh start keeps every write off the
  simulator's App Group):

```bash
xcrun simctl shutdown all
xcrun simctl boot "iPhone 17"
cd "$SCRATCH/health-probe"
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -derivedDataPath "$SCRATCH/probe-dd"
xcrun simctl install booted "$SCRATCH/probe-dd/Build/Products/Debug-iphonesimulator/WaterBuddy.app"
xcrun simctl launch --console-pty booted sardor.WaterBuddy -WaterBuddyFreshStart -HealthProbe
```

  The owner answers Health's sheet: it must list **Water** under *Allow "WaterBuddy" to write data* and
  nothing to read — that is (b), with no exception printed. Then **Allow**.
  Expected lines: `b: status after 2`; `a:` the same count before and after (the Health app's own entry
  hidden — the count is WaterBuddy's alone, 0 before); `c: after v2 300 → 1 sample(s) ["300.0 v2"]`; the
  equal and the lower version leave `300.0 v2`; `f: start drift 0.0 s, amount 250.0`; `delete … removed 1`.

- [ ] **Step 6: (d) The owner opens the simulator's Settings › Privacy & Security › Health › WaterBuddy**
  and says whether that path exists and shows the Water switch. Screenshot: `xcrun simctl io booted
  screenshot "$SCRATCH/task0-d.png"`. Also open the Health app › profile › Apps (or Privacy › Apps) ›
  WaterBuddy, for the policy's deletion sentence (Task 8).

- [ ] **Step 7: Record and decide.** Write the printed lines and (d)'s path into the spec's §4a under a
  *Measured, 2026-10-29* heading. **If (a) or (c) fails, stop: the spec is revised before anything else.**
  If (b) demands `NSHealthShareUsageDescription`, Task 1's wording and Task 6's test change to name it, read
  for nothing. If (d)'s path differs, Task 7's refusal string takes the measured one. If (f) drifts, keep
  the millisecond comparison and write the measured drift beside it.

- [ ] **Step 8: Remove the worktree; reinstall nothing** — the next real install replaces the probe build:

```bash
git worktree remove --force "$SCRATCH/health-probe"
git worktree prune
git worktree list
```

  Expected: one worktree, the repository's own. Stage the spec's §4a (`git add docs/superpowers/specs/2026-10-29-apple-health-design.md`).

---

### Task 1: Type the rule wording, for the owner — no product code until it is approved

**Files (all unstaged, for the owner's review):** `.claude/rules/70-privacy.md`, `15-project.md`,
`10-architecture.md`, `20-state.md`, `25-shared-storage.md`, `43-concurrency.md`, `50-views.md`,
`65-accessibility.md`, `85-testing.md`, `00-workspace.md`, `60-design-system.md`.

- [ ] **Step 1: `70-privacy.md`** — four edits and one section.
  In *Nothing leaves the device*, replace `` `HealthKit`, `CloudKit`, `StoreKit` (two uses, below) `` with
  `` `HealthKit` (one use, below — the phone only), `CloudKit`, `StoreKit` (two uses, below) ``.
  Replace `Keep \`com.apple.security.application-groups\` the only entitlement on either signed target. Adding
  any other capability requires a written justification in this file first` with:

```
- Keep `com.apple.security.application-groups` the only entitlement on every signed target but the app's,
  which also carries `com.apple.developer.healthkit` (*HealthKit, for Apple Health*, below). Adding any other
  capability requires a written justification in this file first
```

  Replace the *Add no `NS*UsageDescription` key* bullet with:

```
- Add no `NS*UsageDescription` key to any Info.plist but `NSHealthUpdateUsageDescription`, on the app target
  alone (*HealthKit, for Apple Health*, below). Notification authorization and Health's permission to write
  Water are the only two permissions this product ever asks for
```

  In *WatchConnectivity is a ruling*, replace the *No third framework rides in behind it* bullet with:

```
- **No third framework rides in behind it.** `CoreLocation` and `CloudKit` remain banned by name, and
  `HealthKit` is banned on the watch — the phone's one use, below, writes from the phone alone. A watch app
  is exactly where someone will propose all three.
```

  Insert before `## The recap's image, on the user's own tap`:

```
## HealthKit, for Apple Health

`HealthKit` may copy the user's servings into Apple Health on the iPhone (roadmap 1.3.3,
`docs/superpowers/specs/2026-10-29-apple-health-design.md`). Health is Apple's store on the device: no
server of ours, no account, no third party. Apple syncs it through iCloud only when the user has turned
that on, under Apple's terms. WaterBuddy's own log stays the source of truth.

Seven limits are conditions of the permission:
- **One file.** `HealthMirror.swift` alone imports `HealthKit`, and reaches it only through
  `HealthMirror.Source`. No view, no widget or watch file, not `DataManager.swift`
- **Write only, Water only.** Authorization asks to share `HKQuantityType(.dietaryWater)` and to read
  nothing. The only samples read back are WaterBuddy's own, which a write permission allows. A read of
  anything another source wrote, or any second type — 1.4.11's workouts among them — needs an amendment
  here first
- **Only on the user's tap.** Asked from Settings' *Apple Health* switch turning on, through
  `HealthMirror.enable()` — never at launch, never from the welcome, a widget, the watch, Siri, the control
  or a notification. A refusal leaves `healthEnabled` false
- **A copy, never a source.** Nothing read from Health reaches a figure, a widget, the watch, Siri, a
  notification or the recap. A sample carries a serving's amount, its instant and its id as the sync
  identifier, and nothing else: no goal, streak, language or device name
- **One entitlement, one key.** `com.apple.developer.healthkit` on the app target alone, beside the App
  Group, and `NSHealthUpdateUsageDescription` — the two exceptions above, each for this alone. No
  `NSHealthShareUsageDescription`: nothing is read
- **Turning it off deletes nothing.** It stops the writing; what is in Health is the user's, to keep or to
  delete in the Health app
- **No diagnostic carries a sample.** A `#if DEBUG` line names the failing condition only (rule
  `75-diagnostics`)
```

- [ ] **Step 2: `15-project.md`.** In *Signing*, replace `The App Group is the only entitlement on any of the
  four targets (rule \`70-privacy\`).` with `The App Group is the only entitlement on the widget and both watch
  targets; the app's file also carries \`com.apple.developer.healthkit\` (rule \`70-privacy\`'s *HealthKit, for
  Apple Health*).` and replace `All four files are currently byte-identical (same content, re-verified by
  \`shasum\`) and nothing enforces that.` with `The widget's and the two watch targets' files are
  byte-identical (re-verified by \`shasum\`); the app's differs by the HealthKit entitlement alone. Nothing
  enforces either.` In *Membership*, after the `RecapCard` and `RecapSheet` bullet, add:

```
- `HealthPlan` and `HealthMirror` are app-only and stay out of every exception set. HealthKit enters by its
  `import` in `HealthMirror.swift` alone, as `FoundationModels` does in `InsightWriter.swift`
```

  In *Localization*, after the `AppShortcuts.xcstrings` bullet, add:

```
- `WaterBuddy/InfoPlist.xcstrings` is a sixth catalogue — the Info.plist's one localised string,
  `NSHealthUpdateUsageDescription`, which Health's sheet shows — in `en`, `ru` and `uz`
```

  In *Submission*, after the export-compliance bullet, add:

```
- **The App ID `sardor.WaterBuddy` carries the HealthKit capability.** Automatic signing adds it when Xcode
  next signs for a device; check a distribution profile carries it before an archive, or the upload is
  refused for an entitlement the profile lacks
```

- [ ] **Step 3: `10-architecture.md`.** In the diagram, `WaterBuddy.store         11 keys, derived cache` →
  `WaterBuddy.store         12 keys, derived cache`. After `` `Key.weekTotals`, the last seven days' totals the
  week widget draws, brings it to 11. `` add `` `Key.healthEnabled`, the Apple Health switch, brings it to 12. ``
  After the insights ruling, add:

```
- **Apple Health is a copy, written by the app.** `HealthPlan`, pure, decides from the rows and the samples
  WaterBuddy already wrote; `HealthMirror`, app-only and the one file importing HealthKit, carries it out
  through one `ReconcileQueue`. It reads back only WaterBuddy's own samples, and no figure comes from Health
  (rule `70-privacy`)
```

  In *Forbidden*, after the `FoundationModels` line, add:
  `` - `import HealthKit` outside `HealthMirror.swift`, and any read of a type or a source but WaterBuddy's own Water ``

- [ ] **Step 4: `20-state.md`.** After the `claimReviewRequest(version:)` bullet, add:

```
- `healthEnabled` joins that surface. Its setter writes `Key.healthEnabled` and nothing else — no doorbell,
  no reschedule, no wrist publish, since nothing outside Settings draws it — and only `HealthMirror` sets it,
  after asking Health
```

  After the `recap(of:)` bullet, add:

```
- `logs(since:)` is a read beside `recap(of:)`: the rows from a bound — every row for `nil` — and `nil` on
  a failed read, never `[]`. Apple Health's mirror deletes every sample whose serving is not among them, so a
  failed read returned as nothing would empty Health of the user's water
```

  At the end of the *Every path that changes a `WaterLog` ends in `saveAndRecompute()`* bullet, append:
  `` . It ends by posting `logsDidSaveNotification`, the manager as its object, when the save succeeded — Apple Health's mirror listens; nothing else does ``

- [ ] **Step 5: `25-shared-storage.md`.** After the *Absence carries meaning* bullet, add:

```
- `Key.healthEnabled` is absent until the user turns Apple Health on, as `Key.remindersEnabled` is: absent
  and `false` both mean off. Only the app reads or writes it; no snapshot, mirror or notification carries it
```

- [ ] **Step 6: `43-concurrency.md`.** After the `InsightWriter` bullet, add:

```
- `HealthMirror` is `@MainActor @Observable`, `InsightWriter`'s shape: HealthKit only through
  `HealthMirror.Source`, built by `static func live()`. Its passes run on a `ReconcileQueue` of its own; it
  hears its manager's saves through `logsDidSaveNotification`, observed with `object:` that manager,
  `queue: .main` and `MainActor.assumeIsolated`. `HealthPlan` is `nonisolated` and imports Foundation alone
```

  In *Tests*, `` `MonthRecapTests` or `StoreSampleTests` to make them `` → `` `MonthRecapTests`, `StoreSampleTests` or `HealthPlanTests` to make them ``.

- [ ] **Step 7: `50-views.md`.** After the *Premium's state comes from* bullet, add:

```
- Apple Health's switch reads `@Environment(HealthMirror.self)`: its binding calls `enable()` on and
  `disable()` off — one call each — and Settings draws the card only where `isAvailable`
```

- [ ] **Step 8: `65-accessibility.md`.** After the week widget's VoiceOver bullet (*The week widget is one
  element: …*), add:

```
- Settings' *Apple Health* is one switch, its label the title it draws and its hint the line under it, on
  the `Toggle` itself — the *Smart reminders* row's shape
```

- [ ] **Step 9: `85-testing.md`.** After the *Apple's model is reached in a test only through* bullet, add:

```
- HealthKit is reached in a test only through `HealthMirror.Source`'s closures — never `Source.live()`.
  Health's sheet, the Health app's Water and a pour on a locked phone are proved by hand
```

  In *Isolation*, `` `MonthRecapTests`, `StoreSampleTests`. They are `` → `` `MonthRecapTests`, `StoreSampleTests`, `HealthPlanTests`. They are ``.
  At the end of *A green suite is not proof*'s first paragraph (after *through the local StoreKit
  configuration.*), add: `After a change to Apple Health, turn it on, pour, correct, delete and *Undo*, and read the Health app's Water; refuse it on a fresh install; withdraw it in Health and come back.`

- [ ] **Step 10: `00-workspace.md` and `60-design-system.md`.** In `00-workspace`, `` `Double` appears only as a drawing fraction `` →
  `` `Double` appears only as a drawing fraction — or at HealthKit's boundary, in `HealthMirror.Source.live()`, handed an `Int` and rounded back to one ``.
  In `60-design-system`'s *Water*, after `rounds back to \`Int\` on the way out` append
  `` — and at HealthKit's boundary, in `HealthMirror.Source.live()`, from an `Int` and rounded back to one ``.

- [ ] **Step 11: Show the owner `git diff .claude/rules/` and stop for approval.** No later task starts
  before the owner approves the wording as typed (roadmap §8). Do not stage `.claude/`: the owner's
  `/commit` admits it, as every earlier item's wording was.

---

### Task 2: The branch

- [ ] **Step 1:** With the owner's commit of this plan, the spec and §4a on `main`, make the branch — the
  typed rule wording comes with it, unstaged:

```bash
git switch -c feature/apple-health
git status --short
```

  Expected: `## feature/apple-health`, the eleven rule files modified, `.claude/settings.json` and the two
  watch schemes as before. Every later task runs here; `main` stays the 1.4 upload.

---

### Task 3: `DataManager`'s Health surface — the key, the switch, the read, the notification

**Files:**
- Modify: `WaterBuddy/DataManager.swift` (`Key`, stored state, `init`, after `remindersEnabled`, after
  `allLogs()`, `appliedLedgerRetentionDays`, `saveAndRecompute()`)
- Create: `WaterBuddyTests/HealthMirrorTests.swift` (this task: its fixtures and `HealthSurfaceTests`)
- Modify: `WaterBuddyTests/DataManagerTests.swift` (`everyKeyTheProductWritesIsOnTheRoster`)

**Interfaces — produces:**
- `DataManager.Key.healthEnabled: String`, on `Key.all`
- `var healthEnabled: Bool` (observable, settable)
- `func logs(since start: Date?) -> [WaterLog]?`
- `nonisolated static let logsDidSaveNotification: Notification.Name`, posted with `object:` the manager
- `nonisolated static let appliedLedgerRetentionDays = 90` (was `private static`)

- [ ] **Step 1: Write the failing tests** — `WaterBuddyTests/HealthMirrorTests.swift`:

```swift
//
//  HealthMirrorTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 29/10/26.
//

import Foundation
import SwiftData
import Testing
@testable import WaterBuddy

// MARK: - Fixtures

private let utcDay: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar
}()

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
}

/// The tests' clock: 29 October 2026, 15:00 UTC.
private let today: () -> Date = { utc(2026, 10, 29, 15) }

/// A suite, a store and a manager of their own, torn down after — never the real App Group (rule
/// `85-testing`): `@Test` functions run in parallel in one process.
@MainActor
private final class Bench {
    let name = "test.waterbuddy.health.\(UUID().uuidString)"
    let defaults: UserDefaults
    let container: ModelContainer
    let manager: DataManager

    init(container: ModelContainer? = nil) throws {
        defaults = try #require(UserDefaults(suiteName: name))
        self.container = try container
            ?? ModelContainer(for: WaterLog.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        manager = Self.manager(defaults: defaults, container: self.container)
    }

    /// A second manager over the same suite and store — another process's, as the widget extension's is.
    static func manager(defaults: UserDefaults, container: ModelContainer) -> DataManager {
        DataManager(
            defaults: defaults, modelContainer: container, calendar: utcDay, now: today,
            reloadWidgets: {}, rescheduleReminders: { _ in }, publishWrist: { _ in }
        )
    }

    func tearDown() {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
}

/// Counts a notification's arrivals — rule `85-testing`'s `@unchecked Sendable` box.
nonisolated private final class Arrivals: @unchecked Sendable {
    var count = 0
}

// MARK: - DataManager's Health surface

@MainActor
struct HealthSurfaceTests {

    @Test func theSwitchIsOffUntilTheUserTurnsItOn() throws {
        let bench = try Bench()
        defer { bench.tearDown() }

        #expect(!bench.manager.healthEnabled)
        #expect(bench.defaults.object(forKey: DataManager.Key.healthEnabled) == nil, "absent, never materialised")
    }

    @Test func theSwitchWritesItsOwnKeyAndNothingElse() throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let before = bench.defaults.dictionaryRepresentation().filter { $0.key.hasPrefix("sardor.WaterBuddy.") }

        bench.manager.healthEnabled = true

        let after = bench.defaults.dictionaryRepresentation().filter { $0.key.hasPrefix("sardor.WaterBuddy.") }
        #expect(Set(after.keys).subtracting(before.keys) == [DataManager.Key.healthEnabled])
        #expect(bench.defaults.object(forKey: DataManager.Key.healthEnabled) as? Bool == true)
        #expect(Bench.manager(defaults: bench.defaults, container: bench.container).healthEnabled, "a new manager reads it back")

        bench.manager.healthEnabled = false
        #expect(bench.defaults.object(forKey: DataManager.Key.healthEnabled) as? Bool == false)
    }

    @Test func theLogsSinceABoundAreTheRowsFromIt() throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let older = try #require(bench.manager.addLog(amount: 200, at: utc(2026, 10, 27)))
        let middle = try #require(bench.manager.addLog(amount: 250, at: utc(2026, 10, 28)))
        let newest = try #require(bench.manager.addLog(amount: 300))

        let since = try #require(bench.manager.logs(since: utcDay.startOfDay(for: utc(2026, 10, 28))))
        #expect(Set(since.map(\.id)) == [middle, newest])
        #expect(Set(try #require(bench.manager.logs(since: nil)).map(\.id)) == [older, middle, newest])
    }

    /// "Cannot be read" is not "no servings": the mirror deletes what it does not find.
    @Test func aFailedReadIsNothingNotEmpty() throws {
        let store = try UnreadableStore()
        defer { store.remove() }
        let bench = try Bench(container: store.container)
        defer { bench.tearDown() }
        bench.manager.addLog(amount: 250)

        try store.breakReads()
        #expect(!store.stillReads, "the store must be unreadable before anything is asserted about a failed read")

        #expect(bench.manager.logs(since: nil) == nil)
    }

    /// Every way a serving changes ends in `saveAndRecompute()`, and each says so — with this manager as
    /// the object, so a mirror hears only its own.
    @Test func everyWayAServingChangesAnnouncesTheSave() throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let mine = Arrivals()
        let theirs = Arrivals()
        let other = Bench.manager(defaults: bench.defaults, container: bench.container)
        let a = NotificationCenter.default.addObserver(forName: DataManager.logsDidSaveNotification, object: bench.manager, queue: nil) { _ in mine.count += 1 }
        let b = NotificationCenter.default.addObserver(forName: DataManager.logsDidSaveNotification, object: other, queue: nil) { _ in theirs.count += 1 }
        defer {
            NotificationCenter.default.removeObserver(a)
            NotificationCenter.default.removeObserver(b)
        }

        let id = try #require(bench.manager.addLog(amount: 250))
        #expect(mine.count == 1, "addLog")
        let log = try #require(bench.manager.todaysLogs.first { $0.id == id })
        bench.manager.updateLog(log, newAmount: 300)
        #expect(mine.count == 2, "updateLog")
        bench.manager.removeWater(amount: 100)
        #expect(mine.count == 3, "removeWater")
        _ = bench.manager.ingest([WristPour(id: UUID(), amount: 150, at: today())])
        #expect(mine.count == 4, "ingest")
        let second = try #require(bench.manager.addLog(amount: 400))
        bench.manager.undoLog(id: second)
        #expect(mine.count == 6, "addLog, then undoLog")
        bench.manager.resetDailyProgress()
        #expect(mine.count == 7, "resetDailyProgress")
        #expect(theirs.count == 0, "another manager's notification is its own")
    }
}
```

  And in `WaterBuddyTests/DataManagerTests.swift`'s `everyKeyTheProductWritesIsOnTheRoster`, after
  `manager.remindersEnabled = true           // remindersEnabled`, add:

```swift
            manager.healthEnabled = true              // healthEnabled
```

- [ ] **Step 2: Run to verify RED**

  Run the invocation with `-only-testing:WaterBuddyTests/HealthSurfaceTests`.
  Expected: build failure — `type 'DataManager.Key' has no member 'healthEnabled'`, `value of type
  'DataManager' has no member 'logs'`, `… 'logsDidSaveNotification'`.

- [ ] **Step 3: Implement** — in `WaterBuddy/DataManager.swift`:

  After `static let remindersEnabled = prefix + "remindersEnabled"`:

```swift
        /// The Apple Health switch. Absent until the user turns it on — like ``remindersEnabled``,
        /// "missing" and "off" mean the same thing, so nothing materialises it. Read and written by the
        /// app alone: no widget, reminder or watch reads it (spec `2026-10-29-apple-health-design.md`).
        static let healthEnabled = prefix + "healthEnabled"
```

  In `Key.all`, `didMigrateFromStandard, remindersEnabled, language, …` → `didMigrateFromStandard, remindersEnabled, healthEnabled, language, …`.

  After `@ObservationIgnored private var storedRemindersEnabled: Bool`:

```swift
    @ObservationIgnored private var storedHealthEnabled: Bool
```

  In `init`, after `storedRemindersEnabled = defaults.bool(forKey: Key.remindersEnabled)`:

```swift
        storedHealthEnabled = defaults.bool(forKey: Key.healthEnabled)
```

  After the `remindersEnabled` property:

```swift
    /// Whether servings are copied to Apple Health — Settings' *Apple Health* switch (spec
    /// `2026-10-29-apple-health-design.md`). A preference like ``remindersEnabled``, and quieter: it rings
    /// no widget doorbell, re-plans no reminder and reaches no watch, because none of them draws it.
    /// `HealthMirror`, app-only, is the one thing that acts on it, and the one thing that sets it — after
    /// asking Health.
    var healthEnabled: Bool {
        get {
            access(keyPath: \.healthEnabled)
            return storedHealthEnabled
        }
        set {
            guard newValue != storedHealthEnabled else { return }
            withMutation(keyPath: \.healthEnabled) {
                storedHealthEnabled = newValue
                defaults.set(newValue, forKey: Key.healthEnabled)
            }
        }
    }
```

  After `allLogs()`:

```swift
    /// The servings from `start` on — every serving for `nil` — newest first, as ``allLogs()``; and
    /// **`nil` when the store cannot be read**, never `[]`. Apple Health's mirror deletes every sample whose
    /// serving is not among these, so a failed read handed over as nothing would empty Health of the user's
    /// water (rule `20-state`). A read: it publishes nothing and writes neither store.
    func logs(since start: Date?) -> [WaterLog]? {
        guard let start else { return fetch(nil) }
        return fetch(#Predicate<WaterLog> { $0.timestamp >= start })
    }
```

  `private static let appliedLedgerRetentionDays = 90` →

```swift
    /// Apple Health's recent pass reaches back the same span (`HealthPlan.recentDays`): the latest a
    /// watch pour can still arrive and be applied.
    nonisolated static let appliedLedgerRetentionDays = 90
```

  Above `private func saveAndRecompute() -> Bool` (after its DocC, as a sibling declaration before the
  `@discardableResult`), add:

```swift
    /// Posted by ``saveAndRecompute()`` once a change to the rows is saved, with the manager as its
    /// object. App-only `HealthMirror` copies the change to Apple Health; posted in the widget extension
    /// too, where nothing listens.
    nonisolated static let logsDidSaveNotification = Notification.Name("sardor.WaterBuddy.dataManager.logsDidSave")

```

  And in `saveAndRecompute()`, immediately before `return saved`:

```swift
        if saved {
            NotificationCenter.default.post(name: Self.logsDidSaveNotification, object: self)
        }
```

- [ ] **Step 4: Run to verify GREEN** — `HealthSurfaceTests`; then `-only-testing:WaterBuddyTests/DataManagerTests`
  (the roster) and `-only-testing:WaterBuddyTests/WaterSnapshotTests` (`readingLeavesTheStoreUntouched` and
  `readingAnEmptySuiteDoesNotCreateKeys`, which read `Key.all` and so see the new key — rule `30-rollover`).
  Expected: all pass. If `undoLog` posts other than once, read its path before changing the
  test: the expectation `6` is one save for the pour and one for the undo.

- [ ] **Step 5: Stage**

```bash
git add WaterBuddy/DataManager.swift WaterBuddyTests/HealthMirrorTests.swift WaterBuddyTests/DataManagerTests.swift
```

---

### Task 4: `HealthPlan` — what Health should be told

**Files:**
- Create: `WaterBuddy/HealthPlan.swift`
- Create: `WaterBuddyTests/HealthPlanTests.swift`

**Interfaces:**
- Consumes: `DataManager.appliedLedgerRetentionDays`, `DataManager.nextDayBoundary(after:calendar:)`
- Produces: `HealthPlan.Serving(id:amount:at:)`, `HealthPlan.Sample(object:serving:amount:at:version:)`,
  `HealthPlan.Save(serving:version:)`, `HealthPlan.Changes(saves:deletions:)` with `isEmpty`,
  `HealthPlan.Scope` (`.all`, `.recent`, `widened(by:)`, `interval(endingAt:calendar:) -> DateInterval?`),
  `HealthPlan.recentDays`, `HealthPlan.changes(servings:samples:within:) -> Changes`

- [ ] **Step 1: Write the failing tests** — `WaterBuddyTests/HealthPlanTests.swift`:

```swift
//
//  HealthPlanTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 29/10/26.
//

import Foundation
import Testing
@testable import WaterBuddy

private let utcDay: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar
}()

private func at(_ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
    utcDay.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour, minute: minute))!
}

private func serving(_ amount: Int = 250, at instant: Date = at(10, 29)) -> HealthPlan.Serving {
    HealthPlan.Serving(id: UUID(), amount: amount, at: instant)
}

private func sample(
    of serving: HealthPlan.Serving?, amount: Int? = nil, at instant: Date? = nil, version: Int = 1
) -> HealthPlan.Sample {
    HealthPlan.Sample(
        object: UUID(), serving: serving?.id, amount: amount ?? serving?.amount ?? 250,
        at: instant ?? serving?.at ?? at(10, 29), version: version
    )
}

/// Not `@MainActor`, on purpose: a compile-time canary that `HealthPlan` stayed `nonisolated` (rule
/// `43-concurrency`).
struct HealthPlanTests {

    @Test func aServingHealthHasNotSeenIsSavedAtTheFirstVersion() {
        let glass = serving()
        #expect(HealthPlan.changes(servings: [glass], samples: [], within: nil)
                == HealthPlan.Changes(saves: [HealthPlan.Save(serving: glass, version: 1)], deletions: []))
    }

    @Test func aServingHealthAlreadyHasIsLeftAlone() {
        let glass = serving()
        #expect(HealthPlan.changes(servings: [glass], samples: [sample(of: glass, version: 4)], within: nil).isEmpty)
    }

    @Test func aCorrectedAmountIsSavedOneVersionAboveTheSample() {
        let glass = serving(300)
        let changes = HealthPlan.changes(servings: [glass], samples: [sample(of: glass, amount: 250, version: 3)], within: nil)
        #expect(changes == HealthPlan.Changes(saves: [HealthPlan.Save(serving: glass, version: 4)], deletions: []))
    }

    @Test func aMovedServingIsSavedOneVersionAboveTheSample() {
        let glass = serving(at: at(10, 29, 9, 30))
        let changes = HealthPlan.changes(servings: [glass], samples: [sample(of: glass, at: at(10, 29, 12))], within: nil)
        #expect(changes.saves == [HealthPlan.Save(serving: glass, version: 2)])
        #expect(changes.deletions.isEmpty, "a move is a replacement, not a deletion")
    }

    /// Review Focus 1: an instant read back a hair different must not be written again on every pass.
    @Test func anInstantThatComesBackAHairDifferentIsNotWrittenAgain() {
        let glass = serving()
        let drifted = sample(of: glass, at: glass.at.addingTimeInterval(0.000_2))
        #expect(HealthPlan.changes(servings: [glass], samples: [drifted], within: nil).isEmpty)
    }

    @Test func aSampleWhoseServingIsGoneIsDeleted() {
        let gone = sample(of: serving())
        #expect(HealthPlan.changes(servings: [], samples: [gone], within: nil).deletions == [gone.object])
    }

    @Test func aSecondSampleOfOneServingIsDeletedAndTheHighestVersionKept() {
        let glass = serving()
        let older = sample(of: glass, version: 1)
        let newer = sample(of: glass, version: 2)
        let changes = HealthPlan.changes(servings: [glass], samples: [newer, older], within: nil)
        #expect(changes.deletions == [older.object])
        #expect(changes.saves.isEmpty)
    }

    /// Review Focus 4: a sample WaterBuddy did not write is never WaterBuddy's to delete.
    @Test func aSampleWithoutASyncIdentifierIsLeftAlone() {
        #expect(HealthPlan.changes(servings: [], samples: [sample(of: nil)], within: nil).isEmpty)
    }

    @Test func outsideTheIntervalNothingIsSavedOrDeleted() {
        let week = DateInterval(start: at(10, 23, 0), end: at(10, 30, 0))
        let unseen = serving(at: at(10, 1))
        let orphan = sample(of: serving(at: at(10, 2)))
        #expect(HealthPlan.changes(servings: [unseen], samples: [orphan], within: week).isEmpty)
    }

    /// Half-open, as every day bound in the product: the interval's first instant is in, its end is out.
    @Test func theIntervalIncludesItsStartAndExcludesItsEnd() {
        let week = DateInterval(start: at(10, 23, 0), end: at(10, 30, 0))
        let first = serving(at: week.start)
        let past = serving(at: week.end)
        #expect(HealthPlan.changes(servings: [first, past], samples: [], within: week).saves
                == [HealthPlan.Save(serving: first, version: 1)])
    }

    @Test func theRecentScopeReachesBackItsDaysToTomorrowsMidnight() throws {
        let interval = try #require(HealthPlan.Scope.recent.interval(endingAt: at(10, 29, 15), calendar: utcDay))
        #expect(interval.end == at(10, 30, 0))
        #expect(utcDay.dateComponents([.day], from: interval.start, to: at(10, 29, 0)).day == HealthPlan.recentDays - 1)
        #expect(utcDay.component(.hour, from: interval.start) == 0)
    }

    /// Days, not 86,400-second steps: the interval starts at a midnight even across a DST change (rule
    /// `30-rollover`).
    @Test func theRecentScopeCountsDaysAcrossADaylightSavingChange() throws {
        var newYork = Calendar(identifier: .gregorian)
        newYork.timeZone = TimeZone(identifier: "America/New_York")!
        newYork.locale = Locale(identifier: "en_US_POSIX")
        let afterTheChange = newYork.date(from: DateComponents(year: 2026, month: 11, day: 2, hour: 12))!

        let interval = try #require(HealthPlan.Scope.recent.interval(endingAt: afterTheChange, calendar: newYork))
        #expect(newYork.component(.hour, from: interval.start) == 0)
        #expect(newYork.dateComponents([.day], from: interval.start, to: newYork.startOfDay(for: afterTheChange)).day
                == HealthPlan.recentDays - 1)
    }

    @Test func theWholeHistoryHasNoBound() {
        #expect(HealthPlan.Scope.all.interval(endingAt: at(10, 29), calendar: utcDay) == nil)
    }

    @Test func aPassAskedForWhileAnotherWaitsTakesTheWiderReach() {
        #expect(HealthPlan.Scope.recent.widened(by: .all) == .all)
        #expect(HealthPlan.Scope.all.widened(by: .recent) == .all)
        #expect(HealthPlan.Scope.recent.widened(by: .recent) == .recent)
    }
}
```

- [ ] **Step 2: Run to verify RED** — `-only-testing:WaterBuddyTests/HealthPlanTests`. Expected: build
  failure, `cannot find 'HealthPlan' in scope`.

- [ ] **Step 3: Implement** — `WaterBuddy/HealthPlan.swift`:

```swift
//
//  HealthPlan.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 29/10/26.
//

import Foundation

/// What Apple Health should be told, worked out from the log and from what WaterBuddy already wrote there —
/// ``ReminderPlan``'s position for Health (spec `2026-10-29-apple-health-design.md` §3.3).
///
/// **Pure.** Foundation alone, no HealthKit and no clock: ``HealthMirror`` reads the rows and the samples
/// and carries the answer out. App-only, in no exception set; its suite is not `@MainActor`.
///
/// **Health is a copy of the log** (the owner's D6): a serving with no sample is saved; a sample with no
/// serving is deleted; a sample that differs is saved again one version above itself, which HealthKit takes
/// as a replacement because the sync identifier — the serving's id — matches. A sample with no sync
/// identifier is not one WaterBuddy wrote, and is never WaterBuddy's to judge.
nonisolated enum HealthPlan {

    /// A serving as Health needs it.
    nonisolated struct Serving: Sendable, Equatable {
        let id: UUID
        let amount: Int
        let at: Date
    }

    /// A sample WaterBuddy wrote, read back.
    nonisolated struct Sample: Sendable, Equatable {
        /// Health's own id for the sample — what a deletion names.
        let object: UUID
        /// The sync identifier read back as a serving's id; `nil` when the sample carries none.
        let serving: UUID?
        /// Whole millilitres, rounded by the writer on the way in.
        let amount: Int
        let at: Date
        let version: Int
    }

    /// One serving to write, at the version that makes HealthKit keep it.
    nonisolated struct Save: Sendable, Equatable {
        let serving: Serving
        let version: Int
    }

    /// One pass's answer.
    nonisolated struct Changes: Sendable, Equatable {
        var saves: [Save] = []
        var deletions: Set<UUID> = []

        var isEmpty: Bool { saves.isEmpty && deletions.isEmpty }
    }

    /// How far back a pass reaches.
    nonisolated enum Scope: Sendable, Equatable {
        /// Every serving ever logged — when the switch turns on.
        case all
        /// The last ``HealthPlan/recentDays`` days, today among them — every other pass.
        case recent

        /// The wider of the two, for a pass asked for while another waits.
        func widened(by other: Scope) -> Scope {
            self == .all || other == .all ? .all : .recent
        }

        /// The half-open interval a pass reads, `nil` for every day. Days are stepped on the calendar,
        /// never in seconds (rule `30-rollover`). A calendar that cannot step back answers `nil` too: a
        /// wider pass costs time, never a wrong deletion.
        func interval(endingAt now: Date, calendar: Calendar) -> DateInterval? {
            guard self == .recent,
                  let start = calendar.date(
                      byAdding: .day, value: -(HealthPlan.recentDays - 1), to: calendar.startOfDay(for: now))
            else { return nil }
            return DateInterval(start: start, end: DataManager.nextDayBoundary(after: now, calendar: calendar))
        }
    }

    /// The latest a serving can still arrive or change: the span the phone keeps a watch pour's day in its
    /// applied ledger. History's own edits reach only its week, well inside it. By name, so the two cannot
    /// drift.
    static let recentDays = DataManager.appliedLedgerRetentionDays

    /// What Health should be told, from servings and samples read over the same interval — `nil` for every
    /// day. Both sides are cut to that half-open interval here, whatever either read returned around its
    /// edges.
    static func changes(servings: [Serving], samples: [Sample], within interval: DateInterval?) -> Changes {
        func inside(_ instant: Date) -> Bool {
            guard let interval else { return true }
            return interval.start <= instant && instant < interval.end
        }

        var written: [UUID: [Sample]] = [:]
        for sample in samples where inside(sample.at) {
            guard let id = sample.serving else { continue }
            written[id, default: []].append(sample)
        }

        var changes = Changes()
        var seen = Set<UUID>()
        for serving in servings where inside(serving.at) {
            seen.insert(serving.id)
            let copies = (written[serving.id] ?? []).sorted { $0.version > $1.version }
            guard let kept = copies.first else {
                changes.saves.append(Save(serving: serving, version: 1))
                continue
            }
            changes.deletions.formUnion(copies.dropFirst().map(\.object))
            if kept.amount != serving.amount || !sameInstant(kept.at, serving.at) {
                changes.saves.append(Save(serving: serving, version: kept.version + 1))
            }
        }
        for (id, copies) in written where !seen.contains(id) {
            changes.deletions.formUnion(copies.map(\.object))
        }
        return changes
    }

    /// Instants compared to the millisecond: an instant HealthKit hands back a hair different must not be
    /// written again on every pass, its version climbing forever (Task 0's measurement f).
    private static func sameInstant(_ a: Date, _ b: Date) -> Bool {
        (a.timeIntervalSinceReferenceDate * 1_000).rounded() == (b.timeIntervalSinceReferenceDate * 1_000).rounded()
    }
}
```

- [ ] **Step 4: Run to verify GREEN** — `HealthPlanTests`. Expected: 14 pass, and no warning in the build log
  for `HealthPlan.swift` or `HealthPlanTests.swift`.

- [ ] **Step 5: Stage** — `git add WaterBuddy/HealthPlan.swift WaterBuddyTests/HealthPlanTests.swift`

---

### Task 5: `HealthMirror` — the switch, the passes, and Health through `Source`

**Files:**
- Create: `WaterBuddy/HealthMirror.swift`
- Modify: `WaterBuddyTests/HealthMirrorTests.swift` (add `FakeHealth` and `HealthMirrorTests`)

**Interfaces:**
- Consumes: Task 3's `healthEnabled`, `logs(since:)`, `logsDidSaveNotification`; Task 4's `HealthPlan`;
  `ReconcileQueue` (`NotificationManager.swift`: `enqueue(_:)`, `settled()`)
- Produces: `HealthMirror(manager:source:calendar:now:)`, `convenience init(manager:)`; `isAvailable: Bool`;
  `status: HealthMirror.Status` (`.notDetermined`, `.allowed`, `.denied`); `enable() async`, `disable()`,
  `readStatus()`, `reconcile() async`, `request(_:)`, `settled() async`; `HealthMirror.Source(isAvailable:status:requestWrite:samples:save:delete:)`,
  `Source.silent()`, `Source.live()`

- [ ] **Step 1: Write the failing tests** — append to `WaterBuddyTests/HealthMirrorTests.swift`:

```swift
// MARK: - The mirror

/// A Health of its own, in memory: a sample is replaced as HealthKit replaces one — the same sync
/// identifier at a higher version — so a test reads what Health would hold. A box, rule `85-testing`'s
/// `@unchecked Sendable` shape, so the closures it hands the mirror carry no isolation of their own.
nonisolated private final class FakeHealth: @unchecked Sendable {
    var status: HealthMirror.Status = .notDetermined
    /// What the sheet sets when it is shown.
    var answer: HealthMirror.Status = .allowed
    var samples: [HealthPlan.Sample] = []
    var readable = true
    var asked = 0
    var reads = 0
    var writes = 0
    var intervals: [DateInterval?] = []

    var servings: Set<UUID> { Set(samples.compactMap(\.serving)) }

    func sample(of id: UUID) -> HealthPlan.Sample? {
        samples.first { $0.serving == id }
    }

    @MainActor func source() -> HealthMirror.Source {
        HealthMirror.Source(
            isAvailable: { true },
            status: { self.status },
            requestWrite: {
                self.asked += 1
                self.status = self.answer
            },
            samples: { interval in
                self.reads += 1
                self.intervals.append(interval)
                return self.readable ? self.samples : nil
            },
            save: { saves in
                self.writes += 1
                for save in saves {
                    let written = HealthPlan.Sample(
                        object: UUID(), serving: save.serving.id, amount: save.serving.amount,
                        at: save.serving.at, version: save.version)
                    if let index = self.samples.firstIndex(where: { $0.serving == save.serving.id }) {
                        guard save.version > self.samples[index].version else { continue }
                        self.samples[index] = written
                    } else {
                        self.samples.append(written)
                    }
                }
                return true
            },
            delete: { objects in
                self.writes += 1
                self.samples.removeAll { objects.contains($0.object) }
                return true
            }
        )
    }
}

@MainActor
private func makeMirror(on bench: Bench, _ health: FakeHealth) -> HealthMirror {
    HealthMirror(manager: bench.manager, source: health.source(), calendar: utcDay, now: today)
}

@MainActor
struct HealthMirrorTests {

    @Test func turningItOnAsksOnceAndWritesTheWholeHistory() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        let spring = try #require(bench.manager.addLog(amount: 300, at: utc(2026, 3, 1)))
        let yesterday = try #require(bench.manager.addLog(amount: 250, at: utc(2026, 10, 28)))
        let now = try #require(bench.manager.addLog(amount: 500))

        await mirror.enable()
        await mirror.settled()

        #expect(health.asked == 1)
        #expect(bench.manager.healthEnabled)
        #expect(mirror.status == .allowed)
        #expect(health.servings == [spring, yesterday, now], "every serving, the spring's beyond the recent days among them")
        #expect(health.sample(of: spring)?.amount == 300)
    }

    @Test func aRefusalLeavesItOffAndWritesNothing() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        health.answer = .denied
        let mirror = makeMirror(on: bench, health)
        bench.manager.addLog(amount: 250)

        await mirror.enable()
        await mirror.settled()

        #expect(!bench.manager.healthEnabled)
        #expect(mirror.status == .denied)
        #expect(health.samples.isEmpty)
        #expect(health.writes == 0)
    }

    @Test func aRefusalAlreadyGivenIsNotAskedAgain() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        health.status = .denied
        let mirror = makeMirror(on: bench, health)

        await mirror.enable()

        #expect(health.asked == 0, "Health shows its sheet once; asking again shows nothing")
        #expect(!bench.manager.healthEnabled)
    }

    @Test func aPermissionAlreadyGivenIsNotAskedAgain() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        health.status = .allowed
        let mirror = makeMirror(on: bench, health)

        await mirror.enable()

        #expect(health.asked == 0)
        #expect(bench.manager.healthEnabled)
    }

    @Test func aPourWhileItIsOnReachesHealth() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        await mirror.enable()
        await mirror.settled()

        let id = try #require(bench.manager.addLog(amount: 250))
        await mirror.settled()

        #expect(health.sample(of: id)?.amount == 250)
    }

    @Test func aPourWhileItIsOffReachesNothing() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)

        bench.manager.addLog(amount: 250)
        await mirror.settled()

        #expect(health.reads == 0)
        #expect(health.writes == 0)
    }

    @Test func turningItOffWritesNothingMoreAndDeletesNothing() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        let first = try #require(bench.manager.addLog(amount: 250))
        await mirror.enable()
        await mirror.settled()

        mirror.disable()
        bench.manager.addLog(amount: 500)
        bench.manager.deleteLog(try #require(bench.manager.todaysLogs.first { $0.id == first }))
        await mirror.settled()

        #expect(!bench.manager.healthEnabled)
        #expect(health.servings == [first], "what is in Health stays; nothing new arrives")
    }

    @Test func turningItOnAgainCatchesUpWithoutDoubling() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        let first = try #require(bench.manager.addLog(amount: 250))
        await mirror.enable()
        await mirror.settled()
        mirror.disable()
        let second = try #require(bench.manager.addLog(amount: 500))

        await mirror.enable()
        await mirror.settled()

        #expect(health.asked == 1)
        #expect(health.servings == [first, second])
        #expect(health.samples.count == 2, "one sample a serving")
    }

    @Test func anEditAndADeleteFollowIntoHealth() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        await mirror.enable()
        let id = try #require(bench.manager.addLog(amount: 250))
        await mirror.settled()
        let log = try #require(bench.manager.todaysLogs.first { $0.id == id })

        bench.manager.updateLog(log, newAmount: 300)
        await mirror.settled()
        #expect(health.sample(of: id)?.amount == 300)
        #expect(health.sample(of: id)?.version == 2)

        bench.manager.deleteLog(log)
        await mirror.settled()
        #expect(health.sample(of: id) == nil)
    }

    /// D6, the owner's: Health is a copy of the log.
    @Test func aSampleDeletedInHealthComesBackWhileItsServingStands() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        await mirror.enable()
        let id = try #require(bench.manager.addLog(amount: 250))
        await mirror.settled()

        health.samples.removeAll()
        await mirror.reconcile()
        await mirror.settled()

        #expect(health.sample(of: id) != nil)
    }

    /// A failed read of the log is never a log of nothing: the samples already written stay.
    @Test func aFailedReadOfTheLogWritesAndDeletesNothing() async throws {
        let store = try UnreadableStore()
        defer { store.remove() }
        let bench = try Bench(container: store.container)
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        let id = try #require(bench.manager.addLog(amount: 250))
        await mirror.enable()
        await mirror.settled()
        let writes = health.writes

        try store.breakReads()
        #expect(!store.stillReads, "the store must be unreadable before anything is asserted about a failed read")
        mirror.request(.recent)
        await mirror.settled()

        #expect(health.writes == writes)
        #expect(health.sample(of: id) != nil)
    }

    /// A locked phone: Health cannot be read, so nothing is written until a later pass can.
    @Test func aFailedReadOfHealthWritesNothing() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        health.status = .allowed
        health.readable = false
        let mirror = makeMirror(on: bench, health)
        bench.manager.addLog(amount: 250)

        await mirror.enable()
        await mirror.settled()

        #expect(bench.manager.healthEnabled)
        #expect(health.writes == 0)
    }

    /// Review Focus 3: the switch turned off between the pass's two reads.
    @Test func turningItOffMidPassWritesNothing() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        health.status = .allowed
        var source = health.source()
        let read = source.samples
        let manager = bench.manager
        // `@MainActor` stated: it turns the switch off, which only the main actor may.
        source.samples = { @MainActor interval in
            manager.healthEnabled = false
            return await read(interval)
        }
        let mirror = HealthMirror(manager: bench.manager, source: source, calendar: utcDay, now: today)
        bench.manager.addLog(amount: 250)

        await mirror.enable()
        await mirror.settled()

        #expect(health.reads == 1)
        #expect(health.writes == 0)
    }

    @Test func comingForwardTurnsItOffWhenHealthSaysNo() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        await mirror.enable()
        await mirror.settled()

        health.status = .denied
        await mirror.reconcile()

        #expect(!bench.manager.healthEnabled)
        #expect(mirror.status == .denied)
    }

    /// Review Focus 2, and the widget's button: another manager's save is not this mirror's to hear, and
    /// the app coming forward catches it up.
    @Test func comingForwardWritesWhatAnotherProcessLogged() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        await mirror.enable()
        await mirror.settled()
        let widget = Bench.manager(defaults: bench.defaults, container: bench.container)

        let id = try #require(widget.addLog(amount: 250))
        await mirror.settled()
        #expect(health.sample(of: id) == nil, "the widget's save is the widget's")

        await mirror.reconcile()
        await mirror.settled()
        #expect(health.sample(of: id) != nil)
    }

    @Test func passesAskedForWhileOneWaitsBecomeOneOfTheWiderReach() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        await mirror.enable()
        await mirror.settled()
        health.reads = 0
        health.intervals = []

        mirror.request(.recent)
        mirror.request(.recent)
        mirror.request(.all)
        await mirror.settled()

        #expect(health.reads == 1)
        #expect(health.intervals == [nil], "widened to the whole history")
    }

    @Test func theRecentPassReadsTheRecentDays() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let health = FakeHealth()
        let mirror = makeMirror(on: bench, health)
        await mirror.enable()
        await mirror.settled()
        health.intervals = []

        mirror.request(.recent)
        await mirror.settled()

        #expect(health.intervals == [HealthPlan.Scope.recent.interval(endingAt: today(), calendar: utcDay)])
    }
}
```

- [ ] **Step 2: Run to verify RED** — `-only-testing:WaterBuddyTests/HealthMirrorTests`. Expected: build
  failure, `cannot find 'HealthMirror' in scope`.

- [ ] **Step 3: Implement** — `WaterBuddy/HealthMirror.swift`:

```swift
//
//  HealthMirror.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 29/10/26.
//

import Foundation
import HealthKit
import Observation

/// Keeps a copy of the log in Apple Health — the one file that imports HealthKit (rule `70-privacy`, spec
/// `2026-10-29-apple-health-design.md`).
///
/// **Write only, Water only.** It asks Health to write Water and to read nothing; the only samples it
/// reads back are its own, which a write permission allows. No figure WaterBuddy draws comes from Health.
///
/// **Reconciled, never streamed** — `NotificationManager`'s shape. ``HealthPlan`` decides from the rows and
/// the samples WaterBuddy already wrote; this carries the answer out, one pass at a time on one
/// ``ReconcileQueue``. A pass asks for both reads before it writes anything, so a locked phone or a failed
/// read leaves Health as it was until the next pass — the app coming forward, or any later save.
///
/// **Health through ``Source`` only**, a struct of closures built by ``Source/live()`` — `PremiumStore`'s
/// and `InsightWriter`'s shape — so every decision here is tested without HealthKit (rule `85-testing`).
/// App-only, built once by `WaterBuddyApp.init()`; the widget and the watch never compile it.
@MainActor
@Observable
final class HealthMirror {

    /// What Health says of WaterBuddy's permission to write Water.
    nonisolated enum Status: Sendable, Equatable {
        case notDetermined, allowed, denied
    }

    /// Every way Health is reached. Main-actor, as `InsightWriter.Source` is: only the mirror calls these.
    struct Source {
        var isAvailable: () -> Bool
        var status: () -> Status
        /// Shows Health's sheet — write Water, read nothing — and returns once it is answered. Health's
        /// request succeeds whether or not Water was allowed, so the mirror reads ``status`` after it.
        var requestWrite: () async -> Void
        /// WaterBuddy's own Water samples around `interval` — every one for `nil` — or `nil` when Health
        /// cannot be read.
        var samples: (_ interval: DateInterval?) async -> [HealthPlan.Sample]?
        var save: (_ saves: [HealthPlan.Save]) async -> Bool
        var delete: (_ objects: Set<UUID>) async -> Bool
    }

    /// Whether this device has Health at all. Every iPhone does; Settings draws no card where it does not.
    let isAvailable: Bool

    /// What Health last said — read when the switch is tapped and whenever the app or Settings comes
    /// forward. Settings draws its refusal line from it.
    private(set) var status: Status

    @ObservationIgnored private let manager: DataManager
    @ObservationIgnored private let source: Source
    @ObservationIgnored private let calendar: Calendar
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private let passes = ReconcileQueue()
    /// The pass waiting its turn, if one is: a request while it waits widens it rather than queueing a
    /// second.
    @ObservationIgnored private var waiting: HealthPlan.Scope?
    @ObservationIgnored private var saveObserver: NSObjectProtocol?

    init(manager: DataManager, source: Source, calendar: Calendar = .waterBuddyDay, now: @escaping () -> Date = Date.init) {
        self.manager = manager
        self.source = source
        self.calendar = calendar
        self.now = now
        isAvailable = source.isAvailable()
        status = source.status()
        // This manager's saves only — not another process's, not a test's beside this one.
        saveObserver = NotificationCenter.default.addObserver(
            forName: DataManager.logsDidSaveNotification, object: manager, queue: .main
        ) { [weak self] _ in
            // `queue: .main` is the main thread, so the main actor — `WristInbox`'s reasoning.
            MainActor.assumeIsolated {
                self?.request(.recent)
            }
        }
    }

    convenience init(manager: DataManager) {
        self.init(manager: manager, source: .live())
    }

    deinit {
        if let saveObserver {
            NotificationCenter.default.removeObserver(saveObserver)
        }
    }

    /// The switch turning on — the one place Health's sheet is asked for (rule `70-privacy`), and only while
    /// Health has not been asked, since it shows its sheet once. Allowed, it writes the whole history.
    func enable() async {
        if source.status() == .notDetermined {
            await source.requestWrite()
        }
        status = source.status()
        manager.healthEnabled = status == .allowed
        request(.all)
    }

    /// The switch turning off: nothing more is written, and nothing is deleted (D4).
    func disable() {
        manager.healthEnabled = false
    }

    /// What Health says now — for Settings coming forward.
    func readStatus() {
        status = source.status()
    }

    /// The app coming forward: the permission read again — withdrawn in Health, the switch goes off — and
    /// a pass over the recent days, for what was logged where this process could not write: the widget's
    /// button, Control Center, a locked phone.
    func reconcile() async {
        readStatus()
        if status == .denied, manager.healthEnabled {
            manager.healthEnabled = false
        }
        request(.recent)
    }

    /// Asks for a pass while the switch is on. A pass already waiting takes the wider reach instead of a
    /// second joining the queue.
    func request(_ scope: HealthPlan.Scope) {
        guard manager.healthEnabled else { return }
        if let waiting {
            self.waiting = waiting.widened(by: scope)
            return
        }
        waiting = scope
        passes.enqueue { [weak self] in
            await self?.runWaitingPass()
        }
    }

    /// Returns once every pass asked for before it has run.
    func settled() async {
        await passes.settled()
    }

    private func runWaitingPass() async {
        guard let scope = waiting else { return }
        waiting = nil
        await pass(scope)
    }

    /// One pass: the log read first, then Health — and nothing written unless both answered, and only while
    /// the switch is still on after the wait (spec §3.5).
    private func pass(_ scope: HealthPlan.Scope) async {
        guard manager.healthEnabled else { return }
        let interval = scope.interval(endingAt: now(), calendar: calendar)
        guard let rows = manager.logs(since: interval?.start) else { return }
        let servings = rows.map { HealthPlan.Serving(id: $0.id, amount: $0.amount, at: $0.timestamp) }
        guard let samples = await source.samples(interval), manager.healthEnabled else { return }

        let changes = HealthPlan.changes(servings: servings, samples: samples, within: interval)
        if !changes.deletions.isEmpty, !(await source.delete(changes.deletions)) {
            #if DEBUG
            // Names the condition, never a sample (rule `75-diagnostics`).
            print("[WaterBuddy] Could not delete from Apple Health; the next pass tries again.")
            #endif
        }
        if !changes.saves.isEmpty, !(await source.save(changes.saves)) {
            #if DEBUG
            print("[WaterBuddy] Could not save to Apple Health; the next pass tries again.")
            #endif
        }
    }
}

extension HealthMirror.Source {

    /// A device with Health that was never asked, and writes nowhere — for a `#Preview`, the DEBUG fresh
    /// start and the UI tests' captures.
    static func silent() -> Self {
        Self(
            isAvailable: { true },
            status: { .notDetermined },
            requestWrite: {},
            samples: { _ in [] },
            save: { _ in true },
            delete: { _ in true }
        )
    }

    /// Health itself. Water in millilitres, start and end at the serving's instant, the serving's id as the
    /// sync identifier: HealthKit replaces a sample whose identifier matches and whose version is lower.
    /// The `Double`s are HealthKit's: each is made from an `Int` and rounded back to one (rule
    /// `00-workspace`).
    static func live() -> Self {
        let store = HKHealthStore()
        let water = HKQuantityType(.dietaryWater)
        let millilitres = HKUnit.literUnit(with: .milli)
        return Self(
            isAvailable: { HKHealthStore.isHealthDataAvailable() },
            status: {
                switch store.authorizationStatus(for: water) {
                case .sharingAuthorized: .allowed
                case .sharingDenied: .denied
                default: .notDetermined
                }
            },
            requestWrite: {
                // Write Water, read nothing (rule `70-privacy`). A sheet that could not be shown leaves the
                // status as it was, which is what the mirror reads next.
                try? await store.requestAuthorization(toShare: [water], read: [])
            },
            samples: { interval in
                var predicates = [HKQuery.predicateForObjects(from: HKSource.default())]
                if let interval {
                    // Loose at the edges: `HealthPlan.changes` cuts both sides to the same half-open interval.
                    predicates.append(HKQuery.predicateForSamples(withStart: interval.start, end: interval.end))
                }
                let query = HKSampleQueryDescriptor(
                    predicates: [.quantitySample(type: water, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates))],
                    sortDescriptors: []
                )
                guard let found = try? await query.result(for: store) else { return nil }
                return found.map { sample in
                    HealthPlan.Sample(
                        object: sample.uuid,
                        serving: (sample.metadata?[HKMetadataKeySyncIdentifier] as? String).flatMap(UUID.init(uuidString:)),
                        amount: Int(sample.quantity.doubleValue(for: millilitres).rounded()),
                        at: sample.startDate,
                        version: (sample.metadata?[HKMetadataKeySyncVersion] as? NSNumber)?.intValue ?? 0
                    )
                }
            },
            save: { saves in
                let samples = saves.map { save in
                    HKQuantitySample(
                        type: water,
                        quantity: HKQuantity(unit: millilitres, doubleValue: Double(save.serving.amount)),
                        start: save.serving.at,
                        end: save.serving.at,
                        metadata: [
                            HKMetadataKeySyncIdentifier: save.serving.id.uuidString,
                            HKMetadataKeySyncVersion: save.version,
                            HKMetadataKeyWasUserEntered: true,
                        ]
                    )
                }
                do {
                    try await store.save(samples)
                    return true
                } catch {
                    return false
                }
            },
            delete: { objects in
                do {
                    _ = try await store.deleteObjects(of: water, predicate: HKQuery.predicateForObjects(with: objects))
                    return true
                } catch {
                    return false
                }
            }
        )
    }
}
```

- [ ] **Step 4: Run to verify GREEN** — `HealthMirrorTests`, then `HealthSurfaceTests` again. Expected: all
  pass. **Read the build log for `HealthMirror.swift`**: a warning that `HKHealthStore` is not `Sendable`
  (spec §6, e) is fixed by building the store inside each closure that uses it — `let store = HKHealthStore()`
  as each closure's first line, the shared one removed — never by an annotation. Any other new warning is a
  failure: fix it before staging.

- [ ] **Step 5: Stage** — `git add WaterBuddy/HealthMirror.swift WaterBuddyTests/HealthMirrorTests.swift`

---

### Task 6: The entitlement, the usage key and its catalogue

**Files:**
- Modify: `Entitlements/WaterBuddy.entitlements`
- Modify: `WaterBuddy.xcodeproj/project.pbxproj` (the app target's two configurations)
- Create: `WaterBuddy/InfoPlist.xcstrings`
- Modify: `WaterBuddyTests/LocalizationTests.swift`

- [ ] **Step 1: Write the failing tests** — in `LocalizationTests.swift`, before `/// ``Bundle/figure(_:_:locale:)``` (the
  `GroupedFigureTests` heading), add:

```swift
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
```

- [ ] **Step 2: Run to verify RED** — `-only-testing:WaterBuddyTests/HealthPurposeTests`. Expected: FAIL —
  the Info.plist has no `NSHealthUpdateUsageDescription`, and each language's table falls back to the key.

- [ ] **Step 3: Implement.** `Entitlements/WaterBuddy.entitlements`, inside `<dict>` after the App Group's
  `</array>`:

```xml
	<key>com.apple.developer.healthkit</key>
	<true/>
```

  `WaterBuddy.xcodeproj/project.pbxproj` — in the app target's Debug (`9947C23D3046293F00972CEA`) and its
  Release configuration (the one with `CODE_SIGN_ENTITLEMENTS = Entitlements/WaterBuddy.entitlements;` and
  `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO;`), after that `ITSAppUsesNonExemptEncryption` line:

```
				INFOPLIST_KEY_NSHealthUpdateUsageDescription = "WaterBuddy saves each serving you log to Apple Health as water. It reads nothing from Health.";
```

  `WaterBuddy/InfoPlist.xcstrings` (joins the app through its synchronized folder, no project edit):

```json
{
  "sourceLanguage" : "en",
  "strings" : {
    "NSHealthUpdateUsageDescription" : {
      "extractionState" : "manual",
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "WaterBuddy saves each serving you log to Apple Health as water. It reads nothing from Health."
          }
        },
        "ru" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "WaterBuddy сохраняет каждую порцию в «Здоровье» как воду. Из «Здоровья» приложение ничего не читает."
          }
        },
        "uz" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "WaterBuddy har bir porsiyani Apple Health ilovasiga suv sifatida saqlaydi. Health ilovasidan hech narsa o‘qimaydi."
          }
        }
      }
    }
  },
  "version" : "1.0"
}
```

- [ ] **Step 4: Run to verify GREEN** — `HealthPurposeTests`. Expected: pass. Then `git diff
  WaterBuddy/InfoPlist.xcstrings`: if the build extracted Info.plist keys of its own (`CFBundleDisplayName`
  and the like), keep them as extracted — they draw nothing new — and say so in the task's record.
  Then prove the entitlement reached the built app (rule `25-shared-storage`: a missing one degrades
  silently):

```bash
APP=$(xcodebuild -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -showBuildSettings 2>/dev/null | awk -F' = ' '/ CODESIGNING_FOLDER_PATH /{print $2; exit}')
codesign -d --entitlements - "$APP" 2>&1 | grep -E 'healthkit|application-groups'
shasum Entitlements/*.entitlements
```

  Expected: both entitlements printed; the three other entitlement files share one hash, the app's differs.

- [ ] **Step 5: Stage** — `git add Entitlements/WaterBuddy.entitlements WaterBuddy.xcodeproj/project.pbxproj WaterBuddy/InfoPlist.xcstrings WaterBuddyTests/LocalizationTests.swift`

---

### Task 7: The app's wiring, Settings' *Apple Health* card and its words

**Files:**
- Modify: `WaterBuddy/WaterBuddyApp.swift`, `WaterBuddy/SettingsView.swift`, `WaterBuddy/RootTabView.swift`
- Modify: `WaterBuddy/Localizable.xcstrings`
- Modify: `WaterBuddyTests/LocalizationTests.swift`, `WaterBuddyUITests/GoalSetupUITests.swift`

**Interfaces — consumes:** Task 5's `HealthMirror` (`isAvailable`, `status`, `enable()`, `disable()`,
`readStatus()`, `reconcile()`, `Source.silent()`, `init(manager:)`).

- [ ] **Step 1: Write the failing tests.** `LocalizationTests.swift`, after `premiumKeys`:

```swift
/// Settings' *Apple Health* card (spec `2026-10-29-apple-health-design.md` §6).
private let healthKeys = [
    "Apple Health",
    "Saves each serving to Apple Health as water. WaterBuddy reads nothing from Health.",
    "Health access is off for WaterBuddy. Turn it on in Settings › Privacy & Security › Health › WaterBuddy.",
]
```

  and after `PremiumStringTests`:

```swift
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
```

  `GoalSetupUITests.swift`, in `testEverySettingsControlIsOneElement`, after the *Smart reminders* assertion:

```swift
        XCTAssertEqual(app.switches.matching(identifier: "Apple Health").count, 1, "the Apple Health switch is not one element")
```

- [ ] **Step 2: Run to verify RED** — `-only-testing:WaterBuddyTests/HealthStringTests` (FAIL: no value for
  the three keys) and, as its own invocation,
  `-only-testing:WaterBuddyUITests/GoalSetupUITests/testEverySettingsControlIsOneElement` (FAIL: `0` is not
  equal to `1`).

- [ ] **Step 3: Implement the strings** — in `WaterBuddy/Localizable.xcstrings`, each entry in its
  alphabetical place among the keys (the file's own `"key": {` spelling and two-space indent):

```json
    "Apple Health": {
      "extractionState": "manual",
      "localizations": {
        "en": { "stringUnit": { "state": "translated", "value": "Apple Health" } },
        "ru": { "stringUnit": { "state": "translated", "value": "Apple Здоровье" } },
        "uz": { "stringUnit": { "state": "translated", "value": "Apple Health" } }
      }
    },
    "Health access is off for WaterBuddy. Turn it on in Settings › Privacy & Security › Health › WaterBuddy.": {
      "extractionState": "manual",
      "localizations": {
        "en": { "stringUnit": { "state": "translated", "value": "Health access is off for WaterBuddy. Turn it on in Settings › Privacy & Security › Health › WaterBuddy." } },
        "ru": { "stringUnit": { "state": "translated", "value": "Доступ к «Здоровью» для WaterBuddy выключен. Включите его в Настройках › Конфиденциальность и безопасность › Здоровье › WaterBuddy." } },
        "uz": { "stringUnit": { "state": "translated", "value": "WaterBuddy uchun Health ruxsati o‘chiq. Uni Sozlamalar › Maxfiylik va xavfsizlik › Health › WaterBuddy bo‘limida yoqing." } }
      }
    },
    "Saves each serving to Apple Health as water. WaterBuddy reads nothing from Health.": {
      "extractionState": "manual",
      "localizations": {
        "en": { "stringUnit": { "state": "translated", "value": "Saves each serving to Apple Health as water. WaterBuddy reads nothing from Health." } },
        "ru": { "stringUnit": { "state": "translated", "value": "Каждая порция сохраняется в «Здоровье» как вода. WaterBuddy ничего не читает из «Здоровья»." } },
        "uz": { "stringUnit": { "state": "translated", "value": "Har bir porsiya Apple Health ilovasiga suv sifatida saqlanadi. WaterBuddy Health ilovasidan hech narsa o‘qimaydi." } }
      }
    },
```

  (Written expanded, one `stringUnit` per line, as the file's neighbours are — the compact form above is for
  reading. If Task 0 (d) measured another path, the refusal key and its three values take that path.)

- [ ] **Step 4: Implement the wiring** — `WaterBuddy/WaterBuddyApp.swift`. After `private let writer: InsightWriter`:

```swift
    /// Apple Health's copy of the log — written only while the user's switch is on, and only by this
    /// process (``HealthMirror``). It never reads what another app wrote.
    private let health: HealthMirror
```

  In the DEBUG fresh start's branch, after `manager = fresh` and before its `return`:

```swift
            // A fresh start reaches no Health: the switch draws, and nothing is ever written.
            health = HealthMirror(manager: fresh, source: .silent())
```

  After `manager = DataManager.shared`:

```swift
        // After the manager, whose saves it hears; before anything draws, so the first save is heard.
        health = HealthMirror(manager: manager)
```

  In `body`, after `.environment(writer)`: `.environment(health)`. In the `scenePhase` handler, after the
  reminders' `Task`:

```swift
                // And Health: a permission withdrawn while the app was away turns the switch off, and a
                // pass catches up what the widget's button, the control or a locked phone logged.
                Task { await health.reconcile() }
```

- [ ] **Step 5: Implement the card** — `WaterBuddy/SettingsView.swift`. After `@Environment(PremiumStore.self) private var premium`:

```swift
    @Environment(HealthMirror.self) private var health
```

  In `body`'s stack, replace

```swift
                    remindersCard.arrives(arrived, order: lead + 2).scrollDepth()
                    LanguageCard().arrives(arrived, order: lead + 3).scrollDepth()
                    privacyPolicyLink.arrives(arrived, order: lead + 4).scrollDepth()
```

  with

```swift
                    remindersCard.arrives(arrived, order: lead + 2).scrollDepth()
                    // Under reminders: both are about what happens between pours, and both ask iOS first.
                    healthCard.arrives(arrived, order: lead + 3).scrollDepth()
                    LanguageCard().arrives(arrived, order: lead + 4).scrollDepth()
                    privacyPolicyLink.arrives(arrived, order: lead + 5).scrollDepth()
```

  and after `.animation(Motion.settle, value: explanation)` add
  `.animation(Motion.settle, value: healthExplanation)`.
  In `readSystemState()`, first line: `health.readStatus()`.
  After `openSettingsRow`, add:

```swift
    // MARK: - Apple Health

    /// The *Smart reminders* row's twin: the switch's label is the card's title, drawn and spoken, and the
    /// line under it is the switch's hint (spec `2026-10-29-apple-health-design.md` §6). Drawn only where
    /// the device has Health.
    @ViewBuilder
    private var healthCard: some View {
        if health.isAvailable {
            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: healthBinding) {
                    Text("Apple Health", bundle: strings)
                        .cardTitle()
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
                .toggleStyle(SwitchToggleStyle(tint: Aurora.cyan))
                .frame(minHeight: 44)
                // On the `Toggle` itself, as the reminders row's are (rule `65-accessibility`).
                .accessibilityLabel(Text("Apple Health", bundle: strings))
                .accessibilityHint(Text("Saves each serving to Apple Health as water. WaterBuddy reads nothing from Health.", bundle: strings))

                Text(healthExplanation)
                    .cardNote()
            }
            .settingsCard()
        }
    }

    /// One call each way into the mirror (rule `50-views`): on asks Health, off only stops the writing.
    private var healthBinding: Binding<Bool> {
        Binding(
            get: { manager.healthEnabled },
            set: { wantsHealth in
                guard wantsHealth else {
                    health.disable()
                    return
                }
                enables += 1
                Task { await health.enable() }
            }
        )
    }

    private var healthExplanation: String {
        if health.status == .denied {
            return strings.localizedString(forKey: "Health access is off for WaterBuddy. Turn it on in Settings › Privacy & Security › Health › WaterBuddy.", value: nil, table: nil)
        }
        return strings.localizedString(forKey: "Saves each serving to Apple Health as water. WaterBuddy reads nothing from Health.", value: nil, table: nil)
    }
```

  `SettingsView`'s `#Preview`: `.environment(PremiumStore(source: .silent()))` →
  `.environment(PremiumStore(source: .silent())).environment(HealthMirror(manager: manager, source: .silent()))`.
  `RootTabView`'s `#Preview`, after `.environment(InsightWriter(source: .silent()))`:

```swift
        // Settings reads it; a canvas never reaches Health.
        .environment(HealthMirror(manager: manager, source: .silent()))
```

- [ ] **Step 6: Run to verify GREEN** — `HealthStringTests`; `LocalizationTests` whole (the drawn-string
  check sees the three new keys translated); then the UI test of Step 2. Expected: all pass.

- [ ] **Step 7: Stage** — `git add WaterBuddy/WaterBuddyApp.swift WaterBuddy/SettingsView.swift WaterBuddy/RootTabView.swift WaterBuddy/Localizable.xcstrings WaterBuddyTests/LocalizationTests.swift WaterBuddyUITests/GoalSetupUITests.swift`

---

### Task 8: The privacy policy — both forms, shipped with Health

**Files:** `PRIVACY.md`, `Tools/PrivacyPolicy.html` — changed together, as each says of the other. They are
published with the release that carries Health, never before it (spec §3.10).

- [ ] **Step 1: The frameworks.** `PRIVACY.md`: in *Why we can say …*, replace
  `… UIKit, Core Graphics, **StoreKit** and **FoundationModels**. Two of them deserve a sentence each:` with
  `… UIKit, Core Graphics, **StoreKit**, **FoundationModels** and **HealthKit**. Three of them deserve a sentence each:`,
  and after the **FoundationModels** bullet add:

```
- **HealthKit** is Apple Health's own framework. WaterBuddy uses it only if you turn on *Apple Health* in Settings, to write your servings there — and it reads nothing from Health. See *Apple Health, if you turn it on* below.
```

  `Tools/PrivacyPolicy.html`, the same two changes in its `<p>` and `<ul>`:
  `<strong>StoreKit</strong> and <strong>FoundationModels</strong>. Two of them deserve a sentence each:` →
  `<strong>StoreKit</strong>, <strong>FoundationModels</strong> and <strong>HealthKit</strong>. Three of them deserve a sentence each:`,
  and after the FoundationModels `<li>`:

```html
  <li><strong>HealthKit</strong> is Apple Health’s own framework. WaterBuddy uses it only if you turn on <em>Apple Health</em> in Settings, to write your servings there — and it reads nothing from Health. See <a href="#health">Apple Health, if you turn it on</a> below.</li>
```

- [ ] **Step 2: The complete list.** Both forms: `no location, no health record, no contacts` →
  `no location, no health record of its own, no contacts`, and after that paragraph add — `PRIVACY.md`:

```
**Copied to Apple Health, only if you turn it on:** each serving's amount and moment, as Water. See *Apple Health, if you turn it on* below.
```

  `Tools/PrivacyPolicy.html`:

```html
<p><strong>Copied to Apple Health, only if you turn it on:</strong> each serving’s amount and moment, as Water. See <a href="#health">Apple Health, if you turn it on</a> below.</p>
```

- [ ] **Step 3: The section.** After *6. Links you tap* — `PRIVACY.md`:

```
### 7. Apple Health, if you turn it on

*Apple Health* in Settings is **off until you turn it on**. When you do, iOS asks whether WaterBuddy may write **Water** to Health — and WaterBuddy asks to read nothing.

- **What is written:** each serving you log — its amount in millilitres and the moment you logged it — as a Water entry, with the serving's random identifier, so that correcting or deleting the serving in WaterBuddy corrects or deletes its entry in Health. Nothing else: no goal, no streak, no name, no language.
- **Everything you have logged is written once** when you turn it on, and each new serving after that — whichever way you log it. A serving logged from a widget or Control Center reaches Health the next time WaterBuddy opens.
- **Nothing is read.** WaterBuddy reads back only the entries it wrote itself, to keep them in step. Water other apps write to Health is never read, and no figure WaterBuddy shows comes from Health.
- **Health is Apple's.** Health keeps its data on your iPhone, encrypted, and syncs it through iCloud only if you have turned that on in Health — under Apple's terms, not ours. Nothing is sent to us.
- **Turning it off** stops the writing. It deletes nothing: what is in Health is yours, and the Health app can delete it — open your profile, then *Apps*, then *WaterBuddy*. Deleting WaterBuddy leaves it in Health too.
```

  `Tools/PrivacyPolicy.html`, after the *6. Links you tap* `<p>`:

```html
<h3 id="health">7. Apple Health, if you turn it on</h3>
<p><em>Apple Health</em> in Settings is <strong>off until you turn it on</strong>. When you do, iOS asks whether WaterBuddy may write <strong>Water</strong> to Health — and WaterBuddy asks to read nothing.</p>
<ul>
  <li><strong>What is written:</strong> each serving you log — its amount in millilitres and the moment you logged it — as a Water entry, with the serving’s random identifier, so that correcting or deleting the serving in WaterBuddy corrects or deletes its entry in Health. Nothing else: no goal, no streak, no name, no language.</li>
  <li><strong>Everything you have logged is written once</strong> when you turn it on, and each new serving after that — whichever way you log it. A serving logged from a widget or Control Center reaches Health the next time WaterBuddy opens.</li>
  <li><strong>Nothing is read.</strong> WaterBuddy reads back only the entries it wrote itself, to keep them in step. Water other apps write to Health is never read, and no figure WaterBuddy shows comes from Health.</li>
  <li><strong>Health is Apple’s.</strong> Health keeps its data on your iPhone, encrypted, and syncs it through iCloud only if you have turned that on in Health — under Apple’s terms, not ours. Nothing is sent to us.</li>
  <li><strong>Turning it off</strong> stops the writing. It deletes nothing: what is in Health is yours, and the Health app can delete it — open your profile, then <em>Apps</em>, then <em>WaterBuddy</em>. Deleting WaterBuddy leaves it in Health too.</li>
</ul>
```

  The Health app's path is Task 0 (d)'s, and *Deleting WaterBuddy leaves it in Health* is Task 9's walk —
  either measured otherwise changes these words before staging.

- [ ] **Step 4: The dates.** Both forms: *Last updated* (the header's, and the HTML's band and footer) → the
  day this task is done. *Effective* stays.

- [ ] **Step 5: Check** — `python3 -I` with `html.parser` over `Tools/PrivacyPolicy.html`: no unclosed or
  mismatched tag (the script the support page used, `docs/AI_CONTEXT.md` 2026-10-29); and `grep -c 'HealthKit'
  PRIVACY.md Tools/PrivacyPolicy.html` — at least 2 each.

- [ ] **Step 6: Stage** — `git add PRIVACY.md Tools/PrivacyPolicy.html`

---

### Task 9: The gate, the walk, the review, the records

- [ ] **Step 1: The gate** — rule `85-testing`'s five invocations, then the UI invocation again on
  `OS=26.5`, one simulator, `xcrun simctl shutdown all` first. Expected: every test passes but the one
  skipped (#157), both widget schemes build. Record the counts from the run.

- [ ] **Step 2: Warnings** — a clean build of a copy of the index and a clean build of a `main` export, each
  into an empty DerivedData, compared by file and message, primary `file:line:col: warning:` lines only
  (`tasks/lessons.md`):

```bash
SCRATCH="/private/tmp/claude-501/-Users-sardorallaberganov-Desktop-Projects-MobileApps-Games-WaterBuddy/545ffb2a-aa3a-4172-9213-465467d7b6b5/scratchpad"
rm -rf "$SCRATCH/w-main" "$SCRATCH/w-index" && mkdir -p "$SCRATCH/w-main" "$SCRATCH/w-index"
git archive main | tar -x -C "$SCRATCH/w-main"
git checkout-index -a --prefix="$SCRATCH/w-index/"
for side in main index; do
  for scheme in WaterBuddy WaterBuddyWidgetExtension WaterBuddyWatch WaterBuddyWatchWidget; do
    case $scheme in WaterBuddyWatch*) dest='platform=watchOS Simulator,OS=27.0,name=Apple Watch Series 12 (46mm)';; *) dest='platform=iOS Simulator,OS=27.0,name=iPhone 17';; esac
    (cd "$SCRATCH/w-$side" && xcodebuild build -project WaterBuddy.xcodeproj -scheme $scheme -destination "$dest" -derivedDataPath "$SCRATCH/dd-$side-$scheme" 2>&1) \
      | grep -E '^/.*:[0-9]+:[0-9]+: warning:' | sed -E 's#^.*/(w-(main|index))/##; s/:[0-9]+:[0-9]+: / /' | sort -u > "$SCRATCH/warn-$side-$scheme.txt"
  done
done
for scheme in WaterBuddy WaterBuddyWidgetExtension WaterBuddyWatch WaterBuddyWatchWidget; do
  echo "== $scheme"; diff "$SCRATCH/warn-main-$scheme.txt" "$SCRATCH/warn-index-$scheme.txt" && echo "unchanged ($(wc -l < "$SCRATCH/warn-index-$scheme.txt"))"
done
```

  Expected: `unchanged` on all four (20, 17, 2, 17 by message). Any new line is fixed before Step 3.

- [ ] **Step 3: The walk, by hand** — the spec's §4 list on iOS 27.0, then 26.5 and 18.6: Health's sheet asks
  to write Water and to read nothing; allowed, the Health app's Water shows every serving with WaterBuddy as
  its source; a pour on Home appears; an edit in History moves it; a delete and an *Undo* remove it; a widget
  pour appears once the app comes forward; off, a pour adds nothing; on again, caught up with nothing
  doubled; a refusal on a fresh install shows the refusal line; withdrawn in Health, the switch reads off on
  return; VoiceOver on the card; and **delete WaterBuddy, then open Health: are its entries still there?** —
  Task 8's sentence follows what is seen. Measure the `.recent` pass on a lived-in store (the spec §3.4: if
  its row read is over 6 ms, the save-triggered pass narrows to History's week). What a device alone shows —
  a reminder's *Log a Glass* on a locked iPhone, a watch pour — joins 1.2.7's sweep as a new known issue.

- [ ] **Step 4: Review your own diff against the rules** — `git diff --cached` read file by file against the
  Global Constraints and rule `70-privacy`'s new section; `grep -rn 'import HealthKit' WaterBuddy WaterBuddyWidget WaterBuddyWatch WaterBuddyWatchWidget`
  → `WaterBuddy/HealthMirror.swift` alone; `grep -n 'HealthPlan\|HealthMirror' WaterBuddy/DataManager.swift`
  → only the two DocC mentions.

- [ ] **Step 5: Records** — a `HISTORY.md` checkpoint (what changed, the rulings, the files, the gate as run,
  the warnings, the walk) and its staging block last; then the owner's `/doc_sync` — `CLAUDE.md`'s storage
  table (twelve keys), `docs/STATE.md` (`Key.healthEnabled`), `docs/AI_CONTEXT.md` (files, counts, the
  device-only known issue), `docs/ROADMAP.md` (1.3.3). Stage by name; **no commit** — the owner runs
  `/commit` on `feature/apple-health`, and the merge into `main` waits for the 1.4 upload.
