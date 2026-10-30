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
- The schedule is a **fixed grid** of hours — `ReminderPlan.Schedule.standard`, or the user's own
  (set B, spec `2026-10-30-coaching-design.md`) — not a rolling timer. A slot is only ever
  **dropped**, never moved: by the goal (today only, below), by a drink less than
  `ReminderPlan.quietAfterDrink` before it, the drink clamped to `now`, by a quiet weekday, which
  plants nothing that day, or — with *Only when behind* on, today only — by water that already covers
  `ReminderPlan.due` at the slot's fire. A rolling "two hours after your last serving" timer moves
  slots, and a moved slot fires outside the window
- `quietAfterDrink` is one hour — `theQuietHourEndsExactlyAnHourAfterTheDrink` pins it. One drink
  drops at most one slot — `oneDrinkSilencesAtMostOneSlot` pins that, and it holds only while
  `quietAfterDrink` stays within the grid's interval and the clamp stays: a watch pour carries the
  watch's own clock, and one stamped ahead of the phone's would otherwise silence every slot up to
  an hour past it. No interval `Schedule.intervals` offers is shorter than it —
  `oneDrinkSilencesAtMostOneSlotOnEveryInterval` sweeps each
- Derive a slot's fire date with `calendar.date(bySettingHour:minute:second:of:)` on a day produced
  by `calendar.date(byAdding: .day, …)`. Never add 86,400 seconds
- `slots(...)` degrades rather than traps: the loop bound is `0...(7 × horizon)`, `horizon` never below
  zero, and both failable calendar computations fall through rather than force-unwrapping. The horizon
  counts **reminder days** beyond today — a quiet day uses none of it, so the days after a quiet stretch
  are still filed (`aQuietStretchDoesNotUseUpTheHorizon`); today always counts, so a horizon of 0 is
  today alone
- Goal-reached silencing applies to `offset == 0` only, and a today-slot at exactly `now` is excluded
  (`fire <= now`). Do not extend the silence to future days or relax the comparison. *Only when
  behind* is today's alone too, and what it drops is a run at the front of today's slots, because
  `due` never falls through a day
- A schedule's horizon is `Schedule.horizonDays` — `ReminderPlan.horizonDays`, shortened so
  `hours.count × (horizon + 1) ≤ maximumPendingRequests` (64).
  `everyScheduleKeepsThePlanInsideTheCap` sweeps every schedule `Schedule` accepts; raising
  `horizonDays` or widening `Schedule.earliest...latest` re-runs it. A caller passing its own
  `horizonDays` still walks past the cap silently

## Identifiers
- A reminder identifier is exactly
  `"sardor.WaterBuddy.reminder." + dayOrdinal + "." + String(format: "%02d", hour)` — a pure function
  of day and hour. Never add a timestamp, a UUID, a total, or anything that varies between two
  computations of the same slot. A schedule is whole hours, so the identifier keeps this shape
  whichever schedule planted it
- Every request identifier is built from the `identifierPrefix` constant. Never hand-write a literal
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
  Never operate on the raw result of `pending()`
- When a slot drops out of the plan, clear it from the delivered list as well as the pending one —
  `removePending` and `removeDelivered` take the same `stale` array

## The applier holds no policy
- `NotificationManager.reconcile` contains no scheduling policy — no hour arithmetic, no goal
  comparison, no `enabled` check. It diffs the given `[ReminderPlan.Slot]` against the pending set
  and files or unfiles
- Skip a slot already pending **with the wording it would be filed with now** — the title, body and
  category `reminderContent(in:)` gives it in the bundle passed. File again a pending reminder of ours
  whose wording differs: `add` replaces it under the same identifier, so nothing is removed and no
  slot moves. That is how a reminder filed before an update gains the button, and one filed before a
  language change is put into the new language. Never unconditionally re-`add` the whole plan
- A failed `add` appends to `outcome.failed` and continues the loop. Only
  `UNErrorDomain` + `UNError.Code.notificationsNotAllowed` sets `deniedAuthorization`. Never `throw`
  out of the loop or return early on a single failure
- A pass that removes but adds nothing still ends on an awaited `scheduler.pending()`
  round trip — do not delete or short-circuit that trailing await
- `ReconcileOutcome` is **returned, never logged** — the caller is the only thing that can react
  (rule `75-diagnostics`). Both production callers currently discard it
- `ReminderScheduler` stays a struct of closures and never traffics in a `UNNotificationSettings`:
  `UNUserNotificationCenter.init` is `NS_UNAVAILABLE`, so a subclass cannot be compiled and a
  protocol seam would be untestable. It is `nonisolated`: its closures are called on both sides of
  the main actor — off it by the app's queue, on it by `ReminderPermission` — and a synchronous
  closure read off a main-actor struct from nonisolated code warns
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
  `LocalizationTests.swift` — except the button's title, *Log a Glass*, which only the app resolves:
  it is the Siri phrase's title, the same act in the same words

## The button
- A reminder carries one action, *Log a Glass*, in one category. Both identifiers are constants on
  `NotificationManager` — `reminderCategoryIdentifier` and `logTheGlassActionIdentifier`, never a
  literal at a call site, and never built from `identifierPrefix`, which names requests — and
  `reminderContent(in:)` sets the category, so a reminder the widget extension files carries the
  button too
- The category is built by `NotificationManager.reminderCategory(in:)`, whose bundle is never
  defaulted, and registered **only by the app**: `DataManager.requestReminderReschedule` registers it
  through the scheduler's `setCategories`, inside its queued operation, in the bundle it files the
  copy in, before the reconcile. Never from `reconcile` itself, which the extension runs —
  `setNotificationCategories` replaces every category the app has
- The action's options are empty: not `.foreground`, because the press logs without opening the app;
  not `.authenticationRequired` (rule `70-privacy`); not `.destructive`. Its icon is the Glass's glyph,
  `vesselSlots[DataManager.usualSlot].symbol`
- The press is answered by `ReminderResponder`, the app's notification delegate, installed in
  `WaterBuddyApp.init()` and held by its `static let shared` — the centre holds its delegate weakly.
  It logs only for `logTheGlassActionIdentifier`; a tap on the reminder opens the app as it always
  did. It implements no `willPresent`, so a reminder due while the app is open is still not shown
- The press logs the Glass read when it is pressed, through `LogServingIntent.logTheGlassInTheBackground()`
  — the steps the Siri phrase takes — and returns only after it has awaited the watch link and
  `DataManager.remindersSettled()`: returning is the completion, after which iOS may suspend the launch

## Authorization
- Requested only through `ReminderPermission.enable(on:using:)`, and only from the two taps that ask
  for reminders: the Settings toggle turning on, and *Turn on reminders* in the welcome. A refusal
  leaves `manager.remindersEnabled` **false** — never store the intent and hope
- Re-read the status every time the app comes forward (`ReminderPermission.reconcile`) and whenever
  the settings screen appears, and clear `remindersEnabled` when it reads `.denied`. Do not cache the
  status from launch

## Who reschedules
- Every state change that can move the plan calls `rescheduleRemindersNow()`: the `currentWater`
  path via `recomputeToday()`, the `dailyGoal` setter, the `remindersEnabled` setter, the
  `reminderSchedule` and `onlyWhenBehind` setters, the `language` setter — which moves no slot, but
  every pending reminder's wording —, `applyDailyReset(on:)` and `refresh()`. A new mutation path
  without that call is incomplete
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
- The production hook files every plan through one `ReconcileQueue`
  (`DataManager.reminderReconciles`), in the order the plans were asked for — never a `Task` per
  reconcile. A mutation reschedules twice, two `Task`s are unordered, and a reconcile makes the
  pending set equal *its* plan, so the plan from before a drink could land last and file the slot
  the drink dropped. `anOlderPlanCannotRefileTheSlotANewerPlanDropped` pins it
- `refresh()`'s unconditional reconcile on every foreground is the backstop for a widget tap the
  extension sandbox may not have permitted. Do not remove it as redundant
- `LogServingIntent.logTheGlassInTheBackground()` — what `perform()` and the reminder's button both
  run — holds the app process open until the reminder queue has run what its mutation asked for — `await DataManager.remindersSettled()` — never by calling `reconcile` itself,
  which would run outside the queue

## Tests
- Every test fixture and every `#Preview` that constructs a `DataManager` passes
  `rescheduleReminders: { _ in }` explicitly. The parameter's production default is
  `DataManager.requestReminderReschedule`, which builds a **real** `UNUserNotificationCenter` — and
  `init` calls `rescheduleRemindersNow()`, so merely constructing the manager reconciles against it
- A test that reaches a real centre can remove pending requests under `identifierPrefix`. Rule
  `85-testing` forbids it outright
