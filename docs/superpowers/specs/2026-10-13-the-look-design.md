# The look — stage 3c

**Date:** 2026-10-13
**Status:** design, written by the session that will build it, from a design the owner approved in
chat and a throwaway probe they asked for before this document. Their rulings are marked
*(owner)*; everything else is this session's reading and is theirs to overturn (§9). **Built and
staged on 2026-10-13, not committed**, its §8 rule wording typed into the rule files and left
unstaged for the owner; the build settled the sheer and opaque scrims at 0.30 and 0.80 and added
L11 — the measured values are in `docs/DESIGN.md`, *The look, measured*.
**Builds on:** `2026-10-09-premium-redesign-design.md` (the redesign; this is the look its §3, §5 and
§6 describe, as the canvas drew it) and the two stage 3b documents, which moved the letters **a**,
**b**, **c** and **g** here (`2026-10-11-navigation-and-motion-design.md` §1, N7).
**Roadmap:** item 1.2.1 of `docs/ROADMAP.md`.

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then
`CLAUDE.md`. Where it proposes a rule change (§8), the rule stands as written until the owner
approves the wording.

**Provenance.** Every claim about the repository was read at HEAD `684f3dd` on 2026-10-13. Every
measurement was taken that morning by a throwaway probe — a `git checkout-index` export of the index
in the session's scratchpad, with launch-environment knobs, seeded with the canvas's own week — on
*WaterBuddy Probe 27* (iOS 27.0, iPhone 17), *WaterBuddy Probe 26.5* (iOS 26.5) and *WaterBuddy
Fallback 18.6* (iOS 18.6, iPhone 16). Method, tables and every run are in the git-ignored ledger
`.superpowers/sdd/2026-10-13-premium-redesign-stage-3c/progress.md`. A claim nobody has rendered is
marked **unrendered**.

---

## 1. What is being built

On 2026-10-11 the owner was shown the built screens beside the approved canvas with seven
differences marked **a** to **g**, and said "go". Stage 3b took **f**; **d** and **e** stay as decided
on 2026-10-09. The canvas's own legend for the four that are this stage:

- **a — Glass.** Canvas: light, see-through, a bright rim. Built: dark and flat, from the tint that
  contrast required.
- **b — Vessel.** Canvas: a glow beneath, a halo, a highlight. Built: flatter.
- **c — Week card.** Canvas: rounded bars in tracks, a dashed goal line, a white circle on today's
  letter. Built: capsules, a solid line, a ring round today's column.
- **g — A serving's glyph.** Canvas: on a cyan wash. Built: in a dark well.

The owner's rulings, 2026-10-13, each by a question with written options:

1. **"Floors hold."** Where the canvas's look and a contrast floor collide — the glass, the glyph,
   the week's cyan bars — get as near the canvas as the floors allow, and show where it lands.
2. **The glass: keep Apple's glass, tint it with `Aurora.top` instead of black, and draw the
   hand-made lit rim and sheen over it**, the tint re-climbed and rendered, never estimated.
3. **The design as presented**, in five sections — the glass, the vessel, the week card, the glyph,
   the proof — with the hand-made pane below iOS 26 brought to the floors too (known issue #85).
4. After the probe: **tint `0.64`**; **a blue scrim below iOS 26**; **the week card's dimmed text
   as the canvas drew it** — asked as "full white", which was this session's misreading of the
   canvas; what the canvas draws is in §5, and asked again on the corrected values the owner chose
   **"Match the canvas exactly"** (§9, L9).

## 2. What happens today

Read at HEAD; measured where marked.

- **Apple's glass** (iOS 26 and later) is `Glass.regular` tinted `Color.black.opacity(0.52)`
  (`LiquidGlass.systemTintOpacity(for:)`), the clear variant untinted. Nothing else of the
  hand-made stack is drawn on it: `ownPane(systemGlassDrawn: true)` returns no view. It reads dark
  grey-navy and flat beside the canvas (`out/sbs-history.png` in the ledger).
- **The hand-made stack** (iOS 17–25; the widget's `.archived` base; the watch) scrims with black at
  0.16 / 0.28 / 0.40 for sheer / frosted / opaque, in Dark Mode. On iOS 18.6 it reads **slate grey**,
  and pairs are under their floor: stage 3's record of HEAD's own card on iOS 18.6
  (`docs/AI_CONTEXT.md`, #85) has the weekday letters 3.41–3.93, the disclosure 4.15, the goal line
  2.12–2.98 and the week's cyan bar 2.78 beside the pane, 1.98 over an empty track. The probe, whose
  card was already redrawn (§5), still read the letters **4.38** and the cyan bar **2.97** at rest
  with today's scrim.
- **The vessel** is `WaterVessel` in `HomeView.swift`: water, `WaterReadabilityScrim`, the readout,
  on `.liquidGlass(in: Circle(), density: .sheer, elevation: .floating)` — Apple's clear variant on
  iOS 26 and later.
- **The week card** (`HistoryCard`, `HistoryView.swift`): a `Capsule` track at white 0.12 and a
  `Capsule` bar per day, 8 pt in from each side of its slot; a solid 1 pt goal line at white 0.55;
  one travelling `Capsule` round the shown day's whole column, `LiquidGlass.Selection`'s fill 0.08
  and rim 0.55; weekday letters at white 0.72, the shown one full white and bold; the labels at 0.9;
  the disclosure at 0.70.
- **A serving's glyph** (`ServingRow`): `Aurora.cyan` on `Circle().fill(.black.opacity(0.4))`,
  because a cyan wash left the cyan glyph at **2.0:1** on the hand-made pane.

## 3. The glass (a)

### 3.1 Apple's glass, iOS 26 and later

- **The tint is `Aurora.top`, at `0.64`, through `Glass.tint`** *(owner)*. A new
  `nonisolated static let systemTintColor: Color = Aurora.top` beside
  `systemTintOpacity(for:)`, which answers `0.64` for `.regular` and still `0` for `.clear`.
- **Why the colour.** A black tint greys the aurora under the pane; the canvas's pane is navy, not
  black. Measured: at the same strength the blue tint is much lighter — the weekday letters read
  6.52 under black 0.52 and 4.74 under `Aurora.top` 0.52 — so it needs more of it.
- **The lit rim and the sheen are drawn on Apple's glass too.** `ownPane(systemGlassDrawn: true)`
  draws the stack's own `specular` fill and `edge` stroke — the same two gradients, the same
  Increase Contrast and press boosts — as the pane's background: over the glass, under the content.
  The scrim, the tint ceiling and the two shadows stay the hand-made stack's. Every system pane
  gets them, the clear vessel included.
- **Why 0.64.** Rendered, iOS 27.0 (whose glass is the lightest), with the rim and sheen on:

  | Tint | Glyph | At rest | A minute's sweep |
  |---|---|---|---|
  | `0.52` | cyan, wash 0.16 | weekday letters **4.28**, glyph **2.46** | — |
  | `0.56` | cyan, wash 0.08 | letters **4.48**, glyph **2.66–2.79** | — |
  | `0.60` | white, wash 0.16 | nothing under | nothing under; letters **4.64**, range labels 4.68 |
  | **`0.64`** | white, wash 0.16 | nothing under | **nothing under; letters 4.78, range labels 4.93, cyan bar 3.44, goal dashes 3.68, glyph 4.47** |

  The glyph changed between rows (§6), so "nothing under" from `0.60` up is with the white glyph.
  `0.60` passes with 0.14 to spare; `0.64` is the first rung with room — the same reasoning that
  set `0.52` in stage 1, where `0.48` sat on the floor. iOS 26.5 at `0.64`, swept: nothing under,
  tightest the goal dashes 4.56 and the cyan bar 4.57, against 3.
- **The probe's figures run high against the old record.** The probe's control — the scratch
  build at black 0.52 with no rim or sheen, its week card already redrawn — reads the weekday
  letters 6.52 at rest, where `docs/DESIGN.md` recorded 5.97 at rest at the same value; the card's
  layout and the sky's clock have changed since. And the probe
  sampled fifteen pairs, not the seventy-one of *Apple's glass, measured*: not the serving sheet,
  Settings below its second card, Home's small panes, the first run or History's empty state. **So
  `0.64` is the value to build at, and the plan's full pass may still raise it** — a pair seen under
  its floor moves the tint to the next rendered rung, never to an estimate.

### 3.2 The hand-made pane on the phone, iOS 17–25

- **Its scrim is `Aurora.top`, not black** *(owner)* — on a `.material` base, on iOS only. That is
  the phone app's own panes below iOS 26. The widget's `.archived` base and the watch (a `.material`
  base on watchOS) keep the black scrim and today's values: the modifier is compiled into both, and
  neither is this stage's. The widget's glass stays `.archived` in the redesign's own widget stage
  too (its §8: "The glass stays `.archived`"); the watch's glass is decided in its stage 7.
- **Per density, not one multiplier.** A single factor of 2.5 would put the opaque density's scrim
  at 1.0, a solid slab. The values:

  | Density | Today (black) | Phone, `.material`, iOS (`Aurora.top`) |
  |---|---|---|
  | sheer | 0.16 | set by the plan's measurement, starting at **0.40** (as rendered on Home in the probe, **unmeasured**) |
  | frosted | 0.28 | **0.70** — measured, swept |
  | opaque | 0.40 | set by the plan's measurement, starting at **0.80**; it may not reach 1 |

- **Why blue.** On iOS 18.6, at the same margins, black raised to ×1.5 stays slate grey while
  `Aurora.top` reads like the canvas and like iOS 27.0's new pane (`out/sbs-186.png`). Swept, a
  minute per screen: blue frosted 0.70 — nothing under, letters 4.92, cyan bar 3.38, dashes 3.71;
  black 0.42 — nothing under, letters 4.99, bar 3.42. The choice was the look, and the owner chose.
- **One pure function decides it**, so the three answers can be pinned without a view:
  `LiquidGlass.scrim(density:scheme:base:onPhone:) -> (color: Color, opacity: Double)`. The
  modifier passes `onPhone` from `#if os(iOS)`. Light mode still answers zero, as today.
- **The hand-made tab bar** below iOS 26 is a glass pane and turns blue with the rest. Its captions
  are in the plan's measured set.

## 4. The vessel (b)

Home's `WaterVessel` only. `WaterSurface.swift` — shared with the widget and the watch — is not
touched. The redesign leaves the widget's vessel as it is (its §8); the watch's is its stage 7.

The canvas's values below are read from its *Home (A · Aurora)* board, a 300 pt vessel
(`Main.dc.html` in the copy the ledger names), and turned into ratios of the diameter.

- **A glow beneath:** an ellipse 0.76 × 0.21 of the diameter, a radial `Aurora.cyan` at 0.36 fading
  to nothing, blurred by 0.033 of the diameter, centred half a diameter below the vessel's centre.
  The canvas's glow is `rgba(0,200,255,.36)`, not an `Aurora` colour; `Aurora.cyan` stands in.
- **A halo:** a ring of white at 0.05, 0.033 of the diameter wide, just outside the rim.
- **A highlight:** an ellipse 0.427 × 0.207 of the diameter at (0.10, 0.067), turned −28°, a radial
  white at 0.4 fading to nothing — drawn **above** `WaterReadabilityScrim` and **under** the
  readout, so the readout keeps its scrim (rule `60-design-system`, *Water*) and the two shadows
  `WaterVessel`'s readout already carries.
- **Each ratio lives as a named constant in `WaterVessel`**, with the canvas value it came from.
- **Under Reduce Transparency none of the three is drawn**, as the rest of the glass gives way to
  the opaque pane. All three are decoration inside an element that already ignores its children
  for VoiceOver.

## 5. The week card (c)

The canvas's values below are read from its *History* board (`History.dc.html` in the copy the
ledger names).

- **Tracks.** Each day's slot draws a rounded rectangle — corner radius `LiquidGlass.innerCornerRadius`,
  a new token, `12`, continuous — at white 0.10; the bar inside it is the same shape. The row stands
  16 pt in from the card and each bar 4 pt in from its slot, so tracks are 8 pt apart and the outer
  two 20 pt from the card's edge, as the canvas drew them (radius 12, white .1, 8 px gaps, 20 px
  padding).
  *Amended after the final review, 2026-10-13:* the row stands 16 pt in **only where the card
  affords it** — `HistoryView.dayRowInset(across:count:)`, laid out by a `DayRow` layout. On a
  375-pt iPhone the card is 327 wide and a fixed 16 left each day 42.1 pt, under the 44-pt floor
  the `HistoryCard` DocC and rule `65-accessibility` set; there the row stands 9.5 pt in and each
  day is exactly 44. From a 390-pt phone up it is the full 16 (L11).
- **Fills unchanged.** A met day's bar is `Aurora.cyan`, an unmet day's white, and a met bar still
  stands at or above the goal line (rule `65-accessibility`). The canvas's lighter cyan gradient is
  not adopted: it is not an `Aurora` colour, and stage 3 chose the solid fill by measurement.
- **The goal line is dashed:** 1.5 pt at white **0.62** — the canvas's values — and 3.67:1 at its
  worst frame on iOS 27.0 at `0.64` against its floor of 3. The canvas says only `dashed`, which a
  browser draws; the dash of 4.5 on 3 is this session's.
- **The shown day:** a **ring** on its track — white 0.8, 1.5 pt, `LiquidGlass.Selection.ringOpacity`
  — and a **white disc** behind its letter — `LiquidGlass.Selection.discFill` — with the letter in
  `Aurora.top`. Both travel from day to day with `Motion.land`, as today's capsule does: the ring
  over the row, the disc beneath the letters. The capsule round the whole column goes.
- **Never colour alone.** The shown letter is also heavier than the others (heavy against semibold,
  the canvas's 800 against 600), and the day keeps its `.isSelected` trait.
- **The text as the canvas drew it** *(owner, confirmed on these values — L9)*: the six other
  weekday letters full white (0.72 today; the canvas `#ffffff`, weight 600); the labels *Average*,
  *Best day*, *Goal met* stay at 0.9 (the canvas's own `.9`); the disclosure 0.70 → **0.88** (the
  canvas's `.88`). The question put to the owner said all three were full white; only the letters
  are.
- **Accessibility unchanged:** one button per day, its label and value, `.isSelected` on the shown
  day; the summary on the title.

## 6. A serving's glyph (g)

- **A cyan wash:** `Aurora.cyan` at 0.16 behind the glyph, in place of the black well. The canvas's
  wash is `rgba(94,240,240,.16)`, not an `Aurora` colour; `Aurora.cyan` stands in at the same
  opacity.
- **The glyph turns white.** On the wash, a cyan glyph read **2.46–2.79** against its floor of 3
  at every wash tried (0.16, 0.08): the wash lightens the ground, and the sheen lands exactly where
  the glyph sits, at the row's top left. White on the 0.16 wash, swept: **4.47** on iOS 27.0, **5.30**
  on 26.5, **4.42** on 18.6. This was the agreed fallback, and the owner has been told.

## 7. Testing and verification

### 7.1 Tests, written first (rule `85-testing`)

In `WaterBuddyTests/LiquidGlassTests.swift`, beside the routing and primary-surface tests already
there:

1. `theTintIsNoLighterThanTheLightestRungThatPassed` — moved from `>= 0.52` to `>= 0.64`. RED today.
2. `theGlassIsTintedWithTheSkysOwnBlue` — `LiquidGlass.systemTintColor == Aurora.top`. RED: the
   symbol does not exist.
3. `thePhonesOwnPanesAreScrimmedWithTheSky` — `scrim(density:scheme:base: .material, onPhone: true)`
   is `Aurora.top`, frosted `0.70`, each density darker than today and under 1, and zero in light mode.
4. `theWidgetKeepsItsBlackScrim` — `.archived`, on the phone: black, 0.16 / 0.28 / 0.40.
5. `theWatchKeepsItsBlackScrim` — `.material`, not on the phone: black, 0.16 / 0.28 / 0.40.
6. `theShownDaysLetterReadsOnItsDisc` — a derived pair, both fills solid: `Aurora.top` on
   `Selection.discFill`, at least 7:1, by the arithmetic `thePrimaryLabelClearsSevenToOneEvenAtTheFootOfTheShade`
   already uses.

`onlyTheRegularVariantIsDarkened` stands as it is. Each test is run and seen RED before the code.

### 7.2 Rendered and measured

The `docs/DESIGN.md` method — the worst pixel of clean ground beside each text, the foreground
composited over it, every three seconds for a minute per screen — over the full seventy-one pairs of
*Apple's glass, measured*, re-placed on today's layouts, plus what this stage draws new: the goal
dashes, the ring, the disc's letter, the white glyph on its wash, the cyan bar against its track.
On iOS 27.0 and 26.5 at the tint, and on iOS 18.6 at each density's scrim. Then Increase Contrast
(iOS 27.0) and Reduce Transparency (iOS 27.0 and 18.6) rendered. **Fixing a value:** a pair under its
floor moves the value to the next rendered rung; the clean-ground yardstick is the floor and the
beside-the-glyphs one is recorded (#95).

Side by side for the owner, before the stage closes: the canvas's Home and History boards beside the
built screens on all three systems.

*Not done as written (2026-10-13):* the beside-the-glyphs reading was not taken, and the set is not
the seventy-one pairs but the pairs of today's layouts — 46 on the iPhone 17, 47 on the iPhone 16
— listed in `docs/DESIGN.md`, *The look, measured*; the disc's letter is derived by
`theShownDaysLetterReadsOnItsDisc`, not measured.

### 7.3 The gate

Rule `85-testing`'s five invocations, the UI suite also on iOS 26.5, `-parallel-testing-enabled NO`,
in the foreground, on the *WaterBuddy …* simulators; no new warning against a clean
`build-for-testing` baseline of HEAD on the same toolchain, per file and message. The widget and the
watch builds are in the gate because the modifier is compiled into both.

## 8. Rules this departs from — proposed, not edited

**`60-design-system`, *Glass*:**

- *"The scrim, the tint ceiling, the specular, the lit rim and the two shadows are properties of the
  **hand-made** stack. On Apple's glass none of them is drawn; the system brings its own edge and
  depth"* → **"The scrim, the tint ceiling and the two shadows are properties of the hand-made
  stack. The specular and the lit rim are drawn on both: on Apple's glass as the pane's background,
  over the glass and under the content, so the canvas's bright edge survives the tint."**
- *"Apple's regular glass is darkened with a black `Glass.tint`, at
  `LiquidGlass.systemTintOpacity(for:)`; …"* → **"Apple's regular glass is darkened with
  `LiquidGlass.systemTintColor` — `Aurora.top`, the sky's own blue; a black tint greys the aurora
  under it — through `Glass.tint`, at `LiquidGlass.systemTintOpacity(for:)`; the clear variant — the
  vessel — takes none."** The rest of the bullet stands.
- *"The dark-mode black scrim is what makes dark glass work. Raising the tint is the wrong fix"* →
  **"The dark-mode scrim is what makes dark glass work, and `LiquidGlass.scrim(density:scheme:base:onPhone:)`
  is the one place it is decided: `Aurora.top` on the phone's own panes, black for the widget's
  `.archived` base and for the watch. Raising the white tint is the wrong fix."**
- *"Use `LiquidGlass.cornerRadius` for every rounded pane. Never write a corner-radius literal in a
  view"* — add: **"A rounded element inside a pane — the week's tracks and bars — uses
  `LiquidGlass.innerCornerRadius`."**
- *"A selected slot or day is marked with `LiquidGlass.Selection`'s fill **and** rim, present at zero
  opacity when unselected. Never a fill or a rim written as a literal in a view"* → **"A selected
  slot is marked with `LiquidGlass.Selection`'s fill **and** rim; the week card's shown day with
  `Selection.ringOpacity`'s ring on its track **and** `Selection.discFill` behind its letter, the
  letter heavier than the rest. Each mark is present at zero opacity when nothing is selected.
  Never a fill, a rim, a ring or a disc written as a literal in a view."** The sentence is replaced,
  not extended: the capsule round the shown day's column goes (§5), so "a … day is marked with the
  fill and rim" would no longer be true.

**`65-accessibility`, *Reduce Transparency*** — add: **"Home's vessel draws its glow, halo and
highlight only when Reduce Transparency is off."**

**`65-accessibility`, *Contrast*** — nothing changes in substance; *"Never let a tint be the only
carrier of state"* already covers the ring, the disc and the weight.

## 9. Decisions taken here, for the owner

| # | Decision | Taken by |
|---|---|---|
| L1 | The tint is `Aurora.top` at `0.64`, and may rise in the plan's full pass | owner (value), this session (may rise) |
| L2 | The lit rim and sheen are drawn on every system pane, the clear vessel included | this session |
| L3 | Below iOS 26 the phone's panes scrim with `Aurora.top`; frosted `0.70`, sheer and opaque by measurement, opaque under 1 | owner (blue), this session (values) |
| L4 | The widget and the watch keep the black scrim and today's values | this session |
| L5 | The vessel's glow, halo and highlight take the canvas's ratios; `Aurora.cyan` stands in for the canvas's glow and wash colours, neither an `Aurora` colour | this session |
| L6 | The tracks at white 0.10 and corner radius 12, the ring white 0.8 at 1.5 pt, the goal line 1.5 pt at 0.62 — the canvas's values; the dash 4.5 on 3 — this session's | this session |
| L7 | The bars keep solid `Aurora.cyan`, not the canvas's gradient | this session |
| L8 | The shown letter is heavy, the others semibold — the canvas's 800 and 600 | this session |
| L9 | The week card's text as the canvas drew it: letters full white, labels 0.9 (unchanged), disclosure 0.88 | owner — asked first on a wrong description ("all three full white"), then confirmed on these values |
| L10 | A serving's glyph is white on the cyan wash | the floors, as agreed |
| L11 | The week card's row inset gives way on narrow phones — 9.5 pt on a 375-pt iPhone — so each day stays 44 pt wide (added after the final review) | this session |

## 10. Not in scope

- The widget and the watch, beyond keeping their panes exactly as they are.
- Settings' own restyle (stage 4). Its panes change colour with every other pane here, and its text
  is in the measured set; nothing on it is rearranged.
- **d** (servings as rows) and **e** (counted nouns, #40), as decided on 2026-10-09.
- Apple's own tab bar on iOS 26 and later, which is the system's.
- Retuning `Base.archived`'s derived fills, which belong to the widget.
