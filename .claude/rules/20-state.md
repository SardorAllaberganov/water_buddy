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
  `deleteLog(_:)`, `updateLog(_:newAmount:timestamp:)`, `saveDailyGoal(ml:)`, `resetIfNeeded()`,
  `resetDailyProgress()` and `refresh()`. Anything new joins that list rather than reaching around it

## Today's total is derived, never authored
- `recomputeToday()` is the only place the total is computed, and it writes back **through the
  `currentWater` setter** — never `defaults.set(sum, forKey: Key.currentWater)`
- The setter's four steps stay in this order: clamp to `0...maximumDailyIntake` → `guard clamped !=
  storedCurrentWater` → `withMutation` wrapping both the in-memory store and the `defaults.set` →
  `reloadWidgets()` **outside** the mutation block. Move the doorbell above the guard and every
  no-op write rings it
- Sum with `addingReportingOverflow` and saturate at `maximumDailyIntake`. Plain `+` or
  `reduce(0, +)` traps on a corrupt `Int.max` row and crashes the app instead of degrading
- `removeWater(amount:)` takes water off the `WaterLog` rows — delete each serving it swallows
  whole, shrink the one it partly covers. Never subtract from `currentWater` or the cached key; the
  next `recomputeToday()` silently undoes it

## Mutate only after a re-read
- `addLog(amount:at:)` and `removeWater(amount:)` call `refresh()` as their first statement after
  the `amount > 0` guard, before touching `modelContext`. Two processes hold their own
  `DataManager`; an idle instance otherwise computes `staleTotal + amount` over a newer figure
- `refresh()` republishes rows only. It must **not** call `recomputeToday()`: a cross-process read
  can succeed while missing a row the extension just wrote, and re-deriving would overwrite it
- Every path that changes a `WaterLog` ends in `saveAndRecompute()` — `try modelContext.save()` in
  a `do/catch` that logs inside `#if DEBUG`, then `recomputeToday()`. Never call
  `modelContext.save()` directly from a mutation method, and never let a save failure crash

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
- `isGoalSet`, `todaysLogs` and `historyLogs` stay get-only. All three are consequences, not inputs
- Do **not** add an equality guard to the `todaysLogs` or `historyLogs` republish. `WaterLog` is a
  `@Model` class hashed by `persistentModelID`, so the array after an amount edit compares equal to
  the array before it — a guard would swallow exactly the change it is meant to publish
- `loadFromStore()` compares each re-read value against its `stored…` field before wrapping the
  assignment in `withMutation`. `refresh()` runs on every foreground; an unconditional mutation
  redraws the whole tree for nothing

## Isolation and the clock
- `DataManager` stays `@MainActor`. Anything an extension's `nonisolated` code must reach —
  `defaultServing`, `defaultServings`, `maximumDailyIntake`, `appGroupIdentifier`, `isAppExtension`,
  `snapshot(defaults:calendar:now:)`, `dayOrdinal(for:in:)`, `resolveLanguage(in:)`,
  `resolveServings(in:)` — is declared `nonisolated static` (rule `43-concurrency`)
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
