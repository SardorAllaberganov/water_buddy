---
description: Reminders — a pure plan decides when, and only the applier touches UserNotifications
globs: ["WaterBuddy/ReminderPlan.swift", "WaterBuddy/NotificationManager.swift", "WaterBuddy/SettingsView.swift", "WaterBuddyWidget/AddWaterIntent.swift", "WaterBuddyWatch/WaterBuddyWatchApp.swift"]
---

# Notifications

`ReminderPlan` decides **when**. `NotificationManager` only **files and unfiles**. Neither knows
about the other's job, and that split is what makes the schedule testable without the notification
system.

## The plan is pure
- `ReminderPlan.swift`'s imports stay `Foundation` alone. Never add `UserNotifications`, and never
  call `Date()` inside it
- A new decision about *whether* or *when* to remind goes in `ReminderPlan.slots`, never in
  `NotificationManager`
- `ReminderPlanTests.swift` deliberately imports neither `UserNotifications` nor `@MainActor` — it
  is a compile-time canary, not an oversight. Do not "fix" it
- The schedule is a **fixed grid** of hours, not a rolling timer. "Remind me two hours after my last
  serving" would need a plan that changes every time the user drinks, which is a different product
  and a different failure mode
- Derive a slot's fire date with `calendar.date(bySettingHour:minute:second:of:)` on a day produced
  by `calendar.date(byAdding: .day, …)`. Never add 86,400 seconds
- `slots(...)` degrades rather than traps: the loop bound is `0...max(0, horizonDays)`, and both
  failable calendar computations fall through rather than force-unwrapping
- Goal-reached silencing applies to `offset == 0` only, and a today-slot at exactly `now` is excluded
  (`fire <= now`). Do not extend the silence to future days or relax the comparison
- Raising `horizonDays` or lengthening `hours` requires re-checking
  `hours.count × (horizonDays + 1) ≤ maximumPendingRequests` (64). The code clamps nothing — only
  `theHorizonStaysWellInsideTheSixtyFourRequestCap` catches an overrun, and it exercises the default
  horizon, so a caller passing a large `horizonDays` walks past the cap silently

## Identifiers
- A reminder identifier is exactly
  `"sardor.WaterBuddy.reminder." + dayOrdinal + "." + String(format: "%02d", hour)` — a pure function
  of day and hour. Never add a timestamp, a UUID, a total, or anything that varies between two
  computations of the same slot
- Every identifier is built from the `identifierPrefix` constant. Never hand-write a literal
  identifier at a call site
- Identifiers must be unique **within one plan**: `add` replaces a request with the same identifier,
  so a collision silently drops a reminder rather than erroring

## Never clear what you did not name
- **Never call `removeAllPendingNotificationRequests()`.** Called from the widget process it would
  clear the **app's** entire set, because an extension has no notification identity of its own
- The only removal APIs in this codebase are the identifier-taking ones wrapped in
  `ReminderScheduler.live()`. A diff that widens either closure, or reaches
  `UNUserNotificationCenter.current()` for removal outside that seam, is rejected
- `reconcile` filters the pending set by `identifierPrefix` **before** computing anything to remove.
  Never operate on the raw result of `pendingIdentifiers()`
- When a slot drops out of the plan, clear it from the delivered list as well as the pending one —
  `removePending` and `removeDelivered` take the same `stale` array

## The applier holds no policy
- `NotificationManager.reconcile` contains no scheduling policy — no hour arithmetic, no goal
  comparison, no `enabled` check. It diffs the given `[ReminderPlan.Slot]` against the pending set
  and files or unfiles
- Skip any slot whose identifier is already pending; never unconditionally re-`add` the whole plan
- A failed `add` appends to `outcome.failed` and continues the loop. Only
  `UNErrorDomain` + `UNError.Code.notificationsNotAllowed` sets `deniedAuthorization`. Never `throw`
  out of the loop or return early on a single failure
- A pass that removes but adds nothing still ends on an awaited `scheduler.pendingIdentifiers()`
  round trip — do not delete or short-circuit that trailing await
- `ReconcileOutcome` is **returned, never logged** — the caller is the only thing that can react
  (rule `75-diagnostics`). Both production callers currently discard it
- `ReminderScheduler` stays a struct of closures and never traffics in a `UNNotificationSettings`:
  `UNUserNotificationCenter.init` is `NS_UNAVAILABLE`, so a subclass cannot be compiled and a
  protocol seam would be untestable
- `ReminderScheduler.live()` stays a `static func`, not a `static let`, and every closure calls
  `UNUserNotificationCenter.current()` in its own body rather than capturing a stored centre. Build
  it **inside** the `Task` closure, never hoisted
- Do not set a `timeZone` on the `DateComponents` handed to `UNCalendarNotificationTrigger` — leave
  it nil so the trigger resolves in whatever zone the device is in when it fires

## Content
- Reminder copy contains **no digit and no user value** — no total, no goal, no serving, in any
  language and in both string catalogues. A lock screen is a public surface (rule `70-privacy`)
- Keep `content.interruptionLevel = .active` and `requestAuthorization` options at `[.alert, .sound]`.
  Do not add `.timeSensitive`, `.badge`, or the time-sensitive entitlement
- `.active` makes a reminder eligible for iOS's Notification Summary. That cost is **disclosed** in
  Settings, not hidden
- Never default the `strings: Bundle` parameter on `reconcile` or `reminderContent`, and never read
  `Bundle.main` inside `NotificationManager` — every caller passes the bundle explicitly, because the
  widget process would otherwise file a reminder in the wrong language
- Any new or changed reminder string goes into **both** `WaterBuddy/Localizable.xcstrings` and
  `WaterBuddyWidget/Localizable.xcstrings`, with its key added to `sharedKeys` in
  `LocalizationTests.swift`

## Authorization
- Requested only from `SettingsView.enableReminders()`, at the moment the user flips the toggle on.
  A refusal leaves `manager.remindersEnabled` **false** — never store the intent and hope
- Re-read the status every time the settings screen comes forward and flip the toggle off when it
  reads `.denied`. Do not cache the status from launch

## Who reschedules
- Every state change that can move the plan calls `rescheduleRemindersNow()`: the `currentWater`
  path via `recomputeToday()`, the `dailyGoal` setter, the `remindersEnabled` setter,
  `applyDailyReset(on:)` and `refresh()`. A new mutation path without that call is incomplete
- Never guard the reschedule on `remindersEnabled` — always call through and let `slots` return `[]`.
  **An empty plan is the instruction to clear the schedule**
- `DataManager.requestReminderReschedule` keeps its `guard role.mayFileReminders else { return }` —
  corrected from the `guard !isAppExtension else { return }` this line named until 2026-09-01
  (`docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md` §9.2; the same stale sentence
  was quoted verbatim in rule `40-widget`, and both are fixed together). `.watchApp` and
  `.watchExtension` both answer `mayFileReminders == false`: `ReminderPlan.Slot.identifier` is a
  pure function of day and hour, so a watch constructing a `DataManager` would file
  byte-identical identifiers into a second notification centre that cannot dedupe against the
  phone's. The extension reaches `reconcile` by awaiting it directly inside
  `AddWaterIntent.perform()` — never through the injected hook, and never from a detached `Task`
  that would not outlive `perform()`
- `refresh()`'s unconditional reconcile on every foreground is the backstop for a widget tap the
  extension sandbox may not have permitted. Do not remove it as redundant

## Tests
- Every test fixture and every `#Preview` that constructs a `DataManager` passes
  `rescheduleReminders: { _ in }` explicitly. The parameter's production default is
  `DataManager.requestReminderReschedule`, which builds a **real** `UNUserNotificationCenter` — and
  `init` calls `rescheduleRemindersNow()`, so merely constructing the manager reconciles against it
- A test that reaches a real centre can remove pending requests under `identifierPrefix`. Rule
  `85-testing` forbids it outright
