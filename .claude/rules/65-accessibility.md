---
description: Reduce Motion, Reduce Transparency, Dynamic Type, VoiceOver and contrast
globs: ["WaterBuddy/**/*.swift", "WaterBuddyWidget/**/*.swift", "WaterBuddyUITests/**/*.swift", "WaterBuddyWatch/**/*.swift", "WaterBuddyWatchWidget/**/*.swift", "WaterBuddyWatchTests/**/*.swift"]
---

# Accessibility

The most-cited rule in this codebase. Every glass surface, every animation and every figure on
screen has an accessibility consequence, and most of them are already decided — follow the decision
rather than re-deriving it.

## Reduce Motion
- Read it only through `@Environment(\.accessibilityReduceMotion)`, declared on the view that owns
  the animation
- An animation that **repeats forever** is gated on it and resolves to `nil` — never to a shorter or
  gentler curve. The view renders its resting frame instead
- An animation that runs **once per tap**, or only while a finger is down, gets **no** branch:
  `PressStyle`'s recoil, the pressed material and the tab's selection curve all stay. Reduce Motion
  is aimed at sustained motion, not at feedback
- Under Reduce Motion drop only the *perpetual travel* and keep the value animation — the vessel
  swaps `TimelineView(.animation)` for a frozen phase while the level still animates on change
- The resting frame is **the design that shipped**, not a degraded version of the effect. When
  editing the aurora's lights, keep the values the resting-lights test pins
- `ConfettiOverlay` renders nothing at all under Reduce Motion, and the celebration stays announced
  through a non-motion channel — `Haptics.goalReached` plus the vessel's own arrival

## Reduce Transparency
- Every glass surface goes through `liquidGlass(…)`, whose pane replaces base + scrim + tint +
  specular with `base.opaqueFill` under `@Environment(\.accessibilityReduceTransparency)`, keeping
  only the edge
- A `flat` base's `opaque` fill is the glass stack **composited down over the aurora**, never a
  neutral system grey
- Home's vessel draws its glow, halo and highlight only when Reduce Transparency is off
- In the widget, `WidgetCardBackdrop` draws `Color.clear` when the setting is on, and `WidgetAurora`
  keeps its three light blobs inside `if !reduceTransparency`, leaving only `Aurora.gradient`
- On the watch, `WristAurora` — `WidgetAurora`'s own proportional-geometry twin (rule
  `60-design-system`) — keeps the identical branch: its three blobs sit inside `if
  !reduceTransparency`, leaving only `Aurora.gradient` behind the list. It shipped without one for a
  time, a real gap this rule's own widening to the watch exists to catch: `WristAurora` is a
  self-declared sibling of `WidgetAurora`, and a sibling that skips the branch its own doc claims to
  follow is a defect, not a stylistic difference

## Dynamic Type
- `@ScaledMetric` always scales a **real magnitude**, never a unitless `1` that is then multiplied —
  `UIFontMetrics` rounds to the nearest third of a point, which would quantise twelve categories
  into three
- Bound every scaled dimension at its use site: a tap target gets a floor of 44 **and** a ceiling; a
  decorative or hero dimension gets a ceiling
- Size an annotation as a **ratio** of the figure it annotates, never with its own text style. A
  capped container and an uncapped text style cross over at the accessibility sizes
- Bound a hero readout to the pane it sits in with `.lineLimit(1)`, `.minimumScaleFactor(…)` and a
  `.frame(maxWidth:)`, so it shrinks rather than growing through the container's edge
- When scaled controls overflow their row, let the row overflow and reach it through
  `ViewThatFits(in: .horizontal) { row; ScrollView(.horizontal) { row } }` — never shrink a control
  below the 44pt floor to make the set fit
- On Home, large text raises the vessel's ceiling and never its floor (`HomeView.vesselFloor`): the
  vessel gives way before the quick-add row does, because the row is the screen's one action
- A line that says what a control will do is never cut short to fit. Home's *Undo* draws the first
  of its forms that fits at its own size — *Added 250 ml | Undo*, *250 ml | Undo*, then the two
  stacked — and the quiet line stacks its two times the same way
- Split a name lockup into one `Text` per line inside a `VStack` and give the group `.lineLimit(1)`;
  `.minimumScaleFactor` alone does not prevent hyphenation
- A screen that is mostly type is wrapped in
  `GeometryReader { proxy in ScrollView { … .frame(minHeight: proxy.size.height) } .scrollBounceBehavior(.basedOnSize) }`
  so it centres at ordinary sizes and scrolls at the accessibility ones
- In the widget, cap type sharing a container with the 44pt pour button using
  `.dynamicTypeSize(...DynamicTypeSize.accessibility1)` alongside `.lineLimit(1)` and
  `.minimumScaleFactor(0.6)`

## Tap targets
- Every tappable row carries an explicit `.frame(minHeight:)` of at least 44 — 44 for a tab slot and
  for Settings' *Privacy Policy* link, 50 for a language row, 56 for a serving row and the primary
  buttons. Never a fixed `height`
- Make the whole slot the target, not the glyph: `.frame(maxWidth: .infinity, minHeight: 44)` plus
  `.contentShape(Rectangle())` where the label does not already fill the row
- In the widget, size every `Button(intent:)` label to at least `PourButton.minimumTarget` (44) with
  an explicit `.frame` and `.contentShape` — WidgetKit does not pad a target out
- In the small family keep the vessel and the pour button on a diagonal — never stacked, never
  overlapping
- The tab bar is three slots. A fourth requires re-deriving the per-slot width against the 44pt
  floor, and `theBarHoldsThreeTabs` is the tripwire

## VoiceOver
- The vessel is exactly **one** element in all three processes that draw it — the app, the widget
  and the watch: `.accessibilityElement(children: .ignore)` + a label + an `.accessibilityValue`
  carrying percent and millilitres
- The week card's summary is one element; each day is exactly one button, with `.isSelected` on the
  shown day
- The week card's summary speaks the average, the best day and the days the goal was met. A met
  day's bar is cyan and an unmet day's white, and never by colour alone: a met bar also stands at
  or above the goal line
- Each of the paywall's plans is one button — label the plan's name, value its price line,
  `.isSelected` on the chosen one. The renewal terms are spoken in full, never hidden
- Insights' heading is one element with the header trait, the week's range its value. Each of its panes
  is one element — label the pane's title, value its sentences — and its glyphs, the suggested vessel's
  among them, are hidden. The footer is one element, *Writing…* while the model writes
- The recap's row is one button: label *Monthly recap*, value the offered month's name. The recap
  sheet's heading carries the header trait and its close button is *Done*. The card is one element —
  label *Monthly recap*, value the month's name and every figure it draws, in millilitres — and its
  dots, rim, glyphs and mark are hidden. The best streak's pane is one element, its footnote included.
  The card follows the text size on screen; the image it shares is always rendered at the default size
- History's heading is one element: label the shown day, value its total against the goal, the
  header trait. At an accessibility text size a past day's heading is drawn on two lines — the
  weekday, which is that element, and the date, hidden — because on one line beside the `+` the
  day's name was cut. The strip is one heading — label *When you drank*, value the count of
  servings it draws, which is hidden — and its bars, hours and reminder mark are hidden: the rows
  under it speak every serving
- A serving row's vessel name is drawn and never spoken — it is an inference from today's
  vessels. The sheet's three shortcuts are one button each: label the vessel's name, value its
  amount, `.isSelected` on the one whose amount is showing
- Put `.accessibilityLabel` / `.accessibilityValue` / `.accessibilityHint` / `.accessibilityAddTraits`
  **on the control itself** — never on an `.accessibilityElement(children: .ignore)` wrapper around a
  `Button`, `Toggle` or `Slider`
- Collapse a group of plain `Text` into one stop with `.combine`, or `.ignore` plus an explicit label
  and value
- Mark `.accessibilityHidden(true)` on any figure a sibling control already speaks — the quick-add
  caption, a slider's range labels, the widget's hero total and goal lines
- Hide duplicate figures **individually**, never on an enclosing stack that also contains a control
- Every decorative layer is hidden: the aurora, the water surface, the readability scrim, the
  confetti, a row's drop glyph, the empty state's glyph
- Every `Slider` carries an explicit `.accessibilityLabel` and an `.accessibilityValue` **in
  millilitres** — the stock VoiceOver value is a percentage of the range, which announces nonsense
- Commit a slider's value from `.onChange(of:)` guarded by an `isDragging` flag, never
  `onEditingChanged` alone
- A control's visible text and its VoiceOver label are **one string** resolved from the same bundle —
  never a visible label plus a separately authored accessibility label
- Expose selection with `.accessibilityAddTraits(isSelected ? [.isSelected] : [])`
- Keep every tab's title and symbol non-empty and mutually distinct; an SF Symbol must be proved to
  resolve by a test, because an unknown symbol draws nothing at all
- Home's heading is one element: label *Today*, value the date, the header trait. The streak chip
  is one element — label *Day streak*, value the count with its noun, what it draws where the noun
  fits — and is absent at zero. Where the noun does not fit beside the title, the chip draws the
  count alone and still speaks the noun. The status line speaks millilitres from a `%d` key with
  plural forms while it draws them from a `%@` key
- *Undo* is one button whose label is the word it draws and whose value is the amount. Its offer
  lasts eight seconds, and does not time out while VoiceOver is running; the next pour, leaving the
  tab and leaving the app each end it
- The Lock Screen widget's figures are one element per shape — label *Today's hydration*, value the
  vessel's own percent-and-millilitres string — and its quiet form speaks no figure: the label alone,
  and *Log Water* on the button. A figure hidden from sight is hidden from speech. The small Home
  Screen widget's quiet form is the same: its vessel keeps its label and speaks no figure
- Each pour button on the watch is one button whose label is the phone's `%1$@, add %2$d
  millilitres`; the amounts drawn under its discs are hidden
- Each watch face is one element — label *Today's hydration*, value the vessel's own sentence
  through `WristPlan.Face.spokenFigures(in:locale:)` — and its quiet form speaks its label alone
- The week widget is one element: label *Last 7 days*, value the sentence History's card speaks —
  the average, the best day and the days met. Its bars, letters and figure are hidden. With no
  week, its value is the line it draws
- Settings' *Apple Health* is one switch, its label the title it draws and its hint the line under it, on
  the `Toggle` itself — the *Smart reminders* row's shape
- Settings' *Schedule* is one button — label *Schedule*, value the schedule in words and its quiet days,
  *Premium* added while locked; *Only when behind* is one switch, its line the hint (*Opens Premium* while
  locked). In the schedule sheet each hour is one control, label its row's title and value the hour;
  each interval one button, `.isSelected` on the chosen; each day one button, label the weekday's full
  name, `.isSelected` while it keeps its reminders. Home's pace line is one element — label *Pace*, value
  *On track* or the millilitres behind, from a `%d` key with plural forms, while it draws a `%@` figure

## Contrast
- Small text holds 4.5:1; a non-text glyph holds 3:1
- A heading of `.title3` bold or larger on the aurora is large text and holds 3:1 — *Patterns*,
  *Insights*, History's heading and the recap's alike (the owner's ruling on #177, 2026-10-25). A line
  under such a heading is not, and is held to 4.5 — where it cannot be, it is spoken, not drawn (#171)
- When a colour lands on a `Material`, **measure the composite off a rendered screenshot** and write
  the figure into the comment and `docs/DESIGN.md`. Never derive it from the token
- Never let a tint be the only carrier of state — the tab bar's active slot keeps a white caption and
  signals through the glyph's colour, its glow and the `.isSelected` trait
- Keep `WaterReadabilityScrim` between the water and any readout drawn over it, at `intensity: 1` in
  the app; only a small canvas scales it
- The widget draws its `%` glyph at full white rather than the app's `.white.opacity(0.8)`, and keeps
  the readout's two shadows — a contrast threshold, not taste
- Keep the `@Environment(\.colorSchemeContrast)` edge boost **multiplicative** with the press boost
  and clamped — never let one replace the other

## Proving it
- When a change adds or wraps a control, assert in `WaterBuddyUITests` that its accessibility label
  resolves to exactly one element
- Treat the labels the UI suite queries as a public surface — renaming one breaks the suite, and that
  is the point
- XCUITest lists the screen beneath a sheet with the sheet. Where a sheet carries a label the screen
  under it carries too — the paywall's *Privacy Policy* over Settings' — count what the sheet adds:
  the label's count before it opens, subtracted from the count after, must be one (the owner's ruling,
  2026-10-24). Never narrow the query to hittable elements, which drops a sheet's own controls below
  its fold
- Settings' *Privacy Policy* is one link, its label the paywall's string
- Every VoiceOver string resolves through the `strings` environment bundle, and the shared ones are
  listed in `LocalizationTests` so every bundle that draws them is checked (rule `70-privacy`)
- Never write a probe that queries an element the product deliberately hides, and when verifying at a
  large text size pass a **real** category name (`UICTContentSizeCategoryAccessibilityXXXL`)
