# DESIGN — tokens and the measurements behind them

The numbers, in one place, so a future reader can tell a measurement from a preference. Every
figure here is transcribed from the source; the *arguments* are in the DocC on
`LiquidGlassModifier.swift` / `WaterSurface.swift` and in `.claude/rules/60-design-system`.

**Rule of the file:** record the measurement, not the adjective. "0.24 at 50%" survives a redesign
argument; "looked better" does not.

**Last updated:** 2026-10-10 (the redesign's stage 1, finished and staged. **Apple's glass is tinted
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

In use: app vessel `.floating`, app tab bar `.frosted`/`.floating`, app quick-add vessels
`.raised`, widget card `.raised`, widget vessel and
buttons `.resting`.

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
busy backdrop cannot swallow a whole sentence. In use: vessels `.sheer`, cards and buttons
`.frosted`.

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

Those five colours and the gradient live in `WaterSurface.swift` and are shared by both processes.
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

Those two gradients and the `Aurora` palette are the **only** colour literals allowed outside
`Aurora`.

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

The widget's is roughly double because the app's 1.8% is 5pt of surface at 280pt and only 1.7pt at
92pt — flat. The frozen phase `0.6` is picked so both waves show a crest and a trough across the
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
| White @ 0.8 over the bright wave fill | **3.4–3.9:1** | Safe at the app's 25pt `%` (large text, 3:1). **Not** safe at the widget's 12pt `%` (small text, 4.5:1) — so the widget draws that glyph at **full white** and subordinates it by size alone. |
| White over the bright cyan surface, full | **~1.4:1** | Why the scrim exists at all. |
| White @ 0.8 on the watch vessel's bare glass at 0%, no scrim | **8.58:1** worst column (46mm), **8.60:1** (40mm) | Why the watch's scrim can go to zero when the vessel is empty: the glass alone holds the millilitre line far above 4.5:1. Read off renders after the #35 fix; the glass reads sRGB `(36, 43, 95)` where the full scrim had it at ≈`(24, 28, 62)` — the black hole. |
| White @ 0.8 over water, the watch's millilitre line, full scrim | **3.34:1** worst, **4.13:1** median, **4.65:1** best — under 4.5:1 across **77%** of the line | **A real failure, and pre-existing** — known issue #44, not fixed. The scrim is radial and thins toward the line's ends, and the watch's readout dropped the app's text shadow and its 0.85 opacity. Read off the 63% census capture, column by column, the ground sampled from the clean rows just above and below the line — a first pass that took the darkest pixels *within* the band read glyph ink as ground and published "≈4.7:1 at its centre, 3.3–3.5:1 toward its ends". It is also why the watch's ramp must be full before water reaches the line. |
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
| White @ 0.75 on the Settings cards' pane | **6.04:1** | The vessel names and their millilitre readouts. |
| `Aurora.cyan` on the Settings cards' pane | **5.26:1** | The vessel glyphs and the slider tint — non-text, 3:1. Comfortably clear here, unlike the same colour on the tab bar's lighter pane at 4.34:1. |
| Black status-bar glyphs over the indigo backdrop | **1.57:1** | Why `RootTabView` uses `preferredColorScheme(.dark)` (travels *up*, sets the window style → **13.39:1**) and not `.environment(\.colorScheme, .dark)` (travels *down* only). A widget has no status bar and no hosting controller to hear a preference, so `HydrationView` uses the environment form — the shape `HomeView` rejects, for the opposite reason. |

The widget's readout carries **two** shadows where the app has one: `(0.3, radius 6, y 1)` plus a
tight `(0.45, radius 2)`. The scrim is radial and centred on the vessel, so it is nearly gone by
the time it reaches the `%` out on the right — and that glyph is also the smallest, held to 4.5:1
rather than 3:1. The tight second shadow is a local halo that travels with the glyph and carries it
over the line. (App: a single `(0.3, radius 10, y 2)`.)

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
| app vessel diameter | `280` | `.largeTitle` | `min(…, 340)` |
| app `%` | `58` | `.largeTitle` | `frame(maxWidth: diameter × 0.78)`, `minimumScaleFactor(0.4)` |
| widget `%` | `27` | `.largeTitle` | `min(readoutSize, diameter × 0.33)` |
| widget medium hero | `28` | `.title2` | `minimumScaleFactor(0.6)`, capped at `.accessibility1` — by reading, the cap does not reach this metric, which sits above it (known issue #76, not rendered) |

The `%` glyph is `size × 0.44` in both. The medium family's `of N ml` line is **`totalSize × 0.46`
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
(−18.8%, −20.0%, −19.3%). They were **re-chosen rather than divided by a constant**: scaling all
three by one factor preserves their ratios exactly, and the ratios are the thing that stops the
lights beating together. Doubled to whole seconds the new set is 32 / 45 / 57, whose lowest common
multiple is 27,360 — 3.8 hours to approximately repeat, up from 2.5.

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

Since the redesign's stage 1 (2026-10-09, staged), `liquidGlass(…)` draws one of three panes, and
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
  turns it on, and measures it there. (The flag's own DocC still gives the missing runtime as its
  reason — known issue #91.)
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
- **The pane says its hit region:** `systemPane` ends in `.contentShape(shape)`. The hand-made
  stack is hit-testable through its fills; Apple's glass is not always. On iOS 26.5 a serving row
  in History's `List` took a tap on its text and none on the bare glass between; iOS 27.0 took
  both. `GoalSetupUITests.testAServingRowOpensItsSheetWhereverItIsTapped` holds it.
- `LiquidGlassRoutingTests` pins the table, the mapping, which variant is darkened and that its
  tint is no lighter than `0.52`, without building a view.

**The mapping is settled** (2026-10-10) — see *Apple's glass, measured* below.

## The primary surface

`primarySurface(in:ring:)` — the one surface that is not glass, for a screen's one main action.
*Get Started* and the sheet's *Save* use it; both were frosted glass under a cyan glow.

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
| Quick-add glyph / History's `+` | 7.27 / 9.19 | 7.98 / 9.33 | 3 |

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
| Settings: range labels, now 0.75 / vessel names 0.75 / the note 0.70 | 5.65 / 6.38 / 5.22 | 7.39 / 7.75 / 6.28 | 4.5 |
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
- **The tightest pair is white 0.70 over the magenta lobe, 4.86:1.** The three lights never
  re-sync, so no finite pass sees every way they can line up; three and a half minutes found
  nothing worse than the first. If a pair is ever seen under its floor, the next value is rendered
  and followed through the swing like these — never estimated — and
  `theTintIsNoLighterThanTheLightestRungThatPassed` is moved with it.
- **The vessel is not in this table.** It takes the clear variant and no tint; its readout over
  water is known issue #81, older than the redesign: 2.91–3.07:1 for the millilitre line on every
  path, shipped 1.1 included.

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
| Settings: vessel names @ 0.75 / the note @ 0.70 / the glyph | **3.65** / **2.70** / **2.90** | 4.5 / 4.5 / 3 |
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
`EnvironmentValues.glassIsPressed`, and `LiquidGlassModifier` reads it. It has to travel downward:
`liquidGlass(…)` is applied *inside* a button's label, and `ButtonStyle.Configuration` is visible
only to the style, which wraps the label from outside.

**Interactivity is opt-in**, and only where the glass *is* the pressable surface — the three
quick-add vessels, *Get Started*, a serving row, *Save* / *Cancel*, *Open iOS Settings*. The tab
bar's glass sits outside its buttons and the settings cards sit outside their rows, so neither
reacts: lighting a whole bar because one tab was tapped would be wrong.

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
renderer to blend the shapes and have no hand-rolled equivalent. The quick-add row, three glass
circles in an `HStack`, is *literally* the example Apple's page uses. It was "the first thing to
revisit when Xcode 26 is available"; the SDK now has it, and the redesign's stage 2 adds the container
with the new quick-add row (spec `2026-10-09-premium-redesign-design.md` §3.2, §14). Not built yet.

Apple also warns to "limit the use of Liquid Glass effects onscreen at the same time". Home
currently draws **five** panes (the vessel, three vessels, the tab bar) and Settings four. Not
changed here, and worth a look.

## The haptic ladder

Three rungs, in `Haptics`. Five call sites used to spell the middle one by hand.

| Rung | Weight | Intensity | Where |
|---|---|---|---|
| `confirm` | `.medium` | 0.8 | a goal saved, a switch flipped |
| `pour` | `.heavy` | **1.0** | water logged, and a serving edited |
| `goalReached` | `.heavy` | 1.0 | the goal crossed upward |

**The pour steps the weight because intensity alone cannot express the increase.** Water landing is
meant to be half again firmer than a confirmation; `0.8 × 1.5` is `1.2`, and
`SensoryFeedback.impact(intensity:)` saturates at 1 — so intensity delivers only a quarter of the
requested change before it stops meaning anything, and `.medium` → `.heavy` carries the rest. That
is a genuinely different actuator envelope rather than the same tap turned up.

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
  soften. `WidgetCardBackdrop` and the aurora's lights drop out too: above an opaque card the
  lights would only show as a rim of colour, and the plain gradient is the calmer read.

## Forbidden

- A hand-rolled `.background(.ultraThinMaterial)` instead of `liquidGlass(…)`
- A tint opacity above ~0.6 in light mode
- Glass over a flat background — in the product **or** in a preview
- A `Material` in the widget
- A colour literal outside `Aurora` and the two `WaterSurface` gradients
- Deleting a derivation comment because the number "looks arbitrary"
