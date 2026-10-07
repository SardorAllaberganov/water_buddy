# Add or fix a serving at an earlier time or day — design

**Status:** approved by the owner in conversation on 2026-10-07, in two sections — the model, then the
History screen and the sheet — then "all ok go implementation". **Implemented the same day** — tests
RED then GREEN, the five-invocation gate green, no new warning — and staged for the owner's
`/commit`; the results are in `HISTORY.md`'s checkpoint of that date. Roadmap item 3 (pain #3 in the
2026-10-06 review scan, ~16 mentions). §4–§8 — what it touches beyond History, the rule wording,
testing and verification — were not presented as a separate section. They are recorded here, and
the owner may amend them. The rule wording in §5 was a proposal — rules change only when the owner
decides (rule `99-docs-cascade`) — and the owner approved it the same day; it is written. **Two departures from the text the owner approved**, both stated
where they apply: the copy says *serving*, not *drink* (§3.5), and the wheel spans its card's full width
rather than its inset (§3.4) — the simulator pass found it would not fit (§8.3).

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then
`CLAUDE.md` (rule `99-docs-cascade`). Where it contradicts the code, the code wins and this document
changes.

**Provenance.** Every claim about the repository was read at HEAD `cd09663` on 2026-10-07.

---

## 1. What is being built

A user who forgot a glass this morning — or yesterday — adds it at the right time in a few taps, and
fixes one that was logged wrong. Afterwards the bars, today's total, the widget, the watch and the
reminders all agree.

The owner's three choices:

1. **The reach is the visible week.** Any of the seven days the week card draws can be opened, and its
   servings added to, edited and deleted. Nothing reaches further back: a serving dated before the
   window would vanish from view the moment it was saved.
2. **One route, from History.** Home's one-tap pour is untouched. Rule `50-views` asks for exactly one
   route to each destination, and the sheet has one.
3. **One day · hour · minute wheel**, bounded by the week and by now. An edit can move a serving to
   another day — the "drank it at 23:50, logged it at 00:10" fix is one step — and History follows the
   serving to the day it landed on.

## 2. What happens today

- **The store already holds what this needs.** `WaterLog.timestamp` is a `var Date`, and
  `addLog(amount:at:)` takes any instant — `historyRollsUpBackDatedServingsIntoTheirOwnDays` already
  pins that a back-dated serving lands in its own bar. No schema change, no key, no wire field.
- **The gaps are all on screen and in the edit path:**
  - no `DatePicker` exists anywhere in the product;
  - `updateLog(_:newAmount:)` corrects the amount only;
  - History lists `todaysLogs` alone;
  - `HistoryCard` is seven bars with no control inside, and one VoiceOver element.
- **The store accepts any instant on purpose, and that stays.** `fetchLogsForTodayExcludesOtherDays`
  logs a serving dated *tomorrow* through `addLog` to prove it stays out of today. Rejecting future
  instants in `addLog` would leave that test green while it tested nothing — the hollowed assertion
  rule `85-testing` forbids. So the bound lives in what the screen **offers**, exactly as amounts do
  today: the store's floor is "positive", the editor's offer is `HistoryView.servingRange`.
- **The week card's width was budgeted for this.** `DataManager.historyWindow`'s DocC: "a day column
  with a 44pt tap target is unaffordable much past this on the narrowest supported iPhone once
  `HistoryView`'s 28pt margins are taken off" — `(375 − 2 × 28) / 7 = 45.6 pt`.

## 3. The design

### 3.1 The model (`DataManager.swift`)

- **`historyLogs: [Int: [WaterLog]]`** — the window's servings keyed by day ordinal, newest first
  within each day; a day with none has no key. Read-only and observable, like `todaysLogs` and
  `history`.
  - Published by `republishHistory()` **from the fetch it already makes** for the bars, so a bar and
    the list under it cannot disagree — the same reason `recomputeToday()` publishes today's rows and
    total from one fetch.
  - **No equality guard**, for `todaysLogs`' reason: a `[WaterLog]` compares by `persistentModelID`,
    so the array after an edit equals the array before it. `history` keeps its guard, so `HistoryCard`
    still does not redraw on every foreground.
  - Published before the series' guard returns: a time-only edit inside a past day leaves every total
    unchanged and still reorders that day's rows.
  - Only where `role.drawsHistory` — the widget extension never builds it.
- **`updateLog(_:newAmount:timestamp:)`**, replacing `updateLog(_:newAmount:)`. `timestamp: Date? =
  nil` means "keep the time", so the existing call shape still compiles and still means what it did.
  One call saves amount and time together (rule `50-views`: a mutating button makes exactly one call).
  - A non-positive amount ignores the **whole** edit, time included.
  - Nothing changed → nothing happens: no save, no recompute, no doorbell, no re-plan.
  - It addresses the row by identity and does not `refresh()` first — rule `30-rollover`'s existing
    ruling for `updateLog` and `deleteLog`.
  - `saveAndRecompute()` does the rest: today's total, the cache, the widget doorbell and the wrist
    publish fire only if today's total moved; the bars and rows republish; the reminder plan re-plans.
- **`historyWindowStart(endingOn:calendar:)`**, `nonisolated static`, beside
  `nextDayBoundary(after:calendar:)`: the start of the first day the window shows — the one definition
  of where the week starts. `republishHistory()` calls it instead of spelling the arithmetic itself.
  Walked with `calendar.date(byAdding: .day,…)`, never 86,400 seconds (rule `30-rollover`).
- **`correctionRange() -> ClosedRange<Date>`** — `historyWindowStart(endingOn: now(), …)...now()`, on
  the injected clock and calendar. What the sheet's wheel offers. On the model, not on the screen as a
  `static let`, because it depends on the clock and on the window the model owns — the same reason
  `historyWindow` lives here.
- **`suggestedTime(onDay:) -> Date`** — the instant the sheet opens on when adding to a day: that day
  at the current time of day, found by walking `date(byAdding: .day, value: -offset, to: now())` across
  the window. A day outside the window answers `now()`. A wall-clock time a DST change skipped resolves
  the calendar's way and still lands on the chosen day.
- **`dayOrdinal(for:)` stops being `private`**, so the screen can ask which day a saved serving landed
  on without holding a calendar of its own.

### 3.2 The week card becomes the day picker

- **Each day is a button.** The day row spans the card's full width — seven equal slots, 45.6 pt each
  on a 375-pt iPhone (48.1 on 393, 49.4 on 402, 54.9 on 440) — and the whole slot is the target
  (`.contentShape(Rectangle())`, rule `65-accessibility`). The bars become narrower and centre in their
  slots; the title, the figures and the disclosure keep their 20-pt inset.
- **The shown day** is outlined with a lit rim and its weekday label turns full white and bold — never
  colour alone (rule `65-accessibility`). Contrast measured off a render (§8.3).
- **VoiceOver.** The summary stays one element: label "Last 7 days", value "Average … Best …". The
  figures it speaks for are hidden; the *Measured against your current goal* disclosure, which the
  card's old single element swallowed, is read as itself. Each day is exactly one button: label
  "Today" or the weekday, value "%1$d millilitres", `.isSelected` on the shown day.
- **Selection is presentation state** (rule `50-views`): `@State private var selectedDay: Int?`, where
  `nil` means today, so the screen follows midnight on its own. A selection that leaves the window —
  the app open across midnight — falls back to today, and so does every selection while the card is
  hidden (no water anywhere in the week). Leaving the tab resets it.
- Pure helpers on `HistoryView`, `nonisolated static` so a non-`@MainActor` suite can read them (rule
  `43-concurrency`): `shownDay(selected:in:) -> DaySummary?` and `selection(forDay:in:) -> Int?` (the
  selection after a save: `nil` for today, the ordinal otherwise).

### 3.3 The header and the list follow the shown day

- **Today reads exactly as now:** "Today", `currentWater` of `dailyGoal`, `todaysLogs`. The UI tests
  that look for "Today" keep their meaning.
- **A past day** shows its weekday and date (`.dateTime.weekday(.wide).day().month(.abbreviated)`,
  through the environment locale — the one use `DaySummary.date` exists for), that day's
  `DaySummary.total` of `dailyGoal`, and `historyLogs[day]`. Rows behave as today's do: tap to edit,
  swipe to delete.
- **The add button** is a 44-pt `.frosted`/`.raised` glass circle with a `plus` glyph at the right of
  the header, where the gear used to sit — the vessels' recipe, `PressStyle`, label "Add a serving". It
  stays put however long the list grows; under a `List` it would scroll away past six or seven rows.
- **An empty past day** says "Nothing logged that day" / "Tap + to add a serving you forgot." Today's
  empty state is unchanged.

### 3.4 One sheet, two modes

`EditServingSheet` becomes `ServingSheet`, presented by one `.sheet(item:)` bound to an optional
`@State` enum — `.adding(at: Date)` or `.editing(WaterLog)` (rule `50-views`: a `WaterLog` in `@State`
only as a sheet's selection).

- **Title:** "Add a serving" or "Edit serving".
- **Amount:** the existing readout and slider. Adding starts at the middle vessel, `manager.servings[1]`
  — the serving the widget logs.
- **When:** `DatePicker(…, in: manager.correctionRange(), displayedComponents: [.date, .hourAndMinute])`
  in `.wheel` style, labels hidden, spoken label "When", inside the same pane as the amount. Adding
  opens on `suggestedTime(onDay:)` for the shown day; editing opens on the serving's own time.
  **As built**, the wheel runs the card's full width under `.frame(minWidth: 0, maxWidth: .infinity)`
  while the readout and slider keep the 24-pt inset: its natural width is more than the inset leaves,
  and the first build pushed the whole sheet past the screen's right edge.
- **Save** makes one call — `addLog(amount:at:)` or `updateLog(_:newAmount:timestamp:)` — bumps the
  existing `commits` counter (`Haptics.pour`), hands the instant back so History selects the day it
  landed on, and dismisses.
- **Full height only** (`.presentationDetents([.large])`): the wheel does not fit the half-height
  detent on a small phone. The "Logged at %1$@" subtitle goes — the wheel now shows the time — and its
  key leaves the catalogue.

### 3.5 Strings

App catalogue only (`WaterBuddy/Localizable.xcstrings`), `en`/`ru`/`uz`, none drawn by the widget or
the watch. "Serving", not "drink": it is the word every existing History string uses.

| Key | ru | uz |
|---|---|---|
| Add a serving | Добавить порцию | Porsiya qo‘shish |
| When | Когда | Qachon |
| Nothing logged that day | В этот день ничего не записано | Bu kuni hech narsa qayd etilmagan |
| Tap + to add a serving you forgot. | Нажмите +, чтобы добавить забытую порцию. | Unutilgan porsiyani qo‘shish uchun + tugmasini bosing. |

Removed: `Logged at %1$@`.

## 4. What it touches beyond History

- **The widget** is woken only when today's total moves — adding to today, moving a serving into or
  out of today, or editing today's amount. A serving added to or edited inside a past day changes no
  figure the widget draws, and the `currentWater` setter's equality guard keeps it asleep.
- **The watch.** The mirror carries today's total, so the same rule applies on the wire; a past-day
  edit is not news. Editing an ingested pour is safe: the applied ledger is keyed by the pour's own
  `at`, which a resend repeats, and the full-history existence check finds the row by `id` wherever its
  time moved. Both are pinned by tests (§7).
- **Reminders.** `currentReminderSlots()` takes the latest of *today's* rows. Moving today's latest
  serving earlier can bring back a slot it had silenced, if that slot is still ahead; that is correct.
  `recomputeToday()` re-plans on every log mutation already.
- **No celebration.** Home is not mounted while History shows, and `.onChange` does not fire for the
  value Home appears with — so a correction that completes today's goal fills the vessel without
  confetti. The celebration stays tied to a pour (rule `50-views`).
- **Rollover, storage, the shared exception sets, entitlements, the widget's view tree:** unchanged.

## 5. What this amends — written 2026-10-07, at the owner's word

The owner approved this wording after the implementation and asked for it as its own change; it is in
`.claude/rules/` as written below.

- **`20-state`:** the public mutation surface lists `updateLog(_:newAmount:timestamp:)`.
- **`30-rollover`:** the parenthetical under *Detecting the turn* names `updateLog(_:newAmount:timestamp:)`;
  *Day bounds* gains "`DataManager.historyWindowStart(endingOn:calendar:)` is the single definition of
  where the history window starts — the bars' fetch and the sheet's wheel both call it".
- **`50-views`:** "No `@Query` and no `ModelContext` in a view — read `manager.todaysLogs`, or
  `manager.historyLogs` for a past day".
- **`65-accessibility`:** "The week card's summary is one element; each day is exactly one button, with
  `.isSelected` on the shown day".

In code, the DocC that describes the old shape changes with it: `historyWindow`, `history`,
`DaySummary.date` ("a day label" rather than "a weekday label"), `HistoryView`, `HistoryCard`, and
`testLoggingAServingRevealsTheWeekCardAsOneElement`'s.

## 6. Privacy

Nothing new leaves the device, and nothing new is stored. No notification copy, no wire field, no key.

## 7. Testing

Written first, run RED on seams that compile, then GREEN (rule `85-testing`). New file
`WaterBuddyTests/EarlierServingTests.swift`, own UUID suite and in-memory store per test, every seam
injected, plus a test that the fixture routes the reminder plan to the injected seam.

- **The published rows:** published by day, newest first; each day adds up to its bar; rows outside the
  window are not published; a time-only edit inside a past day republishes its rows.
- **The edit:** moving today's serving into yesterday moves its water between the days; the reverse
  raises today; a move across midnight rings the widget doorbell once; a time-only edit within today
  rings none and re-plans the reminders; amount and time change in one call; an edit that changes
  nothing does nothing; a non-positive amount ignores the whole edit; omitting the timestamp keeps the
  time; a serving back-dated into yesterday rings no doorbell.
- **The window:** it starts at midnight six days before today; it walks calendar days across a DST
  change (New York, 2026-11-01); the correction range runs from that midnight to now; the suggested
  time keeps the time of day on the chosen day, is `now` for today and for a day outside the window,
  and lands on the chosen day across a spring-forward gap (New York, 2026-03-08).
- **The watch:** re-timing an ingested pour cannot let a resend duplicate it; deleting a re-timed pour
  cannot let a resend resurrect it.
- **The screen's helpers:** nothing selected shows today; a selection inside the window is shown; one
  that left it falls back to today; an empty window shows nothing; saving to today clears the
  selection and saving to a past day selects it.
- **UI** (`GoalSetupUITests`): the week card resolves to one summary plus exactly one button per day;
  "Add a serving" resolves to exactly one element; a serving added to yesterday appears under
  yesterday.

## 8. Verification

### 8.1 The gate

All five invocations, foreground, commands as rule `85-testing` writes them.

### 8.2 Warnings

A clean build of the code before and after, into empty DerivedData, compared per file and message —
`DataManager.swift` is compiled into all four shipping targets, so every scheme is compared.

### 8.3 On the simulator

- History on an iPhone 17 and the narrowest phone available: select days, add to yesterday, move a
  serving across midnight, delete a past serving, return to Home and check the vessel.
- Contrast sampled off rendered screenshots for every new mark on glass — the shown day's rim and
  label, the `+` glyph, the wheel's text, the past-day empty state — and written into the code comment
  and `docs/DESIGN.md` (rule `65-accessibility`).
- The in-app language switched to Russian and Uzbek: the header date and the wheel follow it.
- Not required by the rules here, because no storage, entitlement, membership or widget view tree
  changes: the Home Screen widget and the watch face.

**Done 2026-10-07**, on the iPhone 17 and the iPhone 17e — at 390 pt the narrowest phone installed;
no 375-pt simulator exists here. It found two layout bugs, both fixed before the gate: the wheel
widening the sheet past the screen (§3.4), and the day row's `minHeight` floor letting it compress at
`AccessibilityXXXL` until the bars overlapped the title — the row now claims its own height. Every new
mark clears its contrast floor except the wheel's neighbouring rows, 2.43–2.80:1 (`docs/AI_CONTEXT.md`
#59, the owner's call). Russian and Uzbek render throughout, the wheel's day names included.

## 9. Known limitations, and what is not in scope

- **A sheet left open across midnight** keeps the window it opened with; a serving saved to the day
  that just left the window is stored and not shown — the same as a late watch pour.
- **Past days are judged against the current goal**, as the card already discloses.
- **A chosen language should set the clock style.** `AppLanguage.locale` is a bare
  `Locale(identifier:)` for an explicit choice, so English is expected to draw a 12-hour wheel even on
  a phone set to 24-hour — as the rows' times would. Inferred from the code, not observed: every render
  this pass used *Follow device*. Pre-existing, and recorded rather than changed here.
- **The wheel's neighbouring rows measure 2.43–2.80:1**, under the 4.5:1 text floor; the row being set
  measures 5.47:1. UIKit's own styling, which no public API changes — `docs/AI_CONTEXT.md` #59,
  accepted by the owner on 2026-10-07.
- **The sheet's *Cancel* and *Save* overflow their capsules at `AccessibilityXXXL`** — pre-existing,
  carried from `EditServingSheet` unchanged; #60. Fixed and verified the same day at the owner's word,
  and held for its own commit, since it shares `HistoryView.swift` with this change.
- **Not in scope:** days older than the week, a Home shortcut, a celebration for a correction, and
  editing more than one serving at once.

## 10. Sequence

1. This spec, staged.
2. Seams that compile — every new member present with wrong behaviour.
3. The tests in §7, run RED, each failing on its own expectation.
4. The model (§3.1), then the screen and the sheet (§3.2–§3.5) — GREEN.
5. The UI tests, then the gate (§8.1) and the warning comparison (§8.2).
6. The simulator pass and the contrast figures (§8.3).
7. `HISTORY.md`, `/doc_sync`, and §5's rule wording put to the owner.
8. Staged by explicit path; no commit until the owner's `/commit`.
