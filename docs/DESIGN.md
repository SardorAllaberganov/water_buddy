# DESIGN — tokens and the measurements behind them

The numbers, in one place, so a future reader can tell a measurement from a preference. Every
figure here is transcribed from the source; the *arguments* are in the DocC on
`LiquidGlassModifier.swift` / `WaterSurface.swift` and in `.claude/rules/60-design-system`.

**Rule of the file:** record the measurement, not the adjective. "0.24 at 50%" survives a redesign
argument; "looked better" does not.

**Last updated:** 2026-10-22 (eighty-second pass — step 1's Task 10, after its walk and its colour
pairs). **No shared token changed; the paywall and the Premium card were measured** — a new section,
*The paywall, measured*: 74 readings off a minute at each of three places on iOS 27.0, none under its
floor, after the owner's four rulings (R1–R4) on what the first measure found. What the eighty-first
pass transcribed below no longer stands for the paywall: the badge has no pill and no cyan, the feature
glyphs have no tiles and are all cyan, the trial note and the promise's check are white, the subtitle is
full white, and the subtitle, the rows and the included line sit on one `.frosted` card. The card's
header sparkle is white; its rim is unchanged.

**Last updated:** 2026-10-22 (eighty-first pass — `/doc_sync` after set A's step 1, Tasks 0–7, staged).
**No shared token changed, and nothing was measured.** Step 1 adds Premium's own measures, all
app-only and transcribed here from the source:
`PremiumRim.width` 1.5 pt — `Aurora.cyan` → `Aurora.magenta` → `Aurora.blue`, top-leading to
bottom-trailing, stroked inside `LiquidGlass.cornerRadius` (28) over the Settings card's standard
`.frosted` + `.raised` pane; `PaywallStyle` — the welcome's text opacities, white **0.92** for lines
and **0.88** for the terms, 44 pt for the close button and every footer link, 56 pt for the primary
surface, plan tiles at least 124 pt tall with a 10 pt gap, the *Best value* badge raised 11 pt across
the yearly tile's edge on `.opaque` glass in `Aurora.cyan`, the preview's dots 14 pt and bars 34 pt
in `Aurora.cyan` and white 0.22 / 0.6; `PremiumCardStyle.buttonHeight` 56. Every new colour pair — the
tiles' lines on their `.frosted` panes, the promise and the badge on glass, the terms and the footer
on the aurora, the card's previews — is **unmeasured**: the step-1 plan's Task 8 measures each off a
render, and one short of 4.5:1 is raised to the lowest value that passes.

**Last updated:** 2026-10-21 (eightieth pass — `/doc_sync` after roadmap item 1.4.1's Task 6). **No
token changed and nothing was measured.** The paywall and Settings card staged by 1.4.1's Task 6 draw
new colour pairs (white 0.92 and 0.88 on glass and on the aurora) that were never measured: the
owner judged that design on their iPhone and had it redesigned before it shipped. The approved
design — the canvas https://claude.ai/artifact/1dyjwFfRVsLYzcvwQ6poGy and spec
`2026-10-21-premium-paywall-and-monthly-design.md` §3.4–3.5 — adds a `.premiumRim()` stroked in
`Aurora.cyan`, `Aurora.magenta` and `Aurora.blue`, and `Aurora.cyan` text on glass; the step-1 plan's
Task 8 measures every pair off renders before this sheet records them.

**Last updated:** 2026-10-21 (seventy-eighth pass — `/doc_sync` after roadmap item 1.3.2's stage 7c,
staged, before its `/commit`). **No token changed.** The watch's three faces draw no glass and no
aurora; the one token they read is `Aurora.blue`, the gauges' tint, as the circle's was before 7c.
Against a full-colour face's black it is **6.21:1** (luminance 0.2605, from `WaterSurface.swift:153`)
— computed from the token, not read off a render, which a solid background allows — over the 3:1 a
non-text glyph is held to. On a tinted face watchOS recolours the gauges, and no pair on a face was
measured. The text on a face is the system's own colour.

**Last updated:** 2026-10-20 (roadmap item 1.3.2's stage 7b, written by the session that built it —
not a `/doc_sync` pass). **No shared token changed**; the watch's screen gains its own, in
*The watch's screen, measured* — the column, the row's discs and capsule, the vessel's figure and
sign, and the scrim's ramp re-derived from the percentage — with every pair measured on watchOS 27.0,
none under its floor. The serving sheet whose amounts read 2.83:1 is gone.

**Last updated:** 2026-10-20 (roadmap item 1.3.2's stage 7a, written by the session that built it —
not a `/doc_sync` pass). **No token changed.** The watch draws Apple's glass: *Three ways to draw a
pane*, the density and elevation lists, *Interactive glass* and the container's note say so in dated
notes, and *The watch's glass, measured* holds its pairs on watchOS 27.0 — the tint stays `0.64`, on
the owner's ruling, though the serving sheet's `.secondary` amounts read 2.83:1 until 7b removes the
sheet.

**Last updated:** 2026-10-20 (the seventy-fourth pass's `/doc_sync`, after roadmap item 1.3.1's stage
6c, staged). **No token changed.** The week widget draws History's week-card values, measured again
on its own pane: *The week widget, measured* holds the eleven pairs and the method — none under its
floor, the nearest the goal line over a track at 3.06:1 and the title at 4.95:1.

**Last updated:** 2026-10-19 (the seventy-third pass's `/doc_sync`, after roadmap item 1.3.1's
stages 6a, committed in `5a46609`, and 6b, staged). **No token changed.** Since 6a the widget's two
pour buttons are the primary surface, not `.frosted` glass: *The primary surface* gains a fourth
place, and the density and elevation lists say so in dated notes. Since 6b `WidgetCardBackdrop`'s
StandBy sentence is history — in StandBy the small widget draws no card, so no backdrop.

**Last updated:** 2026-10-18 (sixty-eighth pass, the owner's `/doc_sync` again). **No token
changed.** *The water*'s table gives the welcome after the fix as 0.176 s, the figure its 3.5 % is
computed from, where it said 0.18.

**Last updated:** 2026-10-18 (sixty-seventh pass of `docs/AI_CONTEXT.md`, the owner's `/doc_sync`
after the lag fix). **No token changed.** *The water*'s older sentence still gave the slosh a
5-second window; it now gives 2.5 seconds, `WaterMotion.settling`, and when it changed.

**Last updated:** 2026-10-18 (the lag fix's records, written by the session that built it — not a
`/doc_sync` pass). **No token changed.** *The water* gains how the water now rests between pours,
with the measurements that chose its 2.5-second window and the two approaches dropped.

**Last updated:** 2026-10-17 (roadmap item 1.2.6's records, written by the session that built it —
not a `/doc_sync` pass). **No token changed.** One new measured pair: the strip's count of servings,
white 0.9 on the strip's pane — 8.17:1 on iOS 27.0, 10.64:1 on 26.5, worst of a minute's sweep — in a
dated note after the measured-pairs table. The count and the chip's noun reuse existing styles
(footnote medium, the chip's own font), so no token gains a user.

**Last updated:** 2026-10-16 (the sixty-third pass of `docs/AI_CONTEXT.md`, the owner's `/doc_sync`
after roadmap item 1.2.5). **No token changed.** One dated note: *The goal-reached burst* gains the
rating request, which waits on the burst's length (`ReviewPrompt.pause`), so the burst's 1.8 s is no
longer read by the overlay alone. The paragraph below is the sixtieth pass's, as it was written.

**Last updated:** 2026-10-14, night (the sixtieth pass of `docs/AI_CONTEXT.md`, `/doc_sync` run
again on the same tree. **No token changed.** Dated notes where the welcome had made a section
incomplete: *Motion*'s *What moves* gains the welcome's step slide, with the tests that hold it;
its held-slider row says the vessel rows are `VesselSliders`, drawn by Settings and the welcome,
and the welcome's goal figure does not grow; its account of the first run handing over says it was
seen on `GoalSetupView`; *Selection* names the calculator's unit and activity marks; *The look,
measured* says its *First run* and *Settings* rows are of screens since deleted or restyled;
`.glassGroup()` is named round the welcome's bell discs as well as Home's row, in two places; and
*The header and a screen arriving* says the welcome's steps read `ScreenMetrics` and `Arrival`.
Then, from two fresh readers: `innerCornerRadius`'s three uses in the welcome; Hello's vessel on
the clear variant, with no readout and no scrim; the welcome's two readers of Reduce Motion; the
pane counts against Apple's warning, which never had History and now name the welcome's
reminders step, ten panes; and the header note's own first form, which credited `pageSettlesIn`
with the steps being whole, corrected — nothing on them arrives.)
Before that: 2026-10-14, night (the fifty-ninth pass of `docs/AI_CONTEXT.md`, `/doc_sync`
after stage 5. **No token changed.** *Welcome, measured* corrected again, from a second pair of
fresh readers: its tightest pair is Settings' Cup glyph, 3.10 on 18.6, then the welcome's Cup
glyph, 3.25, and only then Hello's line, 4.76 — the bullet led with Hello's line and called
Settings' Cup the tightest in the same breath; and its 69 pairs are 59 on the welcome and 10 on
Settings, which the heading now says.)
Before that: 2026-10-14, evening (the redesign's stage 5's own session: a new section,
*Welcome, measured*; the haptics table's `select` and `confirm` rows and a dated note under it; a
note under *Apple's glass, measured*, where `GoalSetupView`'s range labels were still named; then,
from two fresh readers, dated notes where the welcome made a list untrue — the elevations and
densities in use, the interactive call sites (eight), the primary surface's first site, and the
older `.smooth` sites (fifteen) — and *Welcome, measured*'s own count of its first sweep, of its
final pairs (68 read of 69) and of its tightest figures, corrected).
Before that: 2026-10-14 (the fifty-eighth pass of `docs/AI_CONTEXT.md` — `/doc_sync` run
by the owner straight after the redesign's stage 4, Settings, was staged. **No source change and
no token changed in this pass.** The stage's own session wrote its part of this sheet and left this
line as it was. A fresh reader found two sentences the stage made untrue, both fixed where they
stand: *Motion* had the figure under a held slider growing from its trailing edge — a Settings
vessel's amount drawn under its name grows from its leading edge; and *Apple's glass, measured*
said the range labels "are 0.75 now" in `SettingsView`, which draws them at 0.88. Checked against
the code: the haptics table — fifteen `sensoryFeedback` sites in the app, twelve triggered by
counters, `select` and `confirm` as the stage left them; Settings' four cards still `.frosted` +
`.raised`, five panes with the bar and a sixth, *Open iOS Settings*, while notifications are
blocked; *Settings, measured*'s tightest figures as the code's comments give them — the Cup glyph
3.08 / 4.02 / 3.09, the reminders explanation 4.89 / 6.37 / 4.93. Stage 3c, which the pass below
calls staged, was committed in `a58b9e6`.)
Before that: 2026-10-13 to 14 (stage 4's own session: a new section, *Settings, measured*; the
haptics table's `select` and `confirm` rows and a dated note under it; a note under *Contrast
figures that were measured, not eyeballed* — its three Settings rows describe a card since
restyled).
Before that: 2026-10-13 (the fifty-seventh pass of `docs/AI_CONTEXT.md` — `/doc_sync` run
by the owner straight after the redesign's stage 3c, the look, was staged. **No source change in
this pass; the tokens stage 3c changed are now said where they are defined.** The stage's session
had added *The look, measured* and left the sections above it on the old glass. *The stack* names
the scrim's two colours; *`LiquidGlass.Density`* has two scrim columns, the phone's `Aurora.top`
at 0.30 / 0.70 / 0.80 and the widget's and watch's black at the old values; *Specular and edge*
says both are laid over Apple's glass; `innerCornerRadius` is beside `cornerRadius`; *The water*
has the vessel's glow, halo and highlight; *Three ways to draw a pane* has the tint as
`Aurora.top` at 0.64 and the sheen and rim drawn on Apple's glass; *Selection* has the week card's
ring and disc. Each old wording is noted where it stood. **Then a fresh reader found nine more
things in this sheet, all fixed:** *Contrast figures that were measured*, *Selection*, *Home,
measured* and *History, measured* gave pre-stage figures as current and say they are not now;
*Motion*'s marker is the ring and disc; *Interactive glass*'s edge and specular boosts reach the
rim over Apple's glass; the contrast boost was said to reach the specular, which it never has;
the glow sits on the vessel's foot, not above it; the tracks are 36–42 pt, not 43. Stage 3 and 3b,
which sections below call staged or unstaged, were committed on 2026-10-13 in `e0762ab` and
`7368dec`.)
Before that: 2026-10-13 (stage 3c's own session: a new section, *The look, measured*, and
pointers to it from *Apple's glass, measured* and *The hand-made pane, measured again*).
Before that: 2026-10-12 (the fifty-fourth pass of `docs/AI_CONTEXT.md` — `/doc_sync` run
by the owner straight after the fifty-third. **No source change and no token changed; five
statements the fifty-third pass made here are corrected, each where it stands**, found by two
fresh readers; a third and a fourth then read the corrections and found eight things each
in them, the fourth's all small, which are applied. The two builds' foot of the screen on iOS 27.0 agree to within a tolerance and were
called "identical": the table in *Apple's tab bar, measured* has the finer figures now, and
they show **the bar itself differing a little from the `TabView`'s on iOS 27.0 too**. That
section's last line still said the simulator has no switch for Reduce Motion. *Why the scroll
effect does not fade* gave one of the reviewer's two readings to the other's card. *Reduce
Motion* had four things reading the setting where three do. *One sky* named "the other two
scripts" where the stage's sections name four.)
Before that: 2026-10-12 (the fifty-third pass of `docs/AI_CONTEXT.md`, after **stage 3b's
second pass**, unstaged. **A new section, *Motion*:** the curves by name, the page slide, the
drop, the marker, the tick and the scroll effect, with what each was seen to do. *Apple's tab
bar, measured* says what the bar is now — a `UITabBar` standing alone, identical on iOS 27.0
and darker on 26.5, where its captions read 8.0:1 or better — and that its table is the
`TabView` bar's. *The header and a screen arriving* has `Arrival`'s new numbers and says the
settle is the opening page's only. *One sky*, *The haptic ladder* and *Reduce Motion* each
gain a dated note. **The scroll effect shrinks and does not fade**, and why is a contrast
figure. No glass token changed.)
Before that: 2026-10-12 (the fifty-second pass of `docs/AI_CONTEXT.md` — `/doc_sync` run
by the owner straight after the fifty-first. **No source change and no figure changed.** A fresh
reader checked this file's stage 3b sections against the code and four sentences are corrected,
each marked where it stands: the arrival hides everything under the *header*, not under the
title, and its "whole 0.3–0.4 s after the cut" is what the frames showed, not where the curves
end; `goalReached` is the one haptic driven by a model value, not the one "not driven by a
counter" — two of stage 3b's are driven by a view's own state; the aurora's curve is asked for
a value each frame since stage 3b; and three measuring scripts named as `tools/…` are in the
session's scratch folder, not in the repository.)
Before that: 2026-10-12 (the redesign's stage 3b, navigation and motion, finished and
**unstaged**; the fifty-first pass of `docs/AI_CONTEXT.md`. **Two new sections:** *Apple's tab
bar, measured* — the bar is the system's on iOS 26 and later, the selected tab is white, and the
foot of every screen is shaded by a quarter, `BarShade`, because the selected caption read
3.79–4.46:1 on iOS 26.5 without it — and *The header and a screen arriving*: `ScreenMetrics`,
where the title stands, `Arrival`'s numbers, and what was seen frame by frame on three systems.
*The aurora moves* says how the lights are placed now: by one clock every backdrop reads,
`AuroraClock`, because kept screens ran out of step and the backdrop changed at every change of
tab. *The haptic ladder* gains `select` and `remove`. **One caption is under its floor in one
configuration and stays there**; the figures by the tab bar are a first-read method and say so.
No glass token changed.)
Before that: 2026-10-11 (the redesign's stage 3, History, finished and staged; the fiftieth
pass of `docs/AI_CONTEXT.md`. **A new section, *History, measured*:** the header's two lines on
the aurora by both yardsticks, and the cards, the strip and the rows on Apple's glass and on the
hand-made pane — 32 pairs a system, the worst frame of a minute at rest and a minute scrolled.
**One line is under its floor on every system** — the total under the heading, by the
clean-ground yardstick — **and nine more of the swept pairs on the hand-made pane**, one of them
new; a tenth there, the empty state's second line, is from one capture. No token changed or was
added. New in the drawing: a day that reached the goal is cyan and one that did not is white;
the strip's bars and their dark hairline; a row's glyph in a dark well — literals in
`HistoryView.swift` — and the sheet's shortcuts, which use `LiquidGlass.Selection`.
`legibleOnBackdrop()` moved to `AuroraBackground.swift`. The elevation and density lists gain
the strip. **Older tables here keep lines for marks that are no longer drawn that way:** under
*Apple's glass, measured*, three tables have a serving row's time at white 0.75 and its drop
glyph, a fourth a *Row time* column, and the same three the week card's "average and best" at
white 0.75; and *Contrast figures that were measured* has "White @ 0.75 on the week card's
pane … the average/best figures". The row and the card's figures are drawn as *History,
measured* describes them now.
Stage 2, which the passes below call staged, was committed in `1ced514`.)
Earlier the same day (a fourth `/doc_sync` the same day, the forty-ninth pass of
`docs/AI_CONTEXT.md`, checking only what the third had added; **no source changed, nothing
measured anew**. Wrong in the third's text: "a level neither earlier build was measured at" —
stage 1's build was measured with the vessel over-full, so over a full vessel the `%` is **no
better** now, 2.71–2.75 against 2.82; "on Apple's glass each figure is one capture" — the chip's
are, *Undo*'s are the worst of three and the discs' the worst of the sweep; and the scroll note,
which held for English — **in Russian the 402-point phone is two pages from the third
accessibility size**. Tightened: the densities are "every call site but the previews' five"; the
four extra colour literals are the shipping sources', and a test and `Tools/` have their own; the
wave's colours are shared by four targets, not "both processes". In the header below, "sixty
lines under" was 208 and is corrected in place, and two of that pass's changes were not listed:
the colour-literal note and the sheet's title among the text on the aurora.)
Earlier the same day (a third `/doc_sync` the same day, the forty-eighth pass of
`docs/AI_CONTEXT.md`; **no source changed, nothing measured anew**. A fresh reader checked every
token table against the constants, every glass call site's density and elevation, the arithmetic
and each figure of *Home, measured* against the stage's ledger: **no token and no measured figure
was wrong.** Corrected: the second pass's own sentence on the densities in use, which counted four
`.sheer` capsules as three and left out the widget's buttons; the elevation list, completed; the
haptic paragraph's "a quarter of the requested change", which is half; "the three lights never
re-sync", two hundred lines under the 7.6 hours; the app's readout said to carry "the same pair" of
shadows as the widget's; Reduce Transparency, which drops the widget's and the watch's aurora
lights and not the app's; the haptic ladder's *Where* column, now with its conditions; whose build
read 2.91–3.07 before stage 2; and that the figures on Apple's glass are single captures. The two
statements about the page scrolling, which the ledger does not hold, now name their source.)
Earlier the same day (a second `/doc_sync` the same day, on the same staged tree, **no
source changed**. It corrects what the first left behind or got wrong. *Left behind — lines the
stage made false*: the densities in use, the interactive-glass list, the quick-add glyph's row,
the vessel note under *Apple's glass, measured*, the app readout's shadows, the old vessel's 280
and 58, the primary surface's users (three, with Home's Glass disc), what the glass container
wraps, the haptic ladder's *Where* column, and the one line naming `systemPane`, now
`sampling(_:)`. *Left behind — lines that were never right*: the pane count for Settings (five,
not four), which rung five call sites once spelt by hand (the first), the aurora's repeat period
(recomputed: 7.6 hours), the list of permitted colour literals, and a Settings row that gave the
vessels' names the readouts' 0.75. *Got
wrong in the new section*: Home's is not the first text on the aurora, only the first measured
there; not everything in it came from the final source — the Increase Contrast figures did not,
and say so; the `%` over a full vessel is not shown to be better than the shipped build's; the
quiet line is a fifth pair at the edge of the clean-ground yardstick; "every accessibility text
size" below means the five accessibility sizes on one phone, and the sizes under the default were
not rendered.) Earlier the same day (the redesign's stage 2, Home, finished and staged. **A new section,
*Home, measured***: text straight on the aurora carries two shadows and is measured beside its
glyphs — with the clean-ground figures beside them, because by those four pairs are under their
floor and the choice of yardstick is the owner's (known issue #95); the two new panes; every
accessibility text size, and why the vessel's floor is fixed; the *Undo* capsule's three forms.
*Type sizing* is rewritten for Home: the vessel's base is 300 and its readout is now ratios of it.
*Three ways to draw a pane* gains what a setting may and may not move, and the glass container is
built. Stage 1's "staged" is corrected to committed, `c9ef45d`.) Previously 2026-10-10 (the redesign's stage 1, finished and staged. **Apple's glass is tinted
black at `0.52`**, the first rung at which every measured pair passes through the aurora's whole
swing, and the week card's goal line is white 0.55; the table is rewritten — *Apple's glass,
measured*. The pane says its own hit region. **A new section, *The hand-made pane,
measured again*, records that the old glass reads lighter than the figures above it** — known issue
#85. The lozenge is measured on both paths. A second pass the same day corrected one row the first
had left behind: the measured-contrast table still gave the goal line as white 0.45.) Previously 2026-10-09 (stage 1, staged and not finished: `liquidGlass(…)` now
draws Apple's glass on iOS 26 and later — *Three ways to draw a pane*; the primary surface and its
derived contrast; `LiquidGlass.Selection`. **A new section records the first measurements on Apple's
glass, taken on iOS 27.0: most of the app's dimmed text is under its floor there, and the remedy is
not chosen** — known issue #80. Two statements corrected: what `Base.material`'s `opaqueFill` returns,
and "Apple's API is not reachable".) Previously 2026-10-08 (the medium widget hero's row points to known issue #76 — by reading, its
`.accessibility1` cap does not reach the `@ScaledMetric` that sizes it; no token and no measured figure
changed). Previously 2026-10-07 (History's day picker and serving sheet: seven figures measured off renders, one of them — the wheel's neighbouring rows — under the floor and recorded as known issue #59). Previously 2026-10-06 (the watch vessel's own scrim ramp — known issue #35 — and two watch figures measured off renders, one of them a pre-existing failure now recorded as known issue #44)

---

## The stack, bottom to top

`Base` → scrim (dark mode only) → white tint → specular gradient → inset stroke → two
shadows. Six layers, and each one is doing a job the others cannot. The scrim is the sky's own
blue, `Aurora.top`, on the phone's own panes and black in the widget and on the watch, since the
redesign's stage 3c (2026-10-13; `LiquidGlass.scrim(density:scheme:base:onPhone:)`; read "black
scrim" until the fifty-seventh pass):

- **The scrim is what makes dark glass work.** White alone cannot hold back a vivid background at
  any opacity a dark UI can afford: too little and the colours punch through as a coloured film,
  too much and the pane becomes a light slab with nowhere for white text to go. The scrim
  attenuates first; the tint then only supplies sheen.
- **The edge is the detail that sells it.** A flat 1pt white border reads as a drawn outline; a
  stroke bright where the light lands and nearly gone on the shaded side reads as the lit rim of
  something solid.
- **Two shadows, not one.** One alone either hugs the edge with no sense of height, or floats with
  no contact.

`cornerRadius = 28`, continuous — the iOS squircle, not a circular arc. `innerCornerRadius = 12`
for a rounded element inside a pane — the week card's tracks and bars, since stage 3c: the canvas's
12, drawn there on a track about 43 pt wide. Ours are 36–42 pt wide on the four card widths
`everyDayClearsTheTapFloor` tries (a day's slot less its 4-pt inset each side), and a pane's own 28
would round one into a capsule. *(2026-10-14, the sixtieth pass: since stage 5 the welcome uses it
three times too — the calculator's weight wheel is clipped to it, a picked activity is marked on
it, and the reminder preview's app tile is drawn on it, `WelcomeView.swift:943`, `:1036`, `:1125`.)*
`borderWidth = 1`. Default `base` is `.material(.ultraThinMaterial)`, default `density` is
`.frosted`, default `elevation` is `.resting`.

## `LiquidGlass.Elevation`

Each level is two shadows. **Dark mode multiplies both opacities by 1.5** — shadows fall on darker
ground and need more weight to register.

| Elevation | ambient `(radius, y, opacity)` | contact `(radius, y, opacity)` |
|---|---|---|
| `.flush` | `(0, 0, 0)` | `(0, 0, 0)` |
| `.resting` | `(18, 8, 0.14)` | `(3, 1, 0.10)` |
| `.raised` | `(28, 14, 0.18)` | `(4, 2, 0.12)` |
| `.floating` | `(44, 22, 0.22)` | `(6, 3, 0.14)` |

In use: app vessel `.floating`, app tab bar `.frosted`/`.floating`, Home's two glass discs and its
*Undo* capsule `.raised`, Home's streak chip `.resting` (a label, and sitting lower is what keeps it
from reading as something to press), widget card `.raised`, widget vessel and
buttons `.resting`. The Glass disc is not glass: it is the screen's primary surface. **The rest,
which this list left out until the forty-eighth pass:** `.raised` — Settings' four cards,
History's week card, its strip (the redesign's stage 3, staged), its empty state and its `+`; `.floating` — the first-run card, the serving
sheet's card and the watch's vessel; `.resting` — a serving row, the sheet's *Cancel*, *Open iOS
Settings*, and the watch's two capsules, which pass no elevation and take the default.
*(2026-10-14, the redesign's stage 5: there is no first-run card. The welcome's panes are
`.raised` — its three cards, the calculator, the reminder's preview and *Back* — except Hello's
vessel, `.floating` as Home's is, and *Use* and the bells' discs, `.resting`. Its main action is
the primary surface.)* *(2026-10-19, roadmap item 1.3.1's stage 6a, `5a46609`: the widget's buttons
are no longer glass. In full colour they are the primary surface, which casts `Elevation.raised`'s
two shadows; on a template, the rim alone, with no shadow, as every widget pane there.)*
*(2026-10-20, the redesign's stage 7a: the watch's vessel and its two capsules are Apple's glass,
which draws no shadow of this file's, so their elevations are drawn only under Reduce
Transparency's opaque pane. The capsules are `interactive: true` now.)*

## `LiquidGlass.Density`

The tint and the blur compete: every point of tint hides a point of the material behind it.
**Rendered comparisons put the light-mode ceiling at about 0.6** — past it the background stops
reading and the pane becomes flat white paint — so the scale tops out where glass still looks like
glass.

| Density | scrim (dark), the phone's own panes, `Aurora.top` | scrim (dark), widget and watch, black | scrim (light) | tint (dark) | tint (light) |
|---|---|---|---|---|---|
| `.sheer` | `0.30` | `0.16` | `0` | `0.05` | `0.22` |
| `.frosted` | `0.70` | `0.28` | `0` | `0.07` | `0.45` |
| `.opaque` | `0.80` | `0.40` | `0` | `0.09` | `0.58` |

The two scrim columns since stage 3c: the phone's own panes are a `.material` base on iOS, which
draws the hand-made stack from iOS 17 to 25 only; the widget's `.archived` base and the watch kept
black at the old values. *(2026-10-20, the redesign's stage 7a: the watch draws Apple's glass, or
the opaque fill under Reduce Transparency, so no watch pane draws a scrim now; the black column's
watch answer is kept, and `theWatchKeepsItsBlackScrim` still holds it.)* The blue figures are measured, in *The look, measured*; opaque is not the
lightest rung that passed, so the three stay in density order. (One column, black at
`0.16`/`0.28`/`0.40`, until the fifty-seventh pass; the values lived on `Density.scrimOpacity(for:)`,
which stage 3c removed.)

Use `.frosted` or `.opaque` behind body text; keep `.sheer` for short labels and controls, where a
busy backdrop cannot swallow a whole sentence. *(2026-10-14, the redesign's stage 5: the list
below predates the welcome, whose panes are `.frosted` — its three cards, the calculator, the
reminder's preview and the bells' discs — except Hello's vessel, *Back* and *Use*, `.sheer`; and
the previews' own are six, `VesselSliders`' the sixth. "The first run" among the cards below is
the welcome's.)* In use, every call site but the previews' own five: the three vessels — app,
widget, watch — `.sheer`; the cards (first run, Settings' four, History's week card, strip, empty
state and sheet, the widget's), the tab bar, Home's two discs and its streak chip, History's `+` and its
serving rows, and the widget's two pour buttons `.frosted`; Home's *Undo* capsule `.opaque` — the
app's first pane at that density, because it carries a line of text (*Home, measured*); and four
small capsules `.sheer` — the sheet's *Cancel*, *Open iOS Settings* and the watch's two. *(Read
"vessels `.sheer`, cards and buttons `.frosted`" until the forty-seventh pass, whose rewrite
counted the four capsules as three and left the widget's buttons out; corrected in the
forty-eighth.)* *(2026-10-19, stage 6a, `5a46609`: the widget's two pour buttons are the primary
surface now, not `.frosted` panes — *The primary surface*, below.)*

## Specular and edge

**Specular** — a light source above and to the left, falling off fast, with the faintest lift at
the far edge where light passes back through. `peak` is `0.28` in dark, `0.55` in light:

| location | opacity |
|---|---|
| `0.00` | `peak` |
| `0.28` | `peak × 0.22` |
| `0.55` | clear |
| `1.00` | `peak × 0.10` |

**Edge** — a two-stop gradient from lit to shaded, along the same `topLeading → bottomTrailing`
axis:

| | lit | shaded |
|---|---|---|
| dark | `0.55` | `0.06` |
| light | `0.85` | `0.18` |

**`colorSchemeContrast == .increased` multiplies the edge by 1.4**, capped at 1; the specular
takes only the press boost (*Interactive glass*). *(Read "multiplies both" until the fifty-seventh
pass; `specular` has never read the contrast setting.)*

**The specular and the edge are also laid over Apple's glass**, under the content, since stage 3c —
the modifier's `litSurface`, with the same boosts. Nothing else of the stack is: no scrim, no
tint, no shadows.

## `LiquidGlass.Base.archived` is derived, not guessed

A widget cannot sample a backdrop, so a `Material` resolves to nothing there.

```swift
static let archived = Base.flat(
    translucent: Color(white: 0.24).opacity(0.5),
    opaque:      Color(red: 0.22, green: 0.19, blue: 0.36)
)
```

**The derivation.** `platformContentUltraThinDark.materialrecipe` is a saturation boost, a backdrop
blur, and a 50% mix toward a grey chosen by remapping the backdrop's luminance through the stops
`[0.24, 0.24, 0.30, 0.39]`. Every colour in the aurora is below the first knee, so the remap is
**constant at 0.24** and the material collapses to exactly `Color(white: 0.24).opacity(0.5)`. The
blur half contributes nothing, because the aurora is already low-frequency — the same reason the
app's backdrop needs blobs at all.

The saturation boost has no backdrop to act on in a flat fill, so it is applied to
`WidgetCardBackdrop` instead, at **`1.1`**.

`opaque` is that stack composited down over the aurora — **not** the neutral
`secondarySystemBackground` grey — so Reduce Transparency keeps the product's colour instead of
turning the widget into a system slab. `Base.material`'s `opaqueFill` returns
`Base.archived.opaqueFill`, so the app, the widget and the watch draw one colour under Reduce
Transparency; `materialAndArchivedAgreeUnderReduceTransparency` pins it. *(This sentence said the
material's fill "is `Color(.secondarySystemBackground)`" until 2026-10-09. That stopped being true
when the watch target joined the file: the colour does not exist on watchOS.)*

**Do not delete the derivation comment because the number "looks arbitrary". The number is the
record of the measurement.**

## `Aurora` — colour is shared, shape is not

```swift
top     = Color(red: 0.04, green: 0.13, blue: 0.52)
bottom  = Color(red: 0.36, green: 0.10, blue: 0.62)
blue    = Color(red: 0.00, green: 0.55, blue: 1.00)
magenta = Color(red: 0.78, green: 0.25, blue: 0.98)
cyan    = Color(red: 0.00, green: 0.85, blue: 0.85)
gradient = LinearGradient([top, bottom], .top → .bottom)
```

Those five colours and the gradient live in `WaterSurface.swift` and are shared by every target that compiles it — the app, the widget and both watch targets.
**The shape of the light is not shared**, because `±240pt` means nothing in a 158pt widget.

`AuroraBackground` (app) — three blurred circles at absolute offsets, `blur = size × 0.22`:

| light | size | offset | opacity |
|---|---|---|---|
| blue | 340 | `(-130, -240)` | 0.75 |
| magenta | 320 | `(150, 250)` | 0.70 |
| cyan | 210 | `(140, -140)` | 0.38 |

`WidgetAurora` — the same three lights, positioned **proportionally** and drawn as radial gradients
whose stops are the numeric profile of the app's disc-plus-Gaussian, so the falloff matches without
the archive having to carry a blur filter at all:

| light | centre (unit) | size | opacity |
|---|---|---|---|
| blue | `(0.18, 0.10)` | `width × 1.05` | 0.75 |
| magenta | `(0.86, 0.92)` | `width × 1.00` | 0.70 |
| cyan | `(0.84, 0.20)` | `width × 0.65` | 0.38 |

Stops, as a fraction of each light's opacity, over `endRadius = size × 0.72`:

| location | `0.00` | `0.35` | `0.50` | `0.65` | `0.80` | `0.90` | `1.00` |
|---|---|---|---|---|---|---|---|
| × opacity | `1.00` | `0.98` | `0.87` | `0.57` | `0.21` | `0.08` | clear |

**Glass needs something behind it.** The blobs are not decoration: a perfectly smooth gradient gives
the material nothing to blur, and the glass disappears. Never place a glass pane over a flat
background, in the product or in a preview.

### The card's backdrop is deliberately out of register

`WidgetCardBackdrop` = `WidgetAurora` at `scaleEffect(1.22)`, `blur(radius: 12)`,
`saturation(1.1)`. Drawn larger and clipped back for two reasons: a blur samples past its own edge
and would otherwise fade the corners to nothing, and **the resulting offset is what puts these
lights out of register with the ones outside the card** — which is the whole refraction cue. A
backdrop shared pixel-for-pixel with the surround gives the eye nothing to tell the card from a
grey rectangle painted on top.

It is opaque, so it also covers the case where the system has stripped the container background: in
StandBy the card brings its own light rather than floating on bare black. *(2026-10-19, roadmap item
1.3.1's stage 6b, staged: no longer — when iOS strips the background, the small family draws no
card and so no backdrop; the vessel's rim and water and the white button stand on the black
(`docs/WIDGET.md`, *Layout*). The medium family is not shown in StandBy, which is inferred.)*

## The water

Two sine surfaces travelling opposite ways. One wave reads as a scrolling ribbon; **the
interference between two reads as a surface** — which is as true of a frozen frame as a moving one,
and is why the widget can freeze the phase at all.

| | phase | amplitude | frequency | gradient (top → bottom) |
|---|---|---|---|---|
| wave 1 | `phase × 0.85` | `amplitude` | `1.1` | `(0.35, 0.78, 1.00) @ 0.55` → `(0.04, 0.45, 0.95) @ 0.75` |
| wave 2 | `-phase × 1.25 + 1.4` | `amplitude × 0.7` | `1.7` | `(0.45, 0.86, 1.00) @ 0.90` → `(0.02, 0.40, 0.92) @ 0.95` |

Those two gradients and `LiquidGlass.Base.archived`'s two fills (above) are the **only** colour
literals allowed outside `Aurora` — rule `60-design-system`'s list. (The three shipping source folders hold four more, in
no screen: the busy backdrop of the `#Preview` at the foot of `LiquidGlassModifier.swift`. A test
and the scripts under `Tools/` have a few of their own.) *(This sentence named the
gradients "and the `Aurora` palette" until the forty-seventh pass, and left `Base.archived` out.)*

`WaveShape` damping — flatten as the vessel approaches empty or full, because an almost-empty
vessel has nothing to slosh and at the brim a wave would break the circle's silhouette:

```swift
damping = min(1, level * 9) * min(1, (1 - level) * 9)
peak    = amplitude * damping
```

Path is walked in `2pt` steps. `animatableData` exposes **`level` only** — `phase` may be supplied
fresh every frame by a `TimelineView`, so letting it interpolate would fight the clock.

**Amplitude by context:**

| | resting amplitude | phase |
|---|---|---|
| app | `diameter × 0.018` `+ diameter × 0.05 × slosh` | `WaterMotion.phase`, from `TimelineView(.animation)` while the water moves *(2026-10-18; `seconds × 1.1` until then)* |
| widget | `diameter × 0.035` | frozen at **`0.6`** |

The widget's is roughly double because the app's 1.8% is 5.4pt of surface at 300pt and only 1.7pt at
92pt — flat. *(5pt at 280pt until the redesign's stage 2 made the vessel 300.)* The frozen phase `0.6` is picked so both waves show a crest and a trough across the
vessel's width rather than crossing zero flat in the middle.

App slosh decays as `exp(-elapsed × 1.5)` over a 2.5-second window after a pour — `WaterMotion.settling`,
5 seconds until 2026-10-18 (below). Water is inset —
`padding(10)` in the app, `padding(diameter × 0.04)` in the widget — so it sits in a well and can
never cover the vessel's lit rim.

**The water rests between pours, since 2026-10-18** (`WaterMotion`, spec
`2026-10-18-the-waters-cost-design.md`). The app's phase is no longer `seconds × 1.1`: after a pour
it sets off at 1.1 rad/s and eases evenly to a standstill — `settling × (u − u²/2)` seconds of
travel, `u` the share of the window gone — then stands, and the next pour carries on from where it
stood. The window, `WaterMotion.settling`, is **2.5 s**, and the slosh shares it: at 2.5 s
`exp(−1.5 t)` has the slosh at 2 % of its height. Home's vessel runs its `TimelineView` only while the
water moves and the app is active; the welcome's hello vessel moves for the same window each time
its step is shown. **Measured, not chosen** (simulator, Debug, the app's own CPU over five seconds):

| | before | after |
|---|---|---|
| Home, idle | 0.83 s (17 % of a core) | 0.20 s (4 %) |
| The welcome's first step, idle | 1.10 s (22 %) | 0.176 s (3.5 %) |
| A pour and the five seconds after it | 1.78 s (36 %) | 1.15 s (23 %) |

Of a pour, the water moving under glass was the cost — 1.65 s with it, 0.73 s without; the drop,
the swell, *Undo* and the level's spring each fell within the noise. A 4 pt path step saved nothing,
and moving a wider wave instead of redrawing it made the pour heavier (spec §4). The level still
animates as before, and under Reduce Motion nothing travels at all.

**Home's vessel has depth, since stage 3c** — the canvas's, as ratios of the diameter (`HomeView`'s
private `Depth`), in the app only:

| | shape | colour | size, as a ratio of the diameter |
|---|---|---|---|
| glow | an ellipse centred on the foot, blurred `0.033` — the canvas's sat just above it, and the code's comment still says so (#125(e)) | `Aurora.cyan` `0.36` → clear | `0.76` × `0.21` |
| halo | a ring outside the rim | white `0.05` | `0.033` wide |
| highlight | an ellipse at the top left, turned `-28°` | white `0.4` → clear | `0.427` × `0.207`, from `(0.10, 0.067)` |

The glow and halo sit behind the glass; the highlight sits between the readability scrim and the
readout, away from the readout's figures. None of the three is drawn under Reduce Transparency.

## The readability scrim

**White on the bright cyan surface at full measures about 1.4:1.** `WaterReadabilityScrim` makes
the contrast a constant, and reads as depth rather than as a plate:

```swift
RadialGradient(
    colors: [.black.opacity(0.45 * intensity), .black.opacity(0.22 * intensity), .clear],
    center: .center, startRadius: 0, endRadius: diameter * 0.5
)
```

The app keeps `intensity` at **1**. The widget scales it with **`min(1, level * 1.6)`** — at 0%
there is nothing bright to hold back and a full scrim only turns a small vessel into a black hole.

The watch scales it too, on a ramp of its own: **`WristVessel.scrimIntensity(at:)`**, none at 0%
and full strength by **20%**. It had the app's constant until 2026-10-06, and its empty vessel drew
as a near-black disc (known issue #35). **The widget's ramp cannot be borrowed.** It is calibrated
to the widget's readout — a large, centred percentage, held to 3:1 — while the watch's lowest
readout is the small millilitre line *below* centre, held to 4.5:1, which water first reaches at
`(0.2625·D − 6) / (D − 12)`: 0.203 at the 60pt floor, about 0.23–0.24 on real watches. That line
has no contrast to spare over water even at full strength (the table below), so the ramp has to be
full before water can reach it; the widget's would have left it at about 3.0:1. Each small canvas
calibrates its ramp to where its own text sits.

## Contrast figures that were measured, not eyeballed

| Figure | Measured | Consequence |
|---|---|---|
| White @ 0.8 over the bright wave fill | **3.4–3.9:1** | **Not** safe at the widget's 12pt `%` (small text, 4.5:1) — so the widget draws that glyph at **full white** and subordinates it by size alone. *The app drew its `%` at this white until the redesign's stage 2, 25pt and safe as large text; it is 30pt, bold and full white now, and measured in *Home, measured*.* |
| White over the bright cyan surface, full | **~1.4:1** | Why the scrim exists at all. |
| White @ 0.8 on the watch vessel's bare glass at 0%, no scrim | **8.58:1** worst column (46mm), **8.60:1** (40mm) | Why the watch's scrim can go to zero when the vessel is empty: the glass alone holds the millilitre line far above 4.5:1. Read off renders after the #35 fix; the glass reads sRGB `(36, 43, 95)` where the full scrim had it at ≈`(24, 28, 62)` — the black hole. |
| White @ 0.8 over water, the watch's millilitre line, full scrim | **3.34:1** worst, **4.13:1** median, **4.65:1** best — under 4.5:1 across **77%** of the line | **A real failure, and pre-existing** — known issue #44, not fixed. The scrim is radial and thins toward the line's ends, and the watch's readout dropped the text shadow and the 0.85 opacity the app's line had then (the app's line is full white with four shadows since the redesign's stage 2 — *Home, measured*). Read off the 63% census capture, column by column, the ground sampled from the clean rows just above and below the line — a first pass that took the darkest pixels *within* the band read glyph ink as ground and published "≈4.7:1 at its centre, 3.3–3.5:1 toward its ends". It is also why the watch's ramp must be full before water reaches the line. |
| `Aurora.cyan` on the tab bar's pane | **4.34:1** | Fine for the active **glyph** (non-text, 3:1) and **under the 4.5:1 floor for the label beside it**. So the tab bar tints the icon, never the caption — the first draft tinted both and was a real violation. Pane sampled at sRGB `(0.388, 0.282, 0.484)`. |
| White on the tab bar's pane, full | **7.66:1** | The active label. |
| White @ 0.72 on the tab bar's pane | **4.89:1** | The inactive label — clears 4.5:1, so the inactive state is a real dimming rather than a token one. |
| White @ 0.55 on the week card's pane | **4.06:1** | **A real failure, caught by measuring.** The *Measured against your current goal* disclosure was drafted at 0.55 and is small text, so its floor is 4.5:1. It looked perfectly legible. Raised to **0.70 → 5.49:1**. |
| White @ 0.60 on the week card's pane | **4.50:1** | The weekday captions as first written — *exactly* the floor, with no margin for the aurora drifting lighter beneath the pane, which it does continuously. Raised to **0.72 → 5.70:1**. |
| White @ 0.75 on the week card's pane | **6.02:1** | The average/best figures. |
| White @ 0.45 on the week card's pane | **3.26:1** | The goal reference line as it was drawn until 2026-10-10 — non-text, 3:1. **The line is white 0.55 now**: on Apple's glass 0.45 fell to 2.85:1 as the aurora swung (*Apple's glass, measured*); at 0.55 it reads 3.74:1 there at its worst, and 2.80:1 on the hand-made pane of iOS 18.6 (*The hand-made pane, measured again*). |
| `Aurora.cyan` on the week card's pane | **5.22:1** | The bar fill — non-text, 3:1. |
| `Aurora.blue` on the week card's pane | **2.72:1** | **Under the 3:1 floor**, which is why the bars are a solid cyan and not the `Aurora.blue` → `Aurora.cyan` gradient they were first drawn with. Below `t ≈ 0.15` along that gradient the fill fails, and a nearly-empty day is drawn almost entirely in that end. |
| White @ 0.72 on the week card's pane, the full-width day row | **5.43:1** | The weekday letters, re-measured 2026-10-07 once the days became full-width buttons; pane sRGB `(0.208, 0.296, 0.444)` at the letters. Still clear of 4.5:1, a shade under the first layout's 5.70:1. |
| White inside the shown day's rim | **7.4:1** | The shown day's letter, full white and bold; pane inside the rim sRGB `(0.258, 0.343, 0.440)`. A first sample taken at the rim's curve read the stroke as ground and gave 4.84:1 — resampled at four points clear of both stroke and glyph, 7.36–7.54:1. |
| White @ 0.55, the shown day's 1pt rim | **4.15:1** rendered, **4.16:1** derived | Non-text, 3:1. Pane beside it sRGB `(0.188, 0.277, 0.390)`. It carries the selection with the letter's weight and `.isSelected`, never colour alone. |
| White on History's `+` | **11.69:1** | The glyph; the circle's glass sRGB `(0.192, 0.210, 0.354)`. |
| White / white @ 0.70 on the empty past-day pane | **8.03:1** / **5.24:1** | *Nothing logged that day* and *Tap + to add a serving you forgot.* |
| The serving sheet's wheel, the row being set | **5.47:1** | System-drawn (`UIDatePicker`, `.wheel`), so read off its brightest glyph pixel against its band, sRGB `(0.292, 0.259, 0.404)`. |
| The serving sheet's wheel, the rows around it | **2.43–2.80:1** | **Under the 4.5:1 floor — known issue #59, accepted by the owner on 2026-10-07 as the system control's styling.** UIKit draws them in a dimmed grey that assumes a near-black backdrop, and no public API recolours them. Switching the card to `.opaque` adds scrim and tint together, and is estimated — not measured — to darken it too little to help. |
| White @ 0.70 on the **Settings** cards' pane | **5.50:1** | `ServingsCard`'s *"The middle vessel is the one your widget logs."* The figure was first *borrowed* from the week card's measurement and only verified afterwards — see the note below, because borrowing it was not sound and it happened to hold. |
| White @ 0.75 on the Settings cards' pane | **6.04:1** | The vessels' millilitre readouts. *(The names beside them are full white — `SettingsView` gives only the readout the 0.75; this row named both until the forty-seventh pass.)* |
| `Aurora.cyan` on the Settings cards' pane | **5.26:1** | The vessel glyphs and the slider tint — non-text, 3:1. Comfortably clear here, unlike the same colour on the tab bar's lighter pane at 4.34:1. |
| Black status-bar glyphs over the indigo backdrop | **1.57:1** | Why `RootTabView` uses `preferredColorScheme(.dark)` (travels *up*, sets the window style → **13.39:1**) and not `.environment(\.colorScheme, .dark)` (travels *down* only). A widget has no status bar and no hosting controller to hear a preference, so `HydrationView` uses the environment form — the shape `HomeView` rejects, for the opposite reason. |

**Every row above that is on one of the phone's panes was measured before stage 3c** (2026-10-13),
which re-tinted those panes with `Aurora.top` and redrew the week card: the disclosure is white 0.88
now, the weekday letters full white, the shown day a ring (white 0.8, 1.5 pt) round its track with
its letter in `Aurora.top` on a white disc, and the goal line a 1.5-pt dashed rule at white 0.62.
Today's figures for them are in *The look, measured*; the rows stay as the record of their day.
*(Noted in the fifty-seventh pass, after a fresh reader found "The line is white 0.55 now" still
reading as current.)* *(Stage 4, 2026-10-13: the three Settings rows describe a card since restyled —
the note now reads "The Glass is the one your widget, Siri and Control Center log." at white 0.92,
and the vessels' amounts are full white. Today's figures are in *Settings, measured*.)*

The widget's readout carries **two** shadows — where the app had one until the redesign's stage 2,
and has two of its own now (the end of this paragraph): `(0.3, radius 6, y 1)` plus a
tight `(0.45, radius 2)`. The scrim is radial and centred on the vessel, so it is nearly gone by
the time it reaches the `%` out on the right — and that glyph is also the smallest, held to 4.5:1
rather than 3:1. The tight second shadow is a local halo that travels with the glyph and carries it
over the line. (App, since stage 2: `(0.3, radius 10, y 2)` and the same tight `(0.45, radius 2)`
on the readout, and the widget's pair again on the millilitre line — four on that line in all.
Until then: the first of those alone.)

**The three tab-bar figures were sampled from a rendered screenshot, not derived.** The pane is a
`Material` over the aurora, so its composite is not computable from the tokens — the only honest
way to get the number is to render the bar and read the pixels back. That is also why the
violation existed at all: it is invisible in the source, in the unit suite, and in any reasoning
about the palette.

**Two `.frosted`/`.raised` cards on different screens are not the same pane, and it is luck that
these agree.** `ServingsCard` shipped citing the week card's 5.49:1 for its disclosure line. That
was a *borrowed* figure, not a measured one — the two cards sit at different heights over a moving
aurora, and the rule is to sample the pane the text actually lands on. Measured afterwards, the
Settings pane is sRGB `(0.350, 0.227, 0.440)` at its foot against the week card's
`(0.214, 0.283, 0.398)` — visibly **more magenta**, because it sits lower over that lobe — and yet
`L = 0.0631` against `0.0640`, near enough that white at 0.70 lands on **5.50:1** either way.

Hue moved and luminance did not, so the ratio survived. Contrast is a luminance relationship, which
is exactly why that can happen — and exactly why it cannot be relied on: nothing about the design
guarantees two panes share a luminance, and the next card placed somewhere else has no such luck.
**Measure the pane the text is on.**

**A sampled figure can still measure the wrong thing.** The bars were first published here at
"**3.33:1** at the blue end" — a real number, read off a real rendered bar. It was wrong anyway:
that pixel region is the *average* of a blue→cyan gradient across a short bar, not the gradient's
blue **endpoint**, which composites to **2.72:1** and fails. Sample the extreme a colour actually
reaches, not a patch of the thing wearing it.

**So were the week-card figures**, and the method matters: the card's pane was sampled at
**both** ends — sRGB `(0.191, 0.244, 0.376)` at the head and `(0.214, 0.283, 0.398)` at the foot,
because the aurora is lighter under the bottom of the card — and every ratio was computed against
the **lighter** of the two, which is the worst case for white ink. Sampling only the top would have
reported the disclosure line at a passing figure. The card sits at `.frosted`/`.raised`, the same
pair as `HistoryView`'s empty state.

**The 2026-10-07 figures were read off XCUITest screenshots** of the iPhone 17 simulator (iOS 26.5),
taken by a throwaway probe test that attached them and was deleted afterwards, and exported with
`xcrun xcresulttool export attachments` — no product hook. White-ink figures are computed against
the pane sampled beside the mark, as above; the wheel's, being system-drawn, against its own
brightest glyph pixel. The day row's geometry behind them: seven equal slots across the card's full
width — `(375 − 2 × 28) / 7 = 45.6` pt on the narrowest supported iPhone, 49.4 pt on the iPhone 17 —
each bar `barInset` (8 pt) in from its slot, so 16 pt between bars and 8 pt from the card's edge.

## Type sizing

`@ScaledMetric` must scale a **real magnitude, never a unitless `1`**: it resolves through
`UIFontMetrics`, which rounds to the nearest third of a point, so scaling `1` quantises twelve
Dynamic Type categories into three distinct sizes and the widget would not move at all between
Large and XXL.

| Readout | base | `relativeTo` | bound |
|---|---|---|---|
| app vessel diameter | `300` | `.largeTitle` | what the rest of Home's column leaves, between `HomeView.vesselFloor` (`200`, fixed) and `min(scaled, 340)`, and never wider than the column (`min(…, width)`) — `HomeColumn`, a `Layout` |
| app figure, `%` and millilitre line | — | none: ratios of the vessel | `diameter × 0.28`, `× 0.1`, `× 0.057` (84, 30 and 17 pt at 300); `frame(maxWidth: diameter × 0.78)`, `minimumScaleFactor(0.4)` |
| Home's side discs | `68` | `.title3` | `44…92` |
| Home's Glass disc | `88` | `.title3` | `44…120`; the primary surface's ring adds 6 pt a side |
| a disc's glyph; its amount; its name | — | none: ratios | `disc × 0.4`; `side disc × 0.22` and `× 0.18` (15 and 12 pt at 68) |
| widget `%` | `27` | `.largeTitle` | `min(readoutSize, diameter × 0.33)` |
| widget medium hero | `28` | `.title2` | `minimumScaleFactor(0.6)`, capped at `.accessibility1` — by reading, the cap does not reach this metric, which sits above it (known issue #76, not rendered) |

The widget's `%` glyph is `size × 0.44`; the app's has been a ratio of the vessel since the
redesign's stage 2 (0.1 of the diameter, 0.36 of the figure). **Until 2026-10-11 the app's vessel
was a `@ScaledMetric` of 280 and its figure one of 58, the `%` 0.44 of the figure**; both rows above are stage 2's. The medium family's `of N ml` line is **`totalSize × 0.46`
— a ratio of the figure it annotates, not its own text style**: `.footnote` and a fixed 28pt hero
are the same size at default and cross over at the accessibility sizes, so the annotation would end
up bigger than the number. A ratio cannot invert.

## The aurora moves

Three lights, drifting and cross-fading between `Aurora` colours, so what crosses the backdrop is
hue and not merely shape.

| | colour → | size | rest | drift | period |
|---|---|---|---|---|---|
| 1 | `blue` → `cyan` | 340 | `(-130, -240)` | `(70, 90)` | 16 s |
| 2 | `magenta` → `blue` | 320 | `(150, 250)` | `(-90, -60)` | 22.5 s |
| 3 | `cyan` → `magenta` | 210 | `(140, -140)` | `(-60, 80)` | 28.5 s |

The periods were 19 / 27 / 34 and were shortened on request, to run about **20% faster**
(18.8%, 20.0% and 19.3% faster; the periods themselves fell 15.8%, 16.7% and 16.2%). They were
**re-chosen rather than divided by a constant**: scaling all three by one factor preserves their
ratios exactly, and the ratios are the thing that stops the lights beating together. Doubled to
whole seconds the new set is 32 / 45 / 57, whose lowest common multiple is 27,360.

**How long before the field repeats — recomputed in the forty-seventh pass.** A period is one
*leg*: until 2026-10-12 `AuroraBackground` animated with `.easeInOut(duration: light.period)` and
`repeatForever(autoreverses: true)`, and `AuroraDrift` draws the same journey on the same curve
(*One sky*, below), so a light is back where it started, moving the same way,
after two periods — 32, 45 and 57 seconds. All three are back together after their lowest common
multiple, 27,360 seconds: **7.6 hours**. The old set's there-and-backs were 38, 54 and 68 seconds,
and 34,884 seconds — 9.7 hours — so the new set repeats sooner, not later; either is far past
anything a session will see. *(This paragraph read "3.8 hours to approximately repeat, up from
2.5" until then: 27,360 taken as half-seconds, beside 17,442 — the old set's own lowest common
multiple, never doubled — taken the same way. The DocC in `AuroraBackground.swift` still says 3.8
and calls a period "one there-and-back" — `docs/AI_CONTEXT.md` known issue #103.)*

Three constraints, each with a test behind it:

- **The resting frame is the design that shipped.** `rest` and `opacity` are the numbers the static
  backdrop always drew, so Reduce Motion is not a degraded version of the effect — it is the
  previous product exactly. Measured: the static build sampled sRGB `(10.8, 96.7, 206.4)` over a
  260×260 region away from the vessel; the animated build at rest, `(11.2, 96.5, 204.4)`.
  Seven seconds later, `(15.9, 93.0, 175.5)`.
- **No light drifts off its own footprint** — `drift < size / 2`. The blobs exist to give the
  material something to blur; one that wandered further than its own radius would take that texture
  out from under the glass on the way past.
- **The three periods are pairwise non-harmonic.** Equal or harmonic periods put the lights on a
  shared beat the eye reads as a pulse. Same reason `WaterSurface` interferes two waves at different
  frequencies rather than scaling one.

Two endpoints and a curve rather than a `TimelineView`: the view's body is not run again per
frame. *(Read "there is nothing to recompute per frame" until the fifty-second pass — true of the
built-in repeating curve, which the render server carried whole. Since stage 3b the curve is
`AuroraDrift`, which SwiftUI asks for the lights' place each frame and which reads the clock to
answer — arithmetic on one number, and no body; see *One sky*.)*
The colour cross-fade is **two stacked
fills interpolating opacity**, not one animated `fill` — a `Shape`'s style is not itself animatable.
One blur covers both, so it costs a second fill and not a second blur.

### One sky

*Added 2026-10-12, the redesign's stage 3b.* Every screen stands its own `AuroraBackground`. The
curve was `easeInOut(duration:).repeatForever(autoreverses: true)`, which counts from the moment
it starts, and each screen started its lights the first time it was shown. Under the app's own
container a screen was rebuilt on every change of tab, so its backdrop restarted from rest inside
an eight-frame cross-fade. Under Apple's `TabView` (iOS 26 and later) a screen is kept, its
lights go on running, and the three stood out of step for the rest of the session: **the
backdrop changed at every change of tab.**

*2026-10-12, stage 3b's second pass:* the three tabs no longer stand a backdrop each. Their
pages slide, and a backdrop inside a page would slide with it, so `RootTabView` stands one
behind all three and the pages are clear. The first-run screen and the serving sheet still
stand their own, and the one clock is what makes them the same sky as the tabs': the first-run
screen hands over to the app by a cross-fade in place, and the frames of it show one backdrop.
The figures below are the first build's, taken when each tab had its own.

Read in the screens' side margins, x 2–18 pt and 384–400 pt, y 250–720 pt, on a 402 × 874 pt
phone, iOS 27.0, nine captures of one walk (`tools/margins.py`, in the session's scratch folder
and not in the repository, as are the other four scripts this stage's sections name — `sky.py`,
`selected.py`, `barcontrast.py` and `caption.py`; "the other two" until the fifty-fourth pass
of `docs/AI_CONTEXT.md`, which added two of its own there, `maxdiff.py` and `bands.py`; mean change
over the two strips, levels of 255):

| | Before | With one clock |
|---|---|---|
| Home → Settings, Settings shown for the first time | 16.3 | 5.7 |
| Settings → Home | 12.5 | 4.1 |
| Home → History, History shown for the first time | 14.8 | 6.6 |
| History → Home | 5.7 | 5.3 |
| Four seconds on one screen, no change of tab | 3.1–5.5 | 3.4–5.2 |

Those captures are a second or more apart, so the right-hand column is drift, not a jump. Frame
by frame off a recording, in three patches above the header where no screen draws anything
(`tools/sky.py`, the session's scratch folder): **the largest change between consecutive frames across Home → History is 0.56
and across History → Home 0.43, against a steady 0.3–0.5** on either side of the cut.

`AuroraDrift` is a `CustomAnimation`: asked for a light's displacement, it reads `AuroraClock` —
the device's uptime since the first backdrop was drawn — and returns the place on the journey
that clock says, by `UnitCurve.easeInOut`. It is not asked how long it has been running. The
clock starts at nothing, so the app still opens on the resting frame; Reduce Motion still passes
no animation and draws the resting frame alone. `AuroraDriftTests` pins the journey, the curve's
symmetry and that the clock alone places a light; what no test can call is `animate` itself —
`AnimationContext` has no public initialiser — and the recording is its evidence.

**The widget's aurora does not move and cannot.** A widget's view is an archive replayed by another
process, with no clock (rule `40-widget`).

## Three ways to draw a pane

**What a setting may move (stage 2, 2026-10-11).** The pane changes with Reduce Transparency; what
is *inside* it does not move. `LiquidGlassModifier.routed` branches on the pane's base, which is
fixed where the modifier is written, and never on the rendering: a `.material` pane on iOS 26 and
later is always `content.background(own pane).glassEffect(…)`, handed `Glass.identity` when the pane
is not Apple's, so flipping the setting under a running screen rebuilds nothing in the pane. Until
then each rendering put `content` in its own branch (known issue #91a). Flipped on and off under
Home on iOS 27.0 and 26.5: every pane went opaque and came back, and every control answered after
each flip. **Sibling panes that sit close together are wrapped with `.glassGroup()`** — Apple's
`GlassEffectContainer` on iOS 26 and later, nothing elsewhere — as Home's quick-add row is, and,
since stage 5, the welcome's seven bell discs (`WelcomeView.swift:1193`).

Since the redesign's stage 1 (2026-10-09; committed 2026-10-10 in `c9ef45d`), `liquidGlass(…)` draws one of three panes, and
`LiquidGlass.rendering(base:reduceTransparency:systemGlassAvailable:)` chooses, in this order:

| Condition | Pane |
|---|---|
| Reduce Transparency is on | the opaque fill and lit rim, on every OS (`.opaque`) |
| the base is `.flat` — the widget's `.archived` | the hand-made stack (`.handMade`) |
| the base is `.material`, iOS 26 or later, or the watch | Apple's glass, `glassEffect(_:in:)` (`.system`) |
| the base is `.material`, below iOS 26 | the hand-made stack |

*(The table's last two rows read "iOS 26 or later" and "below iOS 26 — and the watch, for now" until
the redesign's stage 7a, 2026-10-20.)*

- `LiquidGlass.systemGlassAvailable` is `true` on iOS 26 and later and, **since the redesign's stage
  7a (2026-10-20), on the watch** — `#available(iOS 26.0, watchOS 26.0, *)`, which on the watch,
  whose floor is 26.0, is always true; `theWatchDrawsAppleGlass` holds it. The watch's panes were
  rendered and measured on watchOS 27.0 only (*The watch's glass, measured*): no watchOS 26.x
  runtime reached this Mac, and on the owner's ruling the stage went ahead without one, so the
  watch's floor runs Apple's glass compile-verified. *(Until 7a: **`false` on watchOS**, by
  `#if os(iOS)` — no watch pane had been drawn on Apple's glass. The flag's own DocC gave the missing
  runtime as its reason until the redesign's stage 2 corrected it — known issue #91d.)*
- **Everything above this section describes the hand-made stack.** On Apple's glass the scrim, the
  tint and the two shadows are not drawn, and `tint`, `tintOpacity` and `elevation` are ignored.
  The specular and the lit rim **are** drawn, over the glass and under the content, since stage 3c
  (`litSurface`), so `borderWidth` and the highlight points apply there too. (Read "the specular,
  the rim … are not drawn" until the fifty-seventh pass.)
- The variant: `density: .sheer` on a pane that is not interactive takes `Glass.clear` (the vessel,
  whose readout has its own scrim); every other pane takes `Glass.regular`. `interactive: true` adds
  `.interactive()`. `LiquidGlass.systemVariant(density:interactive:)` is the mapping.
- **The regular variant is tinted with the sky's own blue**, through Apple's own `Glass.tint(_:)`:
  `LiquidGlass.systemTintColor`, which is `Aurora.top`, at `LiquidGlass.systemTintOpacity(for:)`,
  **`0.64`**. The clear variant takes none — it is the vessel, and a tint would dull the water
  behind its readout. The value is measured, in *The look, measured* below. (Black at `0.52`, from
  *Apple's glass, measured*, until stage 3c; read so here until the fifty-seventh pass.) *(2026-10-14,
  the sixtieth pass: since stage 5 a second vessel takes the clear variant — Hello's, on the
  welcome's first step (`WelcomeView.swift:840`), `.sheer` and not interactive. It draws no
  readout, so it carries no scrim; the mapping picks it by density and interaction, not by what it
  holds.)*
- **The pane says its hit region:** `sampling(_:)` — `systemPane` until the redesign's stage 2 —
  ends in `.contentShape(shape)`, for every `.material` pane on iOS 26 and later, the opaque one
  under Reduce Transparency included. The hand-made
  stack is hit-testable through its fills; Apple's glass is not always. On iOS 26.5 a serving row
  in History's `List` took a tap on its text and none on the bare glass between; iOS 27.0 took
  both. `GoalSetupUITests.testAServingRowOpensItsSheetWhereverItIsTapped` holds it.
- `LiquidGlassRoutingTests` pins the table, the mapping, which variant is tinted, that the tint is
  `Aurora.top` (`theGlassIsTintedWithTheSkysOwnBlue`) and that it is no lighter than `0.64`, without
  building a view. `LiquidGlassScrimTests` pins the hand-made stack's two scrims.

**The mapping is settled** (2026-10-10) — see *Apple's glass, measured* below.

## The primary surface

`primarySurface(in:ring:)` — the one surface that is not glass, for a screen's one main action.
Three places use it: *Get Started* and the sheet's *Save* — both were frosted glass under a cyan
glow — and, since the redesign's stage 2, **Home's Glass disc**, the only one on a `Circle`: the
slot every one-tap door logs, between two glass discs. *(2026-10-14, the redesign's stage 5: the
first is now the welcome's main action, in its bar — *Get Started*, then *Continue*, then *Turn on
reminders* — on a rounded rectangle at `LiquidGlass.cornerRadius` (`WelcomeView.swift:677`).
Still three places.)* *(2026-10-19, roadmap item 1.3.1's stage 6a, `5a46609`: **four** — the Home
Screen widget's pour button, a `Circle` in the small family and a `Capsule` in the medium, through
`PourSurface`: `ring: false`, so the button stays exactly 44 pt and the vessel's clearance holds,
and in `.fullColor` only — on a template it is white content in the lit rim. The pair is the same,
`Aurora.top` on the shaded white, so the figures below cover it.)*

| Token (`LiquidGlass.Primary`) | Value | |
|---|---|---|
| fill | `.white` | no colour token added |
| content | `Aurora.top` | the modifier sets it; a label must not set its own |
| `shadeOpacity` | `0.12` | `Aurora.top` over the fill, clear at the head, this at the foot |
| `pressedShadeOpacity` | `0.10` | `Aurora.top` over the whole fill while `glassIsPressed` |
| `ringOpacity`, `ringWidth` | `0.13`, `6` | white, outside the shape; `ring: false` for a widget |
| shadows | `Elevation.raised` | the same two shadows, after `compositingGroup()` |

**Its contrast is derived, because its fill is solid** (rule `65-accessibility` requires a
measurement only where a colour lands on a `Material`). Computed from the tokens, sRGB composited in
encoded space:

| `Aurora.top` on | Ratio |
|---|---|
| the head of the fill, pure white | **13.39:1** |
| the foot, sRGB `(0.885, 0.896, 0.942)` | **10.60:1** |
| the head, pressed | **11.03:1** |
| the foot, pressed | **8.80:1** |

`thePrimaryLabelClearsSevenToOneEvenAtTheFootOfTheShade` asserts the foot stays at or over 7:1.

## Selection

`LiquidGlass.Selection` — `fillOpacity = 0.08`, `rimOpacity = 0.55`, white, a `Capsule`. Present for
every slot at zero opacity. History's shown day drew this pair from literals; the tab bar's active
tab now draws it too, from the same tokens. On the hand-made pane the pair's figures are the week
card's rows in the table above (rim 4.15:1, the letter inside 7.4:1). The tab bar's lozenge had not
been measured on the hand-made pane when this was first written; the iOS 18.6 pass has run since.

**Since stage 3c the week card's shown day is marked another way**, from the canvas, with three
more tokens: a ring round its track (`ringOpacity = 0.8`, white, `ringWidth = 1.5`) and a white disc
behind its letter (`discFill`), the letter drawn in `Aurora.top` on it. There is one ring and one
disc, which travel to the shown day (`Motion.land`) and stay at zero opacity when no day in the
window is shown — a place animates, not a layer. The fill-and-rim pair is now the app's own tab
bar's — below iOS 26; above it the bar is Apple's — and the sheet's shortcuts'. The ring's figures
are in *The look, measured*; the letter on its disc is derived, by
`theShownDaysLetterReadsOnItsDisc`. **Every figure in this section was measured before stage 3c**,
on black-tinted glass and the black-scrim hand-made pane, and the ones that name History's shown
day — the paragraph above's included — are of the pair it drew then. *(2026-10-14, stage 5: the
fill-and-rim pair also marks the welcome calculator's picked unit, on a capsule, and its picked
activity, on a rounded rectangle at `innerCornerRadius` (`WelcomeView.swift:978`, `:1036`; the
mark itself `:1103–1104`). *Welcome, measured* gives the text inside them, not the rim.)*

**Measured 2026-10-10**, worst pixel of clean ground, the three tabs each selected in turn — at rest,
and on Apple's glass at the `0.48` tint of that evening (at the final `0.52`, through the aurora's
swing, the worst of the three are rim 3.41, glyph 4.11, caption 7.25 — *Apple's glass, measured*):

| The lozenge | Apple's glass, iOS 27.0 | Apple's glass, iOS 26.5 | hand-made, iOS 18.6 | Floor |
|---|---|---|---|---|
| the active caption inside it, white | 6.87–8.10 | 9.52–10.11 | 5.00–6.16 | 4.5 |
| the cyan glyph, beside the caption | 3.89–4.59 | 5.40–5.73 | **2.83**–3.49 | 3 |
| its rim, white 0.55 | 3.29–3.70 | 4.08–4.25 | **2.69**–3.10 | 3 |

History's shown day, the same tokens: rim 3.45 inside and 4.10 outside on iOS 27.0, its letter 7.31.
The two figures under 3 are at the hand-made bar's lightest end, the *Home* slot, where the shipped
app's glyph already reads 2.49–2.90 with no lozenge (known issues #85 and #86).

**A third user since the redesign's stage 3 (staged 2026-10-11): the serving sheet's vessel
shortcuts.** Any whose amount is showing carries the same fill and rim, in a `Capsule` — two,
when two vessels hold one amount — and the rest carry them at zero opacity. **One capture a
system, not a sweep** — the sheet has its own
aurora and it moves — on the sheet's `.frosted`, `.floating` card:

| The sheet's shortcuts | Apple's glass, iOS 26.5 | Apple's glass, iOS 27.0 | hand-made, iOS 18.6 | Floor |
|---|---|---|---|---|
| glyph and figure, white, on an unselected slot's pane | 13.67 | 10.74 | 6.04 | 4.5 |
| the same, on the selected slot's fill | 10.54 | 8.37 | 5.45 | 4.5 |
| the selected rim, white 0.55, against the pane outside it | 5.18 | 4.66 | 3.43 | 3 |

## Apple's glass, measured

*Superseded in its values on 2026-10-13 by stage 3c — the tint is `Aurora.top` at 0.64, with the
lit rim and sheen laid over it: see* The look, measured. *Kept as the record of its day.*

**Settled 2026-10-10: the regular variant is tinted black at `0.52`, and the week card's goal line
is white 0.55.** Method: a throwaway UI probe walks every screen and attaches full-screen captures;
for each text a rectangle of clean ground inside the same pane is sampled, and the figure is the
**worst pixel** of it — the foreground's own alpha composited over that pixel. Seventy-one pairs,
each against its floor (4.5:1 for text, 3:1 for a glyph, a rim or a rule). Two things decide where
and when to sample:

- **Where the pane is lightest.** History's fourth and fifth rows lie over the aurora's magenta
  lobe, and Settings' cards scroll through the same place.
- **When it is lightest.** The aurora's three lights swing over 16, 22.5 and 28.5 seconds and back,
  from rest each time a screen appears, and the first one cross-fades blue to cyan. A capture two
  seconds in is the resting frame and nothing else. Each screen is therefore shot every three
  seconds for a minute, and History for three and a half; the figure is the worst frame.
  *("From rest each time a screen appears" was true when this was measured. Since 2026-10-12 the
  lights are placed by one clock that starts when the app's first backdrop is drawn — The aurora
  moves, One sky — so a screen opened a minute into a session is a minute into the swing. The
  rule for sampling is unchanged; a minute from launch still covers it.)*

The climb, on iOS 27.0's iPhone 17 — each rung rendered, none estimated:

| Tint | At rest, 2–4 s in | Through the swing |
|---|---|---|
| `0.40` | 17 of 71 pairs under their floor: the goal line 2.77; white 0.75 / 0.72 / 0.70 over the magenta lobe 4.35 / 4.14 / 4.00 | — |
| `0.44` | 9 of 71: the goal line 2.89; white 0.72 / 0.70 over the magenta lobe 4.43 / 4.28 | — |
| `0.48` | none | the goal line, then white 0.45, under 3 in ten frames of twenty, worst **2.85**; white 0.70 over the magenta lobe **4.50**, on the floor |
| **`0.52`** | — | **none**: white 0.70 over the magenta lobe 4.86; the goal line, now white 0.55, 3.74 |

`0.48` passed its resting frame and was adopted for an evening; the final review asked what the
aurora does afterwards, and the answer above is why the value moved. The goal line was the one pair
no tint in the owner's ladder carried — 3.01 at `0.52` and white 0.45 — so its own opacity was
raised instead of darkening every pane for a one-point rule.

**At `0.52`, the worst frame of the swing, iOS 27.0:**

| Pair | Worst | At rest | Floor |
|---|---|---|---|
| Any pane over the magenta lobe: white 0.70 / 0.72 / 0.75 | **4.86** / 5.05 / 5.33 | 4.97 / 5.16 / 5.48 | 4.5 |
| Week card: the goal line, white 0.55 | **3.74** | 4.03 | 3 |
| Week card: weekday letters 0.72 / average and best 0.75 / disclosure 0.70 | 5.20 / 5.86 / 5.37 | 5.97 / 6.67 / 6.24 | 4.5 |
| Week card: the shown day's rim, white 0.55, inside | 3.44 | 3.64 | 3 |
| Tab bar: inactive caption, white 0.72 | 5.83 | 5.86 | 4.5 |
| Tab bar: the lozenge's rim / cyan glyph / caption | 3.41 / 4.11 / 7.25 | 3.45 / 4.17 / 7.37 | 3 / 3 / 4.5 |
| Serving row, top: time 0.75 / the drop | 5.85 / 5.39 | 7.01 / 6.45 | 4.5 / 3 |
| Settings: range labels 0.75 / the note 0.70 | 5.44 / 5.51 | 6.05 / 5.65 | 4.5 |
| Settings: reminders description / language footnote, 0.75 | 6.16 / 5.91 | 6.73 / 6.13 | 4.5 |
| Sheet: *ml*, white 0.8 / *Cancel* | 6.43 / 9.09 | 7.18 / 10.09 | 4.5 |
| Quick-add glyph (the row as it was then: three glass vessels, 76 pt — replaced in stage 2, whose two discs read 8.18–10.08, *Home, measured*) / History's `+` | 7.27 / 9.19 | 7.98 / 9.33 | 3 |

The three-and-a-half-minute pass over History found no frame worse than the first minute's.

**At `0.48`, at rest — kept because it is the only pass that has iOS 26.5 beside iOS 27.0, the first
run and the empty state:**

| Pair | iOS 27.0 | iOS 26.5 | Floor |
|---|---|---|---|
| Week card: the goal line, white 0.45 | **3.04** | 3.63 | 3 |
| Any pane over the magenta lobe: white 0.70 / 0.72 / 0.75 | **4.58** / 4.74 / 5.00 | 5.96 / 6.21 / 6.60 | 4.5 |
| Tab bar: inactive caption, white 0.72 | 5.72 | 7.19 | 4.5 |
| Week card: weekday letters 0.72 / average and best 0.75 / disclosure 0.70 | 5.60 / 6.25 / 5.87 | 7.22 / 8.26 / 7.52 | 4.5 |
| Serving row, top: time 0.75 / the drop | 6.61 / 6.03 | 8.60 / 8.34 | 4.5 / 3 |
| Settings: range labels, now 0.75 / the vessels' millilitre readouts 0.75 (the names beside them are full white) / the note 0.70 | 5.65 / 6.38 / 5.22 | 7.39 / 7.75 / 6.28 | 4.5 |
| Settings: reminders description / language footnote, 0.75 | 6.21 / 5.79 | 8.27 / 7.23 | 4.5 |
| Sheet: *ml*, white 0.8 / *Cancel* | 6.67 / 9.34 | 8.94 / 12.84 | 4.5 |
| First run: *ml* / range labels 0.75 | 7.54 / 6.07 | — | 4.5 |
| History, empty: the card's title / its body, 0.70 | 8.99 / 5.45 | — | 4.5 |
| Quick-add glyph / History's `+` | 7.69 / 8.74 | 7.83 / 6.38 | 3 |

- **iOS 27.0 sets the value.** Apple's glass is darker on iOS 26.5 than on 27.0 over the same
  aurora — the week card reads about sRGB `(0.00, 0.19, 0.49)` on 26.5 and `(0.02, 0.30, 0.53)` on
  27.0, both at `0.48` — so one value serves both, and 26.5 has room to spare.
- **The range labels were raised, not carried.** At white 0.6 they read 3.75 at `0.40` and would
  read 4.49 on the first-run card at `0.48`; they are 0.75 now, in `SettingsView` and
  `GoalSetupView`. *(Settings' are 0.88 since stage 4 — *Settings, measured*; noted in the
  fifty-eighth pass. `GoalSetupView`'s are still 0.75.)* *(Stage 5, 2026-10-14: `GoalSetupView` is
  gone; the welcome's goal card draws its range labels at 0.88 — *Welcome, measured*.)*
- **Increase Contrast** (iOS 27.0, at `0.48`, at rest): the system darkens the glass a great deal
  by itself. None of the 71 pairs fails; the goal line 4.08 at white 0.45, white 0.70 over the
  magenta lobe 8.62, the lozenge's rim 4.90.
- **Reduce Transparency** (iOS 27.0, flipped through the Settings app): every pane is the opaque
  fill with its lit rim, the vessel's ring included; the primary buttons are unchanged.
- **Not taken at `0.52`:** iOS 26.5, the first run, the empty state and Increase Contrast. Each
  passed at `0.48` with room, and a darker pane only adds to it — an inference, and labelled as
  one. iOS 26.5 was not followed through the swing at either value.
- **The tightest pair is white 0.70 over the magenta lobe, 4.86:1.** The three lights are not back
  together for 7.6 hours (*The aurora moves*), so no pass a session can make sees every way they
  line up; three and a half minutes found
  nothing worse than the first. If a pair is ever seen under its floor, the next value is rendered
  and followed through the swing like these — never estimated — and
  `theTintIsNoLighterThanTheLightestRungThatPassed` is moved with it.
- **The vessel is not in this table.** It takes the clear variant and no tint; its readout over
  water is known issue #81, older than the redesign: 2.91–3.07:1 for the millilitre line on every
  path, shipped 1.1 included — **as stage 1 found it.** Stage 2 redrew the readout; its figures,
  by both yardsticks, are in *Home, measured*.

**The first pass, kept as written on 2026-10-09 — the untinted glass, and two experiments at `0.40`
that sampled the blue lobe only.** On iOS 27.0's iPhone 17 — not the pinned 26.5, and not finished. Over this
aurora Apple's regular glass comes out light and saturated: the pane reads about sRGB
`(0.07, 0.50, 0.88)` on the blue lobe and `(0.68, 0.39, 0.97)` over the magenta one, where the
hand-made pane read `(0.21, 0.30, 0.44)` and `(0.39, 0.28, 0.48)`. Every opacity in this app was
chosen from samples of the darker pane. Worst pixel of clean ground beside each text:

| Pair, on Apple's glass as built | Measured | Floor |
|---|---|---|
| Tab bar, inactive caption, white @ 0.72 | **2.47:1** | 4.5 |
| Tab bar, active caption inside the lozenge | **3.01:1** | 4.5 |
| Tab bar, `Aurora.cyan` glyph inside the lozenge / the lozenge's rim | **1.70:1** / **1.88:1** | 3 |
| Week card: title / weekday letters @ 0.72 / average and best @ 0.75 / disclosure @ 0.70 | **3.88** / **2.90** / **3.21** / **3.14** | 4.5 |
| Week card: the shown day's letter | **3.72:1** | 4.5 |
| Serving row: amount / time @ 0.75 / drop glyph | 4.96 / **3.54** / **2.81** | 4.5 / 4.5 / 3 |
| History's `+` glyph | 5.90:1 | 3 |
| Settings: goal title / range labels @ 0.6 | **3.91** / **2.35** | 4.5 |
| Settings: the vessels' readouts @ 0.75 / the note @ 0.70 / the glyph | **3.65** / **2.70** / **2.90** | 4.5 / 4.5 / 3 |
| Settings: reminders title / description @ 0.75 | **3.81** / **2.82** | 4.5 |
| Sheet: *ml* @ 0.8 / *Cancel* | **3.30** / 4.96 | 4.5 |
| Quick-add glyph | 4.83:1 | 3 |

**A real failure, and this change's own.** Two experiments were measured and **neither is adopted**:

| | Tab inactive | Lozenge caption / glyph | Weekday | Disclosure | Row time | Vessels note | Range labels @ 0.6 |
|---|---|---|---|---|---|---|---|
| a black layer at `0.40` under the content | 5.47 | 6.99 / 3.96 | 4.98 | 5.24 | 5.94 | 4.65 | **3.84** |
| `Glass.regular.tint(.black.opacity(0.4))` | 5.45 | 6.98 / 3.95 | 4.95 | 5.24 | 5.94 | 4.62 | **3.82** |

Apple's tint and a plain black layer of the same opacity measure the same. A black layer is a
multiply, so other values can be estimated from the first table: about 3.9:1 for the tab bar's inactive
caption at `0.28`, and about 4.7–4.8:1 for the range labels at `0.48`–`0.50`. **Those are estimates;
at `0.40` the estimate for the range labels was 4.15 and the render read 3.84.** Which remedy, and
what value, is the owner's decision (known issue #80), and the figures are to be taken again on iOS
26.5 and, for the hand-made path, iOS 18.6.

One more reading from the same pass: **the vessel's millilitre line, white @ 0.85 over water and
`WaterReadabilityScrim`, read 3.10:1** against a 4.5:1 floor, with the vessel over-full. That ground is
water, which this change does not draw; whether it is an old failure is not yet shown (known issue #81).
*(Shown on 2026-10-10: it is old. See the settled account above.)*

## The hand-made pane, measured again

*Superseded for the phone's own panes on 2026-10-13 by stage 3c — the scrim is `Aurora.top` at 0.30
/ 0.70 / 0.80: see* The look, measured. *The widget and the watch keep the black scrim.*

**2026-10-10. The hand-made pane reads lighter than the tables above it, and several pairs they show
passing are under their floor** (known issue #85). Two sources, the same method as *Apple's glass,
measured*: stage 1 on a new iOS 18.6 simulator (iPhone 16), and the shipped 1.1, `8a44e8f`, in store
captures taken on iOS 27.0 (iPhone 18 Pro Max) — both draw the hand-made stack.

| Pair | Recorded above | Shipped 1.1, iOS 27.0 | Stage 1, iOS 18.6 | Floor |
|---|---|---|---|---|
| Week card: disclosure, white 0.70 | 5.49 | **4.18** | **4.38** | 4.5 |
| Settings: the vessels note, white 0.70 | 5.50 | **4.32** | **4.09** | 4.5 |
| Tab bar: inactive caption, white 0.72 | 4.89 | **4.29**–4.87 | **3.91**–4.98 | 4.5 |
| Any pane over the magenta lobe: white 0.75 / 0.70 | — | 4.52 / **4.17** | **4.43** / **4.09** | 4.5 |
| Goal slider: range labels, white 0.6 (0.75 since stage 1) | — | **3.01** at 0.6 | **4.03** at 0.75 | 4.5 |
| Week card: the goal line, white 0.45 | 3.26 | **2.16** | **2.37** | 3 |

- The pane beside the goal card's labels: sRGB `(0.251, 0.370, 0.507)` in the shipped app on iOS
  27.0, `(0.251, 0.367, 0.504)` on iOS 18.6. The record for the week card's pane is
  `(0.208, 0.296, 0.444)`.
- **The two new sources agree with each other and not with the record.** The record was taken on
  iOS 26.5's iPhone 17. Whether the difference is the system, the size of the screen or the moment
  of the aurora is not established: no hand-made pane was rendered on iOS 26.5 this time.
- **The goal line is white 0.55 since stage 1**, on both paths; the table's row was taken at 0.45.
  From the same ground it is 2.80:1 on iOS 18.6 at 0.55 — better, and still under 3.
- **Nothing was retuned.** Stage 1 leaves the hand-made stack as it shipped. A remedy would be the
  stack's dark scrim, raised until the pane is as dark as these opacities were chosen for — which
  changes the look below iOS 26 and on the watch, so it is a decision of its own.
- Until then, **a figure in the tables above is true of the device and the day it was taken**, and
  not a property of the pane.

## Home, measured

*Its figures on a pane are superseded by stage 3c's re-tinted glass — *The look, measured*, below.
The stage drew nothing new under the text on the aurora; in the vessel it added a highlight at the
top left, and took no before-and-after figure for the line over the water (#95). Kept as the record
of its day. (Pointer added in the fifty-seventh pass.)*

**2026-10-11, the redesign's stage 2.** Most of Home's text now sits straight on the aurora — the
date and title, the status line, the quiet line and the three discs' captions have no pane under
them — and a line of text stays over the water. **It is not the first text on the aurora, only the
first measured there:** History's and Settings' headers, the serving sheet's title and the first-run
screen's lines sit on the same backdrop under one shadow, `(0.25, radius 8, y 2)`, the old Home's `N ml` captions under its
three vessels sat there at white 0.8 with no shadow at all, and none of them has a row in this
document. The two contrast tables and the panes' rows
were taken from the staged source on three simulators made for it: iOS 27.0 and 26.5 (*iPhone 17*,
Apple's glass) and iOS 18.6 (*iPhone 16*, the hand-made stack), each walked from an empty day to
the goal, **with a capture every three seconds for a minute at 45 %**, because the aurora's lights
swing for 16, 22.5 and 28.5 seconds and a figure is the worst frame, never one capture. Three
things here are from elsewhere and say so where they stand: the Increase Contrast figures (an
earlier build of the same day), the large-text renders (two other simulators) and the widget.

### Text on the backdrop: two shadows, and two yardsticks

`legibleOnBackdrop()` — a private helper in `HomeView.swift` until the redesign's stage 3, which
moved it unchanged to `AuroraBackground.swift` for History's header to share (staged 2026-10-11)
— is the widget readout's recipe (see
*Contrast figures that were measured*): black 0.3, radius 6, y 1, for depth, and black 0.45, radius
2, a halo that travels with the glyphs. The vessel's readout keeps its wider first shadow (radius
10, y 2) and gains the second; the millilitre line carries the helper as well. Three whites the
canvas dimmed are **full white** — the quiet line (0.88), a side disc's name (0.92) and the `%`
(0.88) — each because it still failed with both shadows; the date keeps 0.92.

**Beside the glyphs** — the ground 3 to 7 pixels from the text, where the halo is; worst frame:

| Pair | Floor | iOS 27.0 | iOS 26.5 | iOS 18.6 |
|---|---|---|---|---|
| Bottle's amount, 15 pt bold, over the magenta light | 4.5 | **4.59** | 4.66 | 5.17 |
| Bottle's name, 12 pt semibold | 4.5 | 4.72 | 4.73 | 5.09 |
| the vessel's millilitre line, 17 pt bold, over water | 4.5 | 4.80 | 4.82 | 4.87 |
| the date, white 0.92 | 4.5 | 4.87 | 4.85 | 4.73 |
| the quiet line, 13 pt medium | 4.5 | 4.95 | 4.94 | 5.06 |
| the vessel's `%`, 30 pt bold | 3 | 3.43 | 3.44 | 3.48 |
| the status line, 22 pt bold | 4.5 | 5.74 | 5.76 | 6.31 |
| the title, 34 pt bold | 3 | 5.17 | 5.15 | 5.09 |
| the Glass's and the Cup's captions | 4.5 | 6.18–7.39 | 6.17–7.40 | 6.13–7.91 |

Twelve pairs, none under its floor on any of the three. With Increase Contrast on, iOS 27.0, on
the source before the fix pass (which changed nothing drawn at this size): 4.61, 4.75, 4.97, 4.85,
4.97, 3.50, 5.82, 5.15.

**On clean ground** — a rectangle 12 points out from the text, the way every earlier table in this
document was taken; the same captures:

| Pair | Floor | iOS 27.0 | iOS 26.5 | iOS 18.6 |
|---|---|---|---|---|
| Bottle's amount | 4.5 | **4.12** | **4.15** | **4.42** |
| Bottle's name | 4.5 | **4.20** | **4.20** | **4.43** |
| the millilitre line, over water at 45 %, 70 %, full | 4.5 | **3.39, 3.26, 3.29** | **3.39, 3.29, 3.31** | **3.45, 3.34, 3.34** |
| the `%`, over a full vessel | 3 | **2.71** | **2.71** | **2.75** |
| the `%`, at 45 % and 70 % | 3 | 3.26, 3.13 | 3.26, 3.13 | 3.33, 3.16 |
| the millilitre line, vessel empty | 4.5 | 5.01 | 5.52 | 8.25 |
| the quiet line | 4.5 | 4.70 | 4.70 | 4.58 |
| the date, white 0.92 | 4.5 | 4.78 | 4.73 | 4.69 |
| the status line | 4.5 | 4.99 | 4.97 | 5.32 |
| the title | 3 | 4.65 | 4.64 | 4.68 |

**Four pairs are under their floor by this yardstick, on all three systems, and none by the
other.** A shadow darkens the ground a letter is read against, and a rectangle 12 points away does
not see it; equally, a halo two points wide is not a pane. Which one is this project's measure of a
shadowed line has not been ruled (known issue #95) — the plan for this stage said clean ground.
**A fifth pair is at the edge:** the quiet line reads 4.58–4.70 on clean ground here and read 4.48,
at full white, in the stage's first clean-ground table (iOS 26.5, an earlier build, another minute
of the aurora). Before stage 2, at 45 % and 65 %, the millilitre line read 2.91–3.07 and its `%`
2.75–2.89 on clean ground (#81): the shipped 1.1 at 65 % (2.91–2.93), and stage 1's build at 45 %
on Apple's clear glass and on iOS 18.6. **Stage 1's build was also measured with the vessel
over-full, at 333 %: the line 2.99–3.00 (3.10 in an earlier pass) and the `%` 2.82.** So **the
millilitre line is better than it was by either yardstick, at every level; the `%` is better at
45 % and 70 % (3.13–3.33) and no better over a full vessel — 2.71–2.75 on clean ground against
that 2.82.** The conditions are not identical: 333 % then, a vessel at its goal now. The
Bottle's captions are new text on a new ground. *(Until the forty-ninth pass this said a full
vessel was "a level neither earlier build was measured at"; stage 1's ledger has the figures.)*

### The two new panes

Measured at the content — the first samples of each capsule were of its lit end, where nothing sits.

| Pane | Pair | Floor | iOS 27.0 | iOS 26.5 | iOS 18.6 |
|---|---|---|---|---|---|
| *Undo*, `.opaque`, `.raised`, interactive | *Added 250 ml*, 15 pt medium | 4.5 | 9.60 | 13.41 | **4.64** |
| | *Undo*, 15 pt bold | 4.5 | 9.25 | 13.22 | 7.45 |
| | the glyph, `Aurora.cyan` | 3 | 5.09 | 7.53 | 4.44 |
| the streak chip, `.frosted`, `.resting` | the number, 15 pt bold | 4.5 | 12.31 | 15.66 | 8.60 |
| | the flame, `Aurora.cyan` | 3 | 6.97 | 8.88 | **3.22** |
| a glass disc, `.frosted`, `.raised` | the glyph, white | 3 | 8.18–10.08 | 11.29–13.90 | 5.41–6.29 |

**How many captures stand behind each figure, by the samplers' own lists of frames:** the discs'
glyphs are the worst of the sweep's frames and the walk's; *Undo*'s three are the worst of three
captures, the first two of the sweep and the one after the pour; **the chip's two are one
capture**, on every system. On Apple's glass the pane reads as one colour, but an earlier pass
the same day gave ranges on it, on an earlier build: *Added … ml* 9.6–10.1 on iOS 27.0 and
13.3–13.9 on 26.5, the flame 6.5–7.0 on 27.0 — so 6.97 is not the lowest that pair has read. All
are far over their floors. *(This read "one capture is the figure" on Apple's glass until the
forty-eighth pass, which made it "each figure is one capture" — true of the chip only; the
samplers were read in the forty-ninth, not re-run.)* On the hand-made stack
the pane is translucent and lit: the chip's row is the worst of a minute's sweep, the flame against
the highlight at the capsule's leading end (3.31 above it, 4.38 below, 4.71 toward the number).
*Undo* is `.opaque` where the discs are `.frosted` because it is the one pane on Home that carries a
line of text; at `.frosted` that line read 4.48 where the highlight crosses its first letters. With
Increase Contrast, iOS 27.0: 17.73, 17.59 and 9.69 — **taken on the build before the fix pass, on
another simulator, and not taken again**; the fix pass gave the capsule its three forms and left
its material alone, and without the setting the two builds read alike (9.57, 9.27 and 5.11 before;
9.60, 9.25 and 5.09 after). Both hand-made figures are narrow, and known issue #85's remedy would
widen them.

### Large text: what gives way

Home's column is a `Layout`, `HomeColumn`: the header, the status and the row at their own heights,
and the vessel given what is left, between a floor and a ceiling. **The floor is 200 points and does
not scale; the ceiling is the scaled size, capped at 340.** A floor that rose with the text size —
two thirds of the scaled size — was built first and drawn, on a 402 × 874 pt phone (iOS 27.0):

| Text size | Vessel, rising floor | What it cost | Vessel, fixed floor | What shows |
|---|---|---|---|---|
| default | 300 | — | 300 | everything |
| Accessibility 1 | 253 | nothing | 245 | everything, one page |
| Accessibility 2 | 278 | the vessels' names under the tab bar | 228 | everything, one page |
| Accessibility 3 | 297 | the captions gone, the discs' feet at the bar | 210 | everything, one page |
| Accessibility 4 | 322 | 52 pt of each disc under the bar | 200 | the whole row; the page scrolls (two pages) |
| Accessibility 5 | 340 | 42 pt of each disc showing | 200 | the discs whole, their captions under the bar |

The quick-add row is the screen's one action, so the vessel gives way before it. The cost is the
line inside the vessel, a ratio of it: 11 points at the floor whatever the text size (known issue
#97). On a 375 × 667 pt phone the vessel is 214 at the default size with nothing scrolling, and 200
at the second, third and fifth accessibility sizes, the three rendered there, where the screen
scrolls. *("One page" and "scrolls" are the scroll bar's own label in each render's accessibility
tree. On the 402 pt phone **in English**: one page through the third accessibility size, two at
the fourth and fifth — the table above is the English renders. **In Russian it is two pages from
the third**, with the vessel at 200 (the fourth was not rendered). On the 375 pt phone: one page
at the default and two at all three sizes, in both languages, and two in Uzbek at the fifth. The
stage's ledger has the one-page half — "AX1 245, AX2 228, AX3 210 — everything on one page", of
the English renders — and not where it turns to two.)*

**Nothing that says what a control will do is cut short.** The *Undo* capsule draws the first of
three forms that fits at its own size — it is never shrunk onto one line, which at the largest size
cut the amount to *Added 25…*:

| Form | Where it is drawn (English, 402 pt wide) | Russian |
|---|---|---|
| *Added 250 ml \| Undo* | default, Accessibility 1 | default |
| *250 ml \| Undo* — one line, so the row below does not move | Accessibility 2, 3, 4 | Accessibility 1, 2 |
| the amount over the word, each free to shrink to 0.6, the amount to wrap | Accessibility 5 | Accessibility 3 and 5 (4 was not rendered) |

Rendered at the default and all five accessibility sizes in English and at five sizes in Russian on
the 402 pt phone, and at four English, four Russian and one Uzbek on the 375 pt phone: no text cut,
no word broken, none outside its capsule. The sizes below the default were not rendered. The quiet line stacks its two times the same way; in Russian it stacks at the default size.
Two things had to be true before those renders were right, and both are in `tasks/lessons.md`: the
choice is made among whole buttons in the row's full width, and a one-line form is `fixedSize`.

### The widget, after the shared modifier changed

`LiquidGlassModifier.swift` compiles into the widget, and stage 2 changed how it routes. The
widget's four `.archived` pane recipes, rendered in a window from `b8a1386` and from the change:
identical digests with Reduce Transparency off, identical with it on, and the two settings differ
from each other — so both branches ran. Both sizes placed on a Home Screen from each build (iOS
27.0, light): the medium widget's cell, 573,408 pixels, differs in none; the small one's in 34, by
one level, all outside the widget's own rectangle.

### The week widget, measured

*2026-10-20, roadmap item 1.3.1's stage 6c, built and staged, not committed.* The week widget draws
History's values — `Aurora.cyan` for a met day, white for the rest, white 0.10 tracks, the goal line
1.5 pt at white 0.62 — and rule `60-design-system` asks for each pair measured on the widget's own
pane, because History's figures were read on History's. **No token changed.**

Measured off a screenshot of the placed widget on *WaterBuddy Probe 27* (iPhone 17, iOS 27.0, light,
the device's real week, 3× pixels, WCAG relative luminance). The foreground is the element's core —
a bar's interior median, a glyph's brightest tenth. The ground is the **lightest** 8-px patch beside
it — the gaps between tracks, the track above a bar, the pane around a glyph — so each figure is the
worst on that frame. A widget does not move, so one frame is the whole of it; light and dark rendered
identically, as the card sets its own dark scheme.

| Pair | Ratio | Floor |
|---|---|---|
| Met bar at the goal line (cyan) vs the gaps beside it and its track above | **3.66:1** | 3:1 |
| Met bar, full height (cyan) vs the gaps beside it | 5.34:1 | 3:1 |
| Unmet bar (white) vs its track and the gaps | 7.10:1, 7.26:1 | 3:1 |
| An empty day's 2-pt sliver (white) vs its track | 5.32:1 | 3:1 |
| Goal line over a track vs the track | **3.06:1** | 3:1 |
| Goal line over a gap vs the gap | 4.31:1 | 3:1 |
| Weekday letters (white) vs the pane | 7.20:1 | 4.5:1 |
| Title *Last 7 days* (white) vs the pane | **4.95:1** | 4.5:1 |
| Figure *2 of 7* (white) vs the pane | 8.82:1 | 4.5:1 |
| *Goal met* (white 0.85) vs the pane | 6.99:1 | 4.5:1 |
| Track (white 0.10) vs the gap between tracks | 1.79:1 | — |

**Nothing is under its floor.** The nearest are the goal line over a track, 3.06 (History's reads 3.67
on its own pane), and the title, 4.95, where the card is lightest, top left. The track claims no
floor, as History's does not: it is the faint slot a short bar stands in, and a met bar is told by
its colour **and** by standing at or above the line (rule `65-accessibility`). Not measured: a tinted
Home Screen, where a met bar takes iOS's accent (#149).

## History, measured

*Its figures on a pane are superseded by stage 3c's re-tinted glass and redrawn week card — *The
look, measured*, below; its header on the aurora the stage did not change. Kept as the record of
its day, when the stage was staged; stage 3 was committed in `e0762ab`. (Pointer added in the
fifty-seventh pass.)*

**2026-10-11, the redesign's stage 3, staged.** History is one list now: a header straight on
the aurora, then three kinds of pane — the week card, the strip (*When you drank*), a serving
row. Taken on three simulators: iOS 26.5 and 27.0 (*iPhone 17*, 402 × 874 pt, Apple's glass —
*WaterBuddy Probe 26.5* and *Probe 27*) and iOS 18.6 (*iPhone 16*, 393 × 852 pt, the hand-made
stack — *WaterBuddy Fallback 18.6*). **A figure is the worst frame of a capture every three
seconds for a minute with the list at rest, and again for a minute with it scrolled**, at the
ordinary text size, on a day with servings. The script's rectangles were drawn on a capture of
the first iOS 26.5 sweep and looked at before any figure was kept — that first set was wrong in
several places and none of its figures is here. The final sweeps reuse the script, whose
rectangles follow each element's frame; **theirs were drawn and looked at afterwards**, on a
capture of each system, when a reader of this section asked, and none had to move. The sweeps
ran before the stage's final review. By the code its fixes change nothing these sweeps drew —
today's screen at the ordinary text size — and no capture was compared after them.

**On iOS 18.6 the final sweep's second minute did not scroll.** The list had another page and
did not move under the probe's swipe; why is not shown. That system's *scrolled* figures, marked
† below, are from an earlier sweep the same day on the same simulator, taken after the row's
well was set at black 0.4, whose at-rest figures agree with the final sweep's to two decimals.

### The header: two lines on the backdrop, by both yardsticks

The shown day, `.largeTitle` bold, and its total against the goal, `.headline` rounded, both
white with `legibleOnBackdrop()`'s two shadows. *Text on the backdrop*, under *Home, measured*,
says what the two yardsticks are; the owner's "go" to this stage took clean ground as its floor
and both as its record (`docs/AI_CONTEXT.md`, known issue #95).

| Pair | Floor | iOS 26.5 | iOS 27.0 | iOS 18.6 |
|---|---|---|---|---|
| the heading, clean ground | 3 | 4.74 | 4.74 | 4.61 |
| the heading, beside its glyphs | 3 | 5.19 | 5.19 | 5.07 |
| **the total, clean ground** | 4.5 | **4.45** | **4.44** | **4.34** |
| the total, beside its glyphs | 4.5 | 4.65 | 4.68 | 4.62 |
| the `+`, white on its `.frosted` disc | 3 | 15.62 | 12.08 | 6.55 |

**The total is under its floor by the first yardstick on every system, by 0.05 to 0.16, and
over it by the second.** It is not a pane's doing — the same pair fails the same way on all
three — and it was not restyled: it is Home's recipe on Home's backdrop.

### The panes

| Pair | Floor | Apple's glass, iOS 26.5 | Apple's glass, iOS 27.0 | hand-made, iOS 18.6 |
|---|---|---|---|---|
| Week: the title / a figure, 20 pt bold | 4.5 | 12.32 / 13.64 | 8.67 / 9.94 | 4.59 / 6.34 |
| Week: a figure's label, white 0.9 | 4.5 | 11.22 | 8.75 | 5.74 |
| Week: a weekday letter, white 0.72 | 4.5 | 7.02–7.29 | 5.32–5.58 | **3.41–3.93** |
| Week: the disclosure, white 0.70 | 4.5 | 7.26 | 5.92 | **4.15** |
| Week: a cyan bar — a day that reached the goal — beside the pane | 3 | 6.87–7.22 | 4.91–5.12 | **2.78**–3.32 |
| Week: a white bar — a day that did not — beside the pane | 3 | 12.12–12.74 | 8.67–9.04 | 4.91–5.86 |
| Week: the goal line, white 0.55, beside a bar | 3 | 4.74–4.89 | 3.78–3.92 | **2.65–2.98** |
| Week: over an empty day's track — the goal line / a cyan bar / a white bar | 3 | 3.66 / 4.54 / 8.01 | 3.05 / 3.47 / 6.12 | **2.12** / **1.98** / 3.49 |
| Strip: the title / an hour label, white 0.9 | 4.5 | 13.75 / 10.87 | 10.39 / 8.48 | 6.78 / 5.76 |
| **Strip: a serving's cyan bar against the plot's pane — in the small hours / at midday / in the evening** | 3 | 8.05 / 7.43 / 7.02 | 6.45 / 5.65 / 5.58 | **2.73** / 3.80 / 3.69 |
| Strip: white against the same pane, the reminder's bell and rule — the same three places | 3 | 14.21 / 13.11 / 12.40 | 11.38 / 9.97 / 9.84 | 4.82 / 6.71 / 6.52 |
| Row at rest: the amount / the name, white 0.9 / the time, white 0.94 | 4.5 | 10.97 / 9.17 / 9.87 | 8.36 / 7.11 / 7.59 | 6.64 / 5.75 / 6.10 |
| Row scrolled: the same three | 4.5 | 9.04 / 7.65 / 8.19 | 7.12 / 6.10 / 6.49 | 5.40 / 4.74 / 5.00 † |
| Row: the cyan glyph in its well, at rest / scrolled | 3 | 9.78 / 8.10 | 8.72 / 7.05 | 4.48 / 3.84 † |

Where a week-card cell holds a range, it is the card's two ends — the first and the last
boundary between day slots that is clear of the shown day's ring. † is the earlier iOS 18.6
sweep, above.

**Where the strip was sampled.** The sweep's own rectangle is at the plot's left end, the small
hours, which is the first figure in each strip cell: no probe serving stood there and no
reminder can — the plan's hours run from 9 to 21 — but a serving logged at night would. The
other two, at 0.50 and 0.86 of the day, were measured afterwards over the same at-rest
captures, their rectangles drawn and looked at on iOS 27.0 and 18.6, when a reader of this
section pointed out where the first one lay.

- **On Apple's glass nothing in a pane is under its floor.** The nearest is the goal line where
  it crosses an empty day's track on iOS 27.0, **3.05 against 3** — one sweep, 0.05 to spare. The
  line and the track are as they were before this stage.
- **On the hand-made pane nine of the swept pairs are under** (known issue #85): the weekday
  letters, the disclosure, the goal line three ways, the week's cyan bar two ways — each drawn
  as it was before this stage — **and the strip's cyan bar, which is new, at the plot's left
  end only**: 2.73 in the small hours, where the pane's highlight lies, and 3.80 and 3.69 where
  the day's servings stood. Nearest their floor of those that pass there: the week's title,
  4.59, and a row's name scrolled, 4.74, against 4.5. Over all eighteen of the week card's and the strip's pane samples on that system,
  passing ones included and the track's left out, the pane read between `(0.24, 0.34, 0.48)`
  and `(0.39, 0.47, 0.53)`, channel by channel, each at its pair's worst frame — where this
  sheet's oldest record for the week card's pane is `(0.208, 0.296, 0.444)`. *The hand-made pane, measured again*, above, is the same finding,
  and the remedy it names is the pane's, not one for each mark. Nothing in the hand-made stack
  was retuned.
- **On that pane the two bar colours pass differently:** a white bar reads 4.91 and a cyan one
  2.78, so a day that reached the goal is the fainter of the two there. Colour is not the only
  carrier — a met bar also stands at or above the goal line — and the goal line is under its
  floor on the same pane.

### What this stage draws that is new

No token was added, and `LiquidGlassModifier.swift` is unchanged. The cyan is `Aurora.cyan` and
the shortcuts' selection is `LiquidGlass.Selection`; the rest — the hairline, the well, the
widths, the white opacities — are literals in `HistoryView.swift`. Most carry their reason
beside them; the ground line's white 0.3 and the rule's 1.5 pt do not.

- **Two bar colours.** A day that reached the goal is `Aurora.cyan`, one that did not is white;
  one fill whose colour changes. Until this stage every bar was cyan.
- **The strip's bars**: `Aurora.cyan` capsules 8 pt wide, a serving's height its amount against
  the largest of the day's servings and the three vessels, never under `stripFloor` (0.12) of
  the plot. **Each carries a 1 pt hairline, black 0.45**: four servings inside fifteen minutes
  drew as one wide blob without it, and an 8 pt bar is about forty minutes of a day on this
  width. The hairline is not counted in the 2.73 above. The ground line is white 0.3.
- **A row's glyph in a dark well.** The vessel's glyph, `Aurora.cyan`, on a disc filled black
  0.4. The canvas drew a cyan wash under it, and a wash lightens the ground under a glyph of
  its own colour: on the hand-made pane the glyph read **2.00–2.02 against 3**. At black 0.3 it
  read 3.35 scrolled and 3.73 at rest there; at 0.4, 3.84 scrolled and 4.48 at rest.
- **The sheet's shortcuts** use `LiquidGlass.Selection` (see *Selection*), their glyph and
  figure at one size that scales with text and stops at 30 pt.
- **The reminder's mark** on today's strip: a white bell over a white rule 1.5 pt wide. Drawn
  from a stand-in time for the render; reminders could not be switched on on a simulator
  (`docs/AI_CONTEXT.md`, known issue #94).

### One capture a system, not a sweep

**The empty state**, which is drawn as it was before this stage. *Apple's glass, measured* has
it at 8.99 and 5.45 on iOS 27.0 — in its table "At `0.48`, at rest", one resting frame at a
tint that no longer ships; that section says the empty state was not taken at the final `0.52`.
The figures here are at `0.52`, one render each, and read higher. iOS 27.0 and 18.6 on the
phones above, iOS 26.5 on a 375 × 667 pt *iPhone SE*:

| The empty state | Floor | iOS 26.5 | iOS 27.0 | iOS 18.6 |
|---|---|---|---|---|
| its title, white | 4.5 | 13.33 | 12.37 | 5.37 |
| its second line, white 0.7 | 4.5 | 7.37 | 6.84 | **3.80** |

### Not measured

Any figure under Increase Contrast, at a text size other than the ordinary one, in Russian or
Uzbek, on a device, or on iOS 17. The reminder's mark from a real reminder. The sheet's other
text, which this stage did not change.

## The look, measured

**2026-10-13, the redesign's stage 3c** (spec `docs/superpowers/specs/2026-10-13-the-look-design.md`).
It changed what the phone's own panes are drawn on, so **it supersedes the values of *Apple's
glass, measured* and *The hand-made pane, measured again*** for them, and the pane figures of
*Home, measured* and *History, measured*; those tables stay as the record of their day.

**What is drawn now.**

- Apple's glass (iOS 26 and later) is tinted with `Aurora.top` at **0.64**, not black at 0.52, and
  the hand-made stack's sheen and lit rim are laid over it, under the content.
- The phone's hand-made pane (iOS 17–25) is scrimmed with `Aurora.top` at **sheer 0.30, frosted
  0.70, opaque 0.80**, not black at 0.16 / 0.28 / 0.40. The widget's `.archived` base and the watch
  keep black at the old values.
- The week card: tracks at white 0.10, a dashed goal line at white 0.62, a ring (white 0.8) and a
  white disc on the shown day, whose letter is `Aurora.top`; the other letters full white, the
  disclosure 0.88. A serving's glyph is white on
  an `Aurora.cyan` 0.16 wash. Home's vessel has a glow, a halo and a highlight.

**Method.** Two throwaway probes in the session's scratchpad, each seeded with the canvas's own
week and with launch-environment knobs for the tint and the scrim: the first, before the spec, an
export of the index with the look drawn in scratch, climbed the tint; the second, a copy of the
working tree after the build, took the final table. Each walked every screen and captured it every
three seconds for a minute (the *Undo* pane two frames: its offer lasts eight seconds). The figure
is the worst pixel of a rectangle of clean ground beside each text, the text's white composited
over it; a mark — a cyan glyph or bar — is taken at its own rendered colour. Each rectangle was
checked by eye on an annotated capture first, and the ones found touching a rim, a glyph's own
glow or the text itself were moved before any figure was kept (the stage's ledger lists them).
**Clean ground is the floor** (#95). **Not done as the spec's §7.2 asked:** no beside-the-glyphs
figure was taken, and the set is not the seventy-one pairs of *Apple's glass, measured* but the
pairs of today's layouts below. **The scale differs from the old tables':** the first probe's
control, black 0.52 with no rim or sheen, read the weekday letters 6.52 at rest where the record
above has 5.97 at the same value — the card's layout and the sky's clock had changed.

**The tint, climbed on iOS 27.0** (whose glass is the lightest), the rim and sheen on unless the
row says otherwise, the weekday letters still at white 0.72 in every row:

| Tint | Glyph | At rest | A minute's sweep |
|---|---|---|---|
| black `0.52`, no rim or sheen (the control) | cyan, wash 0 | letters 6.52, goal dashes 4.96, cyan bar 4.73 | — |
| `Aurora.top` `0.52`, no rim or sheen | cyan, wash 0.16 | letters 4.74, cyan bar 3.43 | — |
| `Aurora.top` `0.52` | cyan, wash 0.16 | letters **4.28**, glyph **2.46** | — |
| `Aurora.top` `0.56` | cyan, wash 0.08 | letters **4.48**, glyph **2.66–2.79** | — |
| `Aurora.top` `0.60` | white, wash 0.16 | nothing under | nothing under; letters **4.64**, range labels 4.68 |
| **`Aurora.top` `0.64`** | white, wash 0.16 | nothing under | **nothing under**; letters 4.78, range labels 4.93 |

The blue tint does most of the lightening (letters 6.52 → 4.74 at the same opacity), the sheen a
further ~0.5. `0.60` passed with 0.14 to spare; `0.64` is the first rung with room. The letters
were then raised to full white, as the canvas drew them, and read 7.58 in the final sweep.

**The hand-made pane's scrim, on iOS 18.6** (iPhone 16; *Cancel* is the sheer pane, *Undo* the
opaque one), at rest:

| | sheer 0.30 / opaque 0.60 | 0.40 / 0.70 | 0.50 / 0.80 |
|---|---|---|---|
| *Cancel* (sheer) | 5.46 | 5.56 | 5.72 |
| *Undo*'s line / word / glyph (opaque) | 4.90 / 8.54 / 5.28 | 4.99 / 8.95 / 5.46 | 5.03 / 9.26 / 5.57 |

Frosted 0.70 is the value the probe swept before this stage's plan. **Sheer is 0.30**, the lightest
rung tried, with 0.96 of room; nothing lighter was rendered. **Opaque is 0.80, not the lightest passing rung**: 0.60 or 0.70 would put it at or
under frosted and invert the density scale; `thePhonesOwnPanesAreScrimmedWithTheSky` pins the order.
At the same margins, black raised ×1.5 stayed slate grey where the blue reads like the canvas — the
choice of the blue was the owner's, on the look.

**Every measured pair, the final values, worst frame of a minute's sweep** (empty History and the
first run at rest; iOS 27.0 and 26.5 on an iPhone 17, iOS 18.6 on an iPhone 16 with its own
rectangles; the tab bar's pairs exist only below iOS 26, where the bar is ours):

| Pair | Floor | iOS 27.0 | iOS 26.5 | iOS 18.6 |
|---|---|---|---|---|
| Home: streak number (1.0) | 4.5 | 10.43 | 13.44 | 10.21 |
| Home: streak flame (cyan) | 3 | 3.84 | 4.76 | 3.77 |
| Home: Cup disc glyph (1.0) | 3 | 7.58 | 9.51 | 7.45 |
| Home: Bottle disc glyph (1.0) | 3 | 6.48 | 9.06 | 6.87 |
| Home: the vessel's ml line, over water (1.0) | 4.5 | **4.05** | **4.05** | **4.20** |
| *Undo*: line (1.0) | 4.5 | 5.21 | 6.13 | 5.05 |
| *Undo*: word (1.0) | 4.5 | 8.34 | 11.36 | 8.96 |
| *Undo*: glyph (cyan) | 3 | 5.01 | 6.82 | 5.44 |
| History: `+` glyph (1.0) | 3 | 9.04 | 11.41 | 9.02 |
| Week card: title (1.0) | 4.5 | 6.93 | 9.59 | 6.93 |
| Week card: weekday letters (1.0) | 4.5 | 7.58 | 10.69 | 7.79 |
| Week card: figure (1.0) | 4.5 | 8.29 | 11.73 | 8.61 |
| Week card: *Average* (0.9) | 4.5 | 7.16 | 9.82 | 7.45 |
| Week card: disclosure (0.88) | 4.5 | 7.42 | 9.91 | 7.60 |
| Week card: goal dashes (0.62) | 3 | 3.67 | 4.56 | 3.71 |
| Week card: the shown day's ring (0.8) | 3 | 6.57 | 8.62 | 6.59 |
| Week card: cyan bar against track and gap | 3 | 3.44 | 4.57 | 3.38 |
| Week card: today's white bar against its track | 3 | 7.00 | 9.60 | 7.00 |
| Strip: title (1.0) | 4.5 | 8.84 | 12.00 | 8.84 |
| Strip: hour label (0.9) | 4.5 | 7.72 | 10.04 | 7.71 |
| Strip: cyan bar against the pane | 3 | 5.03 | 6.61 | 4.95 |
| Row 1: amount (1.0) | 4.5 | 8.26 | 11.54 | 8.85 |
| Row 1 / row 5: glyph, white on the wash | 3 | 4.46 / 4.66 | 5.30 / 5.41 | 4.42 / 4.42 |
| Row 1 / row 5: name (0.9) | 4.5 | 6.96 / 7.40 | 9.34 / 9.56 | 7.39 / 7.89 |
| Row 4: time (0.94) | 4.5 | 7.66 | 10.51 | 8.48 |
| Sheet: *ml* (0.8) | 4.5 | 5.90 | 7.90 | 5.96 |
| Sheet: *Cancel* (1.0) | 4.5 | 5.97 | 7.22 | 5.46 |
| Sheet: an unselected shortcut's amount (1.0) | 4.5 | 7.74 | 10.93 | 7.87 |
| Sheet: the selected shortcut's amount (1.0) | 4.5 | — | — | 6.96 |
| Settings: the goal's *ml* (0.8) | 4.5 | 5.58 | 7.44 | — |
| Settings: range labels (0.75) | 4.5 | 4.92 | 6.54 | 5.08 |
| Settings: a vessel's readout (0.75) | 4.5 | 5.61 | 7.43 | — |
| Settings: a vessel's glyph (cyan) | 3 | 3.50 | 4.71 | — |
| Settings: the vessels note (0.70), top / scrolled | 4.5 | 5.19 / 5.33 | 6.71 / 6.78 | 5.34 / 5.57 |
| Settings: *Quick-add vessels* title (1.0) | 4.5 | 7.62 | 10.83 | 7.95 |
| Settings: reminders description (0.75) | 4.5 | 5.79 | 7.63 | 5.80 |
| Settings: a language row (1.0) | 4.5 | 8.92 | 11.63 | 8.47 |
| Settings: the checkmark (cyan) | 3 | 5.23 | 7.07 | 5.24 |
| Settings: language footnote (0.75) | 4.5 | 5.80 | 7.57 | 5.94 |
| Tab bar (ours): inactive caption (0.72) | 4.5 | — | — | 5.22 |
| Tab bar (ours): active caption (1.0) | 4.5 | — | — | 7.92 |
| Tab bar (ours): active glyph (cyan) | 3 | — | — | 4.49 |
| Empty History: title (1.0) | 4.5 | 9.13 | 12.57 | 9.24 |
| Empty History: body (0.7) | 4.5 | 5.25 | 6.86 | 5.43 |
| Empty History: drop glyph (0.7) | 3 | 4.80 | 6.32 | 5.00 |
| First run: *ml* (0.8) | 4.5 | 7.25 | 8.87 | 7.07 |
| First run: range labels (0.75) | 4.5 | 6.19 | 7.56 | 6.12 |

*(2026-10-14, the sixtieth pass of `docs/AI_CONTEXT.md`: this table is stage 3c's record of its
day. Its *Settings* rows are of the card stage 4 restyled — *Settings, measured* — and its *First
run* rows are of `GoalSetupView`, which stage 5 deleted; the welcome's figures are in *Welcome,
measured*.)*

*(2026-10-17, roadmap item 1.2.6: **Strip: count of servings (0.9)** — the count roadmap item 1.2.6
drew at the heading's trailing edge, *2 servings*, footnote medium at white 0.9 on the strip's
`.frosted` + `.raised` pane, the pair the *Strip: hour label* row above measures. Floor 4.5: **8.17**
on iOS 27.0 (*WaterBuddy Probe 27*, an iPhone 17) and **10.64** on iOS 26.5 (*WaterBuddy Probe
26.5*, an iPhone 17); iOS 18.6 not measured. Each is the worst of 13 frames five seconds apart, a
minute of the aurora, at the default text size: the glyphs' 99.5th-percentile luminance in the count's
box against the 95th percentile of clean ground in a band 3–9 pt around it, WCAG relative luminance.
Best frames 8.66 and 10.83. A scratch probe, not this table's own run.)*

- **Nothing measured that this stage draws is under its floor, on any of the three systems.** The
  tightest:
  the cyan bar (3.38–3.44 on 27.0 and 18.6), the goal dashes (3.67–3.71), the vessel glyph in
  Settings (3.50) against 3; the range labels (4.92) and *Undo*'s line (5.05) against 4.5.
- **Under, on every system: the vessel's ml line over water**, 4.05–4.20 — water, not glass. This
  stage drew nothing over the water (the new highlight is at the vessel's top left); no
  before-and-after figure was taken. It is #95's line, waiting on the owner's yardstick ruling.
- **Increase Contrast** (iOS 27.0, at rest): the system darkens the glass and every pair rises —
  the goal dashes 4.66, the cyan bar 4.69, the vessel glyph 4.87, the range labels 6.82. The ml line
  over water reads 4.12.
- **Reduce Transparency** (iOS 27.0 and 18.6, switched through the Settings app): every pane is its
  opaque fill with its rim and no sheen; the vessel draws no glow, halo or highlight. The opaque fill
  is still `Base.archived.opaqueFill`, a purple-grey, beside blue glass everywhere else.
- **A pressed pane** (iOS 27.0, recorded): Apple's interactive glass swells the Cup disc and
  lightens it to lavender; the lit rim brightens with it. One reaction. While the finger is down the
  white glyph sits on a light disc and reads faint — seen, not measured; no floor is set for a
  pressed state.
- **The smallest phone** (375 × 667, iOS 26.5): the week card's row stands 9.5 pt in rather than
  16 so each day stays 44 pt wide (`HistoryView.dayRowInset(across:count:)`); the
  ring, the disc and the dashed line sit on the tracks at the ordinary size and at
  `AccessibilityXXXL`.

**Not measured.** On iOS 18.6, Settings' goal *ml*, a vessel's readout and a vessel's glyph; on iOS
27.0 and 26.5, the sheet's selected shortcut's amount. The shown day's letter on its disc (derived
instead, by `theShownDaysLetterReadsOnItsDisc`). The past-day empty state (*Tap + to add a serving
you forgot.*), Settings' *Open iOS Settings* button, the sheet's wheel (#59, accepted), the
selected shortcut's rim, Home's
status and quiet lines and every other text on the aurora (no pane under them, so this stage did
not change them), Russian and Uzbek, iOS 17, a device. The probe's captures and scripts lived in
the session's scratchpad and are not kept; this section is the record.

## The watch's glass, measured

**2026-10-20, the redesign's stage 7a** (spec `docs/superpowers/specs/2026-10-20-the-watch-stage-design.md`
§3.3). The watch's panes moved from the hand-made stack to Apple's glass: the vessel to the clear
variant, untinted; the *More* capsule and the serving sheet's two rows, now `interactive: true`, to the
regular variant, tinted `Aurora.top` at `0.64`, the phone's value.

**Method.** A throwaway probe in a copy of the working tree, seeded through `WristModel.apply(_:)` from
launch arguments — 1,240 of 2,000 ml, and 0 — with switches that draw the sheet open, scroll the
capsule into view and force Reduce Transparency (`simctl` cannot set it); and the same probe in a
`HEAD` export, which draws the hand-made stack, for the column beside it. *WaterBuddy Probe Watch 46*
(Series 12 46mm), **watchOS 27.0 only**: the spec asked for a 26.x runtime too, none reached this
Mac, and the owner ruled the stage go on without it. One capture a state, taken when two in a row
agreed — `WristAurora` does not move, so one frame is the whole of it (the plan's correction (2)).
Eleven captures, each looked at. **The figure** is the label's own full-strength ink — the 98th
percentile of luminance between the clean rows — against the **lightest** pixel of the clean rows
above and below the label across its width: clean ground is the floor (#95). The plan's column
sampler was run as well; its worst column is a glyph's anti-aliased edge, not a floor figure, and its
median agrees with the figure at the median ground.

| Pair | Floor | `HEAD`, hand-made | 7a, Apple's glass | 7a, Reduce Transparency |
|---|---|---|---|---|
| *More*, white, on the capsule | 4.5 | 12.28 | **8.68** | 12.03 |
| *Cup*, white, on its row | 4.5 | 9.44 | **6.92** | 12.03 |
| *Bottle*, white, on its row | 4.5 | 9.41 | **6.87** | 12.03 |
| *150 ml*, `.secondary`, on its row | 4.5 | 4.87 | **2.83** | 4.74 |
| *500 ml*, `.secondary`, on its row | 4.5 | 4.88 | **2.84** | 4.74 |
| *62%*, white, over the water at 62% | 3 | 4.94 | **4.90** | 4.94 |
| *1 240 / 2 000 ml*, white 0.8, over the water (#44) | 4.5 | 2.39 | **2.39** | 2.39 |

- **The tint stays `0.64`, one value for both devices — the owner's ruling**, the plan's own branch
  for this table: the only pairs under their floor that 7a moved are the sheet's `.secondary` amounts,
  and the redesign's stage 7b deletes the sheet. On Apple's tinted glass the secondary style renders
  dimmer (ink 0.28 against 0.35) over lighter ground (0.067 against 0.032). Climbing the watch's tint
  for a pane about to go would have set 7b's discs by a label they do not carry. Between 7a's commit
  and 7b's the amounts read 2.83:1; nothing ships in between.
- **The vessel is unchanged by 7a**, to the figure: its clear glass takes no tint, and its readout
  stands on `WaterReadabilityScrim`. The millilitre line's 2.39 is #44's failure read by this
  method — the ground under the line's foot, where the water is lightest, against the 3.34 worst
  column recorded in *Contrast figures that were measured, not eyeballed* — and 7b removes the line.
- **Reduce Transparency** draws the opaque fill and the plain aurora, as on the phone; every pair
  passes there.
- **Not measured:** watchOS 26.x (no runtime); the other four watch sizes; the press, which on Apple's
  glass is the system's own response and was not captured; Russian and Uzbek. 7b re-renders the
  screen on all five sizes.

## The watch's screen, measured

**2026-10-20, the redesign's stage 7b** (spec `docs/superpowers/specs/2026-10-20-the-watch-stage-design.md`
§3.4). The screen is the canvas's board *Watch*: the vessel a display, the millilitre line under it,
a row of three pour buttons, the sync caption. **It supersedes the vessel and millilitre-line rows of
*The watch's glass, measured*** above; those stay as the record of their day.

**What is drawn**, and where each figure comes from:

| Token | Value | Source |
|---|---|---|
| Column gap | 6 pt | the canvas (`WristColumn.gap`) |
| Column height | the safe area + the bottom inset less 22 pt | the owner's ruling, from three 46 mm renders: the canvas laid out from y = 28 to 226 of 248, which does not fit below the real 53 pt clock inset (`WristView.columnHeight`) |
| Vessel | 60 pt floor; ceiling 100/208 of the screen's width | the canvas's 100 pt on the 46 mm's 208 (`vesselRange`); 77 pt on the 46 mm as built, 60 on the 40 mm |
| Figure | 0.32 × diameter, bold rounded | the canvas's 32 in 100 |
| `%` | 0.14 × diameter, **never under 14 pt**, bold rounded | the canvas's 14 pt bold — large text; at the share alone it was 11 pt in the 77 pt vessel and read 3.99:1 (the owner's ruling) |
| Scrim full at | **32%** (was 20%) | water first reaches the figure's ink at `(0.36·D − 6)/(D − 12)`: the ink ends 0.106–0.115 of D below the centre on `ImageRenderer` renders at 60, 77, 80, 100 and 123 pt, rounded up to 0.12; 0.325 at the floor, rounded down |
| Line | `.footnote` semibold, full white, `minimumScaleFactor(0.7)` | out of the water (#44 retired) |
| Disc | 46 pt (`@ScaledMetric`), held to 44…56; below the accessibility sizes it gives way to its column's share, down to 44, where three do not fit; at the accessibility sizes it keeps its size and the row scrolls sideways | the canvas's 46; rule `65-accessibility`; the 40 mm row would otherwise scroll from the default size (and, as first built, from xLarge — the final review's finding) |
| Least gap between panes | 4 pt, the spare spread between them | rule `60-design-system`; the canvas's 8 on the 46 mm |
| Glyph | 0.46 × disc | the canvas's 22 in 46, rounded down |
| Capsule | glyph + 3 pt + amount, `.footnote` heavy rounded, 8 pt either side | the canvas's 84 pt capsule |
| Amount under a disc | `.caption2` semibold, full white, 3 pt below; below the accessibility sizes it may scale to 0.5 inside its column's even share | the 40 mm row: amounts 45–47 pt wide against 44 pt shares |

**Method.** *The watch's glass, measured*'s — a throwaway probe in a copy of the working tree, seeded
through `WristModel.apply(_:)` from launch arguments, with switches for Reduce Transparency and
`.accessibility5` (`simctl` sets neither on a watch); one capture a state once two agree, each looked
at; the label's full-strength ink against the lightest pixel of the clean rows above and below it,
the box the label's own ink found from the render. Boxes placed by hand with their clean rows 6 to
13 px off the ink read the 100% figure at 2.89 and 2.65 — brighter water further out — and were
superseded. *WaterBuddy Probe Watch 46* and *40*, **watchOS 27.0 only** (#151).

| Pair | Floor | 46 mm | 40 mm | Reduce Transparency, 46 / 40 |
|---|---|---|---|---|
| The line, white, on the aurora | 4.5 | 6.72 | 6.87 | 11.56 / 11.50 |
| Cup's glyph, white, on its disc | 3 | 7.53 | 7.50 | 12.03 / 12.03 |
| Bottle's glyph, white, on its disc | 3 | 7.94 | 7.31 | 12.03 / 12.03 |
| *150 ml* under its disc | 4.5 | 7.22 | 7.07 | 9.64 / 9.18 |
| *500 ml* under its disc | 4.5 | 7.22 | 7.11 | 9.77 / 9.54 |
| The figure at 0% (glass, no scrim) | 3 | 4.42 | 4.48 | — |
| The figure at 62% | 3 | 4.86 | 4.77 | 4.99 / 4.86 |
| The figure at 100% | 3 | 3.31 | 3.21 | — |
| The `%` at 0% | 3 | 4.64 | 4.66 | — |
| The `%` at 62% | 3 | 4.20 | 3.79 | 4.22 / 3.85 |
| The `%` at 100% | 3 | 3.73 | 3.54 | — |

- **The `%` before the floor**, at 0.14 × diameter semibold: 4.58 / 3.99 on the 46 mm (62% / 100%),
  4.42 / 4.00 on the 40 mm, against 4.5 as small text. The widget's two readout shadows raised the
  46 mm's 100% to 4.34; the old 0.28 figure with the shadows to 4.43. Neither reached 4.5.
- **The Glass, white with `Aurora.top` content, is not measured** — its contrast is derived
  (`thePrimaryLabelClearsSevenToOneEvenAtTheFootOfTheShade`).
- **Rendered and looked at, not measured:** all five sizes at 0, 1,300 and 2,600 ml and with
  150/1,000/1,500 ml vessels (the capsule row on 46 and 49 mm; three discs on 40–44 mm and for a
  litre), Russian and Uzbek, a forced xxxLarge on 40, 44 and 46 mm (every row fits, the discs at 44
  on 40 and 44 mm), and `.accessibility5` (on 40 and 44 mm the row scrolls sideways).
- **Not measured:** watchOS 26.x; the press, which the owner made in `DeviceHub.app` and which
  poured each button's serving (#152), but whose glass response was not captured.

## Settings, measured

**2026-10-13, the redesign's stage 4** (spec `docs/superpowers/specs/2026-10-09-premium-redesign-design.md`
§7; plan `docs/superpowers/plans/2026-10-13-premium-redesign-stage-4.md`). It restyled Settings to
the canvas's *Settings* board, so **it supersedes the Settings rows of *The look, measured*** above
and every older Settings figure in this file; those stay as the record of their day.

**What is drawn now** (the canvas's values, read from the board's source; the plan's table gives
each beside what it replaced). Every card: 20 pt padding (the canvas: 22 at the vessels card's
top), 16 pt apart, 20 pt under the title,
`.frosted` + `.raised`. Every card title 17-pt semibold, white. Every note — the vessels note, the
reminders explanation, the language footnote — `.subheadline` (15 pt) at **white 0.92**: one style,
where the canvas draws the language footnote at 13 pt (the owner's ruling S1). The goal's figure 36
pt bold rounded, its *ml* at 17/36 of it, white 0.9; the range labels `.footnote` semibold, white
0.88. A vessel's glyph `Aurora.cyan` in a 26-pt box, its name 17-pt medium, its amount 17-pt bold
rounded **full white**, grouped. Hairlines white 0.16. The vessels note reads *"The Glass is the one
your widget, Siri and Control Center log."*

**Method.** As *The look, measured*: a throwaway probe in a scratch copy of the working tree,
Settings captured at the top and scrolled to its end every three seconds for a minute; the worst
pixel of clean ground beside each text with the text's white composited over it; a cyan mark at its
own rendered colour. Each rectangle was drawn on a capture and looked at before a figure was kept —
the Cup glyph's first foreground box sat on the cup's dark opening and read 1.08; moved onto solid
glyph, 3.08. On the final source's frames the iPhone 16's box above the cup caught the glyph's own
rim and read 2.75; pulled clear of it, 3.09, on those frames and on the sweep's. Clean ground is the
floor (#95). iOS 27.0 and 26.5 on an iPhone 17, iOS 18.6 on an iPhone 16 with its own rectangles.

| Pair | Floor | iOS 27.0 | iOS 26.5 | iOS 18.6 |
|---|---|---|---|---|
| *Daily goal* (1.0) | 4.5 | 5.27 | 6.76 | 5.25 |
| The goal's figure (1.0) | 4.5 | 7.65 | 10.55 | 7.79 |
| The goal's *ml* (0.9) | 4.5 | 7.76 | 10.38 | 7.82 |
| Range labels (0.88) | 4.5 | 5.35 | 7.06 | 5.50 |
| *Quick-add vessels* (1.0) | 4.5 | 7.10 | 9.83 | 7.22 |
| Cup's name and amount (1.0) | 4.5 | 6.78 | 9.39 | 6.70 |
| Glass's name and amount (1.0) | 4.5 | 8.66 | 11.70 | 8.67 |
| Bottle's name and amount (1.0) | 4.5 | 9.11 | 12.59 | 9.38 |
| Cup's glyph (cyan) | 3 | **3.08** | 4.02 | **3.09** |
| Glass's glyph (cyan) | 3 | 4.76 | 6.21 | 4.66 |
| Bottle's glyph (cyan) | 3 | 5.48 | 6.96 | 5.28 |
| The vessels note (0.92), top / end | 4.5 | 7.75 / 7.45 | 10.62 / 10.29 | 7.97 / 7.86 |
| *Smart reminders* (1.0) | 4.5 | 7.90 | 11.28 | 8.16 |
| The reminders explanation (0.92) | 4.5 | **4.89** | 6.37 | **4.93** |
| *Language* (1.0) | 4.5 | 7.09 | 9.25 | 6.86 |
| A language row (1.0) | 4.5 | 8.50 | 11.32 | 8.35 |
| The check (cyan) | 3 | 5.11 | 6.90 | 5.18 |
| The language footnote (0.92) | 4.5 | 7.90 | 10.64 | 8.01 |

Each cell is the worst of 20 frames.

- **Nothing measured is under its floor, on any of the three systems.** The tightest: the Cup's
  glyph (3.08 on iOS 27.0, 3.09 on 18.6, against 3) and the reminders explanation (4.89 / 4.93
  against 4.5). Both sit by
  their card's top-left sheen, the lightest ground on a pane: the Cup's glyph is the first thing in
  its card under the title, and the explanation's first line starts at the sheen's edge.
- **Increase Contrast** (iOS 27.0, one frame): every pair rises — the Cup's glyph 4.11, the
  explanation 6.46.
- **Russian and Uzbek** (iOS 27.0, one frame each, rendered and not measured): nothing is cut.
- **The smallest phone** (375 × 667, iOS 26.5): whole at the ordinary size. At
  `AccessibilityXXXL` a vessel's amount was cut to "150…" beside its name; the row is now a
  `ViewThatFits` that puts the amount under the name, and re-rendered every amount is whole.
- **The status bar** (#108): scrolled, content is cut at the status bar's edge and nothing is drawn
  under the clock, on all four devices rendered.

- **The final source.** The sweep ran before the vessel row became a `ViewThatFits` and before the
  review's changes — the row measured at its widest, and the title's top inset one point less. Three frames a system at rest after them: no
  pair under its floor, and every figure at or above its sweep's worst frame, once the Cup's box
  was pulled clear.

**Not measured.** The *Open iOS Settings* button (shown only while notifications are refused);
Settings under Reduce Transparency (this stage changes no pane); a minute's sweep on the final
source; Russian and Uzbek figures; iOS 17; a device.

## Welcome, measured

**2026-10-14, the redesign's stage 5** (spec `docs/superpowers/specs/2026-10-14-welcome-design.md`;
plan `docs/superpowers/plans/2026-10-14-premium-redesign-stage-5.md`). The first-run screen is
`WelcomeView` — four steps, a pinned bar, the goal calculator — and `GoalSetupView` is gone.

**What is drawn** (the canvas *WaterBuddy welcome*'s values, read from its boards' source, as
`WelcomeStyle` holds them; then the owner's rulings after the first measurement):
- A step's title is `.largeTitle` bold at the tabs' place (`ScreenMetrics`); the goal and vessels
  steps open their card with a line in 17 pt **full white**, the reminders step keeps its line
  under the title, on the aurora, **full white** (the canvas: 0.92 under every title). Cards 20 pt
  padding, 16 apart, `.frosted` + `.raised`.
- Hello: a 232-pt sheer glass circle of `WaterSurface` at half, *Welcome to* `.title2` semibold at
  0.92 over *WaterBuddy* 42 pt heavy (capped 64), the line at 0.92.
- The goal: the figure 60 pt bold rounded (capped 80), *ml* at 22/60 of it, white 0.9; range
  labels `.footnote` semibold 0.88; *Work it out for me* 56 pt, the sparkle **after** the words (the
  canvas: before them). The calculator: a 124-pt weight column (a system wheel, 160 pt, and a
  kg | lb switch), three activity choices 50 pt tall, *Use* on sheer glass, the disclaimer
  `.footnote` 0.88. Choices and units are marked with `LiquidGlass.Selection`'s fill and rim.
- The bar: dots 8 pt, the current 22 pt wide, others **white 0.6** (the canvas: 0.35); *Back* 112
  pt on sheer glass; the main action on the primary surface, both 56 pt; *Not now* 44 pt. The two
  footnotes on the aurora at **white 0.95** (the canvas: 0.88).
- Reminders: a notification preview on frosted glass with the reminder's own two strings; seven
  bells on **frosted** discs (the canvas: sheer), 34 pt, over their hours.

**Method.** As *Settings, measured*: a throwaway probe in a scratch copy of the index, launched with
the DEBUG fresh start; every step and Settings captured 20 times 3 s apart; the lightest pixel of
ground beside each text with the text's white composited over it; a cyan mark at `Aurora.cyan`.
Bands beside each element are built from the frames the probe reads off the tree, and any band
overlapping another element is dropped; text on the aurora is read on clean ground 10–14 pt out
(#95) and beside its glyphs 2–6 pt out. Every band is drawn on a capture; every pair under its
floor was looked at in a zoom before its figure was kept. iOS 27.0 and 26.5 on an iPhone 17, iOS
18.6 on an iPhone 16.

**The first sweep found eight things under their floor, in nine rows of its table** (the dots
were read on two steps; worst frame, iOS 27.0 / 26.5 / 18.6): the goal and vessels lines under the
title, white 0.92 on the aurora's blue light, 3.97 / 3.96 / 4.09
— and at full white still 4.38; the reminders line 4.36 / 4.43 / 4.69; the goal footnote at 0.88,
4.25 / 4.23 / 5.20; the sparkle in the row's lit corner, 2.84 / 3.48 / 2.89; the Cup's glyph at
the vessels card's lit corner (no title above it there), 2.81 / 3.59 / 2.74; a bell on a sheer
disc, 1.83 on 27.0 only; the inactive dots at 0.35, 2.20 / 2.20 / 2.17. The owner ruled each
(R1–R4), and the line moved into the vessels card then read 4.46 at 0.92 by its lit corner — full
white for both card lines (R5). No value was moved by eye.

**On the final source, a minute's sweep a system — 69 pairs in the measurement table, 59 on the
welcome's steps and 10 on Settings after its vessel rows moved out; 68 of them read (all but *Your
weight*, below), none under its floor.** The table below gives the welcome's pairs and two of
Settings':

| Pair | Floor | iOS 27.0 | iOS 26.5 | iOS 18.6 |
|---|---|---|---|---|
| Hello: *Welcome to* (0.92) / *WaterBuddy* | 4.5 / 3 | 5.83 / 6.30 | 5.83 / 6.30 | 5.89 / 6.36 |
| Hello: the line (0.92), clean ground | 4.5 | 4.76 | 4.76 | 4.76 |
| Dots: current / inactive (0.6) | 3 | 7.19 / 3.66 | 7.19 / 3.66 | 6.96 / 3.57 |
| A step's title | 3 | 6.94 | 6.99 | 6.72 |
| The goal card's line (1.0) | 4.5 | 5.13 | 6.56 | 5.02 |
| The goal's figure / *ml* (0.9) | 3 / 4.5 | 7.06 / 7.48 | 9.83 / 10.28 | 7.04 / 7.68 |
| Range labels (0.88), left / right | 4.5 | 6.63 / 7.20 | 9.02 / 9.82 | 6.79 / 7.32 |
| The goal footnote (0.95), clean ground | 4.5 | 4.91 | 4.91 | 6.11 |
| *Work it out for me* / the sparkle (cyan) | 4.5 / 3 | 4.83 / 4.74 | 4.92 / 6.58 | 6.32 / 5.30 |
| The chevron (0.92) / *Back* | 3 / 4.5 | 8.00 / 8.88 | 10.44 / 11.80 | 8.33 / 8.29 |
| *How active are you?* | 4.5 | 9.31 | 12.53 | 9.13 |
| An activity's name, worst / its line, worst | 4.5 | 7.97 / 7.01 | 10.37 / 9.19 | 7.76 / 6.92 |
| *kg* picked / *lb* (0.88) | 4.5 | 8.10 / 7.87 | 10.14 / 10.24 | 7.68 / 7.86 |
| *Use* / the disclaimer (0.88) | 4.5 | 8.80 / 7.45 | 12.09 / 9.91 | 8.29 / 7.71 |
| *Your goal is …* (0.92) / its ✓ (cyan) | 4.5 / 3 | 8.17 / 6.04 | 10.90 / 7.70 | 8.02 / 5.75 |
| The vessels card's line (1.0) | 4.5 | 4.95 | 6.29 | 4.89 |
| Cup's name / amount | 4.5 | 6.20 / 8.66 | 8.42 / 12.09 | 6.18 / 8.65 |
| Cup's / Glass's / Bottle's glyph (cyan) | 3 | 3.28 / 4.08 / 4.78 | 4.39 / 5.67 / 6.64 | 3.25 / 4.16 / 4.88 |
| The Glass note (0.92) / the vessels footnote (0.95) | 4.5 | 7.90 / 5.80 | 10.56 / 5.75 | 8.02 / 6.39 |
| The reminders line (1.0), clean ground | 4.5 | 4.84 | 4.92 | 5.22 |
| Preview: *WaterBuddy* (0.88) / *now* / title / body (0.92) | 4.5 | 5.45 / 7.62 / 8.49 / 6.19 | 7.05 / 10.04 / 11.93 / 8.48 | 5.44 / 7.63 / 8.82 / 6.61 |
| *Smart reminders* / the schedule sentence (0.92) | 4.5 | 4.93 / 8.00 | 6.36 / 10.08 | 4.91 / 7.75 |
| A bell's hour (0.92), worst / a bell (cyan) | 4.5 / 3 | 5.78 / 3.72 | 7.60 / 5.36 | 6.26 / 4.53 |
| *Not now* (0.92) | 4.5 | 7.36 | 7.36 | 7.25 |
| Settings, after the extraction: Cup's glyph / name | 3 / 4.5 | 3.11 / 5.95 | 4.08 / 8.01 | 3.10 / 6.02 |

Each cell is the worst of 20 frames. *Your weight* has no band clear of other frames; it is the same
white, on the same row, as *How active are you?*.

- **The tightest**, by its margin over the floor: Settings' Cup glyph, 3.11 / 4.08 / 3.10 against
  3 — 0.10 over on 18.6, by its card's lit top-left corner, the sheen *Settings, measured* found
  there (3.08 at stage 4); then the welcome's Cup glyph, 3.25 on 18.6, by the vessels card's same
  corner; then Hello's line, 4.76 on all three systems against 4.5, on the aurora's clean ground;
  then, on iOS 27.0, *Work it out for me* (4.83) and the reminders line (4.84), and the vessels
  card's line (4.89 on 18.6), by the card's lit corner. *(This bullet named Hello's line first
  until the fifty-ninth pass; a fresh reader found the two Cups tighter by margin.)*
- **Settings is unchanged by the extraction** of its vessel rows into `VesselSliders`: its figures
  are within a box's width of stage 4's.
- **Increase Contrast** (27.0), **Russian and Uzbek** (27.0), **Reduce Transparency** (27.0, the
  opaque fill on every pane) and **Reduce Motion** (27.0) were rendered, one frame a step, on the
  build before the owner's rulings — which move two lines into their cards, the sparkle after its
  words and the bells onto frosted discs, and raise the whites of the dots, the footnotes and the
  lines, but no control's layout — and not
  measured; so those renders never showed the moved sparkle or the bells' new glass. Nothing is cut in either language; Russian stacks the calculator's two
  columns and the reminders bar's two buttons at the ordinary size, as their `ViewThatFits` allow.
- **The smallest phone** (375 × 667, iOS 26.5): whole at the ordinary size, the bar 76 pt; at
  `AccessibilityXXXL` nothing is cut and each step scrolls above the bar, which stands about 189 pt
  tall on the goal step and about 321 pt on the reminders step — **about half the screen**, its
  three controls stacked (rendered again on the final source). **Landscape** (27.0, final source):
  every step whole and scrolling above the bar; on Hello the greeting stands below the fold.
- **The slide** (27.0, a recording, frames 50 a second): the step arriving starts a screen's width,
  402 pt, out and is in place about 0.6 s after the tap — most of the way in 0.3 s, then the curve's
  tail (`Motion.page`, 0.45 s). Both steps move; the bar stands still. **Under Reduce Motion** a step
  cross-fades in place in 0.2–0.3 s (`Motion.pageFade`, 0.25 s), and Hello's waves stand still.

**Not measured.** The calculator open at the largest text size (rendered, scroll position not
checked); VoiceOver's reading of the bell strip, the greeting and the ✓ line (XCUITest lists their
children; a device check); iOS 17; a device.

## Apple's tab bar, measured

*Added 2026-10-12, the redesign's stage 3b.* On iOS 26 and later the three screens are the tabs
of a `TabView` and the bar is Apple's: its glass, the lens that follows a press dragged along it.
Below iOS 26 the app keeps its own `GlassTabBar`, which the sections above describe. The app
gives Apple's bar three things: `.tint(.white)`, `.tabBarMinimizeBehavior(.never)`, and a shade
under it.

**2026-10-12, stage 3b's second pass: the bar is no longer a `TabView`'s, and everything
measured below was.** A `TabView` offers no transition between its pages, so the pages are the
app's own pager now and the bar is the same `UITabBar` standing alone (`SystemTabBar`), with a
white `tintColor` and the same shade, drawn once by the container. It takes the height it asks
for — 83 pt on a phone with a home indicator — and is pulled down by the bottom inset, which
is where the system stands its own.

| | iOS 27.0 | iOS 26.5 |
|---|---|---|
| The foot of the screen against the `TabView` build's, 402 × 874 pt, pixels differing by more than 24 levels **in grey** (the script turns the difference to grey first) | **none** in the bottom 700 px | the bar's own, and nothing above it (read off the spike's build, whose bar is laid out by the same lines) |
| The same, taken finer in the fifty-fourth pass of `docs/AI_CONTEXT.md` on a stored pair that reproduces the row above — the `TabView` build's Home against this build's (`tools/maxdiff.py`, `tools/bands.py`, in the session's scratch folder): the largest difference, in grey and in one channel | **the bar's own 249 px: 11 and 26** (blue; 14 pixels over 24 in that channel). **The 451 px above it: 2 and 4.** (A share of pixels "differing by something", 21 %, was given here in the fifty-fourth pass and withdrawn in it: it is a count after the difference is turned to grey, and by the same count two captures of one build differ in 14 % and 36 %) | — |
| Two captures of the `TabView` build against each other, the same bands | 2 and 4 at most, bar and all — so the bar's 11 is the bar's and not one capture against the next | — |
| The same, 375 × 667 pt | — | the bar's own; the header not at all |
| The bar's glass | as the `TabView`'s to the eye, and within the 11 grey levels of the row above that gives the bar's own 249 px | **darker**: smoked where the `TabView`'s was vivid over the aurora |
| Captions, by the first-read method below, single frames | — | **every caption ≥ 8.03; the selected one ≥ 11.09**, seven frames across the three tabs: six of the recorded walk, History and Settings selected with rows and controls under the bar, and one still of Home |
| The `TabView` build by the same script on one frame, Home selected | — | selected 5.50, *History* 8.27, *Settings* 7.56 |

- **The darker glass is iOS 26.x's doing and was not asked for.** Not the bar's appearance
  objects — a transparent and a scroll-edge appearance were tried — and not cured by a tab
  controller only as tall as the bar. It seems to need the pages inside the controller
  (`docs/AI_CONTEXT.md` known issue #119).
- **The 26.5 column of the table below describes a bar the app no longer draws.** The new
  figures are from seven frames, not a minute of the aurora, and are not a sweep.
- **The shade is kept at 0.25.** It was measured as needed for the `TabView`'s lighter
  lozenge; whether the darker bar needs it was not measured, and on iOS 27.0 it is part of
  what keeps the two builds within the 24 grey levels of the table's first row — a tolerance,
  not an identity: that script counts pixels over it and reports nothing finer, and the two
  rows under it show the bar differing inside it.
- **The caption under its floor on the small phone (below, #112) was not taken again.**
- **Looked at since:** landscape and a change of language under the standalone bar on iOS
  27.0 — the captions follow the language and the selection holds — and Reduce Motion.

| Token | Value | Held by |
|---|---|---|
| `BarShade.opacity` | 0.25 | `theShadeIsNoLighterThanTheFirstRungWithRoom`, `theShadeLeavesTheAuroraShowing` |
| `BarShade.ramp` | 20 pt | `theRampFitsInsideHomesFoot` |

**The method is not this file's usual one, and the figures do not compare with the tables
above.** A caption on Apple's bar is drawn in a colour the system mixes, so there is no token to
composite: the caption's own colour is read off the render — the brightest half-percent of its
band — against the lightest 2 % of the darker half of the same band (`tools/selected.py`,
`tools/barcontrast.py`, in the session's scratch folder). A first-read method. 402 × 874 pt
phone, ordinary text size, the caption band at y 828–845 pt; through a minute of the aurora on
Home, and with History's rows and Settings' controls scrolled under the bar.

| | iOS 27.0 | iOS 26.5 |
|---|---|---|
| White tint, no shade | every caption ≥ 5.02; the selected one 7.3–7.7 | **the selected caption 3.79–4.46** — Home 4.17, History 3.88, Settings 3.79 at worst |
| Cyan tint, no shade | — | 3.98 |
| Shade `0.20`, a minute | — | 4.78 at worst |
| Shade `0.25`, 24 s | — | 5.18–5.61 |
| Shade `0.40` | — | 6.02–6.58 |
| **As built**: white tint, shade `0.25`, a minute and the scrolled sets | **every caption ≥ 6.77**; the selected one ≥ 9.03 | **every caption ≥ 5.10** — selected Home 5.49, History 5.17, Settings 5.10 |

- **Why a shade and not a tint.** On iOS 26.5 the system draws the selected tab's lozenge lighter
  than the bar — about sRGB (130, 57, 240) — and its caption not white but about
  (255, 218, 255). No tint the app can give moves that pair over 4.5:1; pure white on that
  lozenge would read 5.25–5.5 and is not on offer. The lozenge follows what is behind the bar,
  so the ground is darkened. `0.20` passed with 0.28 to spare; `0.25` is the first rung with
  room.
- **Why white and not `Aurora.cyan`**, which the canvas drew: cyan read 3.98:1 on iOS 26.5
  before the shade. **Cyan was not measured with the shade.**
- **Where the shade is drawn.** Over the foot of each tab's screen and under the bar: a 20 pt
  ramp ending at the bottom of the safe area, then the full shade to the foot of the screen —
  and, in landscape, out to the screen's own edges.

**One caption is under its floor, in one configuration, and is not cured.** A 375 × 667 pt
phone at Accessibility XXXL on iOS 26.5, where Home scrolls and the white Glass disc rests under
the bar beside the selected tab: one capture — **the selected caption 4.01:1**, *History* 4.92,
*Settings* 5.47. `.scrollEdgeEffectStyle(.soft, for: .bottom)` gave the same figures; `.hard`
gave 6.13 / 9.10 / 8.92 and cut the content off square at the bar's top edge, so nothing showed
through the glass. Neither is adopted (`docs/AI_CONTEXT.md` known issue #112).

**On that phone at the ordinary text size** Home is whole above the bar with the vessel at its
200 pt floor, and the vessels' names stand inside the ramp: 8.0, 7.0 and 5.6:1 — one capture,
the names' brightest 1 % against the median of the box around them (`tools/caption.py`, the
session's scratch folder).

**Looked at, not measured:** Increase Contrast on iOS 26.5 — Apple's bar goes dark and nearly
opaque, white on it. **Not looked at:** Reduce Transparency; iOS 26.0–26.4; a device. *(This
line also named Reduce Motion, "for which the simulator has no switch", until the fifty-fourth
pass of `docs/AI_CONTEXT.md`. Its Settings app has one, and the standalone bar was looked at
under it on iOS 27.0 — the note of 2026-10-12 above. Apple's bar inside a `TabView` never
was, and is no longer drawn.)*

## The paywall, measured

**2026-10-22, set A's step 1, Task 8** (spec `docs/superpowers/specs/2026-10-21-premium-paywall-and-monthly-design.md`
§3.4–3.5; plan `docs/superpowers/plans/2026-10-21-premium-paywall-and-monthly.md`, Task 8 Step 3).
It supersedes the eighty-first pass's transcription of `PaywallStyle` and the badge.

**What is drawn now.** The sheet on the aurora: the close button (white glyph, `.sheer` disc, a
control) and the promise — *Logging water is free, always.*, white, its check white — on `.frosted`
glass, a capsule beside the button and a rounded row of its own at the accessibility sizes; the
decorative preview on `.frosted`; **the title alone on the aurora**, `.largeTitle` heavy, white, with
`legibleOnBackdrop()`'s two shadows; **one `.frosted` + `.resting` card** (16 pt padding) holding the
subtitle (`.body`, **full white**), the four feature rows — each glyph `Aurora.cyan` in a 28-pt box
that scales to 42, at 0.72 of it (20 pt, the Settings card's previews' size), no tile; the title
`.subheadline` bold white, the line `.footnote` at white 0.92 — and *New Premium features arrive in
updates, included.* at 0.92; the three plan tiles on `.frosted` glass, one height, the selected one
marked with `LiquidGlass.Selection`; on the yearly, **BEST VALUE** as its first line (`.caption2`
heavy, uppercase, the tile's white), the other two keeping an invisible copy of that line side by
side so the names and prices stand level; names white, prices `.title2` heavy white, the period, the
saving (its own line) and the note at 0.92 — the yearly's free week too; the primary surface; the terms
at 0.88 and the footer at 0.92 on the aurora, both with the two shadows. The Settings card: the rim
unchanged, its header sparkle **white**, the title white, the note 0.92, the previews' captions white
and their glyphs `Aurora.cyan`.

**Method.** As *Welcome, measured*, with the bands built from the pixels rather than the tree: a
throwaway XCUITest method in a scratch copy of the index held each place for a minute, a frame every
3 s — the card in Settings, the sheet's top, the sheet's end — on *WaterBuddy Probe 27* (iPhone 17,
iOS 27.0), sRGB frames. Each element's own ink was found in a box drawn round it; its ground read on a
ring 2–6 pt out (beside its glyphs) and, for text on the aurora, also 10–14 pt out (clean ground, #95);
every other ink on any frame — text, rims, marks — masked out and dilated 3 px, the aurora's cyan
light (green ≤ 159 over the frames) kept as ground; white composited at its opacity over each ground
pixel; a cyan mark at its own rendered colour. Worst frame. Every ring was drawn on a capture and looked
at before a figure was kept: two earlier sets of boxes were thrown away — hand boxes caught the badge's
rim and a glyph tile's rim, and a band finder sampling every second column let a stroke through, each
reading 1.00.

**The first measure found these under their floor**, worst frame: the sheet's text on the aurora,
which had no shadows — the subtitle 2.77–3.46, the feature rows 2.77–4.03, the included line 4.16
(the title held its 3, at 3.05); the glyph tiles on `.sheer` — cyan 1.50, blue and magenta 1.00, white
2.89; the promise on `.sheer` 3.49 and its cyan check 1.76; the *Best value* badge, cyan on its
`.opaque` pill, **1.74** — the pill's own sheen runs from L 0.29 under its first letters to 0.10 under
its last, and cyan reaches about 4.1 even there; the trial note, cyan on the selected tile, 4.10; the
card's cyan sparkle in its lit corner, 2.88. The shadows and `.frosted` went in on precedent (every
other screen's text on the aurora carries the shadows; the welcome's bells went sheer → frosted) and
lifted the text on the aurora by only 0.1–0.4: the aurora's cyan light passes behind the top of the
sheet. **The owner ruled the rest** (R1–R4, the recommended options): R1, one `.frosted` card for the
subtitle, the rows and the included line, the glyphs without tiles; R2, every feature glyph cyan — blue
and magenta read 1.5–1.7 even on frosted glass; R3, the badge's pill dropped, BEST VALUE the yearly
tile's first line in white; R4, the note, the check and the sparkle white. On the card the subtitle then
read 4.32 by its lit corner at 0.92 — read off the same frames at 0.94 / 0.96 / 0.98 / 1.0: 4.43 / 4.54
/ 4.65 / 4.77 — and went to full white, not 0.96, which cleared by 0.04 inside the ~0.06 two captures
of one pair differed by (the welcome's card line, R5, the precedent).

**On the final source, 74 readings, none under its floor** — iOS 27.0 only (#165). Top / end of the
sheet, where an element is at both; beside the glyphs unless marked clean:

| Pair | Floor | Reading |
|---|---|---|
| The title (1.0, large), beside / clean | 3 | 3.20 / 3.20 · 6.52 / 4.07 |
| The subtitle (1.0), on the card | 4.5 | 4.77 · 4.98 |
| A feature row's title (1.0), worst of four | 4.5 | 6.28 · 6.35 |
| A feature row's line (0.92), worst of four | 4.5 | 5.94 · 5.92 |
| The included line (0.92) | 4.5 | 7.68 · 7.78 |
| A feature glyph (cyan), calendar / bars / sparkles / recap | 3 | 3.41 / 4.26 / 5.21 / 5.56 · 3.35 / 3.84 / 4.37 / 4.70 |
| BEST VALUE (1.0), on the selected tile | 4.5 | 4.63 · 4.61 |
| A tile's name (1.0) — Monthly / Yearly / Lifetime | 4.5 | 6.86 / 5.28 / 6.00 · 6.65 / 5.25 / 6.28 |
| A price (1.0, large) — $2.99 / $19.99 | 3 | 8.44 / 6.36 · 8.27 / 6.43 |
| The monthly's lines (0.92) — *a month* / *Cancel any time* | 4.5 | 8.49 / 8.73 · 8.46 / 8.43 |
| The yearly's lines (0.92) — *a year* / *save 20%* / *1 week free* | 4.5 | 6.53 / 6.89 / 6.94 · 6.51 / 6.63 / 6.51 |
| The lifetime's lines (0.92) — *once* / *Yours for good* | 4.5 | 7.60 / 7.97 · 7.49 / 7.67 |
| The close glyph (1.0) / the promise (1.0) / its check (1.0) | 3 / 4.5 / 3 | 7.33 / 5.90 / 4.98 |
| The terms (0.88), beside / clean | 4.5 | 4.65 / 4.66 |
| The footer (0.92), beside / clean | 4.5 | 5.15 / 5.05 |
| The card: title (1.0) / note (0.92) / captions (1.0), worst | 4.5 | 5.80 / 5.45 / 6.43 |
| The card: header sparkle (1.0) / preview glyphs (cyan), worst | 3 | 5.06 / 3.42 |

**Not measured:** iOS 26.5 and 18.6 (#165); Increase Contrast; the thank-you and held screens' lines
(the walk saw them, its frames were not held); the sheet's lines in Russian and Uzbek, which wrap
differently over the same grounds.

## The header and a screen arriving

*Added 2026-10-12, the redesign's stage 3b.*

| Token | Value | What it is |
|---|---|---|
| `ScreenMetrics.margin` | 24 pt | every tab's side margin; `(375 − 2 × 24) / 7 = 46.7` pt a day button |
| `ScreenMetrics.topInset` | 16 pt | from the top of the safe area to the title's line |
| `ScreenMetrics.titleLine` | 44 pt | the least the title's line may be, and the height its accessory is laid out at |
| `HomeView.dateScaleFloor` | 0.45 | the least the date under *Today* is drawn at |
| `Arrival.rise` | 14 pt (10 in the first build) | how far a section of the opening page rises as it arrives |
| `Arrival.duration` | 0.4 s | one section, on `.smooth` |
| `Arrival.stagger` / `longestDelay` | 0.05 s (0.04) / 0.2 s | each section after the one above; the ceiling |
| `Arrival.hiddenFirst` | 50 ms | drawn hidden before it starts, so there is a frame to arrive from |
| `Arrival.hiddenOpacity` | 0.001 | never zero: at zero a kept view left the accessibility tree and did not come back |

**2026-10-12, stage 3b's second pass: the settle is the opening page's only.** As the whole of
a change of tab it was 10 pt under a fade, and the owner, holding it on a phone, saw the screen
"just appear". Run on top of the page slide, it left the arriving page mostly a header: its
first section at half strength with two thirds of the way gone. A page a turn brings in is
told so (`pageSettlesIn`) and draws its sections whole from its first frame; History's bars
still grow as it comes. What a change of tab looks like now is in *Motion*, below.

**Where the title stands**, read off the accessibility tree on a 402 × 874 pt phone, iOS 27.0:

| | Home | History | Settings |
|---|---|---|---|
| Before the stage, ordinary size | (24, 90) | (28, 88.67) | — |
| As built, ordinary size | (24, 79.67) | (24, 79.67) | (24, 79.67) |
| Three sizes up (`UICTContentSizeCategoryXXXL`), before the review's fix | (24, 76.0) | (24, 80.67) | — |
| The same, as built | (24, 78.0) | (24, 78.0) | (24, 78.0) |

The 4.67 pt at the larger size was two faults in opposite directions. History's `+` is 53.3 pt
there and the title's line 48: the line took the button's height and centred the title 2.67 pt
down. And Home's column handed the header its ideal height, which the header's stack divided
evenly first: a line with only a least height reported 44 pt around a 48 pt title, which stood
2 pt above it. The accessory is laid out at 44 pt whatever it draws, and the line is rigid.

*(2026-10-14, the sixtieth pass: since stage 5 the welcome's steps read the same three
`ScreenMetrics` and put their titles where a tab's stands — `testAStepsTitleStandsWhereATabsTitleDoes`
compares a step's title with Settings' after the welcome closes, x and y; its figures were not added
to the table above. Hello's two sections arrive as an opening page's do, by `Arrival`. The other
three steps are whole as they slide in because nothing on them arrives — they carry no `.arrives`,
so the `pageSettlesIn` of `false` the welcome hands them is read by nothing, though the comment at
`WelcomeView.swift:223`–`:224` credits it.)*

**The date under *Today*.** `.headline`, as History's total is. The widest date of a year in the
three shipped languages, measured in iOS's own font at Accessibility XXXL, is *Понедельник,
28 сентября*: 665.9 pt, against 327 pt between the margins of a 375 pt phone — 0.491 of its
size. The floor was 0.5, measured on one Sunday in October. At 0.45 the line is 24 pt there,
where it is 17 pt at the ordinary size (`theWidestDateFitsTheNarrowestPhoneAtTheLargestTextSize`).

**What a change of tab looked like in the first build** — kept as it was read; the second pass
replaced all three (see *Motion*) — frame by frame off recordings of the built code:

- **iOS 27.0** — the page changes in one frame. The title is in the same place on the frame
  before and the frame after; the backdrop does not change (*One sky*); everything under the
  header is drawn at 0.001 for a few frames and is whole 0.3–0.4 s after the cut, read on two
  changes of tab. *(Read "under the title" until the fifty-second pass. The whole header is
  outside the arrival and never hidden — the title, the line under it, and the accessory on its
  line: Home's date and streak chip, History's total and `+`. And "whole" is what the frames
  showed, not where the curves end: by the constants a screen's first section ends 0.45 s after
  it is shown — 50 ms hidden and 0.4 s — Home's last 0.53 s, Settings' last 0.57 s and the
  strip's bars 0.63 s; a `.smooth` curve is all but at rest well before its end.)*
- **iOS 26.5** — the system goes on showing the old page for 0.2–0.3 s after the selection
  moves, while its own lens crosses the bar; then one blended frame, and the new page's content
  arrives. The screen being left stays whole for that time: its arrival flag is cleared when it
  has gone, not when its tab is left.
- **iOS 18.6**, the app's own bar — the old screen fades out whole over 0.28 s as before, and the
  new one's content arrives inside the fade.

History's bars, the week's and the strip's, grow from their baseline over 0.5 s as the screen
arrives; under Reduce Motion they are simply there and the arrival is the fade alone. *Undo*'s
capsule arrives from 0.92 of its size on `.smooth(duration: 0.3)`. **Reduce Motion was not
rendered.** *(All of this paragraph is the first build's too: the capsule arrives from 0.8 on
`Motion.land` now, and Reduce Motion has been rendered — Motion, below.)*

## Motion

*Added 2026-10-12, stage 3b's second pass.* The owner held the first build on a phone and saw
no animation in a change of page. What moves, and by how much, is listed here so that the next
judgement of "too quiet" or "too much" is of numbers.

| Name (`Motion`) | Curve | For |
|---|---|---|
| `page` | `.smooth(duration: 0.45)` | a page changing |
| `pageFade` | `.smooth(duration: 0.25)` | the same, under Reduce Motion |
| `settle` | `.smooth(duration: 0.3)` | a state changing |
| `land` / `landSpring` | `.spring(response: 0.5, dampingFraction: 0.68)` | something that arrives |
| `water` | `.spring(response: 0.8, dampingFraction: 0.62)` | the level in the vessel |
| `drop` | `.easeIn(duration: 0.42)` | a drop on its way to the vessel |

The press keeps its own spring, `0.28 / 0.62`, in `PressStyle` and `LiquidGlassModifier`.
Fifteen older call sites still write `.smooth(duration:)` themselves, at 0.28 to 0.5 s. *(Sixteen
until stage 5, 2026-10-14: `GoalSetupView`'s went with the file; the welcome writes none.)*

| What moves | By how much | Held by |
|---|---|---|
| A page, on a change of tab | a whole screen's width, both pages together, 0.45 s; the backdrop and the bar not at all | `PageTurnTests`, `aPageChangesInUnderHalfASecond` |
| A welcome step, on *Continue* or *Back* (stage 5) | a whole screen's width, both steps together, on `page`; the bar not at all; under Reduce Motion a cross-fade in place on `pageFade` | `WelcomeStepTests` — where the next and previous steps wait, a sliding step seen all the way out, nothing travelling under Reduce Motion |
| A drop, on a pour | 22 pt across, from the pressed disc to the vessel's centre along an arc lifted 56 pt above the line between — the drop itself rises 28 — in 0.42 s; whole for three quarters of the way, then taken in | `PourArcTests` |
| The vessel, as a drop lands | to 1.025 of its size in 0.1 s and back over 0.5 s; the surface surges then | — |
| The level | to its new mark on `water`, past it and back | `whatLandsPassesItsPlaceAndDoesNotRing` |
| The shown day's marker | one ring round the day's track and one disc behind its letter, from day to day, on `land` — since stage 3c; one capsule until then | `theMarkerStandsOverTheDayShown`, the ring's place; the disc is placed from the letter's own anchor and no test holds it |
| The strip's bars | from the baseline to their heights over 0.5 s, as the page arrives and on each change of day; simply there under Reduce Motion | — |
| The saved tick | a 16 pt check (26 at most) trimmed from nothing to whole on `land`, 1.6 s, then faded | — |
| The figure under a held slider | 1.06 of its size, from the edge it is pinned to: the trailing edge, but a Settings vessel's amount drawn under its name — the row's form since stage 4 when the name and the widest amount do not fit side by side — from its leading edge. *(Since stage 5 the vessel rows are `VesselSliders`, drawn by Settings and by the welcome's vessels step alike; the welcome's goal figure does not grow while held — Settings' goal is the only other.)* | — |
| The streak chip, *Undo*'s capsule | from 0.8 of their size, on `land` | — |
| A section scrolling off History or Settings | toward 0.92 of its size, by the share of it no longer showing, drawing back from the edge it is crossing | `ScrollDepthTests` |

**What was seen**, frame by frame off recordings of the built code, 402 × 874 pt:

- **iOS 27.0, 26.5 and 18.6** — both pages are on screen for the length of the slide: the old
  one leaves by one side as the new one comes in from the other, whole, its bars growing as it
  lands. On Apple's bar the lens crosses meanwhile; the app's own bar moves its lozenge. On
  iOS 26.5 the quarter-second the `TabView` held the old page is gone.
- **The first-run screen handing over to the app** is a cross-fade in place, as before. Home
  does not slide in, and its sections settle. *(Seen on `GoalSetupView`, the first-run screen
  then. Stage 5's welcome hands over through the same `RootView` cross-fade, unchanged in the code;
  that hand-over was not recorded frame by frame. Its own slide is in *Welcome, measured*.)*
- **A pour** (iOS 26.5, the Cup): the drop is on the disc as the press ends, crosses in front
  of the status line and *Undo*'s capsule, and is gone into the vessel about 0.45 s later; the
  vessel is seen a little larger for the four frames after that.
- **A day picked:** the marker is between days for about three frames and at rest inside 0.4 s.
  *(The capsule, before stage 3c. The ring and disc that replaced it were not recorded frame by
  frame.)*
- **A goal saved:** the tick is drawn beside *Daily goal* when the slider is let go.
- **Scrolling:** a card crossing the top is narrower than the card below it and no fainter;
  every card on screen at rest is whole.

**Why the scroll effect does not fade.** The owner's choice was "fade and shrink". Built that
way — toward half strength, with the shrink — a 330 pt card with a third of itself past the
top is drawn at about five sixths of its strength while the rest of it is still being read:
the reviewer's arithmetic, not a reading. It read two frames. With History's week card mostly
out of the screen, *Measured against your current goal*, 5.49:1 at rest (above), read about
3.6–4.0:1 against its pane; undimmed text in the same frame read 9.8–10.8:1, so the reading
was not simply low. With Settings' vessels card about a third out, its caption read about
5.9–6.9:1, where the same kind of line in a whole card read 10–12:1: dimmer, and still over
the floor. Off 603 px video frames: indicative, and enough. The first is under the 4.5:1
floor, and a list can come to rest anywhere. A section a few percent smaller loses no
contrast. *(Until the fifty-fourth pass of `docs/AI_CONTEXT.md` this said "in a frame of it",
giving the first reading to the card a third out, whose own reading was the second. The
other records of the pass gave the first range's middle, "about 3.8:1", as if it had been
read.)*

**Why it works out its own place.** SwiftUI's `scrollTransition` is the API for it and was
built first. Inside History's `List` it never reported a row as being at rest: every row stood
at 0.94 and half strength. It was seen on the first recording, on a frame taken at rest.

**Under Reduce Motion**, switched on in the simulator's own Settings app and recorded on iOS
27.0: a change of page is the two pages cross-fading where they stand, 0.25 s; a pour throws no
drop and the vessel does not swell; nothing shrinks as it scrolls; the opening page's sections
fade in without rising. The level, the marker, the tick, the chip and the capsule move as
they do otherwise: each is a value changing once, under a finger. By the code, and not looked
for in that recording: History's bars, the week's and the strip's, are simply there — they
do not grow as the page arrives or when another day is picked (`grown`, in both).

**Not seen:** any of it on a device; a second tab chosen inside the slide; the frame rate of
two pages of glass moving at once.

## Interactive glass

Adopted from Apple's *Applying Liquid Glass to custom views*, which describes `Glass.interactive()`
as glass that "reacts to touch and pointer interactions in real time".

**Apple's API is reachable, since the toolchain moved to Xcode 27.0.** `glassEffect(_:in:)`, `Glass`,
`GlassEffectContainer` and the `.glass` button styles are declared for iOS 26.0 and watchOS 26.0 in
the installed SDK. On iOS 26 and later an interactive pane is therefore Apple's `Glass.interactive()`
(*Three ways to draw a pane*), and what follows is what the **hand-made stack** does instead.
*(2026-10-20, the redesign's stage 7a: on the watch too. Its two capsules take `Glass.interactive()`;
nothing on the watch sets `glassIsPressed`, so no boost below applies there.)* *(This
paragraph said the API "is not reachable from this project" until 2026-10-09: true on Xcode 16.4 with
only `iphoneos18.5`, where the symbols were undeclared rather than unavailable.)* **Since stage 3c
the edge and specular rows apply on Apple's glass too**: the sheen and lit rim laid over it
(`litSurface`) take the same two boosts while an interactive pane is pressed, so its rim answers on
both paths. The tint row stays the hand-made stack's. *(Noted in the fifty-seventh pass.)*

`liquidGlass(…, interactive: true)` makes a pane answer a finger. Three multipliers, because the
three layers carry the press in different schemes:

| | multiplier | carries the press in |
|---|---|---|
| tint | ×1.35, clamped at **0.6** | light mode |
| lit edge | ×1.3 | **dark mode** |
| specular peak | ×1.25 | dark mode |

**Light mode is the tint's job and dark mode is the edge's.** Frosted light goes 0.45 → 0.6075,
clamped to the 0.6 ceiling this document already measured. Frosted *dark* is only 0.07, so ×1.35
moves it 0.025 — real but nearly invisible over a scrim, which is why the lit rim and the specular
do the work there. `theDarkModePressLeansOnTheEdgeRatherThanTheTint` asserts that balance rather
than leaving it to taste. The edge boost **multiplies** with the increased-contrast 1.4×: a standing
accessibility need and a momentary press should not cancel each other.

### How the press reaches the material

`PressStyle` — the only thing in the app that knows a finger is down — injects
`EnvironmentValues.glassIsPressed`, and `LiquidGlassModifier` reads it — as does
`PrimarySurfaceModifier`, in the same file, for the primary surface's pressed wash. It has to travel
downward:
`liquidGlass(…)` is applied *inside* a button's label, and `ButtonStyle.Configuration` is visible
only to the style, which wraps the label from outside.

**Interactivity is opt-in**, and only where the glass *is* the pressable surface — eight call
sites, all in the app: Home's two side discs (one site) and its *Undo* capsule, History's `+`, a
serving row, the sheet's *Cancel*, *Open iOS Settings*, and the welcome's *Back* and *Use* (six
until stage 5, 2026-10-14). *(Until the redesign this list named the three quick-add vessels, *Get
Started* and *Save*. The last two became primary surfaces in stage 1 and Home's Glass disc in
stage 2; a primary surface is not glass and takes its pressed wash from `LiquidGlass.Primary`.)*
The tab bar's glass sits outside its buttons and the settings cards sit outside their rows, so
neither reacts: lighting a whole bar because one tab was tapped would be wrong.

No Reduce Motion path, deliberately — it runs only while a finger is down, the same ruling
`PressStyle` records for its recoil (rule `65-accessibility`).

### Measured, not asserted

Sampled from a real mid-press frame, on bands inside the vessel in both the resting and the
scaled-to-0.93 pressed state, and clear of the glyph:

| Region | at rest | pressed | change |
|---|---|---|---|
| glass left of the glyph | 84.6 | **91.3** | **+7.9%** |
| glass right of the glyph | 78.8 | **83.2** | **+5.6%** |
| control — bare backdrop | 86.5 | 86.5 | 0.0% |

The control is what makes the other two mean anything: the aurora is animating, and a number that
moved is not evidence until you know what else moved with it.

### What could not be adopted

`GlassEffectContainer` and `glassEffectID` — merging and morphing between glass shapes — need the
renderer to blend the shapes and have no hand-rolled equivalent. The quick-add row **as it was
then**, three glass circles in an `HStack`, was *literally* the example Apple's page uses. It was
"the first thing to revisit when Xcode 26 is available"; the SDK now has it, and the redesign's
stage 2 adds the container with the new quick-add row (spec `2026-10-09-premium-redesign-design.md`
§3.2, §14). **Built 2026-10-11, so the heading is half out of date:** `.glassGroup()` — Apple's
`GlassEffectContainer` on iOS 26 and later, nothing at all below it and on the watch — wraps Home's
row, which is no longer three glass circles: two glass discs flank the primary surface, and the
container has those two to sample together. `glassEffectID` is still not used; nothing morphs.
*(2026-10-14, the sixtieth pass: a second container since stage 5, round the welcome's seven
bell discs on its reminders step.)* *(2026-10-20, the redesign's stage 7a: `.glassGroup()` is
`GlassEffectContainer` on the watch too. No watch view calls it yet; 7b's pour row will.)*

Apple also warns to "limit the use of Liquid Glass effects onscreen at the same time". Home
drew **five** panes (the vessel, three vessels, the tab bar); since stage 2 it draws four — the
vessel, two discs and the tab bar, the Glass being the primary surface — a fifth when there is a
streak, and a sixth for the eight seconds an *Undo* stands. Settings draws **five** — its four
cards and the tab bar — and a sixth, *Open iOS Settings*, while notifications are blocked; this
line said four until 2026-10-11, which left the tab bar out where Home's count had it in. Worth a
look. *(Since 2026-10-12 the tab bar in these counts is Apple's own on iOS 26 and later, and the
app's `.frosted`/`.floating` pane only below it.)* *(2026-10-14, the sixtieth pass: History was
never counted here, and since stage 5 the welcome's reminders step draws the most glass on any
screen — **ten** panes: the reminder's preview, the schedule card, seven bell discs in one
`.glassGroup()`, and *Back*; its main action is the primary surface. The welcome's four steps are
all in the tree at once, the three not shown at 0.001 opacity; whether Apple's glass costs
anything for those was not measured.)*

## The haptic ladder

Five rungs, in `Haptics` — three until 2026-10-12, when the redesign's stage 3b added `select`
and `remove`. Five call sites used to spell the first one, `confirm`, by hand.

| Rung | Weight | Intensity | Where |
|---|---|---|---|
| `select` | the system's `.selection` | — | a choice among peers: a change of tab on either bar, a day picked in the week card when the day shown changes, a vessel shortcut in the serving sheet, and each 50 ml step of the sheet's slider; since stage 4, a language picked in Settings, and each step of Settings' goal slider (100 ml) and vessel sliders (50 ml) while a finger drags it; since stage 5, a change of step in the welcome, each step of its goal slider and its vessel sliders under a finger, and a unit or an activity picked in its calculator (the weight wheel plays the system's own tick) |
| `remove` | `.light` | 0.8, `confirm`'s (`takingAwayIsNoFirmerThanAConfirmation`) | a serving swiped away in History |
| `confirm` | `.medium` | 0.8 | a goal saved (first run and Settings), the reminders switch turned on (at the flip, before permission is answered), a vessel's amount committed, and — since stage 2 — *Undo* pressed on Home (whether or not a row was there to take back). A language picked played `confirm` until stage 4. Since stage 5 the first run's is the welcome finishing (*Turn on reminders* or *Not now*, at the tap), and the calculator's *Use* plays it too |
| `pour` | `.heavy` | **1.0** | water logged on Home, and a serving added or edited in History's sheet |
| `goalReached` | `.heavy` | 1.0 | the goal crossed upward **while Home is on screen** — the modifier is Home's, and it watches the model's `hasReachedGoal`, the one haptic driven by a model value; a goal crossed from History's sheet plays `pour` alone |

*(The last row read "the one haptic not driven by a counter" until the fifty-second pass. Since
stage 3b two more are not: the tab's tick is triggered by the shown tab and the sheet's by the
amount under the finger — each a view's own state that only the user's touch changes, and neither
a counter, which is what rules `50-views` and `60-design-system` ask for by the letter;
`docs/AI_CONTEXT.md` known issue #111. The other ten `sensoryFeedback` sites in the app are
triggered by counters.)* *(Stage 4, 2026-10-13: twelve. Settings' two step ticks are counters, each
bumped by its slider's binding while a finger drags it — a value trigger would tick when the screen
re-reads the model. Fifteen sites in all.)* *(Stage 5, 2026-10-14: nineteen — the welcome's five
(`WelcomeView.swift`), `GoalSetupView`'s one gone with the file, and the vessel sliders' tick moved
from Settings into `VesselSliders`, which both screens draw. Fifteen are counters; the welcome's step
tick is triggered by the step shown, a view's own state only a tap changes, as the tab's is — so
three are of that kind, and Home's `goalReached` is still the one driven by a model value.)*

**`goalReached`'s "while Home is on screen" is unverified on iOS 26 and later since
2026-10-12.** Under Apple's tab bar Home is kept while its tab is away and goes on watching the
model, so a goal crossed from History's sheet may now play it, there or on the return to Home.
Which, if either, needs a device (`docs/AI_CONTEXT.md` known issue #114). Below iOS 26 the row
holds as written.

*2026-10-12, stage 3b's second pass: the row holds as written on every system again.* A page is
built when its tab is shown and removed when it has left, so Home does not exist while History
shows, and #114 is retired. No rung was added: the page slide plays the tab's `select` tick as
before, and the drop, the marker and the tick are silent.

**The pour steps the weight because intensity alone cannot express the increase.** Water landing is
meant to be half again firmer than a confirmation; `0.8 × 1.5` is `1.2`, and
`SensoryFeedback.impact(intensity:)` saturates at 1 — so intensity delivers only **half** of the
requested change before it stops meaning anything (0.8 to 1.0, a rise of a quarter, where 0.8 to
1.2, a rise of a half, was asked), and `.medium` → `.heavy` carries the rest. That
is a genuinely different actuator envelope rather than the same tap turned up. *(Read "only a
quarter of the requested change" until the forty-eighth pass, as the DocC in `Haptics.swift` still
does — `docs/AI_CONTEXT.md` known issue #103.)*

`goalReached` is an **impact**, not `.success`. `.success` is the semantically obvious choice and it
is a light double-tick — a notification pattern, meant to be noticed rather than felt. What the
moment wants is weight; the confetti carries the congratulation.

## The goal-reached burst

24 capsules in `Aurora.cyan` / `blue` / `magenta`, thrown from the **vessel's** centre — not the
screen's, which sits lower once the quick-add row and the bar are accounted for. Anchored as an
`.overlay` on `WaterVessel`, which does not clip, so the pieces travel past the rim.

Angles are evenly spaced around the circle *then* jittered inside their own slice: even spacing
alone draws a firework diagram, and pure randomness leaves visible gaps at this count. Distance
120–320pt, sizes 9–17pt, staggered up to 0.28s, all fading over 1.8s with a constant downward
component so the burst reads as thrown rather than as an explosion.

**It is a pure function of a seed**, and that is what makes it work at all: a view reaching for
`Double.random(in:)` in its `body` would deal a different burst on every re-evaluation — including
the ones SwiftUI performs for its own reasons — so the confetti would reshuffle mid-flight. The seed
is the burst *counter*, so two crossings in one day are two different bursts rather than a replay.

No package. A confetti dependency for forty lines of arithmetic is what rule `95-dependencies`
exists to refuse.

*(2026-10-16, the sixty-third pass: **the burst's length also times the rating request.** Since
roadmap item 1.2.5, a pour on Home that reaches the goal on the third day in a row may be followed by
iOS's rating request, which waits `ReviewPrompt.pause` — `Confetti.duration` plus the 0.4 s the
overlay keeps the burst — so the request meets a screen whose confetti has landed. Lengthen the burst
and the request waits with it; change the overlay's 0.4 alone and the two drift apart, which nothing
catches (`docs/AI_CONTEXT.md` known issue #138). Under Reduce Motion no confetti is drawn and the wait
is the same.)*

## Reduce Motion / Reduce Transparency

- **Reduce Motion** — `WaterVessel` swaps the `TimelineView` for a still frame (`phase: 0,
  slosh: 0`). The level still animates when it changes; only the travel is dropped — perpetual
  until 2026-10-18, since then only the 2.5 s after a pour (`WaterMotion`).
  Since stage 3b's second pass three more things read it, each travel across the screen: a
  change of page is a cross-fade, a pour throws no drop, and no section shrinks as it scrolls
  (*Motion*, above — run and recorded with the setting on). The vessel does not swell either,
  and not by reading the setting: the swell answers a drop landing, and there is none. *("Four
  more things read it" until the fifty-fourth pass of `docs/AI_CONTEXT.md`.)* *(2026-10-14, the
  sixtieth pass: since stage 5 the welcome reads it twice more — a change of step is a cross-fade
  in place on `pageFade` (`WelcomeView.swift:188`, `:237`), and Hello's vessel stands its waves
  still, as `WaterVessel` does (`:823`, `:830`–`:831`). Recorded with the setting on: *Welcome, measured*.)*
- **Reduce Transparency** — `LiquidGlassModifier` swaps the whole stack for `base.opaqueFill` plus
  the edge and the shadows. Translucency is the thing being turned off, so there is nothing left to
  soften. In the widget, `WidgetCardBackdrop` and `WidgetAurora`'s lights drop out too, and on the
  watch `WristAurora`'s: above an opaque card the lights would only show as a rim of colour, and
  the plain gradient is the calmer read. **The app's `AuroraBackground` has no such branch** — it
  reads Reduce Motion only and keeps its three lights behind the opaque panes.

## Forbidden

- A hand-rolled `.background(.ultraThinMaterial)` instead of `liquidGlass(…)`
- A tint opacity above ~0.6 in light mode
- Glass over a flat background — in the product **or** in a preview
- A `Material` in the widget
- A colour literal outside `Aurora`, the two `WaterSurface` gradients and `Base.archived`'s two fills
- Deleting a derivation comment because the number "looks arbitrary"
