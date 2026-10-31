# Finishing set B — design

**Status:** **approved by the owner, 2026-10-31 ("ok"), D1–D8 as recommended.** Written for the owner's review
the same day. Taken by `/start_task` with no task named, on the
owner's choice "Finish set B" over export, set C and the workout-aware goal. Eight known issues
(`docs/AI_CONTEXT.md`), set B's final review's deferred minors and the walk's one ruling: **#199–#206**. No
roadmap item of its own: set B (1.4.3, 1.4.9, 1.4.10) is committed on `feature/coaching` and on sale in code,
not merged and not released. Every decision below (D1–D8) is a recommendation for the owner to change at
review. As for finishing set A, there is no plan document. The rule wording in §5 is typed, then left
unstaged for the owner (rule `99-docs-cascade`).

**Out of scope:** #207 (the Russian and Uzbek drafts, the owner's sweep) and #208 (device-only checks).

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then `CLAUDE.md`.
Where it contradicts the code, the code wins and this document changes.

**Provenance.** Every claim about the repository was read at `feature/coaching`'s HEAD `3ca73e5` on
2026-10-31. Line numbers are that commit's.

---

## 1. What is being built

| # | Issue | Decision | Status |
|---|---|---|---|
| D1 | **#199** — the pace hides from the last reminder hour, and the set B spec's §3.1 and §3.4 still read "otherwise on track or behind" | Keep W1 as built: once every share is due, *behind* is the *to go* line above it, word for word. Write W1 into §3.1 and §3.4, marked as amended. No code: `ReminderPlan.pace`'s DocC already says it (`ReminderPlan.swift:310`) | Recommended |
| D2 | **#200** — the days row has no scroll fallback. Seven 44-pt discs need 308 pt; a 320-pt Display Zoom screen leaves 272 pt inside the 24-pt margins | Rule `65-accessibility`'s form: `ViewThatFits(in: .horizontal) { row; ScrollView(.horizontal) { row } }`. In the scrolling form the discs are 8 pt apart, so no two glass discs share an edge, and the scroll's clip is disabled, so their glass is not cut square at the margins | Recommended |
| D3 | **#201** — the hour rows are `.frosted` + `.raised`, their sibling panes `.sheer` + `.resting`, with no reason given | The hour rows take the siblings' pair: `.sheer`, `.resting`, `interactive: true` — the row is the menu's pressable surface. On iOS 26 and later, a sheer interactive pane is Apple's regular glass with the same tint (`LiquidGlass.systemVariant`, `LiquidGlassModifier.swift:276`), and elevation does nothing on that path, so on 27.0 the row barely changes; below 26 it is the hand-made sheer stack the intervals already use. The label is measured on the walk. *Alternative:* keep the pair and state a reason in the DocC | Recommended |
| D4 | **#202** — the sheet's `draft` never re-reads `manager.reminderSchedule` | Rule `50-views`' seed-and-re-read: `.onChange(of: manager.reminderSchedule)` sets `draft`. Nothing else writes the schedule while the sheet is open today, so no test can reach it; that is stated, not tested | Recommended |
| D5 | **#203** — Settings' row speaks *Not on Sat and Sun*, where the discs speak full names | `ReminderScheduleSheet.Summary` gains `spokenQuiet`: the same key, *Not on %1$@*, filled with the full weekday names. The drafts already take a list in the nominative — ru *Кроме: %1$@*, uz *%1$@ — eslatmasiz* — so one key serves both forms. No new string | Recommended |
| D6 | **#204** — tapping the last day still on does nothing: no haptic, no dimming, no reason | One rule decides it, `ReminderPlan.Schedule.mayToggle(weekday:)`, which `toggling(weekday:)` uses too. While it is `false` the disc is `.disabled` (VoiceOver says *dimmed*; it stays selected), its hint is *One day always keeps its reminders.*, and the same sentence is drawn under the row. The drawn sentence is hidden from VoiceOver, since the disc's hint already says it. No haptic: nothing happened, and the haptic vocabulary has no refusal | Recommended |
| D7 | **#205** — the pace line's `.transition(.opacity)` has no animation scope, and an empty `TimelineView` may add a gap | **Measured** by a throwaway probe (SwiftUI on macOS, `ImageRenderer`): an empty `TimelineView` in a `VStack(spacing: 8)` takes the spacing — 36 pt against 28. So a Premium Home with nothing to pace — before the first share, from the last, or with the goal met — carries 8 pt too many in its status. The fix: one `TimelineView(.everyMinute)` around the status's stack, with the pace line a plain `if let` inside it, so nothing to say is no child at all. The unscoped transition is removed: without an animation it never ran, and the line comes and goes with the figure above it, which changes in place | Recommended |
| D8 | **#206** — no end-to-end UI test of a lapsed holder's switch (locked and on), or of Home without a pace line for a non-Premium status | A DEBUG seed, `-WaterBuddyCoachingSeed`, read only beside `-WaterBuddyFreshStart`. It sets a custom schedule and *Only when behind* through the two setters, the one writer. With `-WaterBuddyPremium` and no held purchase, that is exactly a lapsed holder: free, offered, with settings left behind. Two UI tests in `CoachingUITests` (§3.8). *Alternative:* close #206 with no UI test, leaving the pure rules (`behindTapOpensPaywall`, `gate`) as the proof | Recommended |

## 2. Where it lands

- **`WaterBuddy/ReminderPlan.swift`** (shared with the widget and both watch targets): `mayToggle(weekday:)`
  on `Schedule`, used by `toggling(weekday:)` — no change in what any schedule plans.
- **`WaterBuddy/ReminderScheduleSheet.swift`** (app-only): D2, D3, D4, D5's `spokenQuiet`, D6.
- **`WaterBuddy/SettingsView.swift`** (app-only): the row's spoken value takes `spokenQuiet` (D5).
- **`WaterBuddy/HomeView.swift`** (app-only): the status's one clock (D7).
- **`WaterBuddy/WaterBuddyApp.swift`** (app-only, DEBUG): the seed (D8).
- **`WaterBuddy/Localizable.xcstrings`**: one key, *One day always keeps its reminders.* — en, with ru and uz
  drafts added to #207's sweep. App-only: it is not added to `sharedKeys`.
- Tests: `ReminderScheduleTests`, `ReminderScheduleSheetTests`, `FreshStartTests` (in `WelcomeTests.swift`),
  `CoachingUITests`.

No new file, no key in either store, no exception-set or entitlement change, nothing the widget or the watch
draws.

## 3. How it works

### 3.1 The words for W1 (D1)

`docs/superpowers/specs/2026-10-30-coaching-design.md`:
- §3.1's *"It is drawn while something is due and the goal is not reached"* gains *"and a share is still to
  come"*.
- §3.4's *"`nil` while nothing is due or the goal is reached, `.onTrack` … `.behind(Int)` otherwise"* gains
  *"or once every share is due"*.

Each is marked *(amended 2026-10-31, §7 W1)*. §7 already records the cost: a schedule that ends at 17:00
shows no pace line from 17:00.

### 3.2 The days row (D2)

`days` (`ReminderScheduleSheet.swift:196`) draws its discs in one of two whole forms. Both take `.glassGroup()`:

```swift
ViewThatFits(in: .horizontal) {
    HStack(spacing: 0) { discs, each .frame(maxWidth: .infinity) }   // today's row
    ScrollView(.horizontal) { HStack(spacing: Self.discGap) { discs } }
        .scrollClipDisabled()
}
```

`ViewThatFits` measures each form at its ideal width. The first form's ideal width is 7 × 44 = 308 pt, so it
is chosen whenever the margins leave that much: 345 pt on a 393-pt iPhone, 272 pt on a 320-pt screen. The
disc stays at the 44-pt floor. `discGap` is 8, the intervals' gap.

### 3.3 The hour rows (D3)

`hourMenu`'s pane (`:141`) becomes `.liquidGlass(cornerRadius: LiquidGlass.cornerRadius, density: .sheer,
elevation: .resting, interactive: true)`, the intervals' own call. `PressStyle` is not added: a `Menu` is not a
`Button`, and today's row has no press of its own either.

### 3.4 The draft (D4)

```swift
.onChange(of: manager.reminderSchedule) { _, schedule in draft = schedule }
```

On the sheet's root, beside `.sensoryFeedback`. `commit` keeps its `guard schedule != draft`, so the sheet's
own write comes back as a no-op.

### 3.5 The quiet days, spoken (D5)

`Summary` gains `let spokenQuiet: String?`: the same `"Not on %1$@"`, with
`standaloneWeekdaySymbols` in place of `shortStandaloneWeekdaySymbols`, in the locale's order, as a list.
`CoachingRows.spokenValue` (`SettingsView.swift:568`) appends `spokenQuiet`, and draws `quiet` as before.

### 3.6 The last day (D6)

On `ReminderPlan.Schedule`:

```swift
/// Whether the day may be turned quiet, or back: always back, and quiet while another day keeps its reminders.
func mayToggle(weekday: Int) -> Bool
```

`toggling(weekday:)` returns `self` where `mayToggle` is `false`, as it does today through `quiet.count < 6`.

In the sheet: `dayDisc` gains `.disabled(!draft.mayToggle(weekday:))` and, on that disc alone,
`.accessibilityHint(Text("One day always keeps its reminders.", bundle: strings))`. Under the row, while some
day may not be toggled, the sentence is drawn in the *Days* label's style (footnote, white,
`legibleOnBackdrop()`), hidden from VoiceOver. Its appearance
is animated with `.animation(.smooth(duration: 0.3), value: …)`, scoped to the days' `VStack`.

### 3.7 Home's status (D7)

`status` (`HomeView.swift:493`) becomes:

```swift
TimelineView(.everyMinute) { _ in
    VStack(spacing: 8) {
        Text(statusText) …                                     // unchanged
        if premium.state.status?.isPremium == true, let pace = manager.pace {
            paceLine(pace)                                     // the HStack it draws today
        }
        quietLine …                                            // unchanged
    }
}
```

The clock is re-read every minute, as both lines need: a share falls due on the hour, and a passed reminder
stops being *next*. The quiet line keeps its own `TimelineView`, inside its 44-pt frame, where an empty child
costs nothing. Its *Undo* transition and its `Motion.land` scope are untouched. `.arrives` stays outside, on
`status`.

### 3.8 The lapsed holder, end to end (D8)

In `WaterBuddyApp`, inside `#if DEBUG`, beside `storeSampleArgument`:

- `static let coachingSeedArgument = "-WaterBuddyCoachingSeed"`.
- `static let coachingSeed = ReminderPlan.Schedule(first: 5, last: 23, every: 2, quietWeekdays: [7])` — a
  pace window from 05:00 to 23:00, and Saturday quiet, so the row has a quiet day to speak.
- In `freshStartManager(arguments:now:)`, given the argument: `manager.reminderSchedule = coachingSeed` and
  `manager.onlyWhenBehind = true`, through the setters. Only there, so a seed can only ever land in the fresh
  start's own suite, which is cleared at the next launch.

`CoachingUITests` gains two tests:
- **`testALapsedHoldersSettingsKeepWorkingAndTurnOffForFree`** — fresh start, `-WaterBuddyPremium`, the
  seed, no held purchase. In Settings:
  - *Schedule*'s value names the seed's hours, *Not on Saturday* and *Premium*;
  - *Use the standard schedule* is one button;
  - *Only when behind* reads `1`; one tap turns it `0` and no paywall opens; the next tap opens the paywall,
    and after *Not now* it still reads `0`;
  - *Use the standard schedule* restores the standard summary and goes.

  Then Home has no *Pace* element.
- **`testThePaceLineIsPremiums`** — the seed, first held: Home has exactly one *Pace* element; then
  relaunched without the held purchase, with `-WaterBuddyPremium`: none. Outside 05:00–22:59 it is skipped
  with `XCTSkip`, naming the window: the line is `nil` there by design (W1), and an absence then would prove
  nothing.

## 4. Tests, written first and seen RED

Each is run with its suite named, never its file, and its count read against what was asked (lessons,
2026-10-31).

- **`ReminderScheduleTests`**: `theLastDayKeepingRemindersMayNotBeTurnedQuiet` — with nothing quiet every
  day may toggle; with six quiet, the seventh may not and the six may; `toggling` the seventh returns the
  schedule unchanged. RED: `mayToggle` does not exist.
- **`ReminderScheduleSheetTests`**: `theSummaryNamesTheHoursAndTheInterval` gains
  `summary.spokenQuiet == "Not on Sunday and Saturday"` and `standard.spokenQuiet == nil`. RED:
  `spokenQuiet` does not exist.
- **`FreshStartTests`**: `theCoachingSeedLandsOnlyBesideTheFreshStart` — given both arguments the manager
  reads the seed and the switch on; given the fresh start alone, the standard schedule and off; given the seed
  alone, `nil` (no fresh start). RED: the argument does not exist.
- **`CoachingUITests`**:
  - `testAChangeInTheSheetShowsInTheRow`'s `contains("Sat")` becomes `contains("Not on Saturday")` — a
    stronger assertion, RED against today's *Not on Sat*;
  - a new `testTheLastDayKeepingRemindersCannotBeTurnedOff`: six days off, the seventh still selected and not
    enabled. RED: it is enabled;
  - §3.8's two. RED: the seed is not read.
- **No test** for D2 (no simulator here is 320 pt wide without Display Zoom), D3 (a look), D4 (unreachable
  today) or D7's gap (a layout). Each is proved on the walk (§5); D7's mechanism is the probe's.

## 5. Verification

- **The walk**, on a fresh export, by a scratch XCUITest on a throwaway iPhone 17 (27.0), driven by direct
  commands:
  - the sheet at the largest text size, then a 320-pt render of it, choosing the scrolling days row;
  - the hour rows' label against its glass, measured off a screenshot as *Set B, measured* measured the
    discs, floor 4.5;
  - the last day, dimmed in the tree, with its line;
  - Home held, with the goal reached: the gap from *Goal reached* to the quiet line is 8 pt, not 16, read
    from the elements' frames.
- **The gate**: all five invocations, one simulator at a time, `-parallel-testing-enabled NO`, plus the UI
  suite on iOS 26.5. Warnings compared by file and message **and by site count**, against a clean build of a
  `3ca73e5` export (lessons, 2026-10-31).
- **Not proved here**: VoiceOver's speech of the hint and the row (the tree is read, not heard), and a real
  320-pt device.

## 6. The rules, proposed

Typed into `.claude/rules/`, then left unstaged for the owner:

- **`85-testing`**: `-WaterBuddyCoachingSeed` is DEBUG's set B seed, acting only beside
  `-WaterBuddyFreshStart`. It sets a custom schedule and *Only when behind* through their setters. Passed by
  `CoachingUITests` alone, and pinned by `FreshStartTests`. `CoachingUITests` also passes `-WaterBuddyPremium`
  for its lapsed holder.
- **`65-accessibility`**: in the schedule sheet, the last day keeping its reminders is dimmed, its hint the
  reason. *Schedule*'s value names quiet days in full.

`CLAUDE.md`'s *WaterBuddyUITests* row names `PremiumUITests` as the one class launched with
`-WaterBuddyPremium`. It is corrected by the doc sync after this change, not here.

## 7. Records

`docs/superpowers/specs/2026-10-30-coaching-design.md` §3.1 and §3.4 (D1). `docs/DESIGN.md` *Set B,
measured*: the hour rows' pair and their measured label; the days row's scrolling form; the last day's line.
`docs/AI_CONTEXT.md`: #199–#206 retired by dated notes. `HISTORY.md`, and `tasks/lessons.md` if the run
teaches something.
