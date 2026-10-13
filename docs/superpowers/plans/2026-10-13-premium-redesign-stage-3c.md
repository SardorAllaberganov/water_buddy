# The Premium Redesign, Stage 3c (The Look) — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: `superpowers:executing-plans`, **in this session** —
> `CLAUDE.md` allows no implementation subagent ("Planning, test authorship, implementation and review
> all happen in the main loop"). Steps use checkbox (`- [ ]`) syntax for tracking. **No step commits:**
> each task ends by staging its paths, and nothing is committed until the owner runs `/commit`.

**Goal:** The glass, the vessel, the week card and a serving's glyph look like the approved canvas —
Apple's glass tinted with the sky's blue and lit at its edge, the hand-made pane below iOS 26 blue
and back above its contrast floors, the vessel's glow, halo and highlight, the week's tracks with a
dashed goal line and a travelling ring and disc, and a white glyph on a cyan wash — with every
measured pair at or above its floor.

**Architecture:** The glass decisions become values and one pure function on `LiquidGlass`
(`systemTintColor`, `systemTintOpacity(for:)`, `scrim(density:scheme:base:onPhone:)`, new `Selection`
tokens, `innerCornerRadius`), pinned by tests off the main actor; `LiquidGlassModifier` draws from
them and gains the lit surface on Apple's glass. The vessel, the week card and the row's glyph are
view changes in `HomeView.swift` and `HistoryView.swift`, proven by rendering and measuring.

**Tech Stack:** Swift (language mode 5; the app target defaults to main-actor isolation), SwiftUI
(iOS 17 floor; Apple's glass on iOS 26 and later through `.liquidGlass`), swift-testing, XCTest (the UI
suite and one throwaway probe), Xcode 27.0, Python 3 + Pillow for measuring (scratch only).

**Spec:** `docs/superpowers/specs/2026-10-13-the-look-design.md`, approved by the owner on 2026-10-13
("ok"). **Ledger:** `.superpowers/sdd/2026-10-13-premium-redesign-stage-3c/progress.md` (git-ignored) —
the probe's method, tables and every run, the canvas values with their source, the spec reader's
report. **Canvas:** the artifact reads "not found"; its boards are copied in session `4ac349e8`'s
scratchpad (ledger, *Read this first*).

**Authority for running it:** the spec's approval, on top of the owner's 2026-10-09 ruling "build the
remaining stages straight through … stopping only at each stage's `/commit` or a real design
decision". This plan is executed without a second approval.

## Global Constraints

- iOS floor **17.0**, watchOS floor **26.0**; Apple's glass only inside `#if os(iOS)` +
  `if #available(iOS 26.0, *)`, as today.
- **Tint:** `Aurora.top` at **`0.64`** for the regular variant, `0` for the clear one; it may only rise,
  and only to a rendered rung.
- **Hand-made scrim, phone, `.material` base, iOS, Dark Mode:** `Aurora.top` — frosted **0.70**; sheer
  and opaque set in Task 6 by measurement, starting at **0.40** and **0.80**; opaque under 1. **Widget
  (`.archived`) and watch:** black, **0.16 / 0.28 / 0.40**, unchanged. Light Mode: 0.
- **Week card text:** weekday letters **full white** (the shown one `Aurora.top`, heavy); labels
  **0.9** (unchanged); disclosure **0.88**.
- **Canvas values (ledger):** tracks white **0.10**, corner radius **12**; ring white **0.8**, **1.5 pt**;
  goal line **1.5 pt**, white **0.62**; row inset 16 + bar inset 4 = 8 pt gaps, 20 pt from the card; disc
  **0.28 × barHeight**; vessel glow 0.76 × 0.21 d, `Aurora.cyan` 0.36, blur 0.033 d; halo white 0.05,
  0.033 d wide; highlight 0.427 × 0.207 d at (0.10, 0.067) d, −28°, white 0.4.
- **Glyph:** white on `Aurora.cyan` at **0.16**.
- Every colour from `Aurora` (rule `60-design-system`); `WaterSurface.swift` is not touched.
- Contrast floors: **4.5:1** text, **3:1** glyph / rim / rule. Clean ground is the floor; the
  beside-the-glyphs reading is recorded (#95).
- Tests first: write, run, **see RED**, implement, run GREEN (rule `85-testing`). Never narrow an
  assertion to pass.
- **No new warning** against a clean baseline of HEAD on this toolchain, per file and message.
- Edits with `Edit`/`Write` only — no `sed -i`, no heredoc into the tree, no script that writes the
  repository. Scratch work lives in the session scratchpad.
- Simulators: the *WaterBuddy …* devices; `uptime` before every run; boot, `bootstatus -b`, and shut
  down **by UDID** — never `simctl shutdown all`. `-parallel-testing-enabled NO` and
  `-collect-test-diagnostics never` on every test run; `xcodebuild` in the foreground.
- Never write the real `group.sardor.WaterBuddy` suite or `UserDefaults.standard`. Probe seeding runs
  only on *WaterBuddy Probe …* / *Fallback …* simulators.
- Never commit. Stage explicit paths; rule files stay unstaged for the owner's yes.

## Review Focus

1. **Reduce Transparency on:** the vessel draws no glow, halo or highlight; every pane is its opaque
   fill with its lit rim; no sheen anywhere. → rendered in Task 6 Step 9, on iOS 27.0 and 18.6.
2. **Increase Contrast on:** the rim's 1.4 boost now applies on Apple's glass too; nothing may get
   *less* legible. → rendered and the tightest pairs measured in Task 6 Step 9.
3. **The largest text size:** the week card's letters and their disc scale together (font 0.14, disc
   0.28 of the capped bar), so the shown letter stays inside its disc. → rendered at
   `UICTContentSizeCategoryAccessibilityXXXL` in Task 6 Step 10.
4. **The smallest phone (375 × 667):** seven tracks with 8 pt gaps still read as tracks and the ring
   and disc land on the shown day. → rendered on *WaterBuddy Small 26.5* in Task 6 Step 10.
5. **A pressed pane on Apple's glass:** the lit rim brightens with the press while Apple's own
   interactive glass reacts too — the two must read as one reaction. → seen in Task 6 Step 10 by
   pressing a disc and a serving row in a recording.

The widget and the watch keeping their exact panes is pinned by tests (`theWidgetKeepsItsBlackScrim`,
`theWatchKeepsItsBlackScrim`) and by building both in the gate.

## File structure

| File | Change |
|---|---|
| `WaterBuddy/LiquidGlassModifier.swift` | `systemTintColor`; `systemTintOpacity` 0.64; `scrim(density:scheme:base:onPhone:)` replacing `Density.scrimOpacity(for:)`; `runsOnPhone`; `Selection.ringOpacity`, `.ringWidth`, `.discFill`; `innerCornerRadius`; the modifier's lit surface on Apple's glass and its scrim from `scrim(…)`; DocC |
| `WaterBuddyTests/LiquidGlassTests.swift` | the moved tint floor; four new tests; one new solid-pair test |
| `WaterBuddy/HistoryView.swift` | `HistoryCard`: tracks, bars, dashed goal line, ring, disc, letters, disclosure; `ServingRow`: the wash and white glyph; two private helpers (`GoalLine`, `LetterCentres`) |
| `WaterBuddy/HomeView.swift` | `WaterVessel`: glow, halo, highlight |
| `.claude/rules/60-design-system.md`, `65-accessibility.md` | the spec's §8 wording — **unstaged** |
| `docs/DESIGN.md`, `docs/AI_CONTEXT.md`, `HISTORY.md`, `tasks/lessons.md` | records (Task 9) |

---

### Task 0: The ledger and the baseline

**Files:** the ledger only (git-ignored); scratch.

- [ ] **Step 1: Read this first.** Re-read the ledger's *Read this first* and *Log*, this plan's Global
  Constraints, and `git status --short`. Confirm the index holds only the three staged paths from
  before this stage (`Screenshots/en-US/ProductPageHeader/01-one-tap.png`,
  `Tools/ProductPageHeader.html`, `docs/ROADMAP.md`) — this stage stages beside them, and the
  `/commit` plan separates them.

- [ ] **Step 2: The warnings baseline of HEAD.** Export HEAD and build it clean:

```bash
SP=/private/tmp/claude-501/-Users-sardorallaberganov-Desktop-Projects-MobileApps-WaterBuddy/8d4c0d9d-fcdf-4db8-b306-de02687a857c/scratchpad
mkdir -p $SP/base-head && git archive HEAD | tar -x -C $SP/base-head
uptime
xcodebuild build-for-testing -project $SP/base-head/WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -derivedDataPath $SP/dd-base-head > $SP/out/base-head-app.log 2>&1; echo "exit $?"
xcodebuild build -project $SP/base-head/WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -derivedDataPath $SP/dd-base-head > $SP/out/base-head-widget.log 2>&1; echo "exit $?"
```

Expected: both `exit 0`. Then count unique warning lines per file and message:

```bash
grep -hE "warning:" $SP/out/base-head-app.log $SP/out/base-head-widget.log | sed -E 's#^.*/([^/]+\.swift):[0-9]+:[0-9]+: #\1: #' | sort -u > $SP/out/base-head-warnings.txt; wc -l < $SP/out/base-head-warnings.txt
```

Record the count and the file in the ledger. (The baseline is a clean `build-for-testing` plus a widget
`build` into the same folder — a plain `build` is not comparable; ledger memory of 2026-10-12.)

---

### Task 1: The glass's values and its scrim, pinned

**Files:**
- Modify: `WaterBuddy/LiquidGlassModifier.swift` (the `LiquidGlass` enum, `Density`, the modifier's
  `ownPane` and `handMadePane`, the type's DocC list)
- Test: `WaterBuddyTests/LiquidGlassTests.swift`

**Interfaces:**
- Produces: `LiquidGlass.systemTintColor: Color` (`nonisolated static let`);
  `LiquidGlass.systemTintOpacity(for: SystemVariant) -> Double` (regular `0.64`);
  `LiquidGlass.runsOnPhone: Bool` (`nonisolated static let`);
  `LiquidGlass.scrim(density: Density, scheme: ColorScheme, base: Base, onPhone: Bool) -> (color: Color, opacity: Double)`
  (`nonisolated static func`). `Density.scrimOpacity(for:)` is removed.

- [ ] **Step 1: Write the failing tests.** In `LiquidGlassRoutingTests`, move the floor and add the
  colour test:

```swift
    /// A floor, and a measured one: every lighter rung was rendered and failed or had no room.
    /// With `Aurora.top` as the tint, iOS 27.0, the rim and the sheen on: at `0.52` the weekday
    /// letters read 4.28 and at `0.56` 4.48, under 4.5; `0.60` passed with 0.14 to spare; `0.64`
    /// is the first rung with room (stage 3c's ledger; `docs/DESIGN.md`). A lighter glass is a new
    /// measurement first, and then this number.
    @Test func theTintIsNoLighterThanTheLightestRungThatPassed() {
        #expect(LiquidGlass.systemTintOpacity(for: .regular) >= 0.64)
    }

    /// The sky's own blue, not black: a black tint greys the aurora under the pane, and the canvas
    /// drew its panes navy (spec `2026-10-13-the-look-design.md` §3.1).
    @Test func theGlassIsTintedWithTheSkysOwnBlue() {
        #expect(LiquidGlass.systemTintColor == Aurora.top)
    }
```

  After `LiquidGlassRoutingTests`, add a new suite:

```swift
/// The hand-made stack's scrim: who gets the sky and who keeps black (spec
/// `2026-10-13-the-look-design.md` §3.2).
///
/// Not `@MainActor`, like the suites above: the answer is a value, decided without a view.
struct LiquidGlassScrimTests {

    /// Built per use: `Base` carries a `Material` and is not `Sendable` (rule `43-concurrency`).
    private var material: LiquidGlass.Base { .material(.ultraThinMaterial) }

    /// The black values every pane drew before stage 3c, and the widget and the watch still do.
    private func before(_ density: LiquidGlass.Density) -> Double {
        switch density {
        case .sheer: 0.16
        case .frosted: 0.28
        case .opaque: 0.40
        }
    }

    private let densities: [LiquidGlass.Density] = [.sheer, .frosted, .opaque]

    /// The phone's own panes below iOS 26: blue, darker than the black they replace — which left
    /// pairs under their floor on iOS 18.6 (#85) — and never a solid slab. Frosted is the value the
    /// probe swept on iOS 18.6.
    @Test func thePhonesOwnPanesAreScrimmedWithTheSky() {
        for density in densities {
            let scrim = LiquidGlass.scrim(density: density, scheme: .dark, base: material, onPhone: true)
            #expect(scrim.color == Aurora.top)
            #expect(scrim.opacity > before(density))
            #expect(scrim.opacity < 1)
        }
        #expect(LiquidGlass.scrim(density: .frosted, scheme: .dark, base: material, onPhone: true).opacity == 0.70)
    }

    /// The widget's archive cannot sample a backdrop and its fills were derived for the black scrim
    /// (`Base.archived`); the redesign keeps its glass as it is.
    @Test func theWidgetKeepsItsBlackScrim() {
        for density in densities {
            let scrim = LiquidGlass.scrim(density: density, scheme: .dark, base: .archived, onPhone: true)
            #expect(scrim.color == Color.black)
            #expect(scrim.opacity == before(density))
        }
    }

    /// The watch draws the hand-made stack on a `.material` base, and its look is its own stage's.
    @Test func theWatchKeepsItsBlackScrim() {
        for density in densities {
            let scrim = LiquidGlass.scrim(density: density, scheme: .dark, base: material, onPhone: false)
            #expect(scrim.color == Color.black)
            #expect(scrim.opacity == before(density))
        }
    }

    /// Light Mode has no scrim, on any pane — as before.
    @Test func lightModeHasNoScrim() {
        for density in densities {
            #expect(LiquidGlass.scrim(density: density, scheme: .light, base: material, onPhone: true).opacity == 0)
            #expect(LiquidGlass.scrim(density: density, scheme: .light, base: .archived, onPhone: true).opacity == 0)
        }
    }
}
```

- [ ] **Step 2: Run them and see RED.**

```bash
uptime
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/LiquidGlassRoutingTests -only-testing:WaterBuddyTests/LiquidGlassScrimTests -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | tail -25
```

Expected: build failure naming `systemTintColor` and `scrim(density:scheme:base:onPhone:)` — the
symbols do not exist. Record it in the ledger.

- [ ] **Step 3: Implement the values.** In `enum LiquidGlass`, replace `systemTintOpacity(for:)`'s DocC
  and body, and add the colour, the platform flag and the scrim function beside it:

```swift
    /// What Apple's regular glass is tinted with, through `Glass.tint(_:)`: the sky's own deep blue.
    ///
    /// Not black. A black tint greys the aurora under the pane, and the canvas drew its panes navy;
    /// stage 3c rendered both and the blue reads like the canvas (spec
    /// `2026-10-13-the-look-design.md` §3.1). It is lighter than black at the same strength — the
    /// weekday letters read 6.52 under black `0.52` and 4.74 under this — which is why the
    /// opacity below rose with it.
    nonisolated static let systemTintColor: Color = Aurora.top

    /// How much of ``systemTintColor`` Apple's glass is tinted with.
    ///
    /// **Measured, not chosen.** Climbed a rung at a time on iOS 27.0 — whose glass is the
    /// lightest — with the lit rim and sheen drawn over it, and followed through a minute of the
    /// aurora's swing: `0.52` and `0.56` left the weekday letters under 4.5:1, `0.60` passed with
    /// 0.14 to spare, and this is the first rung with room. iOS 26.5's glass is darker and passed
    /// with more. The tables are in `docs/DESIGN.md`, *The look, measured* — re-take them before
    /// moving the number, and never estimate one value from another.
    ///
    /// The clear variant takes none. It is the vessel: its readout has
    /// ``WaterReadabilityScrim``, and a tint would dull the water behind it.
    nonisolated static func systemTintOpacity(for variant: SystemVariant) -> Double {
        switch variant {
        case .regular: return 0.64
        case .clear: return 0
        }
    }

    /// Whether this binary is the phone's — the app or its widget extension — rather than the
    /// watch's. Resolved at compile time; ``scrim(density:scheme:base:onPhone:)`` takes it as a
    /// parameter so a test can ask the watch's question on a phone.
    nonisolated static let runsOnPhone: Bool = {
        #if os(iOS)
        true
        #else
        false
        #endif
    }()

    /// The dark layer under the hand-made stack's white tint, in Dark Mode only — the one place it
    /// is decided.
    ///
    /// This is the layer that makes dark glass work. White alone cannot hold back a vivid
    /// background at any opacity a dark UI can afford: too little and the colours punch straight
    /// through as a coloured film, too much and the pane turns into a light slab with nowhere for
    /// white text to go. The scrim attenuates first; the tint then only has to supply sheen.
    ///
    /// - **The phone's own panes** — a `.material` base on iOS, the hand-made path from iOS 17 to
    ///   25 — are scrimmed with the sky's blue, as Apple's glass is tinted with it, so the panes
    ///   read alike on every system. Darker than the black they replace: that black left the
    ///   week card's letters at 4.38:1 and its cyan bar at 2.97:1 on iOS 18.6 (#85). Frosted was
    ///   swept on iOS 18.6; sheer and opaque were measured in stage 3c's own pass
    ///   (`docs/DESIGN.md`, *The look, measured*). Opaque stays under 1, or the pane is a slab.
    /// - **The widget's `.archived` base and the watch** keep black at today's values: the archive's
    ///   fills were derived for it (``Base/archived``), and the watch's look is its own stage's.
    nonisolated static func scrim(
        density: Density,
        scheme: ColorScheme,
        base: Base,
        onPhone: Bool
    ) -> (color: Color, opacity: Double) {
        guard scheme == .dark else { return (.black, 0) }

        if onPhone, case .material = base {
            let opacity: Double = switch density {
            case .sheer:   0.40
            case .frosted: 0.70
            case .opaque:  0.80
            }
            return (Aurora.top, opacity)
        }

        let opacity: Double = switch density {
        case .sheer:   0.16
        case .frosted: 0.28
        case .opaque:  0.40
        }
        return (.black, opacity)
    }
```

  In `enum Density`, delete `scrimOpacity(for:)` and its DocC (the rationale moved to `scrim(…)`
  above). In `LiquidGlassModifier`'s type DocC, change item 2 of the list to:

```swift
///   2. A scrim, in Dark Mode only — see ``LiquidGlass/scrim(density:scheme:base:onPhone:)``.
```

  and change the first bullet's last sentence (*"`tint`, `elevation`, the border and the highlight
  below describe the hand-made stack, and Apple's glass takes none of them."*) to:

```swift
///   draws the pane and its depth; this file lays the stack's sheen and lit rim over it, under the
///   content (``litSurface``). `tint`, `elevation` and the scrim describe the hand-made stack, and
///   Apple's glass takes none of them.
```

- [ ] **Step 4: Draw from them.** In `LiquidGlassModifier`, `systemGlass` tints with the colour:

```swift
        // `nil` rather than a clear colour: no tint at all is what the vessel is meant to get.
        let tinted = glass.tint(darkening > 0 ? LiquidGlass.systemTintColor.opacity(darkening) : nil)
```

  `ownPane` draws the lit surface where Apple's glass is drawn:

```swift
    /// What this file draws behind the content: the opaque pane, the hand-made stack, or — where
    /// the system is drawing its own glass — the stack's sheen and lit rim over it.
    @ViewBuilder
    private func ownPane(systemGlassDrawn: Bool) -> some View {
        switch rendering {
        case .opaque: opaquePane
        case .handMade: handMadePane
        case .system:
            if systemGlassDrawn { litSurface } else { handMadePane }
        }
    }

    /// The hand-made stack's sheen and lit rim, laid over Apple's glass and under the content.
    ///
    /// The canvas's panes have a bright edge, and Apple's tinted glass alone reads flat beside them
    /// (stage 3c). The same two gradients the hand-made stack draws, with the same Increase
    /// Contrast and press boosts — nothing else of the stack: the scrim, the tint ceiling and the
    /// shadows stay its own.
    private var litSurface: some View {
        shape
            .fill(specular)
            .overlay { shape.strokeBorder(edge, lineWidth: borderWidth) }
    }
```

  `handMadePane` takes its scrim from the function:

```swift
    private var handMadePane: some View {
        let scrim = LiquidGlass.scrim(density: density, scheme: colorScheme, base: base, onPhone: LiquidGlass.runsOnPhone)

        return baseLayer
            .overlay { shape.fill(scrim.color.opacity(scrim.opacity)) }
            .overlay { shape.fill(tint.opacity(resolvedTintOpacity)) }
            .overlay { shape.fill(specular) }
            .overlay { shape.strokeBorder(edge, lineWidth: borderWidth) }
            .compositingGroup()
            .modifier(Shadows(elevation: elevation, colorScheme: colorScheme))
    }
```

- [ ] **Step 5: Run GREEN**, the same command as Step 2. Expected: `✔ Test run with N tests in 2
  suites passed` (N = the two suites' count, read from the output). Then the whole unit target:

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Test run with|failed|error:" | tail -5
```

- [ ] **Step 6: Build both widgets** (the file is compiled into the widget and both watch targets):

```bash
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' 2>&1 | tail -2
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' 2>&1 | tail -2
```

  Expected: `** BUILD SUCCEEDED **` twice.

- [ ] **Step 7: Stage** `WaterBuddy/LiquidGlassModifier.swift` and `WaterBuddyTests/LiquidGlassTests.swift`
  with `git add <paths>`. Log in the ledger.

---

### Task 2: The selection and corner tokens, and the shown letter's pair

**Files:**
- Modify: `WaterBuddy/LiquidGlassModifier.swift` (`LiquidGlass.Selection`, a new `innerCornerRadius`)
- Test: `WaterBuddyTests/LiquidGlassTests.swift` (`PrimarySurfaceTests`)

**Interfaces:**
- Produces: `LiquidGlass.Selection.ringOpacity: Double` (0.8), `.ringWidth: CGFloat` (1.5),
  `.discFill: Color` (white) — all `nonisolated static let`; `LiquidGlass.innerCornerRadius: CGFloat`
  (12, `nonisolated static let`).

- [ ] **Step 1: Write the failing test** at the end of `PrimarySurfaceTests`, and add one line to the
  suite's DocC (*"The **solid** pairs: the primary surface, and since stage 3c the week card's shown
  letter on its disc."*):

```swift
    /// The week card's shown letter: `Aurora.top` on the white disc behind it. Both fills are solid,
    /// so the pair is derived, not measured — about 13:1.
    @Test func theShownDaysLetterReadsOnItsDisc() {
        let inkColour = Aurora.top.resolve(in: EnvironmentValues())
        let discColour = LiquidGlass.Selection.discFill.resolve(in: EnvironmentValues())
        let ink = luminance([inkColour.linearRed, inkColour.linearGreen, inkColour.linearBlue].map(Double.init))
        let disc = luminance([discColour.linearRed, discColour.linearGreen, discColour.linearBlue].map(Double.init))

        let ratio = (max(ink, disc) + 0.05) / (min(ink, disc) + 0.05)

        #expect(ratio >= 7)
    }
```

- [ ] **Step 2: Run and see RED:**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/PrimarySurfaceTests -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | tail -15
```

  Expected: build failure naming `discFill`.

- [ ] **Step 3: Implement.** In `enum Selection`, update its DocC first paragraph to *"How a selected
  slot is marked: the tab bar's active tab, the sheet's shortcuts — a fill and a lit rim — and the
  week card's shown day — a ring on its track and a disc behind its letter."* and add:

```swift
        /// The ring round the week card's shown track. The canvas's own value; a non-text mark, so
        /// its floor is 3:1 against the pane beside it (`docs/DESIGN.md`, *The look, measured*).
        nonisolated static let ringOpacity = 0.8

        /// The ring's width, the canvas's 1.5 pt.
        nonisolated static let ringWidth: CGFloat = 1.5

        /// The disc behind the shown day's letter, which is drawn in `Aurora.top` on it —
        /// `theShownDaysLetterReadsOnItsDisc` derives that pair.
        nonisolated static let discFill = Color.white
```

  Beside `cornerRadius` in `enum LiquidGlass`:

```swift
    /// A rounded element inside a pane — the week card's tracks and bars. The canvas's 12 on a
    /// track about 43 pt wide; a pane's own radius would round a track into a capsule.
    nonisolated static let innerCornerRadius: CGFloat = 12
```

- [ ] **Step 4: Run GREEN** (Step 2's command). Expected: `✔ … passed`.

- [ ] **Step 5: Stage** both paths.

---

### Task 3: The week card

**Files:**
- Modify: `WaterBuddy/HistoryView.swift` — `HistoryCard` (`barInset`, a new `rowInset`, `days`,
  `dayButton(for:)`, `bar(for:)`, `marker` → `ring` + `disc(over:)`, `goalLine`, the disclosure); two
  new private types at file scope, `GoalLine` and `LetterCentres`
- Test: existing `WaterBuddyTests/HistoryViewTests.swift` (`markerOffset`) and the UI tests that select
  days (`GoalSetupUITests`)

**Interfaces:**
- Consumes: `LiquidGlass.innerCornerRadius`, `Selection.ringOpacity`, `.ringWidth`, `.discFill` (Task 2);
  `HistoryView.markerOffset(ofDay:among:across:)` (unchanged); `Motion.land`.

- [ ] **Step 1: The insets.** Replace `barInset`'s declaration and DocC, and add `rowInset`:

```swift
    /// How far each bar sits in from the sides of its day's slot: 8 pt between neighbouring tracks,
    /// the canvas's gap.
    private let barInset: CGFloat = 4

    /// The row of days stands this far in from the card, so the outer tracks are 20 pt from its
    /// edge — the canvas's padding.
    private let rowInset: CGFloat = 16
```

- [ ] **Step 2: The track and the bar.** In `bar(for:)`, both `Capsule()`s become the inner rounded
  rectangle, the track at the canvas's white 0.10:

```swift
        let shape = RoundedRectangle(cornerRadius: LiquidGlass.innerCornerRadius, style: .continuous)

        return ZStack(alignment: .bottom) {
            // The canvas's track: the day's whole height, faint, so a short bar reads as a short
            // day and not as a short slot.
            shape
                .fill(.white.opacity(0.10))
```

  and the bar's `Capsule()` becomes `shape` (its comment and fill unchanged).

- [ ] **Step 3: The letters.** In `dayButton(for:)`, the weekday `Text` becomes:

```swift
                Text(day.date, format: .dateTime.weekday(.narrow))
                    // A **ratio** of the bar it annotates, never its own text style … (comment kept)
                    .font(.system(size: barHeight * 0.14, weight: isShown ? .heavy : .semibold))
                    // Full white, as the canvas drew them; the shown day's in `Aurora.top` on its
                    // white disc (``disc(over:)``), heavier than the rest — never colour alone
                    // (rule `65-accessibility`). Measured on stage 3c's panes in `docs/DESIGN.md`,
                    // *The look, measured*; the shown pair is derived by
                    // `theShownDaysLetterReadsOnItsDisc`.
                    .foregroundStyle(isShown ? Aurora.top : Color.white)
                    .lineLimit(1)
                    .anchorPreference(key: LetterCentres.self, value: .center) { [day.dayOrdinal: $0] }
```

  (Keep the existing "A ratio of the bar…" comment above `.font`; replace the 0.72 comment with the
  one shown.)

- [ ] **Step 4: The row.** In `days`, the modifiers after `.fixedSize(horizontal: false, vertical: true)`
  become:

```swift
        .backgroundPreferenceValue(LetterCentres.self) { centres in disc(over: centres) }
        .overlay(alignment: .top) { goalLine }
        .overlay { ring }
        .padding(.horizontal, rowInset)
```

  followed by the three `.animation` lines as they are.

- [ ] **Step 5: The ring and the disc.** Replace `marker` and its DocC with:

```swift
    /// The shown day's ring: one, round its track, moved to the day that is shown.
    ///
    /// The canvas's selection, with stage 3b's travel kept: it is always there — at zero opacity
    /// when no day in the window is shown — so what animates is a place and not a layer
    /// (rule `50-views`), and it lands (``Motion/land``). Drawn over the row, so it lies on the
    /// track rather than under it.
    private var ring: some View {
        GeometryReader { proxy in
            let count = manager.history.count
            let index = manager.history.firstIndex { $0.dayOrdinal == shown }
            let slot = proxy.size.width / CGFloat(max(count, 1))

            RoundedRectangle(cornerRadius: LiquidGlass.innerCornerRadius, style: .continuous)
                .strokeBorder(
                    .white.opacity(index == nil ? 0 : LiquidGlass.Selection.ringOpacity),
                    lineWidth: LiquidGlass.Selection.ringWidth
                )
                .frame(width: max(slot - barInset * 2, 0), height: barHeight)
                .offset(
                    x: HistoryView.markerOffset(ofDay: index ?? 0, among: count, across: proxy.size.width) + barInset,
                    y: slotPadding
                )
                .animation(Motion.land, value: index)
        }
        .allowsHitTesting(false)
    }

    /// The white disc behind the shown day's letter, placed on the letter itself.
    ///
    /// Centred from the letter's own anchor rather than computed from the slot: a line of text has
    /// no height the layout states, and a disc a point off its letter reads as a mistake. Twice
    /// the letter's size, as the canvas's 26 pt disc is to its 13 pt letter, so the two scale
    /// together with the capped bar at every text size. Present at zero opacity when no day in
    /// the window is shown; travels with ``Motion/land``.
    private func disc(over centres: [Int: Anchor<CGPoint>]) -> some View {
        GeometryReader { proxy in
            let shownCentre = shown.flatMap { centres[$0] }
            let restingCentre = manager.history.first.flatMap { centres[$0.dayOrdinal] }
            let centre = (shownCentre ?? restingCentre).map { proxy[$0] } ?? .zero
            let size = barHeight * 0.28

            Circle()
                .fill(LiquidGlass.Selection.discFill.opacity(shownCentre == nil ? 0 : 1))
                .frame(width: size, height: size)
                .position(centre)
                .animation(Motion.land, value: shown)
        }
        .allowsHitTesting(false)
    }
```

- [ ] **Step 6: The goal line.** Replace `goalLine`'s body:

```swift
    private var goalLine: some View {
        GoalLine()
            // The canvas's dashed rule, 1.5 pt at white 0.62. A rule has a 3:1 floor: 3.68:1 at
            // its worst frame on iOS 27.0 at the tint, 3.71:1 on iOS 18.6's pane (`docs/DESIGN.md`,
            // *The look, measured*). The canvas says only "dashed"; 4.5 on 3 is ours.
            .stroke(.white.opacity(0.62), style: StrokeStyle(lineWidth: 1.5, dash: [4.5, 3]))
            .frame(height: 1.5)
            .padding(.horizontal, barInset)
            .offset(y: slotPadding + barHeight * (1 - min(Double(manager.dailyGoal) / Double(scale), 1)))
            .allowsHitTesting(false)
    }
```

  (Keep its DocC line, "One line across all seven bars at the goal's height…".)

- [ ] **Step 7: The disclosure.** In `body`, `.foregroundStyle(.white.opacity(0.70))` under *Measured
  against your current goal* becomes `0.88`, and its comment becomes:

```swift
                // 0.88, the canvas's own value (stage 3c). It was 0.70, and 0.55 before that: on the
                // hand-made pane white 0.55 read 4.06:1. Measured on stage 3c's panes in
                // `docs/DESIGN.md`, *The look, measured*.
```

- [ ] **Step 8: The two helpers**, at file scope near the other private types of the file:

```swift
/// A horizontal rule through the middle of its frame, for the week card's dashed goal line.
private struct GoalLine: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }
    }
}

/// Where each day's letter stands in the week card, keyed by its day ordinal — so the shown day's
/// disc is centred on the letter it sits behind, wherever the layout put it.
private struct LetterCentres: PreferenceKey {

    static let defaultValue: [Int: Anchor<CGPoint>] = [:]

    static func reduce(value: inout [Int: Anchor<CGPoint>], nextValue: () -> [Int: Anchor<CGPoint>]) {
        value.merge(nextValue()) { _, later in later }
    }
}
```

  (`PourPlaces` in `PourDrop.swift` is the precedent for the shape of this key.)

- [ ] **Step 9: Build, then the tests that touch the card:**

```bash
uptime
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/HistoryViewTests -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Test run with|failed|error:|warning:.*HistoryView" | tail -8
```

  Expected: `✔ … passed`, no warning naming `HistoryView.swift` beyond the baseline's. Then the UI tests
  that select days, on *WaterBuddy Gate 27* (boot it first by UDID):

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' -only-testing:WaterBuddyUITests/GoalSetupUITests/testTheWeekCardIsOneSummaryAndOneButtonPerDay -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Executed|error" | tail -3
```

  Expected: `Executed 1 test, with 0 failures`.

- [ ] **Step 10: Stage** `WaterBuddy/HistoryView.swift`.

---

### Task 4: A serving's glyph

**Files:** Modify `WaterBuddy/HistoryView.swift` — `ServingRow`'s glyph.

- [ ] **Step 1:** Replace the glyph's `.foregroundStyle(Aurora.cyan)` and the dark well:

```swift
                    // White on the canvas's cyan wash. The canvas's glyph was cyan, and a cyan
                    // glyph on a cyan wash read 2.46–2.79:1 against the 3:1 floor for a non-text
                    // mark at every wash tried — the wash lightens its own ground, and the sheen
                    // lands on the row's top left, where the glyph sits. White on the 0.16 wash
                    // read 4.42–5.30 swept (`docs/DESIGN.md`, *The look, measured*). The canvas's
                    // wash is not an `Aurora` colour; `Aurora.cyan` stands in.
                    .foregroundStyle(.white)
                    .frame(width: disc, height: disc)
                    .background(Circle().fill(Aurora.cyan.opacity(0.16)))
```

- [ ] **Step 2:** Build with the `HistoryViewTests` command of Task 3 Step 9; expected as there.
- [ ] **Step 3: Stage** `WaterBuddy/HistoryView.swift`.

---

### Task 5: The vessel

**Files:** Modify `WaterBuddy/HomeView.swift` — `WaterVessel`.

- [ ] **Step 1: The environment and the layers.** Add under `reduceMotion`:

```swift
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
```

  and make `body`:

```swift
    var body: some View {
        ZStack {
            water
            readabilityScrim
            // Above the scrim, under the readout, so the readout keeps both (rule
            // `60-design-system`, *Water*). Glass decoration: gone under Reduce Transparency.
            if !reduceTransparency { highlight }
            readout
        }
        .frame(width: diameter, height: diameter)
        .liquidGlass(in: Circle(), density: .sheer, elevation: .floating)
        .background {
            if !reduceTransparency { depth }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Today's hydration", bundle: strings))
        .accessibilityValue(String(format: strings.localizedString(forKey: "%1$d percent. %2$d of %3$d millilitres.", value: nil, table: nil), percentage, volume, goal))
    }
```

- [ ] **Step 2: The canvas's depth.** Add a `// MARK: Depth` section after `// MARK: Readout`'s members:

```swift
    // MARK: Depth

    /// The canvas's vessel, a 300 pt board (`Main.dc.html`), turned into ratios of the diameter: a
    /// glow beneath it — `rgba(0,200,255,.36)`, not an `Aurora` colour, so `Aurora.cyan` stands in —
    /// 36 pt in from each side, 64 pt tall, 30 pt below the foot, blurred 10; a halo, a 10 pt ring of
    /// white at 0.05 just outside the rim; and a highlight, 128 × 62 pt at (30, 20), turned −28°.
    private enum Depth {
        static let glowWidth = 0.76
        static let glowHeight = 0.21
        static let glowOpacity = 0.36
        static let glowBlur = 0.033
        static let haloWidth = 0.033
        static let haloOpacity = 0.05
        static let highlightSize = CGSize(width: 0.427, height: 0.207)
        static let highlightOrigin = CGPoint(x: 0.10, y: 0.067)
        static let highlightAngle = -28.0
        static let highlightOpacity = 0.4
    }

    /// The glow beneath and the halo, behind the glass.
    private var depth: some View {
        ZStack {
            Ellipse()
                .fill(RadialGradient(
                    colors: [Aurora.cyan.opacity(Depth.glowOpacity), Aurora.cyan.opacity(0)],
                    center: .center,
                    startRadius: 0,
                    endRadius: diameter * Depth.glowWidth / 2
                ))
                .frame(width: diameter * Depth.glowWidth, height: diameter * Depth.glowHeight)
                .blur(radius: diameter * Depth.glowBlur)
                // The canvas's glow is centred just above the vessel's foot.
                .offset(y: diameter * 0.5)

            Circle()
                .strokeBorder(.white.opacity(Depth.haloOpacity), lineWidth: diameter * Depth.haloWidth)
                .frame(width: diameter * (1 + 2 * Depth.haloWidth), height: diameter * (1 + 2 * Depth.haloWidth))
        }
        .allowsHitTesting(false)
    }

    /// The light on the glass, top left.
    private var highlight: some View {
        Ellipse()
            .fill(RadialGradient(
                colors: [.white.opacity(Depth.highlightOpacity), .white.opacity(0)],
                center: UnitPoint(x: 0.4, y: 0.4),
                startRadius: 0,
                endRadius: diameter * Depth.highlightSize.width * 0.35
            ))
            .frame(width: diameter * Depth.highlightSize.width, height: diameter * Depth.highlightSize.height)
            .rotationEffect(.degrees(Depth.highlightAngle))
            .position(
                x: diameter * (Depth.highlightOrigin.x + Depth.highlightSize.width / 2),
                y: diameter * (Depth.highlightOrigin.y + Depth.highlightSize.height / 2)
            )
            .allowsHitTesting(false)
    }
```

- [ ] **Step 3: Build and the Home tests:**

```bash
uptime
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/HomeServingTests -only-testing:WaterBuddyTests/HomeLayoutTests -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Test run with|failed|error:|warning:.*HomeView" | tail -8
```

  Expected: `✔ … passed`, no warning naming `HomeView.swift` beyond the baseline's.
  (`WaterBuddyTests/HomeViewTests.swift` holds the two suites, `HomeServingTests` and `HomeLayoutTests`.)

- [ ] **Step 4: Stage** `WaterBuddy/HomeView.swift`.

---

### Task 6: On the simulator — render, measure, fix the values

**Files:** scratch only, except the value moves in Steps 6–8, which edit
`WaterBuddy/LiquidGlassModifier.swift` and `WaterBuddyTests/LiquidGlassTests.swift`.

- [ ] **Step 1: A probe build of the working tree.** Copy the tree — not the index; this stage is
  staged and later edits may not be — into the scratchpad, and add the probe there:

```bash
SP=/private/tmp/claude-501/-Users-sardorallaberganov-Desktop-Projects-MobileApps-WaterBuddy/8d4c0d9d-fcdf-4db8-b306-de02687a857c/scratchpad
rsync -a --exclude .git --exclude .superpowers --exclude Screenshots ./ $SP/s3c-build/
```

  Then, with `Write`/`Edit` in `$SP/s3c-build` only: copy `$SP/s3c/WaterBuddyUITests/ZZLookProbe.swift`
  in; add the `WB_SEED` block from `$SP/s3c/WaterBuddy/WaterBuddyApp.swift` (with two variants —
  `WB_SEED=empty` deletes every log and adds none, for History's empty state; `WB_FIRSTRUN=1` makes
  `RootView` show `GoalSetupView`); and in `LiquidGlass`, let `WB_TINT`, `WB_SHEER`, `WB_OPAQUE`
  override the tint and the phone's sheer and opaque scrim when set. Extend `ZZLookProbe.testWalk`
  to capture, each `WB_COUNT` times every `WB_GAP` seconds: Home at rest; Home just after a Cup
  pour (the *Undo* pane, opaque); History at rest and scrolled to the rows; the serving sheet
  (tap `+`); Settings at the top and scrolled to the end. Build it into `$SP/dd-s3c-build`
  (`build-for-testing`, as Task 0).

- [ ] **Step 2: The measured set**, placed with `tools/pairs.py`'s annotated copies on each layout
  (iPhone 17 1206 px; iPhone 16 1178 px — its own `…@186` keys), every rectangle checked by eye. Text
  at its own opacity against 4.5; marks against 3:
  - **Home:** the streak chip's number and flame; the Cup and Bottle discs' glyphs; *Undo*'s line,
    its word and its glyph; the vessel's percentage and millilitre line over water at 65 % (now under
    the highlight's edge); below iOS 26, the tab bar's inactive caption, the lozenge's rim, glyph and
    caption.
  - **History:** the `+` glyph; the week card's title, the six letters, *Average* / *Best day* /
    *Goal met*, the three figures, the disclosure, the goal dashes over track and pane, the ring
    against the pane, the cyan bar and the white bar against their tracks; the strip's title, its
    hour labels and its cyan bars against the pane; each row's amount, name, time and white glyph on
    its wash, rows 1 and 5 (5 lies over the magenta lobe).
  - **Empty History:** the card's title and body.
  - **The sheet:** *ml*, *Cancel*, the shortcuts' names and amounts, the selected shortcut's rim.
  - **Settings:** the goal title and figure, the range labels, the vessels' names, readouts and
    glyphs, the note, the reminders title and description, the language footnote — top and end.
  - **First run:** *ml* and the range labels.

  Record the set and its count in the ledger. Where a pair in `docs/DESIGN.md`'s tables no longer
  exists on screen, say so there.

- [ ] **Step 3: iOS 27.0, *WaterBuddy Probe 27*, a minute's sweep** at the built tint
  (`WB_COUNT=20 WB_GAP=3`, seeded), then `WB_SEED=empty` and `WB_FIRSTRUN=1` at rest. Tabulate with
  `tools/table.py`. **If any pair is under its floor:** render the next rung (`WB_TINT=0.68`, then
  `0.72`), sweep it, and go to Step 6 with the first rung where nothing is under.

- [ ] **Step 4: iOS 26.5, *WaterBuddy Probe 26.5*,** the same sweep at the rung Step 3 settled.

- [ ] **Step 5: iOS 18.6, *WaterBuddy Fallback 18.6*:** sweep at the built scrim; then the sheer and
  opaque rungs — sheer `0.30`, `0.40`, `0.50`; opaque `0.60`, `0.70`, `0.80` — at rest on the panes
  that carry them (sheer: Home's discs, the vessel's glass, the tab bar below iOS 26 if `.sheer`;
  opaque: *Undo*), then the chosen pair swept. **Each density's value is the lightest rung where
  nothing is under, with room** (the tightest pair at least 0.15 over its floor); opaque stays under 1.

- [ ] **Step 6: Move the values, tests first.** If Step 3 raised the tint: change
  `theTintIsNoLighterThanTheLightestRungThatPassed` to the new rung, run it RED, change
  `systemTintOpacity`'s `.regular` and its DocC, run GREEN. If Step 5 settled sheer or opaque on
  values other than 0.40 / 0.80: add `#expect`s for them to `thePhonesOwnPanesAreScrimmedWithTheSky`,
  run RED, change `scrim(…)`, run GREEN. Commands as Task 1 Steps 2 and 5.

- [ ] **Step 7: Re-render once on the final values** on all three systems (rest, then one sweep on
  27.0), so every figure recorded is of the code as staged.

- [ ] **Step 8:** If any value moved, re-run Task 1 Step 5 and Step 6 (the whole unit target, both
  widget builds), and re-stage the two files.

- [ ] **Step 9: Accessibility settings.** On *Probe 27*: `xcrun simctl ui <udid> increase_contrast
  enabled`, render all screens, measure the tightest five pairs, then `disabled`. Reduce Transparency,
  through the Settings app by a throwaway UI test (Accessibility → Display & Text Size → Reduce
  Transparency), on 27.0 and 18.6: render Home and History; confirm no glow, halo, highlight or sheen,
  every pane its opaque fill with its rim; switch it off again the same way.

- [ ] **Step 10: The review focus.** On *WaterBuddy Small 26.5*: History at the ordinary size and at
  `UICTContentSizeCategoryAccessibilityXXXL` (as a launch-environment variant, never an argument) —
  the shown letter inside its disc, the ring on its track. On *Probe 27*: a recording
  (`xcrun simctl io <udid> recordVideo` in the background of the same command as the test, ended
  with `kill -INT`) of pressing the Cup disc and a serving row; frames out through a short `swift`
  script over `AVAssetImageGenerator`; the rim brightens with Apple's press and nothing doubles.

- [ ] **Step 11: For the owner,** side-by-side sheets (`tools/sidebyside.py`): the canvas's Home and
  History boards beside the build on 27.0, 26.5 and 18.6. Shut every simulator down by UDID. Log all
  of it in the ledger, with every figure's frame count and device.

---

### Task 7: The rules — written, shown, left unstaged

**Files:** `.claude/rules/60-design-system.md`, `.claude/rules/65-accessibility.md`.

- [ ] **Step 1:** Apply the spec's §8 wording exactly — five changes in rule 60's *Glass*, one addition
  in rule 65's *Reduce Transparency*. If Task 6 moved the tint or a scrim value, the rule names the
  function, not the number, so nothing in §8's wording changes; check that.
- [ ] **Step 2:** Do **not** stage them. Record in the ledger that they wait for the owner's yes.

---

### Task 8: The review, the gate, the warning comparison

- [ ] **Step 1: A fresh reviewer.** One read-only subagent reviews the staged diff against the spec,
  the rules and the DocC on the changed types — not the plan — and reports findings with file:line.
  Save its report to the ledger folder as it arrives. Check every finding against the code before
  acting; fix what is real, tests first where a test can see it.

- [ ] **Step 2: The gate** — rule `85-testing`'s invocations, on this machine's working destinations
  (the stock iOS 27.0 *iPhone 17* for unit tests; *WaterBuddy Gate 27* and *Gate 26.5* for UI; *WaterBuddy
  Watch 27* for the watch), `uptime` first and shutting down by UDID between systems:

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Test run with|failed" | tail -3
```

  The UI suite, per system, in chunks — `GoalSetupUITests` is 33 tests, three chunks of eleven by name;
  build each chunk's flags into a variable and expand it as `${=FLAGS}` (zsh), and read the
  **executed** count, never the last line:

```bash
NAMES=($(grep -oE "func test[A-Za-z0-9]+" WaterBuddyUITests/GoalSetupUITests.swift | sed 's/func //' | sort))
FLAGS=""; for n in ${NAMES[1,11]}; do FLAGS="$FLAGS -only-testing:WaterBuddyUITests/GoalSetupUITests/$n"; done
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' ${=FLAGS} -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Executed|Failing" | tail -3
```

  then `${NAMES[12,22]}`, `${NAMES[23,33]}`, then the other classes:

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' -only-testing:WaterBuddyUITests -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests -skip-testing:WaterBuddyUITests/GoalSetupUITests -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Executed|Failing" | tail -3
```

  and all four again with `OS=26.5,name=WaterBuddy Gate 26.5`. Then:

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Test run with|failed" | tail -3
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' 2>&1 | tail -1
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' 2>&1 | tail -1
```

  Expected: every run passes; both builds `** BUILD SUCCEEDED **`. A failure is investigated
  (`superpowers:systematic-debugging`), never retried into green without saying so.

- [ ] **Step 3: The warning comparison.** The working tree, built exactly as Task 0 Step 2 built HEAD
  (`rsync` to `$SP/base-tree`, `dd-base-tree`), counted the same way; `diff` the two files. Expected:
  no line in the tree's file that is not in HEAD's. Record both counts.

---

### Task 9: Records, docs — then stop

- [ ] **Step 1: `docs/DESIGN.md`** — a new section *The look, measured* (the probe's method and its
  scale caveat; every table from Task 6 with system, frames and rung; the canvas values and where
  they came from), and a one-line note at the head of *Apple's glass, measured* and *The hand-made
  pane, measured again* that stage 3c supersedes their values. Never rewrite the old tables.
- [ ] **Step 2: `docs/AI_CONTEXT.md`** — a stage 3c block at the head of *Current state*; #85 updated
  (the phone's pane fixed on 18.6 by Task 6's figures; the widget and the watch keep the black scrim,
  so the issue stays open for them — retire nothing that is not fixed on disk); new known issues for
  anything Task 6 or 8 found and left; the gate results with test counts by the attribute grep
  (rule `85-testing`, *Counting*).
- [ ] **Step 3: `tasks/lessons.md`** — append (with `Edit`, anchored on the last lines): a question put
  to the owner described the canvas from memory of a render, not from its source, and the owner
  ruled on it — read the board's source before quoting a value to the owner. Add any lesson Tasks 6
  and 8 earned.
- [ ] **Step 4: `HISTORY.md`** — a checkpoint `## [2026-10-13] — The redesign's stage 3c: the look`,
  appended at the bottom: what changed, the rulings, files touched, the verification actually run.
- [ ] **Step 5: Two fresh readers** (read-only subagents) on the records just written, briefed by line
  range, pointed at the ledger, the gate logs and the saved review; each report saved as it arrives;
  every finding checked against its primary source before editing; fixes by deleting or quoting,
  not by adding new figures.
- [ ] **Step 6: Stage** the code, the spec, this plan and the docs with explicit paths — never `-A` —
  leaving the two rule files unstaged. Write the ledger's and the docs' git block **last**, from
  `git status --short` and `git diff --cached --name-status` run at that moment.
- [ ] **Step 7: Stop.** Report to the owner: what was built, the side-by-side sheets, every value Task
  6 settled, anything under a floor or not rendered, the rule wording waiting for their yes, and the
  commit order (the three earlier staged paths are their own change). Nothing is committed until they
  run `/commit`.
