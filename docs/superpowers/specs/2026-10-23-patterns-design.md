# Patterns — design

**Status:** approved by the owner in conversation on 2026-10-23, in this order: Patterns describes
**the month on screen**, inline in Month mode ("The month on screen"); it counts **finished days
only** ("Finished days only"); it appears **after seven days of water**, with one quiet line below
that ("After 7 days of water"); **approach A**, a `MonthPatterns` value carried on `MonthHistory`;
the design's first three sections, each "Yes, go on" — the third answered "Yes, go to implementation.
All sections are ok. Do not ask". **§3.8 to §3.11 (accessibility, the words, the rule wording, the
tests) were written after that answer, on the recommendations below, and were not shown section by
section**; the owner reads them here. No board was drawn for this step: the concept board *Patterns*
on the design canvas (https://claude.ai/artifact/1dyjwFfRVsLYzcvwQ6poGy, row *Set A — Understand*,
2026-10-21) is the look this step follows, where §3.2 does not differ from it.

It is **step 3 of 5** of set A (`docs/superpowers/specs/2026-10-21-premium-paywall-and-monthly-design.md`,
§1) and roadmap item 1.4.6. It builds on step 2 (`docs/superpowers/specs/2026-10-22-month-view-design.md`,
**the step-2 spec**) and amends nothing in it.

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then
`CLAUDE.md` (rule `99-docs-cascade`). Where it contradicts the code, the code wins and this document
changes.

**Provenance.** Every claim about the repository was read at HEAD `24b2de4` on 2026-10-23. Claims are
marked **measured** (read or run on this toolchain), **inferred**, or **unconfirmed**.

## 1. Where this sits

| Step | Builds | Roadmap |
|---|---|---|
| 1 | the monthly plan, the paywall and the Settings card — committed `d5cf816` | 1.4.1, amended |
| 2 | the month view and full history — committed `40e7e41` | 1.4.2 |
| **3** | **this document** — patterns | 1.4.6 |
| 4 | personal AI insights | 1.4.12 |
| 5 | the monthly recap, and set A put on sale | 1.4.7 |

Nothing reaches a Release user before step 5: Patterns is drawn only inside a holder's Month, and
Month is drawn only where step 2's `HistoryView.offersMonth(status:offered:)` says. A DEBUG build
launched with `-WaterBuddyPremium` shows the switch; a holder's month needs a purchase through the
local StoreKit configuration.

**The Premium line** (`docs/ROADMAP.md` §1) holds: Patterns reads only rows the free app already
stores, and stores nothing. **What the paywall already promises** (measured, `PremiumSet.swift`):
*Your patterns — When you drink, weekdays against weekends*; the locked month: *Premium shows it as
months, with your patterns and a recap*. This step delivers both halves and the third the roadmap
names, the usual first and last drink.

## 2. What exists today (measured)

- **Month mode** (step 2) is, for a holder, rows of History's one `List`: the header, the switch, the
  month card, the opened day while one is open, and the figures (`MonthFigures`, drawn only while
  `month.daysCounted > 0`).
- **`MonthHistory`** is built by `MonthHistory.make(rows:month:firstServing:goal:now:calendar:)` from
  rows reaching from the 1st of the month before to the end of the shown one, published as
  `DataManager.month`, equality-guarded, republished from `showMonth(_:)`, `refresh()`,
  `saveAndRecompute()`, `dayDidTurn()` and the `dailyGoal` setter, and let go by `showMonth(nil)`. A
  failed read leaves it as it stands.
- **The cost budget** is 6 ms added at 500 days; step 2 measured `refresh()` +2.34 ms and a pour
  +2.77 ms on the built code (the step-2 spec §3.7).
- **The day's strip** (`DayStrip`) draws servings across the whole day, its axis labelled at
  `HistoryView.stripHours` (6, 12, 18) through the phone's 12/24-hour form; its plot height is a
  `@ScaledMetric` of 64 pt capped at 92.
- **The concept board** draws a separate screen with a back chevron — which the app cannot have: there
  is no `NavigationStack` (rule `50-views`) — *From your last 30 days*, eighteen hour bars from 6:00 to
  23:00 with the busiest in cyan, two weekday/weekend bars against the goal, two time tiles, and an
  insight sentence.
- **The weekend** (measured, a probe in the scratchpad): `Calendar.isDateInWeekend` follows the
  calendar's locale — Saturday and Sunday under `en_US`, `ru_RU` and `uz_UZ`, Friday and Saturday
  under `ar_SA` and `he_IL`, Sunday alone under `en_IN`, Friday alone under `fa_IR`. The model's own
  `Calendar.waterBuddyDay` is fixed to `en_US_POSIX`, so it would always answer Saturday and Sunday.
- **Strings already in `WaterBuddy/Localizable.xcstrings`** this step reuses: *Patterns* (*Привычки*,
  *Odatlar*), *Measured against your current goal*. 187 keys in all.

## 3. The design

### 3.1 Which days

A day counts toward the shown month's patterns when it is **over**: in the shown month, on or after
the day of the first serving ever recorded, and **before today**. Today joins at midnight, through
`dayDidTurn()`, which already republishes the month. A serving stamped after today — a watch pour
carrying a clock ahead of the phone's — falls in a day that has not finished and counts in nothing.

**Patterns appear** when the counted days include **at least seven with water**
(`MonthPatterns.minimumDays`). Seven days with water among consecutive finished days span at least a
week, so every weekday is in the window — whatever the locale's weekend is, both of §3.4's rows have
days behind them.

### 3.2 The screen

In Month mode, for a holder, after the figures — the rows of History's one `List` become: the header,
the switch, the month card, the opened day while one is open, the figures, **the patterns**. They
follow the shown month: ‹ and › move them; Week lets them go with the month.

- **A heading on the aurora** — the opened day's kind (`OpenedDayHeading`): *Patterns*, and under it
  *From this month's finished days*. The line names no month: Russian would need it in a case
  Foundation cannot give (`tasks/lessons.md`, 2026-10-22).
- **When you drink** — a `.frosted` pane like the day's strip: the title, and *Most around 13:00*
  trailing it (moving under it where the two do not fit); **24 bars, one an hour, across the whole
  day**, so a night drink is kept rather than cut at the board's 6:00 and 23:00; the axis is the
  strip's, `HistoryView.stripHours` in the phone's 12/24-hour form, so the two charts read alike. The
  busiest hour's bar is `Aurora.cyan` and the rest white; an hour with no water draws nothing above
  the baseline.
- **Weekdays and weekends** — one `.frosted` pane, two rows. Each: its name, *3,120 ml a day*, and a bar
  against a goal tick at the bar's end, the bar's length the average against the goal, clamped. A row
  whose average reaches the goal is `Aurora.cyan` and otherwise white — the week card's meaning, and
  never colour alone: a met bar reaches the tick. *Measured against your current goal* under the rows.
- **First drink, usually** and **Last drink, usually** — two tiles in `MonthFigures`' style, side by
  side where they fit and stacked where they do not.
- **Below seven days of water** the heading stays, and one `.frosted` pane carries one line: *Patterns
  need 7 days of water*. It is drawn whenever the month has been read and its patterns are not
  ready — on the 1st of a month too, where the figures above are still absent — so the section never
  silently vanishes. *(Amended 2026-10-23, the final review's M4: this read *Patterns appear after 7
  days of water*, which promises a finished month with fewer days something it will never have; the
  owner's option read "says patterns need seven days of water".)* A month never read (`month == nil`, step 2's quiet card) draws no patterns rows
  at all.
- **Not here:** the concept board's insight sentence (step 4's), its separate screen, and any Settings
  shortcut (the step-2 spec §3.10's one-route ruling).

### 3.3 When you drink

- **Each hour** holds the millilitres poured in it across the counted days, summed with
  `addingReportingOverflow` and saturated at `Int.max` — a corrupt row degrades, never traps (rule
  `20-state`). The bars are drawn as fractions of the busiest hour.
- **A serving's hour** is its instant's hour on the model's calendar, `Calendar.waterBuddyDay`, so after
  a flight the same servings regroup into the new zone's hours, as the month regroups its days. On a
  25-hour day both 01:00s fall in hour 1; on a 23-hour day the skipped hour simply holds nothing.
- **The busiest hour** is the one with the most water; a tie goes to the earlier hour.

### 3.4 Weekdays and weekends

- **Each kind's average** is its counted days' water over its counted days, whole millilitres. **Empty
  counted days stay in the denominator**, as the month's average does (`DaySummary.average(of:)`'s
  rule): a skipped Saturday lowers the weekend's figure rather than vanishing from it.
- **The weekend is the app's locale's** — Saturday and Sunday under all three of the app's languages,
  and under *Follow device* whatever the device's region says (§2). The model keeps each weekday's
  water and its count of days, Sunday first; History hands in the locale's weekend through
  `HistoryView.weekend(in:)`, a `nonisolated static` beside `firstWeekday(in:)`, and the value answers
  the split. So a language change needs no republish, and the view does no arithmetic (rule
  `50-views`).
- **A day's weekday** is its start's weekday on the model's calendar, `1` for Sunday — a number that
  does not depend on the calendar's locale.
- **Judged against the current goal**, as everything in History is (`DaySummary`'s ruling): the model
  carries the goal it was built with, so the bar's fraction and whether a side is met are its answers.

### 3.5 First and last drink, usually

- **For each counted day with water**, the wall-clock time of its earliest and of its latest serving —
  hours and minutes on the model's calendar, never seconds since midnight, so a serving at 23:59 on a
  25-hour day reads 23:59 and not *24:59*.
- **"Usually" is the median** over those days; with an even count, the earlier of the two middle
  values, so no time is invented that no day had.
- **Rounded to the nearest five minutes**, which reads as typical rather than precise, and held inside
  the day: 23:58 is *23:55*, never *00:00*. A day with one serving gives the same first and last.

### 3.6 The model (`WaterBuddy/DataManager.swift`)

- **`MonthPatterns`** — a new file-scope `nonisolated struct`, `Sendable`, `Equatable`, beside
  `MonthHistory` and in this file for `DaySummary`'s reason: `DataManager` publishes it, and every
  target that compiles `DataManager.swift` must see the type. No seventh shared file, no exception set
  changed. It carries:
  - `hourly: [Int]` — 24 entries, the millilitres of each hour;
  - `busiestHour: Int`;
  - `weekdays: [Tally]` — 7 entries, Sunday first, each `water` and `days`;
  - `firstDrink`, `lastDrink: Int` — minutes after midnight on the wall clock, rounded;
  - `daysWithWater: Int`;
  - `goal: Int` — the goal it was judged against;
  - the instants it is drawn with — the busiest hour's, the first drink's and the last drink's, set on
    the month's 1st with `date(bySettingHour:minute:second:of:)` — **for formatting and nothing
    else**, as `MonthHistory.Neighbour.start` is, so the view formats them through the phone's
    12/24-hour setting and holds no calendar;
  - `split(weekend:)` — the weekdays' and the weekends' sides, each its average, its bar's fraction
    (a drawing fraction, clamped to `0...1`) and whether it is met; `nil` for a side with no day;
  - `nonisolated static let minimumDays = 7`.
- **One builder,** `nonisolated static func make(rows:days:firstServing:goal:now:calendar:)`, pure,
  returning `nil` below `minimumDays`.
- **`MonthHistory` gains `let patterns: MonthPatterns?`**, built by `MonthHistory.make` from the shown
  month's rows — the rows it is already handed, the month before's left out.
- **`DataManager` is unchanged in shape**: no new property, no new read, no new call site;
  `republishMonth()` is untouched. `month`'s equality guard, its failed-read rule, its five republish
  sites and `showMonth(nil)` now cover the patterns too. No key, no schema change, no
  `project.pbxproj` edit; nothing reaches the widget or the watch, though all four schemes recompile
  the file.
- **Cost:** one more pass over the shown month's rows — an hour and a minute read per row, a weekday
  per day. Measured on the built code at 500 days against step 2's 6 ms budget: `refresh()` and a pour
  with a month shown. Over it, the work stops and reports.

### 3.7 The view (`WaterBuddy/HistoryView.swift`)

- **`nonisolated static func weekend(in locale: Locale) -> Set<Int>`** beside `firstWeekday(in:)`: a
  Gregorian calendar under the app's locale, one known week walked through `isDateInWeekend`.
- **`nonisolated static func hourPosition(_ hour: Int) -> Double`** — where an hour's bar stands across
  the chart, `hour / 23` of the plot's travel, the strip's model of a plot (a bar's leading edge at its
  fraction; 24 bars, 23 gaps), the axis's labels centred under the bars of the hours they name.
- **`nonisolated static func hourBars(_ hourly: [Int]) -> [Double]`** — each hour's bar against the
  busiest, a sip held at `stripFloor`, an empty hour at nothing. *(Both amended 2026-10-23, the final
  review's M8: this read "24 equal slots", and `hourBars` was unnamed.)*
- **New private structs in the same file**, after `MonthFigures`' precedent: `PatternsHeading`,
  `HoursChart`, `WeekSplit`, `UsualTimes`, `PatternsPending`. `HistoryView` draws them after
  `MonthFigures` when `manager.month` is not `nil`.
- **Glass:** every pane `.liquidGlass(density: .frosted, elevation: .raised)`, the pair its siblings
  share (rule `60-design-system`); every colour `Aurora.cyan` or white.
- **Motion:** the bars change with `.smooth(duration:)` scoped by `.animation(_:value:)` to the
  patterns; nothing repeats, so Reduce Motion needs no branch (rule `65-accessibility`).
- **`HistoryView.swift`** grows from 2,644 lines to roughly 3,000. Rule `50-views` keeps a helper view
  in the file that uses it, so splitting the file stays a task of its own — recorded as a known issue.

### 3.8 Accessibility

- **The heading** is one element with the header trait: label *Patterns*, value *From this month's
  finished days*.
- **When you drink** is one element: label *When you drink*, value the busiest hour, *Most around
  13:00*. The bars and the axis are hidden.
- **Each weekday/weekend row** is one element: label *Weekdays* or *Weekends*, value *3,120 millilitres
  a day* — millilitres spoken, as every figure in History is. The goal tick and *Measured against your
  current goal* are drawn; the line is read as its own text.
- **Each time tile** is one element: label *First drink, usually*, value the time as the phone speaks
  it.
- **The pending line** is one element, its own text.
- **Dynamic Type:** the chart's height a `@ScaledMetric`, capped as the strip's is; its axis labels a
  ratio of the plot, never a text style of their own; the busiest-hour line under the title where they
  do not share a line (`ViewThatFits`, offered the row's whole width, each candidate `.fixedSize()`);
  the tiles across where they fit and in a column where they do not; every sentence wraps,
  `.fixedSize(horizontal: false, vertical: true)`.
- **Contrast:** every new pair measured off renders — the busiest bar and the white bars against the
  pane (3:1, non-text), the two weekday bars and their track and tick (3:1), *Most around 13:00*, the
  rows' names and figures, the tiles, the pending line and the heading (4.5:1) — into `docs/DESIGN.md`.
  One under its floor is raised to the lowest value that passes and measured again; one whose fix
  changes the look goes to the owner.

### 3.9 The words

New keys in `WaterBuddy/Localizable.xcstrings` only — nothing the widget draws, so none joins
`sharedKeys` — each with `en`, `ru` and `uz`, positional specifiers, and plural variations where a count
stands beside a noun (rule `70-privacy`):

| Key | Use |
|---|---|
| `From this month's finished days` | the heading's line |
| `When you drink` | the chart's title |
| `Most around %1$@` | the busiest hour, drawn and spoken |
| `Weekdays` · `Weekends` | the rows |
| `%1$@ ml a day` · `%1$d millilitres a day` | a row's figure, drawn and spoken; the second plural |
| `First drink, usually` · `Last drink, usually` | the tiles |
| `Patterns need %1$d days of water` | the pending line; plural (amended, §3.2) |

Reused: *Patterns*, *Measured against your current goal*. Times are formatted through the injected
`\.locale` and the phone's 12/24-hour setting, never keyed. The Russian and Uzbek follow the paywall's
own words for the feature — *Привычки*, *будни и выходные*; *Odatlar*, *ish va dam olish kunlari* — and
are drafts for the owner's sweep (#170's kind).

### 3.10 What it amends in the rules

Typed into the rule files **unstaged**, for the owner, before any code.

- **`50-views`**, *Composition*: "in Month mode the header, the switch, the month card, an opened day
  and the figures" becomes "… an opened day, the figures and the patterns".
- **`30-rollover`**, *Day bounds*: the month bullet's "Its grid's first weekday is the app's locale's,
  never `Calendar.waterBuddyDay`'s" becomes "Its grid's first weekday and the weekend its patterns
  split are the app's locale's, never `Calendar.waterBuddyDay`'s"; and a new bullet: "A serving's hour
  and time of day in the month's patterns are its instant's wall-clock hour and minute on the injected
  calendar — never seconds since midnight, which a DST day stretches or shrinks".
- **`43-concurrency`** and **`85-testing`**: `MonthPatternsTests` joins the lists of suites that are
  deliberately not `@MainActor`.
- **`docs/ROADMAP.md`** §5: 1.4.6's note.

### 3.11 Testing

Tests first, each run and seen **RED** before its code (rule `85-testing`).

- **`MonthPatternsTests`** (new file `WaterBuddyTests/MonthPatternsTests.swift`, not `@MainActor`,
  pure): only finished days count — today's servings and a serving stamped after today count in
  nothing, yesterday's do; days before the first serving count in no weekday; six days with water are
  no pattern and seven are; each hour holds its own water, summed and saturating on an `Int.max` row;
  the busiest hour, and a tie going to the earlier; the median with the days' times out of order
  (amended 2026-10-23, the final review's M3); the weekday and weekend averages with an empty day
  in each denominator; the split under Saturday–Sunday and Friday–Saturday; a side met and a side
  short, and its fraction clamped; the first and last drink as medians, odd and even counts; rounding
  to five minutes, and 23:58 held at 23:55; a DST day — 00:30 and 23:59 on New York's 25-hour day keep
  their wall clocks, and both 01:30s fall in hour 1; the same instants read in Paris then London
  regroup by an hour; the drawn instants stand on the month's 1st at the times they name.
- **`MonthHistoryTests`** gains: a month carries its patterns at seven days of water and none at six,
  built from the shown month's rows alone — the month before's never reach them.
- **`MonthPublishingTests`** gains: the day turning adds yesterday to the shown month's patterns.
- **`MonthLayoutTests`** gains: `weekend(in:)` for `en`, `ru`, `uz`, `ar_SA` and `en_IN`;
  `hourPosition` at 0, 6, 12, 18 and 23; `hourBars` against the busiest, a sip at the floor, an empty
  hour at nothing.
- **`LocalizationTests`**: every new key resolves in `en`, `ru` and `uz`, with its plural forms.
- **No UI test.** A holder's month has none (the step-2 spec §6: holding Premium in a UI run needs a
  StoreKit purchase, #166's timing). Patterns is proved by the suites above and by the walk (§4).

## 4. Verification

- **The gate:** rule `85-testing`'s five invocations, and the UI suite again on `OS=26.5`. The known red
  (the privacy URL, #159) and the known flakes are reported by name, never hidden.
- **Warnings:** clean builds of a `HEAD` export and of the change, all four schemes, by file and
  message; none new.
- **The cost** (§3.6) measured on the built code and recorded in `docs/STATE.md`.
- **By hand — the walk,** on the simulator, in a scratch copy, with a seeded history and Premium bought
  through an `SKTestSession`, as step 2's was: a month with patterns; a month with fewer than seven
  days of water (the pending line); ‹ to a past month and › back; English, Russian and Uzbek; the
  largest text size; Reduce Transparency, forced in the copy. The colour pairs measured (§3.8).

## 5. Open questions

- **The privacy policy URL** (#159) still gates every Release offer, this step's included.
- ***Most around 13:00* in `Aurora.cyan`**, as the board draws it, is small text on glass; measured, and
  white if it does not hold 4.5:1. *(2026-10-23: measured 5.21 at its worst of twelve frames; kept
  cyan.)*
- ***From this month's finished days*, on the aurora** — *(added 2026-10-23, the walk:)* 4.17 beside its
  glyphs at its worst of forty frames, under 4.5, where the aurora's cyan light passes behind it. It is
  already white at full opacity, so every fix changes the look and is the owner's (§3.8; known issue
  #171).
- **The Russian and Uzbek** wording, for the owner's sweep.
- **The cost.** Over the budget, the work stops and reports before building on it.
