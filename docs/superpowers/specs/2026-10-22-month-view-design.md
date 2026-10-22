# The month view and full history — design

**Status:** approved by the owner in conversation on 2026-10-22, in this order: a past day older than
the week is **seen, read-only** ("See it, read-only"); the free user's locked month blurs **a drawn
month**, not their own; an opened day appears **inline, under the month**; **approach 1**, the model
shows one month at a time; the design's four sections, each "Yes, go on"; and the three boards drawn
from them on the design canvas (https://claude.ai/artifact/1dyjwFfRVsLYzcvwQ6poGy, row *Set A, step 2*,
private to the owner), "Approved". This document writes that design out for the owner's review
**before** the plan and before any code.

It is **step 2 of 5** of set A (`docs/superpowers/specs/2026-10-21-premium-paywall-and-monthly-design.md`,
**the step-1 spec**, §1) and roadmap item 1.4.2. It amends the step-1 spec in one place, §3.5's *Each set
A feature adds its shortcut row here in its own step* (§3.10); everything else there stands.

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then
`CLAUDE.md` (rule `99-docs-cascade`). Where it contradicts the code, the code wins and this document
changes.

**Provenance.** Every claim about the repository was read at HEAD `a6e287b` on 2026-10-22. Claims are
marked **measured** (read or run on this toolchain), **inferred**, or **unconfirmed**.

## 1. Where this sits

| Step | Builds | Roadmap |
|---|---|---|
| 1 | the monthly plan, the paywall and the Settings card, set A declared and not on sale — committed `d5cf816` | 1.4.1, amended |
| **2** | **this document** — the month view and full history; History's locked Month for a free user | 1.4.2 |
| 3 | patterns | 1.4.6 |
| 4 | personal AI insights | 1.4.12 |
| 5 | the monthly recap, and set A put on sale | 1.4.7 |

Nothing reaches a Release user before step 5: the switch this step adds is drawn only where the
paywall is offered or Premium is held (§3.1), and a Release build offers the paywall only once a set
is on sale and the privacy link is set (`PaywallView.isOffered(arguments:)`). A DEBUG build launched
with `-WaterBuddyPremium` shows all of it.

**The Premium line** (`docs/ROADMAP.md` §1) holds as written. No way of logging moves: adding and
correcting a serving stay the week's, for everyone (§3.4). Premium reads only the rows the free app
already stores and stores nothing of its own. When Premium lapses the month goes quiet, and no
serving is hidden from the store.

## 2. What exists today (measured)

- **History reaches seven days and no further.** `HistoryView`'s DocC: *"The reach is the week the
  card draws … Nothing reaches further back, because nothing on screen would show it."* `shownDay`
  falls back to today for any ordinal outside `manager.history`; the sheet's wheel is bounded by
  `correctionRange()`, `historyWindowStart` to now — *"an offer, not a floor"*. The rows themselves
  are all still in the store: the rollover deletes nothing.
- **History reads published state, never the store** (its DocC): `manager.history` (`[DaySummary]`,
  seven days, equality-guarded) and `manager.historyLogs` (`[Int: [WaterLog]]`, unguarded — a `@Model`
  array compares equal after an amount edit). Both are republished by the private
  `republishHistory(cachingTheWeek:)`, behind `role.drawsHistory` (`.phoneApp` only), from `init`,
  `refresh()`, `saveAndRecompute()` and `dayDidTurn()` (the last only when the day really turned).
- **The store's one range query** is the private `readLogs(from:to:)` — *"The one predicate shape in
  this product"*, half-open — through `fetch(_:)`, which returns `nil` on failure, never `[]`.
  `allLogs()` has no production caller. Only two paths read further back than seven days: the
  streak's `readClosedRun(at:)` (30, 120, 480, 1,920 days, cached in `closedRun`) and `ingest(_:)`'s
  existence check; neither publishes rows or per-day totals.
- **`DaySummary`** (file scope in `DataManager.swift`, compiled into all four targets) has no `goal`
  field by ruling; `average(of:)` counts empty days in the denominator; `streak(of:goal:)` treats
  today as open — *"it joins the run once it has reached the goal, and does not break one before
  then"* (`closedDays(of:goal:)`).
- **Cost, as recorded:** the seven-day read is 0.42 ms a tap in the extension (`docs/STATE.md`);
  a pour cost 6 ms at 45 days and 75 ms at 500 before the streak's `closedRun` cache.
- **Premium:** `PremiumStore` (`@MainActor @Observable`) is injected at the scene root beside
  `DataManager`; `state` is `.checking` until the first read, then `.known(Status)`;
  `state.status?.isPremium` is the test. **Neither `HistoryView` nor `RootTabView` reads it**; only
  `RootTabView`'s `#Preview` injects one (`PremiumStore(source: .silent())`). `PaywallView.Entry` has
  one case, `.settings`. Settings draws its card only when
  `PaywallView.isOfferedHere && premium.state != .checking`.
- **The header** (`ScreenHeader`): a title line 44 pt at least, the title with layout priority and a
  0.6 shrink floor (History's day title 0.5), the accessory laid out at the line's height; a detail
  line under it. History's accessory is the `+`, *"the only route to the serving sheet"*.
- **The pager:** a page is built when shown and stays in the tree for its slide after it is left;
  `\.pageIsShown` (`RootTabView.swift`) is the signal that it has been left — `onDisappear` and
  `.task` cancellation are not (`tasks/lessons.md`).
- **Strings already in `WaterBuddy/Localizable.xcstrings`** this step reuses: *Today*, *Week*,
  *Goal met*, *Premium*, *See Premium*, *Not now*, *Measured against your current goal*,
  *When you drank*, `%1$d days`, `%1$d servings`, `%1$d millilitres`, `%1$d of %2$d millilitres`,
  `%1$@ of %2$@ ml`. 167 keys in all.
- **History's previews** inject only `DataManager`; once History reads `PremiumStore` they must
  inject one too, or they fail at run time (inferred from `@Environment`'s behaviour with a missing
  `Observable`).

## 3. The design

### 3.1 Who sees the switch

`nonisolated static func offersMonth(status: PremiumAccess.Status?, offered: Bool) -> Bool` on
`HistoryView`, fed `premium.state.status` and `PaywallView.isOfferedHere`:

| `status` | `offered` | The switch |
|---|---|---|
| `nil` (checking) | either | absent |
| held (`isPremium`) | either | shown — a holder keeps the month even where the paywall is not offered |
| `.free` | `true` | shown, Month locked |
| `.free` | `false` | absent — History exactly as today |

When the switch is absent History is the screen it is today, unchanged in every row.

### 3.2 The screen

- **The header is unchanged in both modes.** In Week mode it names the shown day, as today; in Month
  mode it names **Today** — today's total against the goal, and the `+`, which adds to today. Logging
  stays one tap away whatever is shown.
- **The switch — *Week · Month* — is a row of its own directly under the header**, in both modes, so
  it never moves under the finger. Beside the `+` on the title's line it would have left a 375-pt
  phone 121 pt for *Wednesday, 14 Oct*, below the title's 0.5 floor (§2's header).
- **Week mode** is History as it is today, row for row.
- **Month mode, for a holder** — the rows of the one `List`, in order: the header, the switch, the
  month card (§3.3), the opened day while one is open (§3.4), the figures (§3.5).
- **Month mode, for a free user** — the header, the switch, the locked month (§3.6).
- **History opens in Week mode**, on today, every time its page is built, as it opens on today now.

### 3.3 The month card

- **A title row:** **‹**, the month and year (*October 2026*, formatted in the app's locale), **›**.
  Each arrow is a 44-pt glass circle, labelled with the month it goes to. **‹** stops at the month
  of the first serving ever recorded; **›** stops at this month. At a bound the arrow is drawn
  quieter and disabled.
- **The weekday letters**, then **the grid**: a column a weekday, a row a week, four to six rows. The
  first weekday is the **app's locale's** (Sunday under US English, Monday under Russian and Uzbek),
  not `Calendar.waterBuddyDay`'s — that calendar is fixed to `en_US_POSIX` and would start every grid
  on a Sunday. The day buttons take the week card's slot budget (`HistoryView.daySlot(across:count:)`
  at seven), exactly 44 pt each on the narrowest supported iPhone.
- **Each day is a ring** around its number: the day's total against the **current** goal, the arc
  clamped at full. **`Aurora.cyan`** when the goal was met — the ring closed, so the state is carried
  by shape as well as colour; a **white** arc for part of it; the empty track alone for a counted day
  with nothing logged.
- **Marks:** the **opened day** takes the week card's shown-day marks — `LiquidGlass.Selection`'s ring
  around its ring and its disc behind the number, the number heavier. **Today** is marked by a heavier
  number alone, so the two never collide.
- **Days that cannot be opened** — after today, or before the first serving — are drawn as a quiet
  disc with their number, not as buttons.
- **Under the grid:** a legend, *Goal met* and *Part of it* (hidden from VoiceOver — every day speaks
  its own figures), and *Measured against your current goal*, as the week card says it.
- **A month never read** (its first read failed, so `month` is still `nil`) draws the card's quiet
  form: the pane and an empty grid — no title, no arrow, no ring, no figure — until a later read
  succeeds. History holds no month of its own to name (§3.8).

### 3.4 The opened day

- **Nothing is open when Month first shows.** A tap on a day opens it; a tap on another day opens that
  one instead; a tap on the open day closes it. Moving to another month closes it.
- **It appears between the month card and the figures:** a pane with the day's name
  (*Tuesday, 13 October*) and its total against the goal (*2,000 of 3,000 ml*), then that day's strip
  (`DayStrip`, `marksReminder: false`), then its servings, newest first.
- **Read-only, for every day, in Month mode.** No row opens the sheet, no row swipes, and there is no
  `+` of its own. Correcting stays Week mode's, for the seven days it covers today, and the same for
  every user — so no correction is paid for, and no wheel is ever asked to reach a row older than the
  week it is bounded to (`tasks/lessons.md`, the wheel that snapped back).

### 3.5 The figures

Worked out by one pure value type (§3.7) from the month's rows, the first serving's instant, the
**current** goal, the injected clock and the injected calendar. No view does any of this arithmetic.

**Which days count.**
- A **past month**: every day of it.
- **This month**: the days before today, and **today once it has reached the goal** — the streak's
  rule (§2), so a morning never reads *17 / 21*.
- **The first month**: from the day of the first serving, not the 1st. A month wholly before the first
  serving cannot be reached.

**The six figures.**

| Figure | Drawn | Worked out |
|---|---|---|
| The rings | a ring a day | each day's total against the goal |
| **Days on goal** | *17/21* | met days ÷ counted days |
| **Best streak** | *9 days* | the longest run of met counted days inside the month; a run does not carry over from the month before (Home's streak chip still counts the whole run) |
| **This month** | *62.6 L* | every day's total, today's included, summed with `addingReportingOverflow`; drawn in litres to one decimal through `Decimal`, never `Double`, in the app's locale (*62,6 л*) |
| **Average** | *Average 2,920 ml a day* | counted days' water ÷ counted days, whole millilitres, empty days in the denominator (`DaySummary.average(of:)`'s rule) — so not always the total ÷ the days while today is still open |
| **The change** | *Up 240 ml on the month before* | this month's average minus the month before's, worked out the same way; *Down …*, or *The same as the month before*; left out when the month before has no counted day |

The tiles and the average line are drawn only when the shown month has a counted day.

### 3.6 The locked month

As the board *Step 2 — Month, free user*:
- **A drawn month**, blurred: rings in `Aurora.cyan` and white, no number, no date, no name, hidden
  from VoiceOver — the paywall preview's kind of decoration. Nothing Premium is worked out for a free
  user, and the month is never asked for (`showMonth` is not called).
- **Over it, a card** — `.frosted`, marked with `.premiumRim()` (§5): a white calendar glyph; *Your
  whole month at a glance*; *Every day you have logged is kept. Premium shows it as months, with your
  patterns and a recap.*; **See Premium** on the primary surface — History carries no other, so it is
  the screen's one (rule `60-design-system`); *Back to this week*, at least 44 pt tall, which turns the
  switch back to Week.
- **Under it, the promise:** a white check and *The week, today and every serving stay free. Nothing you
  logged is ever hidden or deleted.*, on a `.frosted` pane.
- **See Premium** opens the paywall through `PaywallView.Entry.history` — *a later item's own locked
  state*, which rule `70-privacy`'s *The paywall's moment* already names.

### 3.7 The model (`WaterBuddy/DataManager.swift`)

- **`MonthHistory`** — a new file-scope `nonisolated struct`, `Sendable`, `Equatable`, beside
  `DaySummary` and in this file for `DaySummary`'s own reason: `DataManager` publishes it, and every
  target that compiles `DataManager.swift` must see the type. No seventh shared file, no exception set
  changed. It carries:
  - `firstDay: Int` — the month's name: the ordinal of its 1st, through `dayOrdinal(for:in:)`, the one
    day representation (rule `30-rollover`);
  - `days: [Day]` — every day of the month, the 1st first, each a `DaySummary` with whether it is
    **counted** and whether it **can be opened**;
  - `daysMet`, `daysCounted`, `bestRun`, `total`, `average: Int?`, `change: Int?`;
  - `earlier: Int?`, `later: Int?` — the neighbouring months' first-day ordinals, `nil` at a bound.
- **One builder,** `nonisolated static func make(rows:month:firstServing:goal:now:calendar:)`, pure,
  and the statics it stands on: a month's bounds from the calendar's `dateInterval(of: .month, for:)`,
  its days walked with `date(byAdding: .day)` — never 86,400 seconds, so a DST month holds its days —
  and an ordinal back to its month's start through the same calendar.
- **Published, get-only, mirroring `history` and `historyLogs`:** `month: MonthHistory?`,
  equality-guarded; `monthLogs: [Int: [WaterLog]]`, the shown month's rows by day, newest first,
  **unguarded**, for `historyLogs`' reason. Both are empty wherever `role` does not draw history.
- **`thisMonth: Int`** — the ordinal of the 1st of the month holding `now()`, worked out on read and
  stored nowhere.
- **`showMonth(_ firstDay: Int?)`** — History's one call: which month it wants, `nil` for none. It
  writes neither store, rings no doorbell and reschedules nothing; it is a read, like `refresh()`, and
  does not join rule `20-state`'s mutation list.
- **`republishMonth()`**, private, behind `role.drawsHistory`, does nothing while no month is wanted.
  Otherwise two reads: `readLogs(from:to:)` from the 1st of the month before the shown one to the end
  of the shown one — the existing predicate, unchanged — and the first serving: oldest first,
  `fetchLimit` 1, no predicate. **Either read failing returns** and leaves `month` and `monthLogs`
  exactly as they stand (rule `20-state`).
- **Republished from:** `showMonth(_:)`; `refresh()`, after `republishHistory()`; `saveAndRecompute()`;
  `dayDidTurn()`, beside `republishHistory()`, so a month that ends on screen stays shown and becomes a
  past month; and the `dailyGoal` setter, because every day is judged against the goal. **Never from
  `init`** — nothing is wanted at launch.
- **Cost:** the month's reads cover two months whatever the history's length; the first-serving read
  is the one that grows with it. Measured in the plan's probe at 7, 45, 150 and 500 days of rows —
  `refresh()` and a pour, with and without a month shown. **The budget:** no more than 3 ms added to
  either at 500 days. Over it, the plan stops and reports; the first fallback is to hold the first
  serving's instant in memory, forgotten on every delete.

### 3.8 The view (`WaterBuddy/HistoryView.swift`)

- Reads `@Environment(PremiumStore.self)`. Its two previews inject `PremiumStore(source: .silent())`.
- **New presentation state:** `mode` (Week or Month, Week whenever the page is built), `openedDay:
  Int?`, `paywall: PaywallView.Entry?`, and haptic counters for the switch, the arrows and a day
  (`Haptics.select`, rule `60-design-system`).
- **Its calls into the model:** choosing Month as a holder — `showMonth(manager.thisMonth)`; an arrow —
  `showMonth(month.earlier)` or `showMonth(month.later)`; choosing Week, the page being left
  (`\.pageIsShown` turning `false`) and Premium ceasing to be held — `showMonth(nil)`. History holds no
  month of its own and does no month arithmetic.
- **Its decisions are `nonisolated static`s taking their state as parameters** (rule `50-views`):
  `offersMonth(status:offered:)` (§3.1) and `monthGrid(for:firstWeekday:)` — the month's days laid
  into weeks, with the leading and trailing blanks.
- **New private structs in the same file**, after its own precedent (`HistoryCard`, `DayStrip`,
  `ServingRow`): `ModeSwitch`, `MonthCard`, `MonthFigures`, `LockedMonth`. The opened day reuses
  `DayStrip` and draws `ServingRow` without its button. The file grows from 1,782 lines to roughly
  2,300; splitting it is a task of its own, not this one.
- **Glass**, every pane through `.liquidGlass(…)`: the switch, the month card, the opened day, the tiles,
  the average line, the locked card and the promise — `.frosted`, sharing the week card's elevation. The
  switch's selected half is marked with `LiquidGlass.Selection`'s fill and rim, never solid white: a
  white fill reads as the primary surface, which on the locked month is *See Premium*'s alone.
- **Motion:** the opened day comes and goes with `.smooth(duration:)` scoped by `.animation(_:value:)`
  on `openedDay`; nothing repeats, so Reduce Motion needs no branch (rule `65-accessibility`).
- **`PaywallView.Entry` gains `.history`**, presented by History's own `.sheet(item:)`, beside its
  editor sheet. Nothing else in `PaywallView` changes.

### 3.9 Accessibility

- **The switch:** two buttons, *Week* and *Month*, `.isSelected` on the shown one, each at least 44 pt
  tall. For a free user Month's value is *Premium*; its lock glyph is hidden.
- **The month card's summary** is one element: the month and year as a heading, *17 of 21 days on goal*
  as its value.
- **Each day that can be opened is one button:** its label the date spelled out (*Tuesday, 13
  October*; *Today* for today), its value *2,000 of 3,000 millilitres*, `.isSelected` on the opened
  day. The quiet days and the legend are hidden.
- **The arrows:** labelled with the month they go to, disabled at a bound.
- **The opened day's heading** is one element with the header trait, labelled and valued as History's
  own heading is; its strip speaks as it does in Week mode; each serving is one element, its label and
  value as the row speaks them now, with no button trait.
- **Each tile and the average line** is one element: *Days on goal*, *17 of 21 days*; *Best streak*,
  *9 days*; *This month*, *62,570 millilitres* — litres drawn, millilitres spoken, as the sliders
  already speak them, which also keeps a plural off a decimal; *Average 2,920 millilitres a day*, and
  the change, spoken in millilitres.
- **The locked card:** its title a heading; *See Premium* and *Back to this week* each one button; the
  drawn month hidden.
- **Dynamic Type:** each day's number is sized as a ratio of its ring, never by a text style of its
  own; the tiles stand three across where they fit and in a column where they do not (`ViewThatFits`,
  offered the row's whole width, each candidate `.fixedSize()`); every sentence wraps,
  `.fixedSize(horizontal: false, vertical: true)`. The grid keeps its 44-pt slots at every size.
- **Contrast:** every new pair is measured off renders — the rings against their track, the day
  numbers (the quiet ones too), the legend, the tiles, the average line, the switch's two labels, the
  locked card and the promise — on rings around each element's own ink, into `docs/DESIGN.md`. One
  under its floor is raised to the lowest value that passes and measured again; one whose fix changes
  the look goes to the owner.

### 3.10 What is not in this step

- **No *Month view* row in Settings' held card.** The step-1 spec §3.5 planned one per feature; it
  would be a second route to History, which rule `50-views` forbids (*Every destination has exactly one
  route to it*). That sentence of the step-1 spec is withdrawn.
- **The paywall's preview stays the drawing.** The step-1 spec allowed step 2 to draw the user's own
  month there; it does not.
- No new key, no schema change, no `project.pbxproj` edit, no exception set changed, no entitlement.
  Nothing reaches the widget or the watch, though all four widget and watch builds recompile
  `DataManager.swift`.

### 3.11 The words

New keys in `WaterBuddy/Localizable.xcstrings` only — nothing the widget draws, so none joins
`sharedKeys` — each with `en`, `ru` and `uz`, positional specifiers, and plural variations wherever a
count stands beside a noun (rule `70-privacy`):

| Key | Use |
|---|---|
| `Month` | the switch |
| `Part of it` | the legend |
| `Days on goal` · `Best streak` · `This month` | the tiles |
| `%1$@/%2$@` | days on goal, drawn |
| `%1$d of %2$d days` | days on goal, spoken; plural on `%2$d` |
| `%1$d of %2$d days on goal` | the month card's value; plural on `%2$d` |
| `%1$@ L` | this month, drawn |
| `Average %1$@ ml a day` · `Average %1$d millilitres a day` | the average, drawn and spoken |
| `Up %1$@ ml on the month before` · `Down %1$@ ml on the month before` · `The same as the month before` | the change, drawn |
| `Up %1$d millilitres on the month before` · `Down %1$d millilitres on the month before` | the change, spoken |
| `Your whole month at a glance` | the locked card |
| `Every day you have logged is kept. Premium shows it as months, with your patterns and a recap.` | the locked card |
| `Back to this week` | the locked card |
| `The week, today and every serving stay free. Nothing you logged is ever hidden or deleted.` | the promise |

Reused: *Today*, *Week*, *Goal met*, *Premium*, *See Premium*, *Measured against your current goal*,
*When you drank*, `%1$d days`, `%1$d servings`, `%1$d millilitres`, `%1$d of %2$d millilitres`,
`%1$@ of %2$@ ml` (§2). Months, weekdays and dates are formatted through the injected `\.locale`,
never keyed. **The change line names no month:** Russian would need it in the prepositional case
(*чем в сентябре*), which Foundation does not produce. The Russian and Uzbek are the plan's draft, for
the owner's sweep.

## 4. What it touches

| File | Change |
|---|---|
| `WaterBuddy/DataManager.swift` | `MonthHistory`; `month`, `monthLogs`, `thisMonth`, `showMonth(_:)`, `republishMonth()` and its five call sites; the first-serving read |
| `WaterBuddy/HistoryView.swift` | the switch, Month mode, the opened day, the figures, the locked month; `offersMonth`, `monthGrid`; the paywall sheet; the previews' `PremiumStore` |
| `WaterBuddy/PaywallView.swift` | `Entry.history` |
| `WaterBuddy/Localizable.xcstrings` | §3.11 |
| `WaterBuddyTests/…`, `WaterBuddyUITests/…` | §6 |

## 5. What this amends in the rules

Typed into the rule files **unstaged**, for the owner, before any code. Approving this document
approves this wording.

- **`20-state`**, *Clamps and guards*: "`isGoalSet`, `todaysLogs`, `historyLogs` and `streak` stay
  get-only" gains `month` and `monthLogs`; "Do not add an equality guard to the `todaysLogs` or
  `historyLogs` republish" becomes "… the `todaysLogs`, `historyLogs` or `monthLogs` republish". A new
  bullet: "`month` and `monthLogs` are published only while History has asked for a month through
  `showMonth(_:)`, behind `role.drawsHistory`, from `showMonth`, `refresh()`, `saveAndRecompute()`,
  `dayDidTurn()` and the `dailyGoal` setter — never `init`. A failed read leaves both as they stand.
  `showMonth(_:)` writes neither store".
- **`30-rollover`**, *Day bounds*: a new bullet: "A month is named by the ordinal of its 1st, its bounds
  come from the injected calendar's `dateInterval(of: .month, for:)` and its days from
  `date(byAdding: .day, …)`. Its grid's first weekday is the app's locale's, never
  `Calendar.waterBuddyDay`'s".
- **`50-views`**, *Composition*: "History is one `List` … the header, the week card, the strip and the
  servings" gains "— in Month mode the header, the switch, the month card, an opened day and the
  figures". *Navigation* gains: "History's *Week · Month* switch is a control inside the screen, not a
  route; it is drawn where `HistoryView.offersMonth(status:offered:)` says, and Month mode's servings
  are read-only — adding and correcting stay Week mode's, for every user". "The paywall is presented
  with `.sheet(item:)` bound to an optional `PaywallView.Entry`" names its two cases, `.settings` and
  `.history`.
- **`60-design-system`**, *Glass*: "Premium's card is marked with `.premiumRim()` … and nowhere else"
  becomes "Premium's Settings card and History's locked month are marked with `.premiumRim()` … and
  nothing else is". The selection bullet gains: "the month card's opened day with `Selection`'s ring
  around its ring **and** its disc behind the number, the number heavier; today's number heavier and
  without a disc".
- **`43-concurrency`** and **`85-testing`**: the two new pure suites (§6) join the lists of suites that
  are deliberately not `@MainActor`.
- **`docs/ROADMAP.md`** §5: 1.4.2's note — specified, then built.

## 6. Testing

Tests first, each run and seen **RED** before its code (rule `85-testing`).

- **`MonthHistoryTests`** (new, not `@MainActor`, pure): a past month counts every day; this month
  counts today only once it is met; the first month starts at the first serving; days on goal, the
  best run (one broken by an unmet day; one that would carry over the month's start does not), the
  total saturating on an `Int.max` row, the average with empty days, the change up, down, the same and
  absent; `earlier` and `later` at and away from their bounds; a DST month — servings at 00:30 and
  23:59 on the 25-hour day stay one day each, and the month keeps its 31 days; the same instants read
  in Paris then London regroup; the 31st at 23:59 and the 1st at 00:01 fall in their own months; a
  leap February has 29 days; a month with no rows; the goal changing re-judges every day.
- **`MonthLayoutTests`** (new, not `@MainActor`): `offersMonth`'s table (§3.1), row for row;
  `monthGrid` for a Sunday and a Monday first weekday, across a 28-, a 30- and a 31-day month, four to
  six weeks, every day once and in order; seven slots clear the 44-pt floor on the narrowest phone.
- **`MonthPublishingTests`** (new, `@MainActor`, the house fixture — throwaway suite, in-memory
  container, `reloadWidgets: {}`, `rescheduleReminders: { _ in }`): nothing is published until
  `showMonth`; `showMonth(nil)` clears both; a pour while shown republishes `month` and `monthLogs`; a
  refresh that changes nothing does not churn `month`'s observers; a failed read (`UnreadableStore`)
  leaves both as they stand; a day turning on the month's last day keeps the month and makes it past;
  a goal change re-judges it; a second instance's write is picked up by `refresh()`; `thisMonth`
  follows the injected clock. The `role.drawsHistory` guard is read, not tested: the test host is
  always `.phoneApp`, as it is for `republishHistory()`'s own guard.
- **`LocalizationTests`**: every new key resolves in `en`, `ru` and `uz`, with its plural forms.
- **`MonthUITests`** (new, `WaterBuddyUITests`): an ordinary run has no switch; with
  `-WaterBuddyPremium`, *Month* shows the locked card, *See Premium* opens the paywall, *Not now*
  closes it (waited out on the paywall's own text, `tasks/lessons.md`), and *Back to this week* returns
  to the week card. **A holder's month has no checked-in UI test:** holding Premium in a UI run needs a
  StoreKit testing purchase, whose timing is #166's. It is proved by the three suites above and by the
  walk (§7), as step 1's purchases were.

## 7. Verification

- **The gate:** rule `85-testing`'s five invocations, and the UI suite again on `OS=26.5`. The known
  red test (the privacy URL, #159) and the known flakes are reported by name, never hidden.
- **Warnings:** clean builds of a `HEAD` export and of the change, all four schemes, by file and
  message; none new.
- **The probe's cost figures** (§3.7) recorded in `docs/STATE.md`.
- **By hand — the walk,** on the simulator, with a plan bought through the local StoreKit configuration
  and without one: Month as a holder and as a free user; a month with a day opened, closed and another
  opened; both arrows to their bounds; the first month starting mid-month; a pour from the widget while
  Month is open; the app in English, Russian and Uzbek; the largest text size; VoiceOver; Reduce
  Transparency. The colour pairs measured (§3.9). The board's three states compared with the screen.

## 8. Open questions

- **The privacy policy URL** (#159) still gates every Release offer, step 2's included.
- **A quiet day's number** — the boards draw it at 0.55 white, likely under 4.5:1 on the card's glass
  (inferred); it is measured and raised to the lowest value that passes.
- **The Russian and Uzbek** wording, for the owner's sweep.
- **The probe's figures.** Over the budget in §3.7, the plan stops and reports before building on it.

## 9. Sequence

1. Probe, in a throwaway copy: the cost (§3.7) at 7, 45, 150 and 500 days; `dateInterval(of: .month)`
   on `Calendar.waterBuddyDay` across a DST month; the first weekday each of `en`, `ru` and `uz`
   resolves to.
2. Type §5's wording into the rule files, unstaged.
3. `MonthHistory` — tests first.
4. `DataManager`'s publishing — tests first.
5. `offersMonth` and `monthGrid` — tests first.
6. The words.
7. The views: the switch, the month card, the opened day, the figures, the locked month, the paywall's
   entry, the previews — then the UI tests.
8. The walk with the owner, the colour pairs, the gate, the warnings, a final review, the records.
