---
description: swift-testing, one simulator, and fixtures that cannot reach real data
globs: ["WaterBuddyTests/**/*.swift", "WaterBuddyUITests/**/*.swift"]
---

# Testing

`WaterBuddyTests` is swift-testing (206 `@Test` functions across 10 suites); `WaterBuddyUITests` is
XCTest (9 cases). Both are live targets — neither is a stub.

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

## Isolation
- Put `@MainActor` on the suite **and** on every helper that constructs a `DataManager`
- Inside a `@MainActor` closure, build factories as **closure literals**, not nested `func`s — a
  nested `func` does not inherit the enclosing closure's isolation
- Some suites are deliberately **not** `@MainActor` — `WaterSnapshotTests`, `WidgetLanguageTests`,
  `AppLanguageTests`, `ReminderPlanTests`, `AppTabTests`, `AuroraLightTests`, `HapticLadderTests`,
  `LiquidGlassInteractionTests`, `NotificationManagerTests`. They are compile-time canaries for
  rule `43-concurrency`: fix the declaration they read rather than annotating the suite
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

```bash
xcrun simctl shutdown all

xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=18.6,name=iPhone 16' \
  -only-testing:WaterBuddyTests -parallel-testing-enabled NO

xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=18.6,name=iPhone 16' \
  -only-testing:WaterBuddyUITests -parallel-testing-enabled NO

xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=18.6,name=iPhone 16'
```

- **`OS=18.6` is load-bearing — do not simplify it away.** `IPHONEOS_DEPLOYMENT_TARGET` is 18.5 and
  the only installed runtime is 18.6, so a bare `platform=iOS Simulator,name=iPhone 16` fails with
  *"Unable to find a device matching the provided destination specifier"*. `OS=latest` fails too.
  Pin the runtime by number, and update it when the installed runtime changes — never by swapping in
  a device `id=`, which resolves nothing on anybody else's machine
- **`-dry-run` is not a probe for this.** A dry-run *build* against the broken spelling reports no
  error at all; only a real `test` invocation surfaces it. Verify a destination by running one test,
  not by asking whether it resolves
- **The test half is two invocations, not one.** The combined run exceeds the 600s foreground limit
- The widget build is not optional: the app scheme never compiles the extension's sources
- Treat every new warning as a failure. This codebase compiles clean, and a concurrency warning here
  is a Swift 6 error later
- A non-parallel run prints `✔ Test run with N tests passed`; a parallel one does not

## A green suite is not proof the product works
The suite injects its own `UserDefaults`, `Calendar` and clock, so it structurally **cannot** see an
entitlement that was not added, a file missing from a target, or a widget that renders blank. The
widget's rendering has no automated coverage at all.

After any change to storage, entitlements, target membership or the widget's view tree: run the app
on the simulator and put the widget on the Home Screen — in light, in dark, and tinted.

## Counting
Count the attribute in the only position it can be one; `@Test` also appears inside DocC comments:
```bash
grep -chE '^[[:space:]]*@Test' WaterBuddyTests/*.swift | awk '{s+=$1} END {print s}'
```
