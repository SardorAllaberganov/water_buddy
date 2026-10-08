---
description: swift-testing, one simulator, and fixtures that cannot reach real data
globs: ["WaterBuddyTests/**/*.swift", "WaterBuddyUITests/**/*.swift", "WaterBuddyWatchTests/**/*.swift"]
---

# Testing

`WaterBuddyTests` is swift-testing (phone side); `WaterBuddyUITests` is XCTest (phone side);
`WaterBuddyWatchTests` is swift-testing (watch side). All three are live targets — none is a stub.
Exact counts belong in `docs/AI_CONTEXT.md`, re-derived every pass — see *Counting* below.

## Tests first
- Write the failing test, **run it and verify RED**, then implement, then run it GREEN. A test first
  seen green proves nothing
- **Never reshape data or weaken an assertion to make a number pass.** If a test and the code
  disagree, stop and report it. A `#expect` narrowed to go green is a deleted test that still looks
  like a test

## A fixture may never reach real data
- Every suite builds its own UUID-named throwaway suite —
  `UserDefaults(suiteName: "test.waterbuddy.\(UUID().uuidString)")` — and tears it down with
  `removePersistentDomain(forName:)` in a `defer`
- Every fixture passes an **in-memory** `ModelContainer`. Letting `modelContainer:` default resolves
  `DataManager.sharedModelContainer`, which is the live App Group store
- Every fixture passes `reloadWidgets: {}` **and** `rescheduleReminders: { _ in }`. The latter's
  production default builds a **real** `UNUserNotificationCenter`, and `init` reschedules — so merely
  constructing a manager reconciles against it and can remove real pending requests. A test that
  constructs a real centre is forbidden outright
- Never touch the real `group.sardor.WaterBuddy` suite or `UserDefaults.standard` — from a test, a
  preview, or any ad-hoc script. `didMigrateFromStandard` is a one-shot flag and burning it by hand
  is not recoverable from inside the app (rule `25-shared-storage`)
- Inject the `Calendar` and the `now: () -> Date` clock rather than waiting for a real day
- Names are never reused across suites, because swift-testing runs `@Test` functions in parallel
  inside one process

## The watch side follows the identical fixture discipline
`WaterBuddyWatchTests` is a **third**, separately-gated suite (`WaterBuddyWatch` scheme,
`-only-testing:WaterBuddyWatchTests`), not a subset of the two above — see *The gate* below. It is
held to the same non-negotiables, adapted for `WristModel` in place of `DataManager`:
- Every fixture that constructs a `WristModel` builds its own **throwaway** `UserDefaults` suite,
  UUID-named exactly the way the phone side does, and tears it down the same way. `WristModel` never
  runs against the real watch-local App Group suite from a test
- Every fixture injects the **clock**: `WristModel`/`WristPlan` take `now: () -> Date` the way
  `DataManager`/`ReminderPlan` do, so a boundary test never waits for a real day to turn
- `WristLinkCompileTests` and `WristPlanCompileTests` are compile-time canaries, the watch-side
  precedent for the same idiom `ReminderPlanTests` already sets on the phone: they exist to prove a
  declaration's isolation or import list stays what it should, not to assert behaviour. Fix the
  declaration they read rather than reshaping the canary
- No watch-side test constructs a real `WCSession` or reaches an actual paired device — `WristLink`'s
  pure halves (`chunk(_:batchId:)`, `decodeBatch(from:)`, `decodeMirror(from:)`) are what is tested;
  the live session is exercised only by hand, on paired simulators (Task 8's spike), never by the
  automated gate

## Isolation
- Put `@MainActor` on the suite **and** on every helper that constructs a `DataManager`
- Inside a `@MainActor` closure, build factories as **closure literals**, not nested `func`s — a
  nested `func` does not inherit the enclosing closure's isolation
- Some suites are deliberately **not** `@MainActor` — `WaterSnapshotTests`, `WidgetLanguageTests`,
  `AppLanguageTests`, `ReminderPlanTests`, `AppTabTests`, `AuroraLightTests`, `HapticLadderTests`,
  `LiquidGlassInteractionTests`, `NotificationManagerTests`, `ReconcileQueueTests`. They are
  compile-time canaries for rule `43-concurrency`: fix the declaration they read rather than
  annotating the suite
- `ReminderPlanTests` deliberately does not `import UserNotifications`. That is the canary proving
  the plan stayed pure (rule `80-notifications`)
- Tally `withObservationTracking`'s `onChange` through a `final class … : @unchecked Sendable` box,
  never a captured local `var`

## Writing assertions
- A suite that asserts against a bundle must **first prove the bundle resolved**. A `Bundle?` that
  came back nil turns every downstream `#expect` into a vacuous pass
- `#expect`'s message is a `Comment`, which is `ExpressibleByStringInterpolation` but **not**
  `ExpressibleByString` — a built or concatenated `String` will not convert. Interpolate inline

## The gate
Run `xcodebuild` in the **foreground**. A build you did not watch finish is not a build you can
report on. One simulator at a time, and always `-parallel-testing-enabled NO` — a cloned run writes
into a container you cannot then read back, which is how a real bug gets mistaken for a broken test.

**Five invocations, not three** — two platforms, and no scheme compiles a sibling's sources:

```bash
xcrun simctl shutdown all

xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests -parallel-testing-enabled NO

xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyUITests -parallel-testing-enabled NO \
  -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests

xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' \
  -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO

xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17'

xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)'
```

- **`-skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests` on the UI-test invocation is
  mandatory, not an optimisation.** `AppStoreScreenshotUITests` is a capture harness, not a test:
  it is **deliberately non-idempotent** — it asserts *Get Started* exists, so it fails on any device
  where setup has already been completed, which is every ordinary run. It is driven only by
  `bash Tools/CaptureScreenshots.sh`, which erases the device first. Dropping the skip turns a green
  gate red for a reason that has nothing to do with the product
- **`OS=26.5` is load-bearing on both platforms — do not simplify it away.** The reason changed on
  2026-09-02 and is now the *stronger* one. It used to be that the deployment targets were 26.5, so
  the runtime and the floor matched; they no longer do — `IPHONEOS_DEPLOYMENT_TARGET` is **17.0** and
  `WATCHOS_DEPLOYMENT_TARGET` is **26.0**, so the app would now happily install on the iOS 18.6
  runtime that is also on this machine. That is exactly why the pin matters more, not less: an
  unpinned or `OS=latest` destination is ambiguous the moment more than one runtime of that platform
  is installed, and the gate must keep reporting on one known runtime rather than whichever one
  resolved that day. Pin the runtime by number, and update it when the installed runtime changes —
  never by swapping in a device `id=`, which resolves nothing on anybody else's machine
- **The floors are compile-and-link-verified, never run-verified.** No iOS 17.x runtime and no
  watchOS 26.0 runtime is installed here, so nothing in this gate has ever *executed* the product at
  its own minimum. `vtool -show-build` on the built binaries is the whole of the evidence
  (`minos 17.0` / `minos 26.0`). Treat "runs on iOS 17" as unproven until someone installs that
  runtime or a real device
- **The watch widget scheme is `WaterBuddyWatchWidget`, with no "Extension" suffix.** Do not
  copy-paste the phone widget's `WaterBuddyWidgetExtension` spelling and assume a parallel name —
  `xcodebuild -list` is the source of truth for every scheme name in this list
- **`-dry-run` is not a probe for a destination.** A dry-run *build* against a broken spelling
  reports no error at all; only a real `test` (or, for the two build-only invocations, a full build)
  surfaces it. Verify a destination by actually running it, not by asking whether it resolves
- **The test half is three invocations, not one.** iOS unit and iOS UI together already exceed the
  600s foreground limit on their own; the watch unit run is gated separately again for the same
  reason and because it is a different scheme entirely
- **The watch invocations are simulator builds, not device-signed ones.** Nothing in this repo's
  toolchain here provisions a device build for either watch target, so these five invocations are
  the full gate available in this environment — a device-signed build remains unproven (see
  `docs/AI_CONTEXT.md`'s known issues)
- Neither widget build is optional: no container scheme compiles either extension's sources
- Treat every new warning as a failure, on **every** invocation above, not just the two inherited
  from before the watch. This codebase compiles clean, and a concurrency warning here is a Swift 6
  error later
- A non-parallel run prints `✔ Test run with N tests passed`; a parallel one does not

## A green suite is not proof the product works
The suite injects its own `UserDefaults`, `Calendar` and clock, so it structurally **cannot** see an
entitlement that was not added, a file missing from a target, or a widget that renders blank.
**No widget's rendering has any automated coverage, on either platform** — the phone's Home Screen
and Lock Screen widgets, its Control Center control, and the watch's `.accessoryCircular` face are all
proved only by placing them and looking.

After any change to storage, entitlements, target membership or the widget's view tree: run the app
on the simulator and put the widget on the Home Screen — in light, in dark, and tinted — and put the
control in Control Center. The same
applies to the watch face: install `WaterBuddyWatch` and add the widget to a watch face by hand: no
part of the automated gate renders it.

## Counting
Count the attribute in the only position it can be one; `@Test` also appears inside DocC comments:
```bash
grep -chE '^[[:space:]]*@Test' WaterBuddyTests/*.swift | awk '{s+=$1} END {print s}'
grep -chE '^[[:space:]]*@Test' WaterBuddyWatchTests/*.swift | awk '{s+=$1} END {print s}'
```
Count each target separately — they are two different gates on two different platforms, and a
combined figure obscures which one moved when only one changed.
