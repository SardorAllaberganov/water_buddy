---
description: State ownership — DataManager is the only writer, and today's total is derived
globs: ["WaterBuddy/**/*.swift", "WaterBuddyWidget/**/*.swift", "WaterBuddyWatch/**/*.swift", "WaterBuddyWatchWidget/**/*.swift"]
---

# State

`DataManager` is a `@MainActor @Observable final class` and the **only writer** to either store.
Views, App Intents and timeline providers read it and call it; they never write a key.

**The one honest weakening.** Since the watch shipped, *"`DataManager` is the only writer"* is no
longer literally true across the whole product, and this file says so plainly rather than hiding
it: it is now **one writer per store** — `DataManager` for the phone's SwiftData/`UserDefaults`
pair, `WristModel` for the watch's own local `UserDefaults` suite (rule `25-shared-storage`).
`WristModel` never touches SwiftData, never touches the phone's App Group container (it resolves
the identical App Group *identifier* on a different physical device), and never writes a key
`DataManager` also writes — the two writers own disjoint key sets. Everything below this line still
holds for `DataManager`'s own store; it is the *scope* of "only writer" that narrowed, not the
discipline. Rule `10-architecture` states the identical weakening — spec §9.1 requires it in both
files, not one, because the earlier draft's Forbidden list still asserted the stronger sentence
after the body above had already conceded it.

## One writer
- No production code outside `DataManager.swift` calls `defaults.set(_:forKey:)` or
  `defaults.removeObject(forKey:)`. The `defaults` field is `@ObservationIgnored private` precisely
  so this is mechanically true
- A `#Preview` may build its own throwaway suite, but must tear it down with
  `removePersistentDomain(forName:)` in the same scope
- The public mutation surface is `addLog(amount:at:)`, `addWater(amount:)`, `removeWater(amount:)`,
  `deleteLog(_:)`, `undoLog(id:)`, `updateLog(_:newAmount:timestamp:)`, `saveDailyGoal(ml:)`,
  `resetIfNeeded()`, `dayDidTurn()`, `resetDailyProgress()` and `refresh()`. Anything new joins that
  list rather than reaching around it
- `claimReviewRequest(version:)` joins that surface. It writes `Key.reviewRequestedVersion` and
  nothing else: it decides through `mayRequestReview(reachedToday:streak:askedVersion:version:)` and
  writes the version **before** it answers `true`, so nothing can ask without recording it. It
  touches no row, rings no doorbell and reschedules nothing
- `healthEnabled` joins that surface. Its setter writes `Key.healthEnabled` and nothing else — no doorbell,
  no reschedule, no wrist publish, since nothing outside Settings draws it — and only `HealthMirror` sets it,
  after asking Health
- `reminderSchedule` and `onlyWhenBehind` join that surface. Each setter writes its own key and
  reschedules, and rings no doorbell and publishes nothing to the wrist: nothing outside the app draws
  them. Setting `.standard` removes `Key.reminderSchedule`. Neither knows Premium — Settings decides who
  may change them, and what is stored keeps working after a lapse (spec `2026-10-30-coaching-design.md`
  D2)
- `addLog(amount:at:)` returns the id of the row it inserted, `nil` for a refused amount. Home's
  *Undo* is the one caller that keeps it. `undoLog(id:)` finds that row among today's, read fresh,
  and deletes it through `deleteLog(_:)`; it does nothing when the row is gone or today's rows
  cannot be read

## Today's total is derived, never authored
- `recomputeToday()` is the only place the total is computed, and it writes back **through the
  `currentWater` setter** — never `defaults.set(sum, forKey: Key.currentWater)`
- The setter's four steps stay in this order: clamp to `0...maximumDailyIntake` → `guard clamped !=
  storedCurrentWater` → `withMutation` wrapping both the in-memory store and the `defaults.set` →
  `reloadWidgets()` **outside** the mutation block. Move the doorbell above the guard and every
  no-op write rings it
- Sum with `addingReportingOverflow` and saturate at `maximumDailyIntake`. Plain `+` or
  `reduce(0, +)` traps on a corrupt `Int.max` row and crashes the app instead of degrading
- The week is derived the same way. `Key.weekTotals` — the last `historyWindow` days' totals by day
  ordinal — is rewritten from the rows by exactly the two paths that recompute today's total, `init`
  and `saveAndRecompute()`, in every process that builds a `DataManager`; in the app from the same
  fetch as the week card. Never by `refresh()` or `dayDidTurn()`, for `refresh()`'s reason. A failed
  read writes nothing and an unchanged week writes nothing. It rings the widget doorbell when it was
  missing or a day before today moved; today's own change is the `currentWater` setter's ring, so a
  real change still rings once
- `removeWater(amount:)` takes water off the `WaterLog` rows — delete each serving it swallows
  whole, shrink the one it partly covers. Never subtract from `currentWater` or the cached key; the
  next `recomputeToday()` silently undoes it

## Mutate only after a re-read
- `addLog(amount:at:)` and `removeWater(amount:)` call `refresh()` as their first statement after
  the `amount > 0` guard, before touching `modelContext`. Two processes hold their own
  `DataManager`; an idle instance otherwise computes `staleTotal + amount` over a newer figure.
  They call its private form, `refresh(republishingMonth: false)`: the save after their write
  republishes the shown month, and a second read of it doubled a pour's cost
- `refresh()` republishes rows only. It must **not** call `recomputeToday()`: a cross-process read
  can succeed while missing a row the extension just wrote, and re-deriving would overwrite it
- Every path that changes a `WaterLog` ends in `saveAndRecompute()` — `try modelContext.save()` in
  a `do/catch` that logs inside `#if DEBUG`, then `recomputeToday()`. Never call
  `modelContext.save()` directly from a mutation method, and never let a save failure crash. It ends by
  posting `logsDidSaveNotification`, the manager as its object, when the save succeeded — Apple Health's
  mirror listens; nothing else does

## A failed read is never written back
- `fetch(_:)` returns `[WaterLog]?` and returns `nil` from its `catch` — never `[]`. A failed read
  that returns `[]` is indistinguishable from "drank nothing today", and `recomputeToday()` would
  faithfully persist the zero to the cache the widget reads
- `recomputeToday()` returns early on `nil`, leaving the total exactly as it stands
- `fetchLogsForToday()`'s `?? []` is for callers that only display rows. Any path that persists a
  derived figure must take the optional and honour the `nil`

## Clamps and guards
- Goal clamped to `1...maximumDailyIntake` in the `dailyGoal` setter, with `reloadWidgets()` and
  `rescheduleRemindersNow()` after the equality guard — a goal of 0 divides by zero and renders the
  first sip as 100%
- Reject non-positive amounts with an early `return`. Never clamp up to 1 (it manufactures a
  serving) and never treat "set to zero" as "delete" (it destroys a row the user meant to correct)
- In `saveDailyGoal(ml:)`, guard the `Key.isGoalSet` **write** on the stored key
  (`defaults.object(forKey:) as? Bool != true`) and the **observation** separately on
  `storedIsGoalSet`. They are not the same: `resolveIsGoalSet(in:goal:)` infers `true` from a
  non-default goal when the key is absent
- `isGoalSet`, `todaysLogs`, `historyLogs`, `month`, `monthLogs`, `insights` and `streak` stay
  get-only. All seven are consequences, not inputs
- `insights` is published only while History has asked for a week through `showInsights(_:)`, behind
  `role.drawsHistory`, from the sites that publish `month` — never `init`, never the `servings` setter
  (the suggestion's vessel is chosen when drawn). A failed read leaves it as it stands. `showInsights(_:)`
  writes neither store. The model's wording of it lives in `InsightWriter`, in memory, and never here
- `streak` is published from `republishHistory()` and from the `dailyGoal` setter, behind
  `role.drawsHistory`, with an equality guard. A failed read leaves it as it stands, never zero.
  Every day is judged against the current goal. It never leaves the app: not the snapshot, not a
  notification, not the wrist's mirror, not Siri, and not the recap's shared image — a month's best run
  is drawn in the recap sheet, beside the card, never on it
- `month` and `monthLogs` are published only while History has asked for a month through
  `showMonth(_:)`, behind `role.drawsHistory`, from `showMonth`, `refresh()`, `saveAndRecompute()`,
  `dayDidTurn()` and the `dailyGoal` setter — never `init`. A failed read leaves both as they stand.
  `showMonth(_:)` writes neither store
- `recap(of:)` is a read beside `showMonth(_:)`, not a mutation: it returns a finished month's
  `MonthHistory` — the same two reads as the month, through `readMonth(_:)` — publishes nothing, writes
  neither store, rings no doorbell and reschedules nothing, behind `role.drawsHistory`; a failed read is
  `nil`. `MonthHistory.recap`, the month a page offers, is a consequence worked out in `make`
- `logs(since:)` is a read beside `recap(of:)`: the rows from a bound — every row for `nil` — and `nil` on
  a failed read, never `[]`. Apple Health's mirror deletes every sample whose serving it saw earlier in
  the run and no longer finds among these rows, so a failed read returned as nothing would empty Health of
  the user's water
- `remaining`, `hasReachedGoal`, `lastDrink`, `nextReminder` and `pace` are computed on read from the
  observable state and stored nowhere. `nextReminder` is the first slot of the plan
  `currentReminderSlots()` files, cut to today. `pace` is `ReminderPlan.pace` over the stored
  schedule — the one definition *Only when behind* drops slots by. `WaterSnapshot` carries `remaining`
  and `hasReachedGoal` too, for Siri's answer; `theSnapshotAgreesWithTheManager` pins the two pairs
  together
- Do **not** add an equality guard to the `todaysLogs`, `historyLogs` or `monthLogs` republish. `WaterLog` is a
  `@Model` class hashed by `persistentModelID`, so the array after an amount edit compares equal to
  the array before it — a guard would swallow exactly the change it is meant to publish
- `loadFromStore()` compares each re-read value against its `stored…` field before wrapping the
  assignment in `withMutation`. `refresh()` runs on every foreground; an unconditional mutation
  redraws the whole tree for nothing

## Isolation and the clock
- `DataManager` stays `@MainActor`. Anything an extension's `nonisolated` code must reach —
  `defaultServing`, `defaultServings`, `maximumDailyIntake`, `appGroupIdentifier`, `isAppExtension`,
  `snapshot(defaults:calendar:now:)`, `dayOrdinal(for:in:)`, `resolveLanguage(in:)`,
  `resolveServings(in:)`, `usualServing(in:)` — is declared `nonisolated static` (rule `43-concurrency`)
- The clock and calendar are injected (`now: @escaping () -> Date = Date.init`,
  `calendar: Calendar = .waterBuddyDay`). Call `now()`, never a bare `Date()`, in any rollover,
  fetch-bounds or reminder-planning logic (rule `30-rollover`)
- **The quick-add amounts are stored state, not a constant.** `Key.servings` holds a positional
  `[Int]` of exactly three — Cup, Glass, Bottle — and index 1 is the vessel the widget draws and
  logs. `defaultServing` is now only the fallback the resolver returns and the middle of
  `defaultServings`; it stopped being "the one spelling of the quick-add amount" when the vessels
  became editable, and was renamed from `standardServing` so the name could not assert an invariant
  the product no longer has
- Never sort or dedupe the triple on read or on write. Sorting would move which vessel the widget
  follows when the user edited a different one, and two vessels holding the same amount is a state
  the user is allowed to choose
- `resolveServings(in:)` discards the **whole** triple on any anomaly — a failed cast, the wrong
  arity, or an element outside `1...maximumDailyIntake` — rather than repairing one element.
  Deliberately unlike `resolveDailyGoal`, which rejects below its floor and clamps above its
  ceiling: that asymmetry is reasonable for one scalar and wrong for a set, because a partly-repaired
  triple is a row of vessels nobody authored. Check arity explicitly — a short array casts to
  `[Int]` perfectly happily
- The single unavoidable literal is `AddWaterIntent`'s `@Parameter` default — macro arguments must
  be compile-time constants — and it is documented as such at the declaration
- Any `#Preview` or test that builds a `DataManager` injects **both** a throwaway `defaults:` suite
  and an in-memory `modelContainer:`. Omitting either resolves the production default and writes
  into the owner's real data (rule `85-testing`)
