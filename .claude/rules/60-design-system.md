---
description: Liquid glass, aurora, water and haptics — one system, no ad-hoc literals
globs: ["WaterBuddy/LiquidGlassModifier.swift", "WaterBuddy/AuroraBackground.swift", "WaterBuddy/WaterSurface.swift", "WaterBuddy/Celebration.swift", "WaterBuddy/PressStyle.swift", "WaterBuddy/Haptics.swift", "WaterBuddy/*View.swift", "WaterBuddyWidget/**/*.swift"]
---

# Design System

Every surface in WaterBuddy is glass over an aurora. The tokens are derived, not chosen — retuning
one by eye breaks a contrast figure somebody measured.

## Glass
- Put content on glass only through `.liquidGlass(cornerRadius:…)` or `.liquidGlass(in:…)`. Never
  hand-roll a pane from `.background(.ultraThinMaterial)`, a bare fill, or a stroke
- Glass goes over content, imagery or colour — never over a flat background
- Choose density by what the pane carries: `.frosted` or `.opaque` behind sentence-length text,
  `.sheer` only for short labels and controls
- Use `LiquidGlass.cornerRadius` for every rounded pane. Never write a corner-radius literal in a
  view
- Sibling panes on one screen share a `density`/`elevation` pair, and peer controls in one row share
  a density. A one-off value needs a stated reason in the diff
- The tab bar sits at `.frosted` + `.floating`, the highest pair in the system; treat it as reserved
- **Reduce Transparency replaces the entire stack**, not just the base — the pane branches and draws
  `opaqueFill` with no blur, no scrim, no rim
- Elevation is always **two** shadows — a wide ambient plus a tight contact — and dark mode weights
  both by 1.5. One shadow alone either hugs the edge or floats with no anchor
- `compositingGroup()` precedes the shadows in both branches so the assembled pane casts **one**
  shadow. Drop it and every stacked overlay casts its own
- When elevated glass sits inside a clipping container (a `ScrollView`, a `List` row), disable the
  clip — otherwise the elevation shadows are sliced off square
- A glass row in a `List` clears the list's own surfaces: `.listRowBackground(Color.clear)`,
  `.listRowSeparator(.hidden)`, explicit `.listRowInsets`
- The dark-mode black scrim is what makes dark glass work. Raising the tint is the wrong fix
- The contrast boost and the press boost multiply, and each is clamped

## Interaction
- Every app `Button` whose label is a glass pane carries `.buttonStyle(PressStyle())`, and
  `PressStyle` stays the only writer of `EnvironmentValues.glassIsPressed`
- Keep `interactive` opt-in (`false` by default). Pass `interactive: true` only where the glass
  itself is the pressable surface — not on a pane that merely contains buttons
- No tint opacity exceeds `LiquidGlass.Interaction.maximumTintOpacity` (0.6) in light mode. A pressed
  pane takes its tint from `LiquidGlass.Interaction.pressedTint(_:)`, never a bare multiplication
- The press curve is `.spring(response: 0.28, dampingFraction: 0.62)` and stays identical in
  `PressStyle` and `LiquidGlassModifier`. State changes use `.smooth(duration:)` scoped with
  `.animation(_:value:)` — never a bare `withAnimation`

## Colour
- Every colour comes from `Aurora` — `top`, `bottom`, `blue`, `magenta`, `cyan`, `gradient`. The
  only permitted literals outside it are the two `WaterSurface` wave gradients and
  `LiquidGlass.Base.archived`
- Share `Aurora`'s colours between app and widget, but **never** its geometry: absolute offsets
  belong to `AuroraBackground`, proportional `UnitPoint`s to `WidgetAurora`
- `Base.archived`'s two fills and the `saturation(1.1)` on `WidgetCardBackdrop` are a **derivation**
  from the dark ultra-thin material recipe. If an `Aurora` colour changes, re-derive them — and never
  delete the derivation comment
- Every full-screen view stands its own `AuroraBackground()` at the bottom of its `ZStack`, and
  there is exactly one definition of it
- An aurora light may never drift off its own footprint, and the three periods stay pairwise
  non-harmonic — otherwise the field visibly repeats
- Colour on a light is cross-faded as two stacked fills with opposed opacities, never animated as
  one fill

## Water
- Draw it with two `WaveShape`s travelling opposite ways at different frequencies (1.1 and 1.7), and
  keep `WaveShape.animatableData` exposing `level` only
- The wave is damped to zero at both ends of the level and the water is inset from the rim, so an
  almost-empty or almost-full vessel does not show a wave clipping through the wall
- Any readout drawn over `WaterSurface` sits above a `WaterReadabilityScrim(diameter:)` sized to the
  vessel. Do not remove it or tune it away in favour of a heavier text shadow
- Leave `intensity` at its default 1 in the app; scale it with the level (`min(1, level * 1.6)`)
  only in the widget's small vessel
- Volumes stay `Int` everywhere, including a view's `@State`. A `Double` may exist only as a drawing
  fraction (`progress`, `progressUnclamped`, `WaterSurface.level`) or inside a `Slider` binding that
  rounds back to `Int` on the way out

## Haptics
- Fire only through `Haptics.confirm`, `Haptics.pour` and `Haptics.goalReached`. Never spell
  `.impact(weight:intensity:)` at a call site, and never play one from the widget extension
- Trigger `.sensoryFeedback` from a counter bumped by the user's own action (`pours`, `commits`,
  `enables`, `switches`) — never directly from a model value such as `manager.currentWater`

## In the widget
- Glass never uses `LiquidGlass.Base.material(_:)`; pass `base: .archived` (which `WidgetPane` does
  for you) — rule `40-widget`
- Outside `.fullColor` rendering, draw only the lit rim — never the glass stack, the scrim or the
  shadows
- The card backdrop is applied **after** the pane and offset from the surround, so it reads as depth
  rather than as a second edge
- Two glass discs may never share an edge in the small family; the vessel cap is derived from the
  button's 44pt target and a 4pt gap
- Every glyph or annotation inside a capped container is sized as a **ratio** of that container,
  never with its own text style — a capped container and an uncapped text style cross over at the
  accessibility sizes (rule `65-accessibility`)
