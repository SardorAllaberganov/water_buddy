---
description: Liquid glass, aurora, water and haptics — one system, no ad-hoc literals
globs: ["WaterBuddy/LiquidGlassModifier.swift", "WaterBuddy/AuroraBackground.swift", "WaterBuddy/WaterSurface.swift", "WaterBuddy/Celebration.swift", "WaterBuddy/PressStyle.swift", "WaterBuddy/Haptics.swift", "WaterBuddy/*View.swift", "WaterBuddyWidget/**/*.swift", "WaterBuddyWatch/**/*.swift", "WaterBuddyWatchWidget/**/*.swift"]
---

# Design System

Every surface in WaterBuddy is glass over an aurora, except the one primary surface a screen may
carry. The tokens are derived, not chosen — retuning one by eye breaks a contrast figure somebody
measured.

## Glass
- Put content on glass only through `.liquidGlass(cornerRadius:…)` or `.liquidGlass(in:…)`. Never
  hand-roll a pane from `.background(.ultraThinMaterial)`, a bare fill, or a stroke
- `.liquidGlass(…)` draws one of three panes, chosen by
  `LiquidGlass.rendering(base:reduceTransparency:systemGlassAvailable:)`: the opaque fill under
  Reduce Transparency; Apple's glass (`glassEffect`) for a `.material` base on iOS 26 and later; the
  hand-made stack everywhere else — a `.flat` base, and iOS 17 to 25. The watch draws Apple's glass
  from its floor, watchOS 26.0. Never call `glassEffect` at a call site
- Sibling panes that sit close together — a row of discs — are wrapped with `.glassGroup()`:
  Apple's `GlassEffectContainer` on iOS 26 and later and on the watch, the content untouched
  elsewhere. Never write `GlassEffectContainer` at a call site
- A pane's content is never moved between branches by a setting. `LiquidGlassModifier` changes the
  background and the glass handed to `glassEffect` — `.identity` when the pane is not Apple's — so
  a Reduce Transparency flip rebuilds nothing inside a pane
- The scrim, the tint ceiling and the two shadows are properties of the hand-made stack. The
  specular and the lit rim are drawn on both: on Apple's glass as the pane's background, over the
  glass and under the content, so the canvas's bright edge survives the tint
- Apple's regular glass is darkened with the theme's `top` — `LiquidGlass.systemTintColor(for:)`, the
  sky's own colour; a black tint greys the aurora under it — through `Glass.tint`, at
  `LiquidGlass.systemTintOpacity(for:theme:)`; the clear variant — the vessel — takes none. Each
  theme's value is the rung adopted when every pair was rendered on iOS 27.0 and followed through the
  aurora's swing (`docs/DESIGN.md`, *The look, measured*, and each theme's own table), and
  `theTintIsNoLighterThanTheLightestRungThatPassed` holds it for every theme. Never retune it by eye,
  and never estimate one value from another — one theme's from another's included. The watch is
  measured on its own renders, never estimated from the phone's
- A pane answers a tap anywhere inside its shape, on both paths. The hand-made stack gets that from
  its fills; on Apple's glass the modifier says it with `.contentShape(shape)`. Never remove it: on
  iOS 26.5 a serving row stopped answering on its bare glass without it
- A selected slot is marked with `LiquidGlass.Selection`'s fill **and** rim; the week card's shown
  day with `Selection.ringOpacity`'s ring on its track **and** `Selection.discFill` behind its
  letter, the letter heavier than the rest. The month card's opened day takes the same ring round its
  ring **and** disc behind its number, the number heavier; today's number is heavier and takes no
  disc. Each mark is present at zero opacity when nothing is selected. Never a fill, a rim, a ring
  or a disc written as a literal in a view
- Premium's Settings card, in both its forms, History's locked month, the recap's card, the export
  sheet's card, Insights' lead pane and the paywall's held card are marked with `.premiumRim()` —
  the theme's `accent`, `second` and `first` stroked around a standard pane — and nothing else is.
  Never a gradient stroke written in a view
- A rim runs one lap of light as it arrives, through `PremiumRim`, and two at a purchase. Never a lap
  on a loop
- The recap's card is rendered into the image the user may share, so it is drawn flat: its canvas is
  the theme's `gradient` in a `LiquidGlass.cornerRadius` shape, not glass, and its tiles take
  `RecapCard.tileBase` — a `.flat` base, for the widget's reason: an `ImageRenderer`, like a widget
  snapshot, has no live backdrop for a `Material` to sample. Its fill, `RecapCard.tileFill(for:)`, is
  History's `.frosted` glass — Apple's regular glass tinted the theme's `top` — frozen by measurement on
  iOS 27.0 for each theme and held by `theTilesFillGivesBackTheAppsOwnGlass` for every theme (the owner's
  ruling on #182). Never retune it by eye; derive it again when the hand-made stack's scrim or tint for a
  flat base moves, or a palette does. Its image is rendered at
  `.dynamicTypeSize(.large)`, so the picture never depends on the sender's text size
- Glass goes over content, imagery or colour — never over a flat background
- Choose density by what the pane carries: `.frosted` or `.opaque` behind sentence-length text,
  `.sheer` only for short labels and controls
- Use `LiquidGlass.cornerRadius` for every rounded pane. Never write a corner-radius literal in a
  view. A rounded element inside a pane — the week's tracks and bars — uses
  `LiquidGlass.innerCornerRadius`
- Sibling panes on one screen share a `density`/`elevation` pair, and peer controls in one row share
  a density. A one-off value needs a stated reason in the diff
- The tab bar sits at `.frosted` + `.floating`, the highest pair in the system; treat it as reserved
- **Reduce Transparency replaces the entire stack**, not just the base — the pane branches and draws
  `opaqueFill` with no blur, no scrim, no rim
- On the hand-made stack, elevation is always **two** shadows — a wide ambient plus a tight contact — and dark mode weights
  both by 1.5. One shadow alone either hugs the edge or floats with no anchor
- `compositingGroup()` precedes the shadows in both hand-made branches so the assembled pane casts **one**
  shadow. Drop it and every stacked overlay casts its own
- When elevated glass sits inside a clipping container (a `ScrollView`, a `List` row), disable the
  clip — otherwise the elevation shadows are sliced off square
- A glass row in a `List` clears the list's own surfaces: `.listRowBackground(Color.clear)`,
  `.listRowSeparator(.hidden)`, explicit `.listRowInsets`
- The dark-mode scrim is what makes dark glass work, and
  `LiquidGlass.scrim(density:scheme:base:onPhone:theme:)` is the one place it is decided: the theme's
  `top` on the phone's own panes, at the opacities measured for that theme on iOS 18.6, black for the
  widget's `.archived` base and for the watch. Raising the white tint is the wrong fix
- The contrast boost and the press boost multiply, and each is clamped

## The primary surface
- A screen's one main action is drawn with `.primarySurface(in:)`: solid white, the theme's `top` content.
  It is the only control that is not glass — the recap's card, a rendered picture, is the one other
  surface that is not — and a screen carries at most one. The recap sheet's is *Share as an image*, the export
  sheet's *Share as a CSV file*
- In the Home Screen widget the pour button is the primary surface in `.fullColor` —
  `.primarySurface(in:ring: false)`, so it stays exactly its 44-pt target and the vessel's clearance
  holds (rule `40-widget`). Outside `.fullColor` it is white content in the lit rim, as every pane
  there is
- Its shade, its pressed wash, its ring and its shadows come from `LiquidGlass.Primary` and
  `Elevation.raised`. Never hand-roll one from `.background(.white)`
- The surface sets its content's colour. Never give a primary label a `.foregroundStyle` of its own
- It carries no glow. The cyan glow *Get Started* and *Save* once had is retired
- Its contrast is derived, not measured, because its fill is solid:
  `thePrimaryLabelClearsSevenToOneEvenAtTheFootOfTheShade`, for every theme
- On the watch the Glass pour button is the primary surface — a capsule carrying its amount where
  the row has room, a disc where it has not — `ring: false`, as the widget's: the ring is the phone's

## Interaction
- **No press response of the app's own on the watch.** `PressStyle.swift` and `Haptics.swift` are in
  none of the watch's exception sets, so its buttons take `.buttonStyle(.plain)` and play no haptic —
  deliberate: haptics were not in the approved watch scope. Its glass controls take
  `Glass.interactive()`, whose press response is the system's; the white Glass has none. A task that
  wants either on the watch adds the file to that exception set first
- Every app `Button` whose label is a glass pane carries `.buttonStyle(PressStyle())`, and
  `PressStyle` stays the only writer of `EnvironmentValues.glassIsPressed`
- Keep `interactive` opt-in (`false` by default). Pass `interactive: true` only where the glass
  itself is the pressable surface — not on a pane that merely contains buttons
- On Apple's glass `interactive: true` becomes `Glass.interactive()`. `PressStyle` keeps its recoil on
  both paths and stays the only writer of `glassIsPressed`, which the hand-made stack, the sheen and
  lit rim laid over Apple's glass, and the primary surface read
- No tint opacity exceeds `LiquidGlass.Interaction.maximumTintOpacity` (0.6) in light mode. A pressed
  pane takes its tint from `LiquidGlass.Interaction.pressedTint(_:)`, never a bare multiplication
- The press curve is `.spring(response: 0.28, dampingFraction: 0.62)` and stays identical in
  `PressStyle` and `LiquidGlassModifier`. State changes use `.smooth(duration:)` scoped with
  `.animation(_:value:)` — never a bare `withAnimation`
- A sheet's content arrives through `Landing`, after the sheet has landed: the sheet comes whole, then
  what is inside moves. A data surface draws from one flag on its screen. Each plays once per arrival:
  on opening a sheet, entering Month or Insights, or turning a month's page, never on a re-read, a
  return from the background or a row scrolled back into view

## Colour
- Every colour comes from the theme's `Aurora` — `top`, `bottom`, `first`, `second`, `accent`,
  `gradient` — read from the environment's `aurora`, which every root that draws the aurora injects
  from the stored theme beside `\.strings` and `\.locale`. `Aurora.classic` is the default theme, the
  palette the app has always drawn. The only permitted literals outside the palettes are the two
  `WaterSurface` wave gradients and the derived fills, `LiquidGlass.Base.archived(for:)` and
  `RecapCard.tileFill(for:)` — derived, never chosen
- **A theme is five colours and the values measured on its renders** (spec
  `2026-11-22-set-c-design.md`). `top` is the ink on white and the glass's tint; `accent` is the third
  light and every mark, switch and accent line; `first` and `second` are the broad lights, the confetti
  and the rim. Its glass tint, hand-made scrims, `Base.archived` fills, recap tile fill and tab-bar
  shade are taken on its own renders — iOS 27.0 and 18.6, the widgets, the watch on its own — by the
  method `docs/DESIGN.md` records, climbing from Aurora's by the same rungs. A theme ships only with its
  table: every pair at its floor, and none lower than Aurora's where Aurora is under on clean ground
- A view never names a palette and never switches on a theme to pick a colour: it draws `aurora`. A
  value derived from a theme is a function of the theme, beside Aurora's number and its DocC
- Share the theme's palette between app, widget and watch, but **never** the geometry: absolute
  offsets belong to `AuroraBackground`, proportional `UnitPoint`s to `WidgetAurora` **and to
  `WaterBuddyWatch/WristAurora.swift`** — a watch face is a small, fixed canvas with no wallpaper to
  sample, exactly `WidgetAurora`'s own reason, so `WristAurora` follows `WidgetAurora`'s
  proportional-geometry approach rather than `AuroraBackground`'s absolute one
- `Base.archived(for:)`'s two fills and the `saturation(1.1)` on `WidgetCardBackdrop` are a
  **derivation** from the dark ultra-thin material recipe, taken for each theme. If a palette's colour
  changes, re-derive them — and never delete the derivation comment
- Every full-screen view on the **phone** stands its own `AuroraBackground()` at the bottom of its
  `ZStack`, and there is exactly one definition of it. `WristAurora` is a deliberate second,
  proportional-geometry definition for the watch's own screen — its own twin, not a duplicate of
  `AuroraBackground` — for the identical reason `WidgetAurora` is already a second definition for the
  phone widget; "exactly one" is a claim about `AuroraBackground` specifically, not about the whole
  system having a single aurora view
- An aurora light may never drift off its own footprint, and the three periods stay pairwise
  non-harmonic — otherwise the field visibly repeats
- Colour on a light is cross-faded as two stacked fills with opposed opacities, never animated as
  one fill

## Water
- **Water is water.** The waves, the falling drop, the vessel's glow and the watch faces' gauges keep
  `Aurora.classic`'s colours in every theme — the one reason code may name a palette
- Draw it with two `WaveShape`s travelling opposite ways at different frequencies (1.1 and 1.7), and
  keep `WaveShape.animatableData` exposing `level` only
- The wave is damped to zero at both ends of the level and the water is inset from the rim, so an
  almost-empty or almost-full vessel does not show a wave clipping through the wall
- Any readout drawn over `WaterSurface` sits above a `WaterReadabilityScrim(diameter:)` sized to the
  vessel. Do not remove it or tune it away in favour of a heavier text shadow
- Leave `intensity` at its default 1 in the app; scale it with the level only on a small canvas: the
  widget's small vessel (`min(1, level * 1.6)`) and the watch's vessel
  (`WristVessel.scrimIntensity(at:)`, full strength by the level at which water reaches the
  percentage's ink, its lowest readout). Each ramp is calibrated to where its
  **own** smallest readout sits and reaches full strength before water can reach it. Never copy one
  canvas's ramp to another
- Volumes stay `Int` everywhere, including a view's `@State`. A `Double` may exist only as a drawing
  fraction (`progress`, `progressUnclamped`, `WaterSurface.level`) or inside a `Slider` binding that
  rounds back to `Int` on the way out — and at HealthKit's boundary, in `HealthMirror.Source.live()`, from
  an `Int` and rounded back to one

## Haptics
- Fire only through `Haptics.confirm`, `Haptics.pour`, `Haptics.goalReached`, `Haptics.select` and
  `Haptics.remove`. `select` is the system's selection tick, for a choice among peers — a tab, a
  day, a vessel, a slider's step, a theme, an icon; `remove` is a light impact, for something taken away. Never spell
  `.impact(weight:intensity:)` or `.selection` at a call site, and never play one from the widget
  extension
- `goalReached` also marks a purchase landing: the two largest moments the app has
- Trigger `.sensoryFeedback` from a counter bumped by the user's own action (`pours`, `commits`,
  `enables`, `switches`, `steps`) — never directly from a model value such as `manager.currentWater`

## In the widget
- Glass never uses `LiquidGlass.Base.material(_:)`; pass `base: .archived` (which `WidgetPane` does
  for you) — rule `40-widget`
- Outside `.fullColor` rendering, draw only the lit rim — never the glass stack, the scrim or the
  shadows
- The card backdrop is applied **after** the pane and offset from the surround, so it reads as depth
  rather than as a second edge
- Two glass discs may never share an edge in the small family; the vessel cap is derived from the
  button's 44pt target and a 4pt gap
- When the system removes the container background — `showsWidgetContainerBackground` is `false`,
  on iPhone StandBy — the small family draws no card, no card pane and no backdrop: the vessel and
  the pour button stand on the system's black. The vessel draws its lit rim and its water, never its
  glass, because glass never goes over a flat background
- The week widget draws History's week card from History's values — the theme's `accent` for a met
  day, white for the rest, white 0.10 tracks, the dashed goal line at white 0.62 — each pair measured
  on the widget's own rendered pane, for each theme (`docs/DESIGN.md`), never carried over from
  History's figures.
  Outside `.fullColor` a met bar is `.widgetAccentable()`
- Every glyph or annotation inside a capped container is sized as a **ratio** of that container,
  never with its own text style — a capped container and an uncapped text style cross over at the
  accessibility sizes (rule `65-accessibility`)
- The Lock Screen widget draws no glass and no `Aurora` colour. iOS renders the iPhone Lock Screen in
  the vibrant mode, which desaturates the widget into its own material, so it is built from the
  system's accessory vocabulary instead — `.accessoryCircularCapacity` and `.accessoryLinearCapacity`
  gauges, `.primary`/`.secondary` foreground styles, `AccessoryWidgetBackground` behind the button —
  with no branch on `widgetRenderingMode` and no `colorScheme` override
- The Control Center control draws nothing of its own — iOS draws its glyph and title in Control
  Center's own style — so it takes no glass, no `Aurora` colour and no tint

## On the watch face
- A face draws no glass and no aurora, and no theme. Its gauges are water, tinted
  `Aurora.classic.first` in every theme, and on a tinted face the header and the gauges are
  `.widgetAccentable()`
- Every figure on a face carries `.privacySensitive()`, and every shape draws its quiet form — the
  drop and an empty gauge, and on the rectangle *Hydration* over an empty bar — whenever
  `redactionReasons` contains `.privacy`
- The rectangle draws the app screen's own line, `WristPlan.Face.millilitreLine(in:locale:)`; the
  faces and the screen read one `WristPlan.Face`

## App icons
- One icon per theme, five in all: Aurora's is the primary, the other four are alternates the user
  picks in Settings, apart from the theme. `Tools/GenerateAppIcon.swift` draws every one — the drop on
  its theme's sky, light, dark (× 0.52) and tinted (grey × 0.85) — and its preview for the picker.
  Never draw or edit an icon by hand
- The generator's palettes are transcribed from `WaterSurface.swift`. A palette's change regenerates its
  icon in the same change
- The watch has one icon, Aurora's: watchOS has no alternate icons
