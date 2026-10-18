# The streak's cost — design

**Status:** approved by the owner in chat on 2026-10-18 (*Yes, B after A*). Change **B** of two; A
is `2026-10-18-the-waters-cost-design.md`. Known issue #99 is its subject.

## 1. What was measured

A throwaway probe in the unit target, Debug, simulator, in-memory store: a history of eight 250 ml
servings a day, every day at the 2,000 ml goal, so the streak's look-back widens as a daily user's
does; the median of seven runs on the main actor — five for a goal change.

| Days of history | Rows | A pour | A `refresh()` (every tab) | A goal change |
|---|---|---|---|---|
| 7 | 56 | 1.7 ms | 0.6 ms | 0.6 ms |
| 45 | 360 | 6.0 ms | 3.0 ms | 2.7 ms |
| 150 | 1,200 | 20.8 ms | 10.3 ms | 10.0 ms |
| 500 | 4,000 | 74.7 ms | 37.0 ms | 36.3 ms |

A frame at 120 Hz is 8.3 ms. The cost is `readStreak()` (#99): every republish reads 30 days, then
120 once the run passes 29 days, then 480 and 1,920 — and a pour republishes twice, `refresh()` then
`saveAndRecompute()`, and every tab's `onAppear` once more.

## 2. The design

**The run of closed days — every day before today — is counted once and kept.** Today's water
cannot change it, so a pour, an *Undo* or a tab's refresh reads only today's rows for today's part
and adds the kept count; the week card's seven-day read is unchanged. It is kept in memory, in
`@ObservationIgnored private var closedRun`, never in either store: the streak stays derived.

- **Keyed by** today's day ordinal, the goal and the calendar's time zone — a new day, a new goal
  or a new zone each find the key stale and count again.
- **Forgotten** where the app changes a day other than today: `addLog(amount:at:)` with a date on
  another day; `deleteLog(_:)` of another day's serving; `updateLog(_:newAmount:timestamp:)` when the serving
  was or becomes another day's; `ingest(_:)` when it folds a pour onto another day; and
  `dayDidTurn()`, the hop on both the day-change and the time-zone observers.
- **Counted** by the same walk as before — `streakWindows`, `DaySummary.series`,
  `DaySummary.streak(of:goal:)`, `streakFillsWindow` — with today's share taken off. A failed read
  still leaves the streak as it stands.
- **Nothing else writes an earlier day.** The widget's `AddWaterIntent`, the Siri phrase, the
  control and a reminder's *Log a Glass* all log now; the watch's pours arrive through `ingest(_:)`.
  `dayDidTurn()` still republishes nothing on a day that did not change (rule `30-rollover`); the
  next read counts again.

## 3. Acceptance

- Tests first: a pour and a tab's `refresh()` no longer read the past — shown by changing an earlier
  day behind the manager's back and finding the count unmoved (red before); and every path above
  that must count again does (guards, green before and after). Every existing streak test stays green.
- The probe above, again: a pour and a refresh flat across 7 to 500 days.
- The full gate, with A, and no new warning against a clean build of `HEAD`.

## 4. Rules

None is changed. Rule `20-state`'s *streak* bullet holds as written — published from
`republishHistory()` and the `dailyGoal` setter, behind `role.drawsHistory`, equality-guarded, a
failed read leaves it as it stands.
