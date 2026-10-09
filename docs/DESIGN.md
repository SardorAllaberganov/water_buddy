# DESIGN — tokens and the measurements behind them

The numbers, in one place, so a future reader can tell a measurement from a preference. Every
figure here is transcribed from the source; the *arguments* are in the DocC on
`LiquidGlassModifier.swift` / `WaterSurface.swift` and in `.claude/rules/60-design-system`.

**Rule of the file:** record the measurement, not the adjective. "0.24 at 50%" survives a redesign
argument; "looked better" does not.

**Last updated:** 2026-10-08 (the medium widget hero's row points to known issue #76 — by reading, its
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
turning the widget into a system slab. (`Base.material`'s `opaqueFill` *is*
`Color(.secondarySystemBackground)`; only the archived base carries the product colour.)

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
| White @ 0.45 on the week card's pane | **3.26:1** | The goal reference line — non-text, 3:1. |
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

## Interactive glass

Adopted from Apple's *Applying Liquid Glass to custom views*, which describes `Glass.interactive()`
as glass that "reacts to touch and pointer interactions in real time".

**Apple's API is not reachable from this project.** `glassEffect(_:in:)`, `GlassEffectContainer`,
`glassEffectID` and `.buttonStyle(.glass)` all ship in the **iOS 26 SDK**; the toolchain here is
Xcode 16.4 with only `iphoneos18.5`. An `if #available(iOS 26, *)` guard does not help — availability
is a runtime check on a symbol the compiler can already see, and these are undeclared rather than
unavailable. So the *behaviour* was adopted into this system instead.

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
circles in an `HStack`, is *literally* the example Apple's page uses. It is the first thing to
revisit when Xcode 26 is available.

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
