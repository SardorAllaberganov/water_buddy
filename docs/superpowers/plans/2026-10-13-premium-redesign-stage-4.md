# The Premium Redesign, Stage 4 (Settings) — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: `superpowers:executing-plans`, **in this session** —
> `CLAUDE.md` allows no implementation subagent. Steps use checkbox (`- [ ]`) syntax. **No step
> commits:** each task stages its own paths, and nothing is committed until the owner runs `/commit`.

**Goal:** Settings looks like the approved canvas's *Settings* board — one card-title style, one
note style, the goal figure and the vessels' amounts as the canvas sets them, the new vessels note —
and it re-reads the model when it is shown, keeps its cards in step with what it re-read, ticks under
a finger on its sliders and its language rows, and no longer scrolls under the status bar.

**Architecture:** A view change in one file, `WaterBuddy/SettingsView.swift`, plus one string in
`WaterBuddy/Localizable.xcstrings`. No model, shared, widget or watch file changes. The typography
lives in one private namespace in `SettingsView.swift` so the four titles and the three notes
cannot drift apart again.

**Tech Stack:** Swift (language mode 5; the app target defaults to main-actor isolation), SwiftUI
(iOS 17 floor; Apple's glass on iOS 26 and later through `.liquidGlass`), swift-testing, XCTest (the
UI suite and a throwaway probe), Xcode 27.0, Python 3 + Pillow for measuring (scratch only).

**Spec:** `docs/superpowers/specs/2026-10-09-premium-redesign-design.md` §7 (approved 2026-10-09,
"ok, approve all"), and the canvas's *Settings* board. No separate spec: §7 and the board are the
design, and the two decisions §7 left open were put to the owner on 2026-10-13 (below).

**Canvas:** the artifact reads "not found"; the board is copied, byte-identical, at
`…/4ac349e8-…/scratchpad/artifact-files/df046c3d-…/project/Settings.dc.html` and
`…/ffe406fb-…/scratchpad/wb-canvas/project/Settings.dc.html` (the session scratchpads of
2026-10-09 and 2026-10-11). Every canvas value below was read from that source, not from a render
(`tasks/lessons.md`, 2026-10-13).

**Ledger:** `.superpowers/sdd/2026-10-13-premium-redesign-stage-4/progress.md` (git-ignored).

**Authority for running it:** the owner's "go", 2026-10-13, to the stage as proposed with S1 and S2
as recommended, on top of the 2026-10-09 ruling "build the remaining stages straight through …
stopping only at each stage's `/commit` or a real design decision". Executed without a second
approval.

## The owner's rulings (2026-10-13, "go")

- **S1 — one note style.** The spec says the footnotes share one style; the canvas draws two (15 pt
  for the vessels note and the reminders text, 13 pt under Language). All three take **15 pt
  (`.subheadline`) at white 0.92**.
- **S2 — the ticks are `Haptics.select`.** Each step of the goal slider and the three vessel
  sliders, and a language picked, tick with `Haptics.select` — a rung rule `60-design-system` does
  not list yet (known issue #121). Stage 3b's wording for that bullet
  (`docs/superpowers/specs/2026-10-11-navigation-and-motion-design.md` §8) is typed into the rule
  file and left unstaged for the owner's yes, beside this stage.

## The canvas, read from source

| Element | Canvas | Built at HEAD `c9d1f6b` |
|---|---|---|
| Header → first card | 20 pt | 22 (stack spacing) |
| Card padding / gap | 20 pt (the vessels card 22 at its top) / 16 pt | 22 / 22 |
| Card corner | 28 | `LiquidGlass.cornerRadius` = 28 |
| Card titles | 17 pt, 600, white | three `.body.weight(.semibold)`, one `.headline` |
| Goal figure | 36 pt, 700, rounded, −0.8 tracking | 34 pt (scaled, cap 48), semibold |
| Goal *ml* | 17 pt, 600, white 0.9 | 0.4 × figure, white 0.8 |
| Range labels | 13 pt, 600, white 0.88 | `.caption`, medium, white 0.75 |
| Vessel glyph | 26 pt, cyan stroke | `.body`, cyan |
| Vessel name | 17 pt, 500, white | `.subheadline`, medium, white |
| Vessel amount | 17 pt, 700, rounded, white | `.subheadline`, semibold, white 0.75; `%1$d ml`, ungrouped |
| Vessel row → its slider / between vessels | 10 pt / 20 pt | 6 / 18 |
| Vessels note | "The Glass is the one your widget, Siri and Control Center log." 15 pt, white 0.92; 16 pt under a hairline, white 0.16 | "The middle vessel is the one your widget logs." `.caption`, white 0.70 |
| Reminders | title and switch on one line; text 12 pt below, 15 pt, white 0.92 | toggle row `minHeight 56`; `.footnote`, white 0.75, 16 pt below |
| Language | title, 6 pt, rows 50 pt with hairlines white 0.16 between; check 20 pt, cyan; footnote 10 pt below, 13 pt, white 0.88 | rows 48 pt, dividers white 0.12; check 15 pt semibold; `.footnote`, white 0.75 |
| Slider, switch | drawn by hand | the system's — kept (spec §12) |

## Global Constraints

- iOS floor **17.0**. Nothing under `#available` changes.
- Every colour from `Aurora` and white opacities (rule `60-design-system`); every pane through
  `.liquidGlass(…)`, `.frosted` + `.raised` as today.
- Volumes `Int`; a visible volume grouped with `strings.figure("%1$@ ml", …, locale:)`; spoken values
  keep their `%1$d millilitres` keys (rule `50-views`).
- Every scaled size is a real magnitude with a ceiling at its use site; a tap target `minHeight` at
  least 44 (rule `65-accessibility`).
- The labels the UI tests query stay: *Daily water goal*, the vessel names on their sliders, *Smart
  reminders*, the four language names, *Settings*.
- Haptics through `Haptics` only, each triggered by a counter the user's own touch bumps — never by
  a model value, never by the re-seed.
- Contrast floors **4.5:1** text, **3:1** glyph; clean ground is the floor (#95). Every opacity the
  canvas sets is at or above today's, so no pair should fall — measured, not assumed.
- Tests first: write, run, **see RED**, implement, run GREEN. Never narrow an assertion.
- **No new warning** against the clean baseline of HEAD (Task 0), per file and message.
- Edits with `Edit`/`Write` only. Scratch work in the session scratchpad.
- Simulators: the *WaterBuddy …* devices and the stock iOS 27.0 *iPhone 17* for unit tests;
  `uptime` first; shut down **by UDID**; `-parallel-testing-enabled NO` and
  `-collect-test-diagnostics never` on every test run; `xcodebuild` in the foreground; no UI run
  that would cross midnight.
- Never write the real App Group suite or `UserDefaults.standard`.
- Never commit. Stage explicit paths; rule files stay unstaged for the owner's yes.

## Review Focus

1. **The re-seed.** `GoalCard` and `ServingsCard` copy the model once, in `init`; after
   `.onAppear { manager.refresh() }` a changed goal or vessel must reach the card, and must not
   while a finger is on its slider. The re-seed must not write, tick or play a haptic.
2. **The largest text size and the smallest phone.** The goal row, the vessel rows and the
   reminders line at `AccessibilityXXXL` on *WaterBuddy Small 26.5*: nothing cut, the screen scrolls.
3. **The status bar (#108).** Scrolled to the end on iOS 27.0, no card is drawn under the clock.
4. **Russian and Uzbek.** The new note and the goal row in both, at the ordinary size.

## File structure

| File | Change |
|---|---|
| `WaterBuddy/SettingsView.swift` | the restyle; the note; `.onAppear` refresh; the cards' re-seed; the step and language ticks; grouped amounts; one point of top padding; DocC |
| `WaterBuddy/Localizable.xcstrings` | the new note in `en`, `ru`, `uz`; the old note removed |
| `WaterBuddyTests/LocalizationTests.swift` | `theVesselsNoteNamesTheGlassByItsOwnName` |
| `WaterBuddyUITests/GoalSetupUITests.swift` | `testSettingsSaysWhichVesselTheOneTapDoorsLog`; `testEverySettingsControlIsOneElement` |
| `.claude/rules/50-views.md`, `60-design-system.md`, `65-accessibility.md` | proposed wording — **unstaged** |
| `docs/DESIGN.md`, `docs/AI_CONTEXT.md`, `HISTORY.md`, `tasks/lessons.md` | records (Task 7) |

---

### Task 0: The ledger and the baseline

- [x] **Step 1:** `git status --short` — the index empty; the six long-standing paths modified and
  `Screenshots/census/` untracked, none of them this stage's.
- [x] **Step 2:** HEAD exported with `git archive` to the scratchpad, `build-for-testing` of the app
  scheme and `build` of the widget scheme into one empty DerivedData folder, both exit 0. Unique
  warning lines by file and message, line numbers dropped: the count goes in the ledger.

### Task 1: The failing tests

**Files:** `WaterBuddyTests/LocalizationTests.swift`, `WaterBuddyUITests/GoalSetupUITests.swift`.

- [ ] **Step 1:** In `LocalizationTests`, beside the other app-bundle checks, a test over `en`, `ru`
  and `uz`: the note's key has an entry in each table, and its value contains that table's word for
  *Glass*; the old note's key has none.
- [ ] **Step 2:** In `GoalSetupUITests`: `testSettingsSaysWhichVesselTheOneTapDoorsLog` — past setup,
  the Settings tab draws the new note as a static text. `testEverySettingsControlIsOneElement` —
  the goal slider, the three vessel sliders, the reminders switch and the four language rows each
  resolve to exactly one element (rule `65-accessibility`, *Proving it*). The second is a guard
  against the restyle and is expected green before and after; say so in the ledger.
- [ ] **Step 3: RED.** The localization test alone, then the two UI tests on *WaterBuddy Gate 27*:

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/LocalizationTests -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Test run with|failed|✘" | tail -8
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' -only-testing:WaterBuddyUITests/GoalSetupUITests/testSettingsSaysWhichVesselTheOneTapDoorsLog -only-testing:WaterBuddyUITests/GoalSetupUITests/testEverySettingsControlIsOneElement -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Executed|error:|Failing" | tail -5
```

  Expected: the localization test fails on its own expectation in all three languages; the note's
  UI test fails; the one-element test passes.

### Task 2: The string

**Files:** `WaterBuddy/Localizable.xcstrings`.

- [ ] **Step 1:** Add *"The Glass is the one your widget, Siri and Control Center log."* — `en` as the
  key; `ru` *"Виджет, Siri и Пункт управления записывают Стакан."*; `uz` *"Vidjet, Siri va Boshqaruv
  markazi Stakanni qayd etadi."* (the vessel's own word in each, and *qayd etadi* as in *Stakanni qayd
  etish*, *Log a Glass*). Remove *"The middle vessel is the one your widget logs."* The two drafted
  translations are flagged for the owner to check.
- [ ] **Step 2: GREEN** for the localization test (Task 1 Step 3's first command). Stage the
  catalogue and the test file.

### Task 3: Settings

**Files:** `WaterBuddy/SettingsView.swift`.

- [ ] **Step 1: The type.** One private namespace for the screen's type — the card title (17 pt
  semibold, `.body.weight(.semibold)`), the note (`.subheadline`, white 0.92), the card padding (20)
  and the gap (16) — read by all four cards.
- [ ] **Step 2: The goal card.** Figure 36 pt bold rounded, tracking −0.8, scaled with `.title` and
  capped at 48 as today; *ml* at 17/36 of the figure, white 0.9; range labels `.footnote` semibold,
  white 0.88. Re-seed `goal` from `manager.dailyGoal` in `.onChange(of:)` unless a drag is in flight.
  A `steps` counter bumped by the slider's binding when the rounded value moves, and
  `.sensoryFeedback(Haptics.select, trigger: steps)`; the commit keeps `Haptics.confirm` and the tick.
- [ ] **Step 3: The vessels card.** Glyph 26 pt (scaled with `.body`, capped), name `.body` medium,
  amount `.body` bold rounded, full white, through `strings.figure("%1$@ ml", …)`; 10 pt from a row
  to its slider, 20 between vessels. The note under a hairline (white 0.16, 16 pt above the text).
  Re-seed `amounts` from `manager.servings` unless a drag is in flight. The same `steps` tick.
- [ ] **Step 4: The reminders card.** The switch's row at `minHeight: 44`; the text 12 pt below, in
  the note style.
- [ ] **Step 5: The language card.** Rows `minHeight: 50`, dividers white 0.16 between rows; the
  check `.body` bold, cyan; the footnote 10 pt below, in the note style; the pick ticks with
  `Haptics.select` in place of `Haptics.confirm`.
- [ ] **Step 6: The screen.** Gaps 16, header to the first card 20; `.onAppear { manager.refresh() }`;
  `.padding(.top, 1)` on the scroll view with History's reason (#108). DocC and comments updated
  where they describe what changed (the 0.70 / 0.75 contrast notes, `GoalCard`'s and `ServingsCard`'s
  seeding paragraphs).
- [ ] **Step 7: GREEN.** The two UI tests (Task 1 Step 3's second command), then the whole unit
  target and both widget builds (Task 6's commands). Stage `SettingsView.swift` and the UI test file.

### Task 4: On the simulator — render and measure

**Files:** scratch only.

- [ ] **Step 1:** Copy the working tree into the scratchpad (`rsync`, excluding `.git`,
  `.superpowers`, `Screenshots`), and add there only: a throwaway `ZZSettingsProbe` UI test that
  passes setup, opens Settings and captures it at the top and scrolled to the end, `WB_COUNT` times
  `WB_GAP` seconds apart, and writes the frames of the labelled elements as an attachment. Build it
  into its own DerivedData.
- [ ] **Step 2: The measured set**, by `docs/DESIGN.md`'s method (the lightest pixel of clean ground
  beside each text, the text's own white composited over it), with every box drawn on an annotated
  capture and looked at before a figure is kept: the four titles, the goal figure and *ml*, the range
  labels, each vessel's name, amount and glyph, the note, the reminders text, a language row, the
  check, the language footnote — at the top and at the end.
- [ ] **Step 3:** A minute's sweep (`WB_COUNT=20 WB_GAP=3`) on *WaterBuddy Probe 27* (iOS 27.0), *Probe
  26.5* and *Fallback 18.6*. Any pair under its floor stops the stage and goes to the owner — no
  value is moved by eye.
- [ ] **Step 4:** Increase Contrast on *Probe 27* (`xcrun simctl ui <udid> increase_contrast
  enabled`, then `disabled`); *WaterBuddy Small 26.5* at the ordinary size and at
  `UICTContentSizeCategoryAccessibilityXXXL` (a launch-environment variant); the app in Russian and in
  Uzbek once each, at rest, on *Probe 27*; scrolled to the end under the clock on 27.0 (#108).
  Reduce Transparency is not re-rendered: this stage changes no pane.
- [ ] **Step 5:** A side-by-side sheet: the canvas's *Settings* board beside the build on 27.0, 26.5
  and 18.6. Shut every simulator down by UDID. Log every figure with its frames and device.

### Task 5: The rules — written, left unstaged

- [ ] `50-views`, *Getting the model* / *Navigation*: "`HomeView` and `HistoryView` do; `SettingsView`
  does not, and reads a stale goal after an external write" → all three do. *Bindings and controls*:
  a value mirrored into `@State` through `init` is re-seeded from the model's change while no drag is
  in flight.
- [ ] `60-design-system`, *Haptics*: stage 3b's bullet (its spec §8), naming `select` and `remove`.
- [ ] `65-accessibility`, *Tap targets*: "48 for a language row" → 50.
- [ ] Not staged; recorded in the ledger as waiting for the owner.

### Task 6: The review, the gate, the warning comparison

- [ ] **Step 1: A fresh reviewer** (read-only subagent) on the staged diff against spec §7, the canvas
  table above, the rules and the DocC of `SettingsView`'s types; its report saved to the ledger
  folder as it arrives; every finding checked against the code before acting.
- [ ] **Step 2: The gate**, rule `85-testing`'s invocations on this machine's destinations — unit tests
  on the stock iOS 27.0 *iPhone 17*; the UI suite on *WaterBuddy Gate 27* and *Gate 26.5*, in chunks
  (`GoalSetupUITests` by name, twelve or fewer a chunk, flags expanded as `${=FLAGS}`, the
  **executed** count read), then the other classes; the watch tests on *WaterBuddy Watch 27*; both
  widget builds. `uptime` before each, shut down by UDID between systems.
- [ ] **Step 3: The warning comparison** — the working tree exported and built exactly as Task 0 Step
  2 built HEAD, counted the same way, `diff`ed. Expected: no line that HEAD's file does not have.

### Task 7: Records, docs — then stop

- [ ] `docs/DESIGN.md`: a *Settings, stage 4* section — the canvas values, the measured table, the
  haptics table's rows for a language picked and a slider's step; older Settings rows marked as
  superseded, never rewritten.
- [ ] `docs/AI_CONTEXT.md`: a stage 4 block at the head of *Current state*; #108 retired only if the
  render shows it fixed; new known issues for anything left; the gate's counts by the attribute grep.
- [ ] `tasks/lessons.md` and `HISTORY.md`: appended with `Edit`, anchored on the last lines.
- [ ] Before reporting: every sheet searched for the names and figures this stage replaced ("middle
  vessel", `0.70`, `0.75` on Settings, "48 for a language row", "`SettingsView` does not"); every
  `SettingsView.swift:N` the sheets cite checked against the tree.
- [ ] **Two fresh readers** on the records, briefed by line range, pointed at the ledger, the gate
  logs and the saved review; each report saved as it arrives; findings checked against their
  primary source; fixes by deleting or quoting.
- [ ] Stage the code, this plan and the docs by explicit path; the rule files stay unstaged. The git
  block is written last, from `git status --short` and `git diff --cached --name-status` run then.
- [ ] **Stop.** Report: what was built, the side-by-side sheet, every measured figure that is tight or
  not taken, the translations to check, the rule wording waiting, and the commit order.
