# DESIGN — tokens and the measurements behind them

The numbers, in one place, so a future reader can tell a measurement from a preference. Every
figure here is transcribed from the source; the *arguments* are in the DocC on
`LiquidGlassModifier.swift` / `WaterSurface.swift` and in `.claude/rules/60-design-system`.

**Rule of the file:** record the measurement, not the adjective. "0.24 at 50%" survives a redesign
argument; "looked better" does not.

**Last updated:** 2026-10-11 (a fourth `/doc_sync` the same day, the forty-ninth pass of
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

`Base` → black scrim (dark mode only) → white tint → specular gradient → inset stroke → two
shadows. Six layers, and each one is doing a job the others cannot:

- **The scrim is what makes dark glass work.** White alone cannot hold back a vivid background at
  any opacity a dark UI can afford: too little and the colours punch through as a coloured film,
  too much and the pane becomes a light slab with nowhere for white text to go. The scrim
  attenuates first; the tint then only supplies sheen.
- **The edge is the detail that sells it.** A flat 1pt white border reads as a drawn outline; a
  stroke bright where the light lands and nearly gone on the shaded side reads as the lit rim of
  something solid.
- **Two shadows, not one.** One alone either hugs the edge with no sense of height, or floats with
  no contact.

`cornerRadius = 28`, continuous — the iOS squircle, not a circular arc.
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
History's week card, its empty state and its `+`; `.floating` — the first-run card, the serving
sheet's card and the watch's vessel; `.resting` — a serving row, the sheet's *Cancel*, *Open iOS
Settings*, and the watch's two capsules, which pass no elevation and take the default.

## `LiquidGlass.Density`

The tint and the blur compete: every point of tint hides a point of the material behind it.
**Rendered comparisons put the light-mode ceiling at about 0.6** — past it the background stops
reading and the pane becomes flat white paint — so the scale tops out where glass still looks like
glass.

| Density | scrim (dark) | scrim (light) | tint (dark) | tint (light) |
|---|---|---|---|---|
| `.sheer` | `0.16` | `0` | `0.05` | `0.22` |
| `.frosted` | `0.28` | `0` | `0.07` | `0.45` |
| `.opaque` | `0.40` | `0` | `0.09` | `0.58` |

Use `.frosted` or `.opaque` behind body text; keep `.sheer` for short labels and controls, where a
busy backdrop cannot swallow a whole sentence. In use, every call site but the previews' own five: the three vessels — app,
widget, watch — `.sheer`; the cards (first run, Settings' four, History's week card, empty state
and sheet, the widget's), the tab bar, Home's two discs and its streak chip, History's `+` and its
serving rows, and the widget's two pour buttons `.frosted`; Home's *Undo* capsule `.opaque` — the
app's first pane at that density, because it carries a line of text (*Home, measured*); and four
small capsules `.sheer` — the sheet's *Cancel*, *Open iOS Settings* and the watch's two. *(Read
"vessels `.sheer`, cards and buttons `.frosted`" until the forty-seventh pass, whose rewrite
counted the four capsules as three and left the widget's buttons out; corrected in the
forty-eighth.)*

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

**`colorSchemeContrast == .increased` multiplies both by 1.4**, capped at 1.

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
StandBy the card brings its own light rather than floating on bare black.

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
| app | `diameter × 0.018` `+ diameter × 0.05 × slosh` | `seconds × 1.1` from `TimelineView(.animation)` |
| widget | `diameter × 0.035` | frozen at **`0.6`** |

The widget's is roughly double because the app's 1.8% is 5.4pt of surface at 300pt and only 1.7pt at
92pt — flat. *(5pt at 280pt until the redesign's stage 2 made the vessel 300.)* The frozen phase `0.6` is picked so both waves show a crest and a trough across the
vessel's width rather than crossing zero flat in the middle.

App slosh decays as `exp(-elapsed × 1.5)` over a 5-second window after a pour. Water is inset —
`padding(10)` in the app, `padding(diameter × 0.04)` in the widget — so it sits in a well and can
never cover the vessel's lit rim.

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
*leg*: `AuroraBackground` animates with `.easeInOut(duration: light.period)` and
`repeatForever(autoreverses: true)`, so a light is back where it started, moving the same way,
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

`repeatForever` rather than a `TimelineView`: there is nothing to recompute per frame, so two
endpoints and a curve let the render server carry the loop. The colour cross-fade is **two stacked
fills interpolating opacity**, not one animated `fill` — a `Shape`'s style is not itself animatable.
One blur covers both, so it costs a second fill and not a second blur.

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
`GlassEffectContainer` on iOS 26 and later, nothing elsewhere — as Home's quick-add row is.

Since the redesign's stage 1 (2026-10-09; committed 2026-10-10 in `c9ef45d`), `liquidGlass(…)` draws one of three panes, and
`LiquidGlass.rendering(base:reduceTransparency:systemGlassAvailable:)` chooses, in this order:

| Condition | Pane |
|---|---|
| Reduce Transparency is on | the opaque fill and lit rim, on every OS (`.opaque`) |
| the base is `.flat` — the widget's `.archived` | the hand-made stack (`.handMade`) |
| the base is `.material`, iOS 26 or later | Apple's glass, `glassEffect(_:in:)` (`.system`) |
| the base is `.material`, below iOS 26 — and the watch, for now | the hand-made stack |

- `LiquidGlass.systemGlassAvailable` is `true` on iOS 26 and later and **`false` on watchOS**, by
  `#if os(iOS)`. When that was written no watchOS 26 runtime was installed and a watch pane could
  not be rendered; watchOS 27.0 has been installed since 2026-10-09, the watch app ran on it on the
  hand-made stack, and no watch pane has been drawn on Apple's glass yet. The redesign's watch stage
  turns it on, and measures it there. (The flag's own DocC gave the missing runtime as its reason
  until the redesign's stage 2 corrected it to this one — known issue #91d.)
- **Everything above this section describes the hand-made stack.** On Apple's glass the scrim, the
  tint, the specular, the rim and the two shadows are not drawn, and `tint`, `tintOpacity`,
  `elevation`, `borderWidth` and the highlight points are ignored.
- The variant: `density: .sheer` on a pane that is not interactive takes `Glass.clear` (the vessel,
  whose readout has its own scrim); every other pane takes `Glass.regular`. `interactive: true` adds
  `.interactive()`. `LiquidGlass.systemVariant(density:interactive:)` is the mapping.
- **The regular variant is darkened**, with Apple's own `Glass.tint(.black.opacity(…))`, at
  `LiquidGlass.systemTintOpacity(for:)`: **`0.52`**. The clear variant takes none — it is the
  vessel, and a tint would dull the water behind its readout. The value is measured, in *Apple's
  glass, measured* below.
- **The pane says its hit region:** `sampling(_:)` — `systemPane` until the redesign's stage 2 —
  ends in `.contentShape(shape)`, for every `.material` pane on iOS 26 and later, the opaque one
  under Reduce Transparency included. The hand-made
  stack is hit-testable through its fills; Apple's glass is not always. On iOS 26.5 a serving row
  in History's `List` took a tap on its text and none on the bare glass between; iOS 27.0 took
  both. `GoalSetupUITests.testAServingRowOpensItsSheetWhereverItIsTapped` holds it.
- `LiquidGlassRoutingTests` pins the table, the mapping, which variant is darkened and that its
  tint is no lighter than `0.52`, without building a view.

**The mapping is settled** (2026-10-10) — see *Apple's glass, measured* below.

## The primary surface

`primarySurface(in:ring:)` — the one surface that is not glass, for a screen's one main action.
Three places use it: *Get Started* and the sheet's *Save* — both were frosted glass under a cyan
glow — and, since the redesign's stage 2, **Home's Glass disc**, the only one on a `Circle`: the
slot every one-tap door logs, between two glass discs.

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

## Apple's glass, measured

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
  `GoalSetupView`.
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

`legibleOnBackdrop()` — a private helper in `HomeView.swift` — is the widget readout's recipe (see
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

## Interactive glass

Adopted from Apple's *Applying Liquid Glass to custom views*, which describes `Glass.interactive()`
as glass that "reacts to touch and pointer interactions in real time".

**Apple's API is reachable, since the toolchain moved to Xcode 27.0.** `glassEffect(_:in:)`, `Glass`,
`GlassEffectContainer` and the `.glass` button styles are declared for iOS 26.0 and watchOS 26.0 in
the installed SDK. On iOS 26 and later an interactive pane is therefore Apple's `Glass.interactive()`
(*Three ways to draw a pane*), and what follows is what the **hand-made stack** does instead. *(This
paragraph said the API "is not reachable from this project" until 2026-10-09: true on Xcode 16.4 with
only `iphoneos18.5`, where the symbols were undeclared rather than unavailable.)*

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

**Interactivity is opt-in**, and only where the glass *is* the pressable surface — six call sites,
all in the app: Home's two side discs (one site) and its *Undo* capsule, History's `+`, a serving
row, the sheet's *Cancel*, and *Open iOS Settings*. *(Until the redesign this list named the three quick-add vessels, *Get
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

Apple also warns to "limit the use of Liquid Glass effects onscreen at the same time". Home
drew **five** panes (the vessel, three vessels, the tab bar); since stage 2 it draws four — the
vessel, two discs and the tab bar, the Glass being the primary surface — a fifth when there is a
streak, and a sixth for the eight seconds an *Undo* stands. Settings draws **five** — its four
cards and the tab bar — and a sixth, *Open iOS Settings*, while notifications are blocked; this
line said four until 2026-10-11, which left the tab bar out where Home's count had it in. Worth a
look.

## The haptic ladder

Three rungs, in `Haptics`. Five call sites used to spell the first one, `confirm`, by hand.

| Rung | Weight | Intensity | Where |
|---|---|---|---|
| `confirm` | `.medium` | 0.8 | a goal saved (first run and Settings), the reminders switch turned on (at the flip, before permission is answered), a language picked, a vessel's amount committed, and — since stage 2 — *Undo* pressed on Home (whether or not a row was there to take back) |
| `pour` | `.heavy` | **1.0** | water logged on Home, and a serving added or edited in History's sheet |
| `goalReached` | `.heavy` | 1.0 | the goal crossed upward **while Home is on screen** — the modifier is Home's, and it watches the model's `hasReachedGoal`, the one haptic not driven by a counter; a goal crossed from History's sheet plays `pour` alone |

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

## Reduce Motion / Reduce Transparency

- **Reduce Motion** — `WaterVessel` swaps the `TimelineView` for a still frame (`phase: 0,
  slosh: 0`). The level still animates when it changes; only the perpetual travel is dropped.
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
