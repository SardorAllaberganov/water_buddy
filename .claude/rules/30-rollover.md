---
description: The daily rollover — the day is an ordinal, and the zero is written before the stamp
globs: ["WaterBuddy/**/*.swift", "WaterBuddyWidget/**/*.swift", "WaterBuddyWatch/**/*.swift", "WaterBuddyWatchWidget/**/*.swift"]
---

# Rollover

Midnight clears today's cached total and leaves history alone. Getting this wrong is invisible in
testing and catastrophic in use — a user flying west loses a day of water on a date that never
changed.

## The day is an ordinal, never a `Date`
- Store the active day as a `yyyyMMdd` `Int` computed by `DataManager.dayOrdinal(for:in:)`. Never
  persist a `Date`, a `startOfDay`, or a formatter string as the day marker — an instant has to be
  re-read under whatever time zone is current
- `WaterLog.timestamp` stays a plain `Date`, and no stored day column, ordinal or `startOfDay` field
  is ever added to the model. These are not in conflict: an instant records a moment, which does not
  move; a stored *day* would be re-read under a different zone
- `WristPour.at` and `WristPlan` follow the identical split, one device further out. There is
  deliberately no stored `dayOrdinal` on a `WristPour` — a stamp made in one time zone and re-read
  in another names a day the watch is no longer in, and the pour vanishes from a display that should
  show it. `WristPlan` buckets the watch's outbox from each pour's own instant, on the **watch's**
  own `Calendar.waterBuddyDay`, only when read — never stored as a day. The watch never rolls
  anything over the way `resetIfNeeded()` does; it filters
- `Calendar.waterBuddyDay` stays a computed `static var` building a fresh Gregorian calendar with
  `timeZone = .autoupdatingCurrent` and `locale = Locale(identifier: "en_US_POSIX")`. A `static let`
  would freeze the launch time zone and defeat the whole point. Never use `Calendar.current` for a
  day boundary
- Any new day-keyed value reuses `dayOrdinal(for:in:)` with the same calendar.
  `ReminderPlan.Slot.dayOrdinal` is the precedent — do not introduce a second day representation

## The order of the two writes
- `applyDailyReset(on:)` writes the zeroed `currentWater` to the suite **before** it stamps
  `lastActiveDay`. Never reorder, merge, or move the two `defaults.set` calls
- A crash between them in this order leaves a stale marker that simply resets again. The opposite
  order launders yesterday's water into today
- This path writes the key directly and **never runs the `currentWater` setter**, so it must repeat
  the setter's side effects by hand: `reloadWidgets()` and `rescheduleRemindersNow()`. Any new side
  effect added to that setter has to be repeated here too
- It publishes via `withMutation(keyPath: \.currentWater)` guarded on `storedCurrentWater != 0`, so
  the zero reaches observers exactly once and a no-op reset does not churn
- It writes **only** `Key.currentWater` and `Key.lastActiveDay`. The goal, the flags and the
  language stay untouched

## Reset clears the cache; only one path deletes rows
- `applyDailyReset(on:)` touches the `UserDefaults` cache only — never `modelContext.delete`,
  `insert` or `save`. Yesterday stays as history
- `resetDailyProgress()` is the only **reset** path that deletes rows, and it deletes only
  `fetchLogsForToday()`. (`deleteLog(_:)` and `removeWater(amount:)` also delete rows, as ordinary
  edits rather than resets)
- After a rollover, `allLogs()` still contains yesterday's rows while `fetchLogsForToday()` and the
  cached total are empty. Assert both halves in any test that touches the rollover

## Day bounds
- Select today's rows with the half-open interval
  `[calendar.startOfDay(for: now()), nextDayBoundary(after: now(), calendar: calendar))` on the
  injected calendar. Never filter by comparing day ordinals inside a `#Predicate`, never
  `Calendar.current`, never a closed upper bound
- `DataManager.nextDayBoundary(after:calendar:)` is the single definition of when the day turns. The
  widget's timeline entry, its refresh policy and `fetchLogsForToday`'s upper bound all call it with
  the same calendar the ordinal uses
- It computes through `Calendar.nextDate(after:matching:matchingPolicy:)`. Never add `86_400` — a
  DST day is 23 or 25 hours long

## Detecting the turn
- Read `Key.lastActiveDay` as `defaults.object(forKey:) as? Int`, never `integer(forKey:)`. A
  missing marker means a fresh install: adopt today and return `false`, never report a rollover
- Guard the stamp with `Self.role.ownsSharedStorage` — corrected from the `!Self.isAppExtension`
  this line read until 2026-09-01, the third live instance of the same stale-guard-text pattern
  fixed in `40-widget.md` and `80-notifications.md`. A non-owner that stamped an empty group
  manufactures exactly the state the migration reads as "already migrated" (rule
  `25-shared-storage`); `.watchApp`/`.watchExtension` both answer `ownsSharedStorage == false` too
- `resetIfNeeded()` stays idempotent and returns `true` exactly once per real day change — safe to
  call from any lifecycle hook without a caller-side "already reset today" flag
- Keep both observers in `startObservingDayChanges()`: `NSCalendarDayChanged` **and**
  `NSSystemTimeZoneDidChange`, hopping to `resetIfNeeded()` on the main queue, removed in `deinit`.
  The time-zone one is what catches the traveller mid-flight
- Keep `refresh()`'s calls in order: `loadFromStore()` → `resetIfNeeded()` → `republishTodaysLogs()`
- `addLog(amount:at:)` and `removeWater(amount:)` call `refresh()` first, so a mutation always lands
  on the right day. Any new mutator that computes from current state must too. (`deleteLog(_:)` and
  `updateLog(_:newAmount:)` currently do not — they address a row by identity rather than by total)
- `seedFromCachedTotalIfNeeded()` may only seed a cached total whose `lastActiveDay` equals today's;
  keep all three of its guards

## The widget rolls itself over
- `DataManager.snapshot(defaults:calendar:now:)` applies the rollover to the **returned value only**
  — no `defaults.set`, no `removeObject`. The app stays the only writer, so a widget drawn at 00:01
  cannot race the app into clearing the day
- Test the marker with `if let`, never `guard let … else { water = 0 }`: a *missing* marker must
  report the cached total, not zero
- The widget also emits a second, midnight-dated timeline entry with a zeroed total, so it turns
  over on its own even if nothing wakes it (rule `40-widget`)
- Keep `readingLeavesTheStoreUntouched` and `readingAnEmptySuiteDoesNotCreateKeys` green for any
  change to the read path. If you add a key, extend the helper those tests compare against — it
  enumerates keys explicitly and will not notice a new one on its own

## The clock
- Take it from the injected `now: () -> Date`, or the `now:`/`after:` parameter on the `nonisolated`
  statics. A bare `Date()` or `.now` is allowed only as a default argument at a composition root,
  never inside rollover logic
- Both travel tests must stay green: the same instant read in Paris then London preserves the total,
  and Los Angeles → Tokyo across the date line rolls over. So must the DST test, which logs at 00:30
  EDT and 23:59 EST on the same 25-hour day
