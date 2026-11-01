# One finish: the premium look, across the app — design

**Status:** **approved by the owner, 2026-11-01 ("go"), D1–D12 as recommended.** No code of it exists yet. The owner's words, on
the export spec: *"ok, then make the premium look for whole app. not one exactly export feature"*. That widens
`2026-11-01-finish-export-design.md`, which becomes stage 1 here. Every decision below is a recommendation for the owner
to change at review. Its plan is `docs/superpowers/plans/2026-11-01-premium-look.md`, whose refinements P1–P8 amend it where the code won.

**The board:** https://claude.ai/artifact/MxsvntEKbdMGXbK1PJJqge, private to the owner: Export, Month, Recap, Insights
and the paywall, each replayable. Its motion is CSS, so its feel is an approximation, and its figures are samples. It has no
frame for stage 5: those changes are small additions to screens the owner already has on their phone.

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then `CLAUDE.md`. Where it
contradicts the code, the code wins and this document changes.

**Provenance.** Read at `feature/export`'s HEAD `9086f06` on 2026-11-01, with the store screenshots of 2026-10-26 for the
look. **The paywall, the export sheet and the schedule sheet were read from code, not from a render.**

---

## 1. What is wrong today

A count of each screen's own motion, by `grep`:

| Screen | Haptics | Glyph bounce | Rolling figures | Arrival |
|---|---|---|---|---|
| Home | 4 | 2 | 3 | yes |
| History (one file, Week most of it) | 6 | 0 | 2 | yes |
| Settings | 5 | 1 | 1 | yes |
| Welcome | 5 | 0 | 1 | yes |
| Paywall | 2 | 0 | 0 | **none** |
| Schedule sheet | 1 | 0 | 0 | **none** |
| Recap sheet and card | **0** | 0 | 0 | **none** |
| Export sheet | **0** | 0 | 0 | **none** |

The free screens had their motion pass in the redesign and `2026-10-11-navigation-and-motion-design.md`. **Everything built
after it was built still: the paid screens, the ones that have to justify a subscription.** The look is sound; it is
the finish that stops where Premium starts. Within History, the month's rings, its figures, the patterns and the insights
stand whole on arrival, while the week's bars grow.

## 2. The finish: six moves

One language, so no screen invents its own. **Every figure below obeys `tasks/lessons.md`, 2026-10-12:** motion under about
20 pt or a fifth of a second reads as nothing, and the boldest version is shown first. The quiet alternative in each case
is the same move at half its size.

| # | Move | Size and length | Where |
|---|---|---|---|
| M1 | **Data draws itself.** Structure arrives whole; then the data draws in | A month's ring sweeps to its value in 0.6 s, each day 18 ms after the last, about 1.25 s for the grid. A recap dot pops 0 → 1.22 → 1 in 0.38 s, each 22 ms after the last, about 1 s for 30 | Month's rings, the recap's dots, the patterns' bars, the paywall's preview, Home's water on opening |
| M2 | **Figures roll.** Each hero figure rolls once as its data draws | 0.8 s | The recap's, the month's three, export's count, the patterns' |
| M3 | **Sheets land.** A sheet slides in whole; what is inside moves after it has landed | Waits 350 ms, then rises 28 pt in 0.5 s, 70 ms apart | Paywall, recap, export, schedule |
| M4 | **The rim is alive.** Premium's mark gains one lap of light as it arrives. Premium's alone: it is how a paid surface says so | One lap, 1.5 s, once, a white arc over the existing gradient | Settings' Premium card, the recap's card, export's card, Insights' lead pane |
| M5 | **Every touch answers.** No tap that opens or chooses anything is silent | §4.1 | Everywhere listed there |
| M6 | **Buying is a moment.** The one tap that pays for the app is its largest moment | Two laps of the rim in 1.9 s, 28 pieces of confetti over 1.5 s, the goal's haptic | The paywall's *Thank you* |

**It runs once per arrival.** It plays on opening a sheet, on entering Month or Insights, and on turning a month's page. It
never plays on a `refresh()`, on coming back from the background or a sheet, or on scrolling a row back into view.

**Under Reduce Motion nothing travels:** data stands drawn, figures stand final, a sheet's content fades in where it stands,
and the rim has no lap. Haptics stay. `ConfettiOverlay` already draws nothing, as it should.

**VoiceOver is untouched.** No spoken value depends on an animation's flag; each reads the real figure from the first frame.

## 3. The decisions

| # | Subject | Decision |
|---|---|---|
| D1 | Scope | **Every screen of the iPhone app, free and paid.** M1, M2, M3 and M5 reach free users too: this is the finish, not a Premium feature, and it moves nothing behind the paywall (`docs/ROADMAP.md`, *The Premium line*) |
| D2 | What stays Premium's | The rim, and so M4 and M6. A free user sees it on Settings' Premium card alone, as today, which is the invitation |
| D3 | Not in scope | **Widgets:** a widget gets snapshots, not frames (rule `40-widget`). **The watch:** rule `60-design-system` keeps press response and haptics off it deliberately, so it is its own item. **Copy and colours:** no token moves, and no colour pair changes, so no earlier measurement is reopened except where §5 says |
| D4 | Rise | A new `Landing.rise`, 28 pt, for a sheet. `Arrival.rise` stays 14 pt for a tab, and `ArrivalTests` holds it at 16 or under. A sheet has room to travel; a tab's page is whole by the owner's own ruling of 2026-10-12 |
| D5 | History's Month | The rings draw from one flag on `HistoryView`, as the week's bars do, so a row recycled by the `List` does not replay. The month's card takes no rim: its cyan rings are its colour, and a rim would be a third voice |
| D6 | Insights | The lead pane takes the rim, its heading moves up to `.title2.weight(.heavy)`, and its sparkle bounces once. The other panes rise after it. A rim there is rule `60-design-system`'s fifth surface |
| D7 | Recap | The share button moves to the sheet's foot, with the note on its pane above it: today a third of a `.large` sheet stands empty. The image is never half-drawn (§5) |
| D8 | Paywall | The preview draws in, the feature rows rise, and choosing a plan springs the tile. Its price rolls only if the plan's own figure changes in place; a tile's price does not, so nothing rolls there. **The moment fires only on a real purchase**, never on a restore, which stays quiet |
| D9 | Home | **On opening the app only, the water rises from empty to today's level** on `Motion.water`, about 0.8 s. Not on a tab turn, and not on a return from the background. This is the one addition to a screen that already works, so the owner can strike it alone |
| D10 | New haptics | None in the vocabulary. `Haptics.goalReached` gains a second meaning, the purchase, because it is *"the firmest thing the app does"* and the moment is the same size |
| D11 | Order | Stages run in §4's order, each put on the owner's iPhone before the next begins. A stage that does not feel right stops the run |
| D12 | Branch | `feature/premium-look`, from `feature/export`. The three branches under it stay unmerged; this adds a fourth. If the owner wants a release sooner, merging first costs nothing here |

## 4. Stages

Each is tests first, then its own UI class, then the owner's iPhone, then staged for `/commit`.

| Stage | What | Touches |
|---|---|---|
| 0 | **The parts.** `Landing` (the sheet's arrival: its wait, rise and stagger, and a modifier that forces `pageSettlesIn` on, since a sheet inherits `false` from a turned page); the rim's lap; `RollingFigure`, one view for M2; `Haptics` unchanged | New `Landing.swift`, `RollingFigure.swift`, `PremiumRim.swift`, `Motion.swift` |
| 1 | **Export.** `2026-11-01-finish-export-design.md`, whole, with `Landing` for its arrival, #212–#214 with it | As that spec |
| 2 | **The paywall**, and the moment | `PaywallView.swift` |
| 3 | **The recap** | `RecapSheet.swift`, `RecapCard.swift` |
| 4 | **Month, patterns, Insights** | `HistoryView.swift` |
| 5 | **The rest:** Settings' Premium card lap, the schedule sheet's landing, Home's water, and M5's gaps | `SettingsView.swift`, `ReminderScheduleSheet.swift`, `HomeView.swift` |

### 4.1 Every touch answers (M5)

The gaps, from the count in §1, each a glyph bounce or a tick from a counter the user's own tap bumps (rule
`60-design-system`):

- Export's card and its share press, as the export spec's D7 and D8.
- The recap row: `Haptics.select` and a bounce on opening. Its share press: `Haptics.confirm`, if the export spec's §3.5
  measurement passes.
- History's *Week · Month · Insights* switch keeps its tick, and a month's chevron gains a tick and a bounce.
- A month's day opening keeps its ring and gains a tick.
- The paywall's buy button: `Haptics.confirm` on the press. Its close button stays silent.
- A refusal stays silent: the vocabulary has no refusal (finishing set B's D6).

## 5. What it can break, and what guards it

- **The recap's image.** `RecapCard` is both the view and what `ImageRenderer` draws, so a half-drawn card could be shared.
  `RecapCard` takes a `drawn` flag that defaults to `true`, and only `RecapSheet` passes the arriving value; the rendered path
  is never told otherwise, and a test renders it and compares pixels with the flag's default.
- **The store screenshots.** `AppStoreScreenshotUITests` would catch screens mid-draw. Each capture waits for the longest
  draw; #216's retake is where it is proved.
- **UI tests.** A hidden row stands at `Arrival.hiddenOpacity`, never zero, so nothing leaves the accessibility tree. Each
  stage's UI class runs before the owner's check.
- **A long month on an old phone.** 31 trimmed circles animating is cheap, but no device below this iPhone is at hand, and the
  floors are unproven at run time (rule `85-testing`).
- **Measurements.** No colour moves, but Insights' lead pane gains a rim and a heavier heading, and the recap's note and button
  stand on a different part of the aurora. Both are measured in their stages, by `docs/DESIGN.md`'s method. **A pair under its
  floor stops the stage.**
- **Rule `60-design-system`'s own sentence.** *"and nothing else is"* changes (§6).

## 6. Rule wording (approved with this spec, then typed unstaged)

- **`60-design-system`, *Glass*:** the `.premiumRim()` line lists the export sheet's card and Insights' lead pane. New line: "A
  rim runs one lap of light as it arrives, through `PremiumRim`, and two at a purchase. Never a lap on a loop".
- **`60-design-system`, *Interaction*:** "A sheet's content arrives through `Landing`, after the sheet has landed. A data
  surface draws from one flag on its screen. Each plays once per arrival, never on a re-read".
- **`65-accessibility`, *Reduce Motion*:** the §2 paragraph.
- **`60-design-system`, *Haptics*:** `goalReached` also marks a purchase.
- **`20-state`, `30-rollover`:** none. No model code changes anywhere in this work, except export's `preview`.

## 7. Verification

1. Each stage: its tests seen RED then GREEN, its UI class counted, and the render read at the default and largest text sizes
   and under Reduce Motion.
2. **The owner's iPhone, every stage.** A recording shows that something plays, never that it is felt (`tasks/lessons.md`,
   2026-10-12). Installed on the fresh start, so the real log is not touched.
3. At the end: all five gate invocations on 27.0, the UI suite on 26.5, and warnings against an export of `9086f06`.
4. `/doc_sync`, and `docs/ROADMAP.md` gains this as its own item.

Stage and stop; the owner runs `/commit`.
