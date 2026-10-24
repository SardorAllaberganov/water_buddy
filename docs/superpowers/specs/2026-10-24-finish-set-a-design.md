# Finishing set A — design

**Status:** approved by the owner in conversation on 2026-10-24 ("ok"), after three rulings. Taken by
`/start_task` with no task named, on the owner's choice "Finish set A" over set B, export and splitting
`HistoryView.swift`. Five known issues (`docs/AI_CONTEXT.md`): **#183**, **#154**, **#171**, **#182** and
**#177**. No roadmap item of its own: set A (1.4.1, 1.4.2, 1.4.6, 1.4.7, 1.4.12) is committed and on sale
in code, and not released. The rule wording in §5 is a proposal, typed and left unstaged for the owner
(rule `99-docs-cascade`). No plan document, as for set A's steps 3 and 4.

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then
`CLAUDE.md`. Where it contradicts the code, the code wins and this document changes.

**Provenance.** Every claim about the repository was read at HEAD `128630c` on 2026-10-24.

---

## 1. What is being built

1. **One close button for both sheets (#183).** The paywall's ✕ is a `.body` glyph in a fixed 44-pt
   circle (`PaywallView.swift:193`), so at the accessibility sizes the glyph outgrows the circle. The
   recap's copy was fixed in set A's step 5's walk (W3) by sizing the glyph as 17/44 of the circle; the
   paywall's was not, and the two screens write the same button twice (the step 5 final review's M5).
2. **A corrupt watch store no longer traps (#154).** `WristPlan` sums the outbox with a plain `reduce`
   (`WristPlan.swift:36`) and adds the mirror's total with a plain `+` (`:55`); `Face.percentage` converts
   to `Int` before it clamps (`:109`). A persisted value at an extreme overflows and crashes the watch app
   or its complication. **Found while reading for this design, of the same class:**
   `WristView.syncedCaption` converts the mirror's age with `Int(… / 60)` (`WristView.swift:369`), which
   traps on a corrupt `composedAt` far from now. None is reachable from the product — the phone composes
   every figure from clamped values — and rule `75-diagnostics` saturates anyway.
3. **The patterns' heading line is spoken, not drawn (#171).** *From this month's finished days* reads
   4.17 against 4.5 where the aurora's cyan light passes, at full white already. **The owner's ruling:**
   drop the drawn line and keep it as the heading's spoken value — which it already is — as Insights'
   heading did for the same reason.
4. **The recap tiles' fill, derived from the app's own pane (#182).** The tiles take `Base.archived`,
   the widget's fill, and read grey-brown beside the app's own panes, which on iOS 26 and later are
   Apple's glass tinted `Aurora.top`. **The owner's ruling:** derive a flat fill from that glass, measured,
   never chosen by eye. **Then, from the probe (§2.4):** "the app's own pane" was two glasses — a
   non-interactive `.sheer` pane, which the tiles declare, is Apple's *clear* glass with no tint
   (`LiquidGlass.systemVariant`), and only `.frosted` and `.opaque` take the regular glass tinted
   `Aurora.top`, as History's panes do. Both were measured; the owner chose **History's frosted pane**
   (B), the one that meets §2.4's acceptance test.
5. **The headings on the aurora are large text (#177).** **The owner's ruling:** a heading of `.title3`
   bold or larger on the aurora is held to the large-text floor of 3, as History's heading and the
   recap's already are. *Patterns* (3.14) and *Insights* (3.37), on step 4's unmasked re-measure, pass.
   Records only.

## 2. How it works

### 2.1 `SheetCloseButton`

`WaterBuddy/SheetCloseButton.swift`, new, app-only — in no exception set. Rule `50-views`: a helper view
earns its own file when a second screen wants it; the paywall and the recap both do.

- `struct SheetCloseButton: View`, `let label: LocalizedStringKey` — the button's spoken name, resolved
  through `\.strings` (*Not now* on the paywall, *Done* on the recap, both existing keys).
- It reads `@Environment(\.dismiss)` and dismisses on tap; both callers did exactly that.
- `xmark` at `.system(size: size × glyph, weight: .semibold)`, white, in a `size × size` frame,
  `.liquidGlass(in: Circle(), density: .sheer, elevation: .resting, interactive: true)`,
  `.buttonStyle(PressStyle())` — today's button, with the recap's glyph sizing. `size` is 44 and `glyph`
  17/44, so at the default text size nothing moves: `.body` is 17 pt there.
- `PaywallView.closeButton`, `PaywallStyle.closeSize`, and `RecapSheet`'s inline button with its
  `closeSize` and `closeGlyph` are removed.

### 2.2 The watch's arithmetic

In `WaterBuddy/WristPlan.swift` (the phone app and both watch targets):

- `todaysTotal(from:now:calendar:)` counts a pour only when its amount is in `1...maximumDailyIntake` —
  the filter the phone's `DataManager.ingest(_:)` applies (`DataManager.swift:784`), so the wrist draws
  what the phone will apply — and sums with `addingReportingOverflow`, saturating at
  `DataManager.maximumDailyIntake`.
- `todaysTotal(mirror:outbox:now:calendar:)` clamps the mirror's `currentWater` to
  `0...maximumDailyIntake` — the phone's own clamp on the figure it sends — and adds the outbox's total
  the same saturating way.
- `Face.percentage` clamps the `Double` to `0...999` before converting, so a `Face` built from any
  `Int` is safe on its own.
- A private saturating helper in `WristPlan`: `DataManager.swift`'s are `fileprivate`.

In `WaterBuddyWatch/WristView.swift`: `syncedCaption` takes the age in whole minutes through
`Int(exactly:)`; an age no `Int` holds — a `composedAt` that cannot be a real sync — reads as *Not yet
synced*, as an absent one does. Everything else is unchanged: under a minute, including a small skew into
the future, is still *Synced just now*.

### 2.3 The patterns heading

`PatternsHeading` (`HistoryView.swift`) keeps its title and its `accessibilityValue`, and loses the drawn
`Text`. The key stays in the catalogue and in `LocalizationTests`' lists: it is still spoken. The DocC
says why the line is not drawn.

### 2.4 The recap tiles' fill

`RecapCard.tileFill`, the derived numbers, and `RecapCard.tileBase`, built from them — `static let`s in
`RecapCard.swift`; the recap is their only user, so `LiquidGlassModifier.swift`, compiled into three
other targets, is untouched:
`LiquidGlass.Base.flat(translucent: <tileFill>, opaque: LiquidGlass.Base.archived.opaqueFill)`. The
opaque fill is `archived`'s, as a `.material` base's already is: Reduce Transparency keeps the product's
one slab colour, with no second literal.

**The derivation.** A `.flat` base is always drawn by the hand-made stack. In the dark scheme, a
`.sheer` pane on a non-`.material` base composites, under the sheen and the rim:

    out = w + (1 − w) · (1 − s) · (a · F + (1 − a) · B)

with `s` the black scrim's opacity (0.16, `LiquidGlass.scrim`'s non-material sheer value), `w` the white
tint's (0.05, `Density.sheer.tintOpacity(for: .dark)`), `B` the ground, and `F`, `a` the base's colour
and opacity. Apple's glass draws the same sheen and rim over itself (`litSurface`), so the two panes are
compared under it.

1. A throwaway probe in a scratch copy of the tree — never this one — draws `Aurora.gradient` full
   screen with two columns of `.flush` `.material(.ultraThinMaterial)` panes at five heights, 150 × 70 pt
   at `LiquidGlass.innerCornerRadius`: `.sheer` on the left (Apple's clear glass), `.frosted` on the right
   (the regular glass tinted `Aurora.top`) — on *iPhone 17*, iOS 27.0, dark. A second frame draws the
   same layout with no panes, so each pane's ground is read at the same pixels.
2. For each pane, the median colour of its interior at least 10 pt inside the rim, where the sheen's
   gradient is at its clear stop (`t` 0.50–0.60 along the light's diagonal), live and bare.
3. Each pane's colour is taken back through `w` and `s` to `X = a·F + (1 − a)·B`; one `F` and one `a`
   are fitted across the five grounds by least squares, per channel with one shared `a`.
4. **Accepted only if** every pane's fitted composite is within ΔE₂₀₀₀ 2 of the live glass, with `F` and
   `a` inside `0...1`. Otherwise the work stops and the residuals go to the owner.
5. The fill drawn through the real hand-made stack in the probe and compared with the live glass at the
   same pixels; the card rendered with it; the tiles' pairs — the figure and the label — measured in
   English and Russian as *The recap, measured* measured them; the image sent to the owner.

**What it found** (2026-10-24, frames in the session's scratchpad):

| | Fill: opacity · colour (sRGB) | Worst ΔE₂₀₀₀, fitted | Drawn |
|---|---|---|---|
| (A) `.sheer`, clear glass, unconstrained | −0.313 · (−0.25, −0.24, −0.26) | 0.20 | not drawable |
| (A) held to `0...1` | 0.569 · (0.488, 0.324, 1.000) | 3.34 | 3.34 |
| **(B) `.frosted`, tinted glass** | **0.4856 · (0.0287, 0.1761, 0.8521)** | **0.26** | **0.29** |

Clear glass lightens every ground by about the same amount; the hand-made stack's black scrim darkens in
proportion to the ground, and no fill in range undoes the one and gives the other — (A) fails step 4.
(B) passes it, and the drawn panes agree with the fit, so the stack blends as the formula says. The
owner chose (B) from the three cards drawn side by side.

## 3. Tests, written first and seen RED

- **`SheetCloseButtonTests`** (new, `@MainActor`): `theGlyphDoesNotGrowWithTheTextSize` renders the
  button through `ImageRenderer` at `.large` and at `.accessibility5` and expects the two PNGs equal.
  RED: the paywall's `.body` glyph moved into the new file unchanged; GREEN with the ratio.
- **`WristSyncTests`**, beside the existing `WristPlan` tests: a corrupt outbox
  (`[Int.max, 0, -250, 250]`) counts 250; three pours of 50 000 count 100 000; a mirror at `Int.max`
  with a pour of 250 counts 100 000, and one below zero counts the pour alone; `Face(total: .max,
  goal: 1).percentage` is 999 and `Face(total: .min, goal: 1)`'s is 0. RED: the process traps, run alone
  with `-only-testing`.
- **`WristViewLogicTests`** (watch): a sync time 10³⁰⁰ seconds before or after now reads *Not yet
  synced*. RED: the process traps.
- **The recap's fill**: `theTilesFillGivesBackTheAppsOwnGlass` composites `RecapCard.tileFill` through
  the stack's own scrim and tint — read from `LiquidGlass.scrim` and `Density.tintOpacity`, not typed —
  over the two ends of the measured gradient, and expects the live glass read there, within 2 of 255 per
  channel. A retuned fill fails it, and so does a change to the stack the derivation rests on. RED: the
  fill first set to `archived`'s own (white 0.24 at 0.5), which gives grey, not the glass.
- **The patterns line**: no test. The page needs seven days of water in a month, which no UI test seeds;
  a screenshot of the page in the scratch copy proves the line gone, and the heading's spoken value is
  unchanged code.

## 4. Records

`docs/DESIGN.md`: *The patterns, measured* — the line's row retired, the title's floor 3 with the
unmasked 3.14; *Insights, measured* — the heading's floor 3; *The recap, measured* — the fill's
derivation and the tiles' new readings. `docs/AI_CONTEXT.md`: #154, #171, #177, #182 and #183 retired by
notes; *Files on disk*; *Targets*. `CLAUDE.md`'s warning trail. `HISTORY.md`, `tasks/lessons.md`.

## 5. The rules, proposed

Typed into `.claude/rules/` and left unstaged for the owner:

- **`60-design-system`**, *Colour*: the permitted literals outside `Aurora` gain `RecapCard.tileBase`.
  *Glass*: the recap's tiles take `RecapCard.tileBase`, derived from Apple's glass as the app tints it —
  no longer "`base: .archived` — the one use of the widget's base in the app".
- **`65-accessibility`**, *Contrast*: a heading of `.title3` bold or larger on the aurora is large text,
  held to 3 (the owner's ruling on #177).

## 6. Not in scope

#186's minors; the paywall's colour pairs on 26.5 and 18.6 (#165); #95's clean-ground question, which the
#177 ruling leaves unmeasured; the drafts in Russian and Uzbek; anything on a device.
