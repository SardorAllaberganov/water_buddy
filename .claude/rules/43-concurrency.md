---
description: Isolation — @MainActor on the model, nonisolated on everything a widget must reach
globs: ["WaterBuddy/**/*.swift", "WaterBuddyWidget/**/*.swift", "WaterBuddyTests/**/*.swift", "WaterBuddyWatch/**/*.swift", "WaterBuddyWatchWidget/**/*.swift", "WaterBuddyWatchTests/**/*.swift"]
---

# Concurrency

The project compiles at `SWIFT_VERSION = 5.0` with no strict-concurrency setting, so the compiler
will not stop you. **Treating every new warning as a failure is the only enforcement there is** — a
warning here is a Swift 6 error later.

## The model is main-actor; the read path is not
- `DataManager` stays `@MainActor @Observable final class`. Never drop it to make a nonisolated call
  site compile — move the callee to a `nonisolated static` instead
- `DataManager.shared` is deliberately main-actor-isolated. That isolation is the mechanism that
  makes a timeline provider unable to touch it by accident
- A member the widget or a non-`@MainActor` test must reach is declared `nonisolated static` and
  takes its inputs (`UserDefaults`, `Calendar`, `Date`) as parameters rather than reading instance
  state: `snapshot(defaults:calendar:now:)`, `nextDayBoundary(after:calendar:)`,
  `dayOrdinal(for:in:)`, `resolveLanguage(in:)`, `usualServing(in:)`, `isAppExtension`,
  `appGroupContainerExists`, and the shared constants
- `isAppExtension` and `appGroupContainerExists` stay `nonisolated static let` lazy globals — both
  are read during `sharedDefaults`' own lazy initialiser
- Give the production default of every injected `DataManager` side-effect closure as a
  `nonisolated static func`, so the parameter stays a plain non-isolated closure

## Sendable, and what may cross a process
- `WaterSnapshot` is the only **state** value handed to a widget process: `Sendable`, `Equatable`,
  and derivable from the cache alone (`nextDayBoundary` is also called there, but it returns a
  `Date`)
- The widget's **draw path** never opens SwiftData, holds a `ModelContext`, or receives a
  `WaterLog`. A `ModelContext` is not `Sendable` and `@Model` classes are reference types with no
  conformance, so any widget-side query would fail the check or force the provider async
- The extension's **write path** legally reaches SwiftData through `DataManager.shared.addWater` —
  but only inside `AddWaterIntent.perform()`, which carries an explicit `@MainActor` on its
  implementation of the nonisolated `AppIntent` requirement. Do not hop by hand
- Every method of `HydrationProvider` stays synchronous and free of `await`, `DataManager.shared`,
  and any `DataManager` construction
- `ReminderPlan` stays free of actor isolation **and** of `import UserNotifications`;
  `ReminderPlan.Slot`'s `Sendable` conformance is load-bearing — the array is captured into a `Task`
- Never store a non-`Sendable` value in a `static let`. Expose it as a `static func` that builds a
  fresh one, and call non-`Sendable` system singletons (`UNUserNotificationCenter.current()`,
  `WidgetCenter.shared`) inside the closure body that uses them
- **`WristLink` is `nonisolated final class WristLink: NSObject, WCSessionDelegate, Sendable`, and
  is never `@MainActor` — the second instance of this codebase deliberately keeping a
  system-callback surface off the main actor, alongside `NotificationManager`'s own
  struct-of-closures design around `UNUserNotificationCenter`.** `WCSession`'s header states its
  delegate callbacks land on "a non-main serial queue," and a `@MainActor` type conforming to a
  nonisolated delegate protocol produces `#ConformanceIsolation` — a warning at this project's
  `SWIFT_VERSION = 5.0`, an error at Swift 6 — so `DataManager` is disqualified as the delegate by
  the SDK itself, not by preference. The explicit `nonisolated` on the class declaration matches
  the pattern already established for `Key.wristApplied`, `AppLanguage.code`, `vesselSlots` and
  `WristModel.requestSend`, all of which needed it because `SWIFT_DEFAULT_ACTOR_ISOLATION =
  MainActor` (set on every native target) infers `@MainActor` onto an unmarked declaration —
  **for those four, removing the keyword reproducibly regresses a real "main actor-isolated …
  cannot be referenced from a nonisolated context" warning; for `WristLink` it does not.** Three
  separate probes against this exact toolchain (an unapplied reference to `activate()`, a direct
  synchronous call to it, and a control test on an unrelated `NSObject` subclass with one plain
  method) produced no diagnostic difference with or without the keyword — most likely because
  `SWIFT_APPROACHABLE_CONCURRENCY = YES` (also set on every target) relaxes this diagnostic
  category, though that is an inference about the compiler's behaviour, not proof the underlying
  isolation was ever safe to omit. The keyword is kept regardless, as explicit documentation of
  intent consistent with its four siblings and with `WCSession`'s own unambiguous statement that a
  callback lands off-main — it is just not, on this toolchain, something the automated gate can
  currently prove will regress loudly if removed (`WaterBuddyTests/WristSyncTests.swift`'s
  `WristLinkReachabilityTests` records the three failed probe attempts, honestly, rather than
  claiming to be a working canary). `WristLink`'s `Sendable` is **earned**: zero stored properties,
  only immutable
  references to global-actor-isolated classes reached through it
- **`WristLink` itself never hops to the main actor at all.** Its `WCSessionDelegate` methods post a
  `Notification` synchronously, straight from whatever queue `WCSession` calls them on — posting is
  thread-safe, and isolation is each observer's own responsibility, not the poster's. There is no
  `Task { @MainActor in }` anywhere in this class, and there never has been one shipped — an earlier
  draft of this rule described that shape and cited "`WristLink`'s own DocC states this ruling in
  full," but no such hop exists in the DocC or the code it describes. The hop happens one step
  further out, on the *receiving* side: `WristInbox` and `WristModel` register their observers with
  `queue: .main` and enter isolation with `MainActor.assumeIsolated` — the same `NotificationCenter`
  idiom this file already sanctions below for `DataManager.startObservingDayChanges()`.
  `assumeIsolated` is correct there specifically because `queue: .main` is what guarantees the
  callback is already on the main queue by the time it runs; it would be wrong inside `WristLink`
  itself, where a `WCSessionDelegate` callback is explicitly **not** guaranteed to be on the main
  queue and `assumeIsolated` would trap rather than merely warn — which is exactly why `WristLink`
  posts instead of hopping, and leaves the hop to callers who can actually make that guarantee
- Spell static properties on a `Sendable` type as `static let`. The two `static var`s are
  `AddWaterIntent.parameterSummary` and `WaterBuddyShortcuts.appShortcuts`, both computed and both
  required by their protocols
- `nonisolated(unsafe)` is permitted only for a value whose thread-safety is stated in a comment on
  the declaration; `sharedDefaults` is the sole instance

## `View` is `@MainActor` — so is anything nested in one
- A value type a non-`@MainActor` suite or the widget reads is declared **at file scope**, never
  nested inside a `View`. `AppTab` and `ConfettiPiece` are the precedent
- When a type genuinely must be nested (`AuroraBackground.Light`), conform it to `Sendable` **and**
  mark the static collection exposing it `nonisolated` — both, not one
- Any `static` inside a `View` type that a non-isolated context reads must be `nonisolated`.
  `HomeView.servings` and `AuroraBackground.lights` carry it; `HistoryView.servingRange` /
  `.servingStep` and `GoalSetupView.goalRange` / `.goalStep` do not — they are latent warnings the
  moment a non-`@MainActor` suite reads them
- The cost is documented: `@Test(arguments:)` evaluates its arguments off the main actor, which
  produced three *"expression is 'async' but is not marked with 'await'; this is an error in the
  Swift 6 language mode"* warnings before `HomeView.servings` was marked

## Hops
- Deliver `NotificationCenter` observations with `queue: .main` and enter isolation with
  `MainActor.assumeIsolated` — never by wrapping the body in a `Task` or `MainActor.run`. The
  `[weak self]` there pairs with `deinit`, which is the only thing that unregisters the observer
- In views, run async work from `.task` or a `Task {}` inside a body modifier and assign
  `@State`/model properties directly after the `await`. Never add `MainActor.run` or
  `DispatchQueue.main.async`
- A `Task {}` that sleeps and then clears view state must re-check that the state is still the one
  it started with
- Build non-`Sendable` collaborators **inside** the `Task {}` body and resolve values from the
  shared suite there — never capture a scheduler, a notification centre, or `DataManager.shared`
- A fire-and-forget `Task {}` in code a non-owner process can reach carries
  `guard role.mayFileReminders else { return }`: a detached task does not outlive `perform()`.
  `requestReminderReschedule` is the instance of this; the `Task`s in `SettingsView` and
  `Celebration` are app-only view work and need no guard
- `AddWaterIntent.perform()`'s trailing `await` is what holds the extension process open. Keep it
  the last awaited work before `return .result()`

## Tests
- Put `@MainActor` on a suite **and** on every fixture helper that constructs a `DataManager`
- Inside a `@MainActor` closure, build helper factories as **closure literals** (`let make = { … }`),
  not nested `func` declarations — a nested `func` does not inherit the enclosing closure's isolation
- Tally `withObservationTracking`'s `onChange` through a `final class … : @unchecked Sendable`
  reference box, never a captured local `var`
- Never add `@MainActor` to `WaterSnapshotTests`, `WidgetLanguageTests`, `AppLanguageTests`,
  `ReminderPlanTests`, `AppTabTests`, `AuroraLightTests`, `HapticLadderTests`,
  `LiquidGlassInteractionTests`, `NotificationManagerTests` or `ReconcileQueueTests` to make them
  compile. They are compile-time canaries: fix the declaration they read instead
