# The Premium Redesign, Stage 1 (Foundation) — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: `superpowers:executing-plans`, **in this session** —
> `CLAUDE.md` allows no implementation subagent ("Planning, test authorship, implementation and review
> all happen in the main loop"). Steps use checkbox (`- [ ]`) syntax for tracking. **No step commits:**
> each task ends by staging its paths, and nothing is committed until the owner runs `/commit`.

**Goal:** On iOS 26 and later every glass pane in the phone app is Apple's own glass, the app's two
main buttons are solid white and obviously tappable, and the tab bar marks its selected tab — with no
call site of `.liquidGlass(…)` changed and nothing different below iOS 26, in the widget or on the
watch.

**Architecture:** `LiquidGlassModifier` asks one pure function, `LiquidGlass.rendering(…)`, which of
three panes to draw: the opaque pane under Reduce Transparency, Apple's `glassEffect` for a `.material`
base where the system has it, the hand-made stack otherwise. A second modifier in the same shared file,
`primarySurface(in:)`, draws a solid white surface with `Aurora.top` content for a screen's one main
action. A two-value token, `LiquidGlass.Selection`, marks a selected slot and is read by the tab bar and
by History's shown day.

**Tech Stack:** Swift (language mode 5; the app target defaults to main-actor isolation, the widget and
watch targets do not), SwiftUI (`glassEffect(_:in:)`, `Glass`, iOS 26 SDK), swift-testing, XCTest (one
throwaway probe), Xcode 27.0 (27A266a).

**Spec:** `docs/superpowers/specs/2026-10-09-premium-redesign-design.md` — read it first; this plan
argues from it (§3.2 to §3.4, §11, §14). Approved by the owner on 2026-10-09 with all of §13.

**Three items moved out of stage 1 while planning, recorded in the spec's §14:**

- **Apple's glass on the watch** goes to stage 7. No watchOS 26 runtime is installed here, so a watch
  pane cannot be rendered, and the routing answers "available" on iOS only until it can be.
- **The glass container** (`GlassEffectContainer`) goes to stage 2 with its first user, the new
  quick-add row.
- **The grouped-figure helper** goes to stage 2 with its first caller, Home's readout.

## Global Constraints

- **Floors stay iOS 17.0 and watchOS 26.0.** The one new version check is `#if os(iOS)` plus
  `if #available(iOS 26.0, *)`, in `LiquidGlassModifier.swift` only.
- **No call site of `.liquidGlass(…)` or `widgetPane(…)` changes**, and no parameter is added to
  either. The widget still passes `.archived`.
- **Source files changed:** `WaterBuddy/LiquidGlassModifier.swift`, `WaterBuddy/PressStyle.swift`
  (comment only), `WaterBuddy/GoalSetupView.swift`, `WaterBuddy/HistoryView.swift`,
  `WaterBuddy/RootTabView.swift`, `WaterBuddyTests/LiquidGlassTests.swift`. **Nothing else under a
  target folder**: no new file, no seventh shared file, no `DataManager.Key`, no catalogue, no
  `project.pbxproj` edit.
- **No new string and no changed string.** *Get Started* and *Save* keep their keys; every label the
  UI tests query is untouched.
- **No colour literal.** The primary surface is `.white` with `Aurora.top`; nothing is added to
  `Aurora`.
- **New statics a test outside the main actor reads are `nonisolated`.** If a main-actor warning
  appears on a new declaration, the fix is `nonisolated` on that declaration, never `@MainActor` on
  the suite (rule `43-concurrency`). No non-`Sendable` value in a `static let`.
- **Tests first.** Write the test, run it, see it fail for the predicted reason, then implement
  (rule `85-testing`). Never narrow an assertion to make it pass; if a test and the code disagree,
  stop and report.
- **A contrast figure on glass is measured off a render, never derived** (rule `65-accessibility`).
  Floors: 4.5:1 for text, 3:1 for a glyph or a rim, and 3:1 for text of 24pt or more.
- Every `xcodebuild` in the foreground, `-parallel-testing-enabled NO`, one simulator at a time. Run
  `xcrun simctl shutdown all` before a test run only if no other `xcodebuild` is running
  (`pgrep -x xcodebuild`).
- **Destinations.** Phone, Apple's glass: `'platform=iOS Simulator,OS=26.5,name=iPhone 17'` (UDID
  `EE56B958-E33F-40A3-99EA-B14D45963685`). Phone, fallback glass:
  `'platform=iOS Simulator,OS=18.6,name=iPhone 16'` (UDID `631501B6-3DE4-4C8F-8C42-2D7227ED5CF4`).
  Watch, build only: `'generic/platform=watchOS Simulator'`. Re-read the UDIDs with
  `xcrun simctl list devices available` if either is refused.
- **Edits with `Edit`/`Write` only.** `Bash(sed -i:*)`, `Bash(defaults write:*)` and
  `Bash(xcrun simctl erase:*)` are on the deny list; a refused call is a stop, never a detour. Never
  write into the Mac's own `group.sardor.WaterBuddy` or `UserDefaults.standard`.
- No new warning against a clean build of HEAD (Task 7).

## Review Focus

Conditions the spec implies that the unit tests of Tasks 1 to 4 cannot drive, most likely to bite
first, each with the check that owns it:

1. **A tap on an interactive glass control on iOS 26** (a quick-add vessel, History's `+`, a serving
   row, *Cancel*) must still fire its action: Apple's interactive glass reacts to touch itself and sits
   inside a `Button`'s label. → Task 5's probe taps every one of them on iOS 26.5, and Task 7's UI
   suite runs on the same OS.
2. **An iPhone below iOS 26** must draw exactly what it draws today, never a blank pane. → Task 1's
   `theAvailabilityFlagMatchesTheRunningSystem`, run on iOS 18.6 in Task 5, and Task 5's captures there.
3. **Text that was legible on the old pane and is not on Apple's.** Every text opacity in the app
   (0.60 to 0.75) was chosen from samples of the hand-made pane. → Task 5's measured table, and its
   one pre-authorised remedy.
4. **Reduce Transparency, switched on while the app is open.** The pane changes from Apple's glass to
   the opaque fill. → Task 1's `reduceTransparencyAlwaysDrawsTheOpaquePane`; Task 5 Step 8 renders it,
   attempted through the Settings app.
5. **The largest text size on the primary surface.** *Save* shares a row with *Cancel* and once ran
   past its capsule (known issue #60). → Task 5's capture at `AccessibilityXXXL`.

---

## File structure

| File | Change | Responsibility |
|---|---|---|
| `WaterBuddy/LiquidGlassModifier.swift` | modify | the routing functions, the three panes, `LiquidGlass.Primary` and `primarySurface(in:)`, `LiquidGlass.Selection`, corrected DocC |
| `WaterBuddy/PressStyle.swift` | modify | one comment, no longer saying Apple's API cannot be called |
| `WaterBuddy/GoalSetupView.swift` | modify | *Get Started* on the primary surface |
| `WaterBuddy/HistoryView.swift` | modify | *Save* on the primary surface; the shown day reads `LiquidGlass.Selection` |
| `WaterBuddy/RootTabView.swift` | modify | the selected tab's lozenge |
| `WaterBuddyTests/LiquidGlassTests.swift` | modify | `LiquidGlassRoutingTests`, `PrimarySurfaceTests`, one corrected DocC |
| `.claude/rules/60-design-system.md`, `.claude/rules/15-project.md` | modify | Task 6's wording, verbatim |
| `WaterBuddyUITests/ZZGlassProbe.swift` | create, then **delete** | Task 5's throwaway captures |

Shell variable used below — **each `Bash` call is a fresh shell**, so set it in every command, to
**your session's** scratchpad:

```bash
SP=/private/tmp/claude-501/-Users-sardorallaberganov-Desktop-Projects-MobileApps-WaterBuddy/<session>/scratchpad
```

One glass suite, used by Tasks 1 and 3 (replace `SUITE`):

```bash
pgrep -x xcodebuild >/dev/null || xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests/SUITE -parallel-testing-enabled NO > $SP/t.log 2>&1; echo "exit $?"
grep -E 'error:|✔ Test run|✘ Test run|Expectation failed|\*\* TEST' $SP/t.log | sed -E 's#^/[^ ]*/##' | sort -u | cut -c1-220
```

The three other schemes, used by Tasks 2 and 3. `LiquidGlassModifier.swift` compiles into all four
targets and no scheme compiles a sibling's sources:

```bash
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' > $SP/b-widget.log 2>&1; echo "widget exit $?"
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'generic/platform=watchOS Simulator' > $SP/b-watch.log 2>&1; echo "watch exit $?"
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget \
  -destination 'generic/platform=watchOS Simulator' > $SP/b-watchwidget.log 2>&1; echo "watchwidget exit $?"
grep -hE 'error:|\*\* BUILD' $SP/b-widget.log $SP/b-watch.log $SP/b-watchwidget.log | sed -E 's#^/[^ ]*/##' | sort -u | cut -c1-220
```

---

### Task 0: Two clean simulators

**Files:** none.

The probe in Task 5 must reach the first-run screen, and uninstalling the app does not clear its App
Group (`tasks/lessons.md`, 2026-08-28). Only an erase does, and only the owner can run one.

- [ ] **Step 1: Ask the owner to run these two lines**, each pasted with its leading `!`:

```
! xcrun simctl erase EE56B958-E33F-40A3-99EA-B14D45963685
! xcrun simctl erase 631501B6-3DE4-4C8F-8C42-2D7227ED5CF4
```

The first is iOS 26.5's *iPhone 17*, the gate's pinned destination, which has refused to boot since
2026-10-08 (known issue #77). The second is iOS 18.6's *iPhone 16*.

- [ ] **Step 2: Prove both boot**

```bash
xcrun simctl shutdown all
xcrun simctl boot EE56B958-E33F-40A3-99EA-B14D45963685 && xcrun simctl bootstatus EE56B958-E33F-40A3-99EA-B14D45963685 -b | tail -1
xcrun simctl shutdown all
xcrun simctl boot 631501B6-3DE4-4C8F-8C42-2D7227ED5CF4 && xcrun simctl bootstatus 631501B6-3DE4-4C8F-8C42-2D7227ED5CF4 -b | tail -1
xcrun simctl shutdown all
```

Expected: each `bootstatus` ends on a line saying the device finished booting. If either says
"cannot be located on disk", stop and report: the erase did not run for that device.

---

### Task 1: The routing, as two pure functions

**Files:**
- Modify: `WaterBuddy/LiquidGlassModifier.swift` (inside `enum LiquidGlass`, after `Density`)
- Test: `WaterBuddyTests/LiquidGlassTests.swift` (new suite at the end)

**Interfaces:**
- Produces: `LiquidGlass.Rendering` (`.opaque`, `.system`, `.handMade`);
  `LiquidGlass.rendering(base: Base, reduceTransparency: Bool, systemGlassAvailable: Bool) -> Rendering`;
  `LiquidGlass.systemGlassAvailable: Bool`; `LiquidGlass.SystemVariant` (`.regular`, `.clear`);
  `LiquidGlass.systemVariant(density: Density, interactive: Bool) -> SystemVariant`. Task 2 calls all
  four.

- [ ] **Step 1: Write the failing suite.** Append to `WaterBuddyTests/LiquidGlassTests.swift`:

```swift
/// The **routing** half of the design system: which pane a `liquidGlass(…)` call draws
/// (spec `2026-10-09-premium-redesign-design.md` §3.2).
///
/// Not `@MainActor`, like the two suites above — and here that is also the point being proved: the
/// choice is made without building a view.
struct LiquidGlassRoutingTests {

    /// Built per use: `Base` carries a `Material` and is not `Sendable`, so it may not sit in a
    /// `static let` (rule `43-concurrency`).
    private var material: LiquidGlass.Base { .material(.ultraThinMaterial) }

    /// Reduce Transparency wins over everything, on every OS and for every base. The SDK does not
    /// say what Apple's glass does under that setting, so this system keeps its own answer.
    @Test(arguments: [true, false])
    func reduceTransparencyAlwaysDrawsTheOpaquePane(systemGlassAvailable: Bool) {
        #expect(LiquidGlass.rendering(base: material, reduceTransparency: true, systemGlassAvailable: systemGlassAvailable) == .opaque)
        #expect(LiquidGlass.rendering(base: .archived, reduceTransparency: true, systemGlassAvailable: systemGlassAvailable) == .opaque)
    }

    /// The widget's base. It exists because a widget cannot sample a backdrop, and Apple's glass
    /// samples one — so it never reaches Apple's glass, whatever the OS.
    @Test(arguments: [true, false])
    func aFlatBaseIsAlwaysHandMade(systemGlassAvailable: Bool) {
        #expect(LiquidGlass.rendering(base: .archived, reduceTransparency: false, systemGlassAvailable: systemGlassAvailable) == .handMade)
    }

    @Test func aMaterialBaseDrawsApplesGlassWhereTheSystemHasIt() {
        #expect(LiquidGlass.rendering(base: material, reduceTransparency: false, systemGlassAvailable: true) == .system)
    }

    /// iOS 17 to 25, and for now the watch: exactly the stack every pane drew before this existed.
    @Test func aMaterialBaseFallsBackToTheHandMadeStackWhereItHasNot() {
        #expect(LiquidGlass.rendering(base: material, reduceTransparency: false, systemGlassAvailable: false) == .handMade)
    }

    /// The flag the modifier passes has to be the truth about the system this suite is running on.
    /// Run on iOS 26.5 it must be `true`; run on iOS 18.6 it must be `false`.
    @Test func theAvailabilityFlagMatchesTheRunningSystem() {
        let isTwentySixOrLater = ProcessInfo.processInfo.isOperatingSystemAtLeast(
            OperatingSystemVersion(majorVersion: 26, minorVersion: 0, patchVersion: 0)
        )
        #expect(LiquidGlass.systemGlassAvailable == isTwentySixOrLater)
    }

    /// `.sheer` asks for the least glass. Only a pane that is not a control — the vessel, whose
    /// readout sits on its own scrim — takes Apple's clear variant for it.
    @Test func onlyAnInertSheerPaneTakesTheClearVariant() {
        #expect(LiquidGlass.systemVariant(density: .sheer, interactive: false) == .clear)
        #expect(LiquidGlass.systemVariant(density: .sheer, interactive: true) == .regular)
    }

    /// Anything that carries a label straight on the glass needs the regular variant's legibility.
    @Test(arguments: [LiquidGlass.Density.frosted, .opaque], [true, false])
    func aPaneThatCarriesTextTakesTheRegularVariant(density: LiquidGlass.Density, interactive: Bool) {
        #expect(LiquidGlass.systemVariant(density: density, interactive: interactive) == .regular)
    }
}
```

- [ ] **Step 2: Run it and see it fail.** Run the glass-suite command with
  `SUITE=LiquidGlassRoutingTests`.

Expected: the build fails, `** TEST FAILED **`, with errors of the form
`type 'LiquidGlass' has no member 'rendering'`, `… no member 'systemGlassAvailable'` and
`… no member 'systemVariant'`, all in `LiquidGlassTests.swift`. Any other error is not the predicted
RED: read it before going on.

- [ ] **Step 3: Implement.** In `WaterBuddy/LiquidGlassModifier.swift`, insert after the closing brace
  of `enum Density` and before the closing brace of `enum LiquidGlass`:

```swift

    /// Which of the three panes a `liquidGlass(…)` call draws.
    ///
    /// A value rather than three `if`s inside the modifier, so the choice can be pinned by a test
    /// that never builds a view (`LiquidGlassRoutingTests`).
    nonisolated enum Rendering: Equatable, Sendable {

        /// The opaque fill and lit rim that replace everything under Reduce Transparency.
        case opaque

        /// Apple's glass, `glassEffect(_:in:)`. The system draws the pane, its edge and its
        /// depth; none of this file's layers is stacked on it.
        case system

        /// The stack this file has always drawn: base, scrim, tint, specular, rim, two shadows.
        case handMade
    }

    /// Decides the pane, in this order — and the order is the ruling.
    ///
    /// 1. **Reduce Transparency first, on every OS.** The SDK's doc comments say nothing about
    ///    what Apple's glass does under that setting, so this system keeps its own answer rather
    ///    than depend on one it cannot read.
    /// 2. **A `.flat` base is hand-made, always.** It exists for a context that cannot sample a
    ///    backdrop — the widget — and Apple's glass samples one as a `Material` does.
    /// 3. Otherwise Apple's glass where the system has it, and the hand-made stack where it has
    ///    not.
    ///
    /// Spec `docs/superpowers/specs/2026-10-09-premium-redesign-design.md` §3.2.
    nonisolated static func rendering(
        base: Base,
        reduceTransparency: Bool,
        systemGlassAvailable: Bool
    ) -> Rendering {
        if reduceTransparency { return .opaque }

        switch base {
        case .flat: return .handMade
        case .material: return systemGlassAvailable ? .system : .handMade
        }
    }

    /// Whether this process can draw Apple's glass.
    ///
    /// **iOS only, for now.** watchOS 26 has the API and the watch's floor is 26.0, so the watch
    /// could take this path today — but no watchOS 26 simulator runtime was installed where this
    /// was built, and a pane nobody has rendered is not one to ship. The watch stage of the
    /// redesign turns it on (spec §9, §14).
    ///
    /// A `static let`, resolved once: the answer cannot change while the process lives.
    nonisolated static let systemGlassAvailable: Bool = {
        #if os(iOS)
        if #available(iOS 26.0, *) { return true }
        #endif
        return false
    }()

    /// Which of Apple's two glasses a pane takes.
    nonisolated enum SystemVariant: Equatable, Sendable {

        /// `Glass.regular` — the adaptive one, for any pane that carries a label.
        case regular

        /// `Glass.clear` — for a container whose content brings its own legibility.
        case clear
    }

    /// `.sheer` asks for the least glass, and only a pane that is not a control gets Apple's
    /// clear variant for it: the vessel, whose readout sits on its own scrim. A sheer *control*
    /// — *Cancel*, *Open iOS Settings* — carries a label straight on the glass and needs the
    /// regular variant's legibility.
    ///
    /// A starting mapping, settled by measurement: the figures are in `docs/DESIGN.md`.
    nonisolated static func systemVariant(density: Density, interactive: Bool) -> SystemVariant {
        switch density {
        case .sheer: return interactive ? .regular : .clear
        case .frosted, .opaque: return .regular
        }
    }
```

- [ ] **Step 4: Run it and see it pass.** Same command.

Expected: `✔ Test run with 7 tests in 1 suite passed`, `** TEST SUCCEEDED **`, and no `error:` line.
`theAvailabilityFlagMatchesTheRunningSystem` passes here with the flag `true`.

- [ ] **Step 5: Stage**

```bash
git add WaterBuddy/LiquidGlassModifier.swift WaterBuddyTests/LiquidGlassTests.swift
```

---

### Task 2: The modifier draws through the routing

**Files:**
- Modify: `WaterBuddy/LiquidGlassModifier.swift` (the `Interaction` DocC; everything from
  `// MARK: - Modifier` to the end of `struct LiquidGlassModifier`)
- Modify: `WaterBuddy/PressStyle.swift` (one comment)
- Modify: `WaterBuddyTests/LiquidGlassTests.swift` (the `LiquidGlassInteractionTests` DocC)

**Interfaces:**
- Consumes: Task 1's four declarations, exactly as named there.
- Produces: no new API. `liquidGlass(in:…)`, `liquidGlass(cornerRadius:…)` and
  `LiquidGlassModifier`'s memberwise initialiser keep their signatures.

No unit test can see a pane. This task's proof is that all four targets compile on both floors, that
the existing glass suites still pass, and Task 5's renders. The routing it relies on is already pinned
by Task 1.

- [ ] **Step 1: Correct the `Interaction` DocC.** In `enum LiquidGlass`, replace the paragraph

```swift
    /// Adopted from Apple's *Applying Liquid Glass to custom views*, which describes
    /// `Glass.interactive()` as glass that "reacts to touch and pointer interactions in real time".
    /// **That API cannot be called here** — `glassEffect(_:in:)` and friends ship in the iOS 26 SDK
    /// and this project builds against 18.5, so the symbols do not exist to guard with
    /// `#available`. The behaviour is expressed in this system instead.
```

with

```swift
    /// Adopted from Apple's *Applying Liquid Glass to custom views*, which describes
    /// `Glass.interactive()` as glass that "reacts to touch and pointer interactions in real time".
    /// On iOS 26 and later an interactive pane **is** that glass
    /// (``LiquidGlass/systemVariant(density:interactive:)``). These multipliers are what the
    /// hand-made stack does instead, wherever ``LiquidGlass/rendering(base:reduceTransparency:systemGlassAvailable:)``
    /// answers `.handMade`: below iOS 26, in the widget, and on the watch until its own stage.
```

- [ ] **Step 2: Move the orphaned DocC onto the type it describes, and update it.** Today the block
  beginning `/// A glossy glass surface:` sits above `// MARK: - The press state`, so it documents
  `GlassPressedKey`, and it says "five layers" over a list of six. Delete the `// MARK: - Modifier`
  line, the blank line after it and that whole block (from `/// A glossy glass surface:` through
  `/// short labels and controls where a busy backdrop cannot swallow a whole sentence.`), so that
  `// MARK: - The press state` follows the closing brace of `enum LiquidGlass`. Then insert this
  immediately above `struct LiquidGlassModifier<S: Shape & InsettableShape>: ViewModifier {`:

```swift
// MARK: - Modifier

/// A glass surface, drawn one of three ways. ``LiquidGlass/rendering(base:reduceTransparency:systemGlassAvailable:)``
/// decides which, and no call site is told.
///
/// - **Apple's glass**, on iOS 26 and later, for a base that can sample its backdrop. The system
///   draws the pane, its edge and its depth. `tint`, `elevation`, the border and the highlight
///   below describe the hand-made stack, and Apple's glass takes none of them.
/// - **The opaque pane**, under Reduce Transparency, on every OS.
/// - **The hand-made stack**, everywhere else. Its six layers, bottom to top, are what make it
///   read as a physical pane rather than a translucent rectangle:
///
///   1. ``LiquidGlass/Base`` — the real blur, sampling whatever is behind the view. Or, where
///      nothing can be sampled, the fill that measures out to the same thing.
///   2. A black scrim, in Dark Mode only — see ``LiquidGlass/Density/scrimOpacity(for:)``.
///   3. A white tint — the body of the glass.
///   4. A specular gradient — a light source above and to the left, falling off fast.
///   5. An inset stroke that is bright where the light hits and dim where it does not.
///   6. Two shadows — ambient height plus a contact edge.
///
/// Glass is invisible without something behind it. Place it over content, imagery, or colour,
/// never over a flat background.
///
/// Density is a legibility decision, not only a look: a pane is only as readable as the
/// background it failed to hide. Use ``LiquidGlass/Density/frosted`` or
/// ``LiquidGlass/Density/opaque`` behind body text, and keep ``LiquidGlass/Density/sheer`` for
/// short labels and controls where a busy backdrop cannot swallow a whole sentence.
```

- [ ] **Step 3: Route `body`.** Replace the whole of `func body(content:)` and the `pane` property —
  from `func body(content: Content) -> some View {` through the closing brace of
  `private var pane: some View { … }` — with:

```swift
    func body(content: Content) -> some View {
        routed(content)
            // Scoped to the value that changed, never a bare `withAnimation` (rule `50-views`),
            // and matched to `PressStyle`'s spring so the material and the frame move together
            // rather than arriving one after the other.
            //
            // No Reduce Motion path, deliberately: this runs only while a finger is down. That
            // rule targets loops that never stop, which is the same ruling `PressStyle` records
            // for its recoil (rule `65-accessibility`).
            .animation(.spring(response: 0.28, dampingFraction: 0.62), value: isReacting)
    }

    // MARK: Routing

    private var rendering: LiquidGlass.Rendering {
        LiquidGlass.rendering(
            base: base,
            reduceTransparency: reduceTransparency,
            systemGlassAvailable: LiquidGlass.systemGlassAvailable
        )
    }

    @ViewBuilder
    private func routed(_ content: Content) -> some View {
        switch rendering {
        case .system: systemPane(content)
        case .opaque: content.background(opaquePane)
        case .handMade: content.background(handMadePane)
        }
    }

    /// Apple's glass. Applied **to** the content rather than laid behind it, because that is what
    /// the API is: it anchors its shape behind the view and applies the glass's foreground
    /// effects over it.
    ///
    /// The `else` and the `#else` can only be reached if `rendering` and this check ever
    /// disagree, which `theAvailabilityFlagMatchesTheRunningSystem` exists to prevent. They draw
    /// the hand-made stack rather than nothing.
    @ViewBuilder
    private func systemPane(_ content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            content.glassEffect(systemGlass, in: shape)
        } else {
            content.background(handMadePane)
        }
        #else
        content.background(handMadePane)
        #endif
    }

    #if os(iOS)
    @available(iOS 26.0, *)
    private var systemGlass: Glass {
        let glass: Glass
        switch LiquidGlass.systemVariant(density: density, interactive: interactive) {
        case .regular: glass = .regular
        case .clear: glass = .clear
        }
        return interactive ? glass.interactive() : glass
    }
    #endif

    // MARK: Layers

    /// Translucency is the thing being turned off, so there is nothing to soften: an opaque
    /// surface, keeping only the edge and the depth.
    private var opaquePane: some View {
        shape
            .fill(base.opaqueFill)
            .overlay { shape.strokeBorder(edge, lineWidth: borderWidth) }
            .compositingGroup()
            .modifier(Shadows(elevation: elevation, colorScheme: colorScheme))
    }

    private var handMadePane: some View {
        baseLayer
            .overlay { shape.fill(Color.black.opacity(density.scrimOpacity(for: colorScheme))) }
            .overlay { shape.fill(tint.opacity(resolvedTintOpacity)) }
            .overlay { shape.fill(specular) }
            .overlay { shape.strokeBorder(edge, lineWidth: borderWidth) }
            .compositingGroup()
            .modifier(Shadows(elevation: elevation, colorScheme: colorScheme))
    }
```

  `baseLayer`, `isReacting`, `resolvedTintOpacity`, `specular` and `edge` stay exactly as they are.
  The two pane bodies are the two branches of the old `pane`, statement for statement.

- [ ] **Step 4: Correct `PressStyle.swift`'s comment.** Replace

```swift
            // Hands the press down to any `liquidGlass(interactive: true)` pane inside the label,
            // so the *material* answers the finger and not only the frame — Apple's
            // `Glass.interactive()` behaviour, expressed in this system because `glassEffect(_:in:)`
            // ships in the iOS 26 SDK and this project builds against 18.5.
```

with

```swift
            // Hands the press down to any `liquidGlass(interactive: true)` pane inside the label,
            // so the *material* answers the finger and not only the frame. On iOS 26 and later
            // that pane is Apple's `Glass.interactive()` and reacts by itself; in any pane the
            // hand-made stack draws, this value is what brightens the tint, the rim and the
            // specular (`LiquidGlass.Interaction`).
```

- [ ] **Step 5: Correct the test suite's DocC.** In `WaterBuddyTests/LiquidGlassTests.swift`, replace

```swift
/// Adopted from Apple's *Applying Liquid Glass to custom views*, which describes
/// `Glass.interactive()` as a material that "reacts to touch and pointer interactions in real
/// time". WaterBuddy cannot call that API — it ships in the iOS 26 SDK and this project builds
/// against 18.5 — so the behaviour is expressed in the hand-rolled system instead. `PressStyle`
/// already recoiled the *frame*; nothing made the *material* respond.
```

with

```swift
/// Adopted from Apple's *Applying Liquid Glass to custom views*, which describes
/// `Glass.interactive()` as a material that "reacts to touch and pointer interactions in real
/// time". On iOS 26 and later an interactive pane is that glass; these numbers are what the
/// hand-made stack does instead, below iOS 26 and wherever a pane cannot sample its backdrop.
/// `PressStyle` already recoiled the *frame*; nothing made the *material* respond.
```

- [ ] **Step 6: The glass suites still pass, on Apple's glass.** Run the glass-suite command three
  times, with `SUITE=LiquidGlassRoutingTests`, `SUITE=LiquidGlassInteractionTests` and
  `SUITE=LiquidGlassBaseTests`.

Expected: `✔ Test run with 7 tests in 1 suite passed`, then `7 tests`, then `2 tests`, each with
`** TEST SUCCEEDED **`. `panesAreInertUnlessTheyAskNotToBe` passing proves the memberwise initialiser
is unchanged.

- [ ] **Step 7: The other three targets compile.** Run the three-scheme command above.

Expected: `** BUILD SUCCEEDED **` three times and no `error:` line. The two watch builds are what
prove `#if os(iOS)` keeps `Glass` out of watchOS.

- [ ] **Step 8: Stage**

```bash
git add WaterBuddy/LiquidGlassModifier.swift WaterBuddy/PressStyle.swift WaterBuddyTests/LiquidGlassTests.swift
```

---

### Task 3: The primary surface, on *Get Started* and *Save*

**Files:**
- Modify: `WaterBuddy/LiquidGlassModifier.swift` (a token group, a modifier, a `View` method)
- Modify: `WaterBuddy/GoalSetupView.swift` (`getStartedButton`)
- Modify: `WaterBuddy/HistoryView.swift` (the *Save* button in `ServingSheet.actions`)
- Test: `WaterBuddyTests/LiquidGlassTests.swift` (new suite at the end)

**Interfaces:**
- Produces: `LiquidGlass.Primary.shadeOpacity`, `.pressedShadeOpacity`, `.ringOpacity`, `.ringWidth`;
  `PrimarySurfaceModifier<S: Shape & InsettableShape>` with `shape: S` and `ring: Bool = true`;
  `View.primarySurface(in:ring:)`. Stages 2, 5, 6 and 7 call `primarySurface(in:ring:)`; stage 6 passes
  `ring: false`.

- [ ] **Step 1: Write the failing test.** Append to `WaterBuddyTests/LiquidGlassTests.swift`:

```swift
/// The **primary surface**: the one solid thing among the glass (spec §3.3).
///
/// Its fill is solid, so unlike anything on a `Material` its contrast can be derived
/// (rule `65-accessibility`) — which is why this figure is a test and the glass figures are
/// measurements in `docs/DESIGN.md`.
struct PrimarySurfaceTests {

    /// sRGB's transfer function and its inverse. The shade is composited the way the screen
    /// composites it, in encoded space, and the luminance is taken from linear components.
    private func encoded(_ linear: Double) -> Double {
        linear <= 0.0031308 ? linear * 12.92 : 1.055 * pow(linear, 1 / 2.4) - 0.055
    }

    private func linear(_ encoded: Double) -> Double {
        encoded <= 0.04045 ? encoded / 12.92 : pow((encoded + 0.055) / 1.055, 2.4)
    }

    private func luminance(_ channels: [Double]) -> Double {
        0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2]
    }

    /// `Aurora.top` on the primary fill, taken at the fill's darkest point: its foot, where the
    /// shade toward `Aurora.top` is strongest. About 13:1 at the head and 10.6:1 here.
    @Test func thePrimaryLabelClearsSevenToOneEvenAtTheFootOfTheShade() {
        let resolved = Aurora.top.resolve(in: EnvironmentValues())
        let ink = [resolved.linearRed, resolved.linearGreen, resolved.linearBlue].map(Double.init)
        let shade = LiquidGlass.Primary.shadeOpacity

        // White leaning toward the ink by `shade`.
        let foot = ink.map { linear((1 - shade) + shade * encoded($0)) }

        let ratio = (luminance(foot) + 0.05) / (luminance(ink) + 0.05)

        #expect(ratio >= 7)
    }
}
```

- [ ] **Step 2: Run it and see it fail.** Run the glass-suite command with
  `SUITE=PrimarySurfaceTests`.

Expected: the build fails with `type 'LiquidGlass' has no member 'Primary'`.

- [ ] **Step 3: Add the tokens.** In `WaterBuddy/LiquidGlassModifier.swift`, insert after the closing
  brace of `enum Interaction` (before the `Elevation` DocC):

```swift

    /// The primary surface: the one solid thing among the glass, for a screen's one main action.
    ///
    /// Solid white, because a main action drawn as one more glass pane read as disabled — *Get
    /// Started* was frosted glass with a glow, and looked like a control waiting to be enabled.
    /// The content on it is `Aurora.top`, the deep blue the backdrop starts from, so the surface
    /// borrows the product's colour without a new token
    /// (`thePrimaryLabelClearsSevenToOneEvenAtTheFootOfTheShade`).
    enum Primary {

        /// How far the fill leans toward `Aurora.top` at its foot. Enough to read as lit from
        /// above; the contrast test is what stops it growing.
        nonisolated static let shadeOpacity = 0.12

        /// The wash laid over the whole fill while a finger is down — the material answering
        /// the press, as `Interaction` does for glass.
        nonisolated static let pressedShadeOpacity = 0.10

        /// The soft ring outside the shape, and how far it reaches.
        nonisolated static let ringOpacity = 0.13
        nonisolated static let ringWidth: CGFloat = 6
    }
```

- [ ] **Step 4: Add the modifier.** Insert after the closing brace of `private struct Shadows` (before
  `// MARK: - View API`):

```swift

// MARK: - The primary surface

/// Draws ``LiquidGlass/Primary``. In this file and not one of its own, because the widget and the
/// watch will draw it too and the shared set does not grow (rule `15-project`).
struct PrimarySurfaceModifier<S: Shape & InsettableShape>: ViewModifier {

    var shape: S

    /// The ring is the phone's. A widget's pour button is exactly its 44pt target, and its
    /// vessel's clearance is derived from that (rule `40-widget`), so it passes `false`.
    var ring: Bool = true

    @Environment(\.colorScheme) private var colorScheme

    /// Set by ``PressStyle``, as for a glass pane.
    @Environment(\.glassIsPressed) private var isPressed

    func body(content: Content) -> some View {
        content
            // The surface owns its content's colour: a label that set `.white` itself would be
            // white on white.
            .foregroundStyle(Aurora.top)
            .background(surface)
            // The same spring as `PressStyle` and `LiquidGlassModifier`, so the wash and the
            // frame move together (rule `60-design-system`).
            .animation(.spring(response: 0.28, dampingFraction: 0.62), value: isPressed)
    }

    private var surface: some View {
        shape
            .fill(.white)
            .overlay { shape.fill(shade) }
            .overlay {
                shape.fill(Aurora.top.opacity(isPressed ? LiquidGlass.Primary.pressedShadeOpacity : 0))
            }
            // One shadow for the assembled surface, not one per layer.
            .compositingGroup()
            .modifier(Shadows(elevation: .raised, colorScheme: colorScheme))
            .background {
                // Present at zero opacity rather than removed, so a caller that turns it off
                // changes a colour and not the view tree.
                shape
                    .inset(by: -LiquidGlass.Primary.ringWidth)
                    .fill(.white.opacity(ring ? LiquidGlass.Primary.ringOpacity : 0))
            }
    }

    private var shade: LinearGradient {
        LinearGradient(
            colors: [Aurora.top.opacity(0), Aurora.top.opacity(LiquidGlass.Primary.shadeOpacity)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
```

- [ ] **Step 5: Add the `View` method.** Inside `extension View`, after the closing brace of
  `liquidGlass(cornerRadius:…)`:

```swift

    /// Places the content on the primary surface: solid white, `Aurora.top` content.
    ///
    /// One per screen, for its main action. Never give its label a foreground colour of its own.
    func primarySurface<S: Shape & InsettableShape>(in shape: S, ring: Bool = true) -> some View {
        modifier(PrimarySurfaceModifier(shape: shape, ring: ring))
    }
```

- [ ] **Step 6: Run the test and see it pass.** Run the glass-suite command with
  `SUITE=PrimarySurfaceTests`.

Expected: `✔ Test run with 1 test in 1 suite passed`, `** TEST SUCCEEDED **`.

- [ ] **Step 7: *Get Started*.** In `WaterBuddy/GoalSetupView.swift`, inside `getStartedButton`,
  replace the label

```swift
            Text("Get Started", bundle: strings)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                // Comfortably past the 44pt floor, and a deliberate `minHeight` so the target
                // grows with Dynamic Type instead of clipping the label.
                .frame(minHeight: 56)
                .liquidGlass(in: Capsule(), density: .frosted, elevation: .raised, interactive: true)
                // The glow: three static layers drawn from the `Aurora` palette — the same
                // lights already behind the glass, so the button reads as lit *by* the backdrop
                // rather than painted on top of it.
                //
                // Three and not one because a single wide shadow renders as haze. A tight hot
                // core is what the eye reads as the source; the mid bloom carries it off the
                // edge; the wide blue layer seats it against the magenta the button happens to
                // sit on, where a lone cyan shadow measured almost invisible on device.
                //
                // Static on purpose: a breathing pulse is a perpetual animation and would owe a
                // Reduce Motion path (rule `65-accessibility`) for no gain.
                .shadow(color: Aurora.cyan.opacity(0.55), radius: 12)
                .shadow(color: Aurora.cyan.opacity(0.38), radius: 28)
                .shadow(color: Aurora.blue.opacity(0.38), radius: 46, y: 10)
```

with

```swift
            Text("Get Started", bundle: strings)
                .font(.headline.weight(.semibold))
                .frame(maxWidth: .infinity)
                // Comfortably past the 44pt floor, and a deliberate `minHeight` so the target
                // grows with Dynamic Type instead of clipping the label.
                .frame(minHeight: 56)
                // This screen's one main action, so it is the primary surface and not glass
                // (rule `60-design-system`). It was frosted glass under a three-layer glow, and
                // read as a control waiting to be enabled. The surface sets the label's colour.
                .primarySurface(in: Capsule())
```

- [ ] **Step 8: *Save*.** In `WaterBuddy/HistoryView.swift`, inside `actions`, replace the *Save*
  label

```swift
                Text("Save", bundle: strings)
                    .font(.headline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 56)
                    .liquidGlass(in: Capsule(), density: .frosted, elevation: .raised, interactive: true)
                    // The same lit-by-the-backdrop glow *Get Started* carries, at the same two
                    // radii — a tight hot core the eye reads as the source, and a bloom to carry
                    // it off the edge. Static, so it owes no Reduce Motion path.
                    .shadow(color: Aurora.cyan.opacity(0.55), radius: 12)
                    .shadow(color: Aurora.cyan.opacity(0.38), radius: 28)
```

with

```swift
                Text("Save", bundle: strings)
                    .font(.headline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 56)
                    // The sheet's main action, on the primary surface like *Get Started*
                    // (rule `60-design-system`). *Cancel* beside it stays glass.
                    .primarySurface(in: Capsule())
```

  The *Cancel* button above it is not touched.

- [ ] **Step 9: Everything compiles, and the suite still passes.** Run the glass-suite command with
  `SUITE=PrimarySurfaceTests` (it rebuilds the app with both edits), then the three-scheme command.

Expected: `** TEST SUCCEEDED **`, then `** BUILD SUCCEEDED **` three times, no `error:` line.

- [ ] **Step 10: Stage**

```bash
git add WaterBuddy/LiquidGlassModifier.swift WaterBuddy/GoalSetupView.swift WaterBuddy/HistoryView.swift WaterBuddyTests/LiquidGlassTests.swift
```

---

### Task 4: One way to draw "selected", and the tab bar uses it

**Files:**
- Modify: `WaterBuddy/LiquidGlassModifier.swift` (a token group)
- Modify: `WaterBuddy/RootTabView.swift` (`GlassTabBar.tabButton`)
- Modify: `WaterBuddy/HistoryView.swift` (`HistoryCard`'s day button background)

**Interfaces:**
- Produces: `LiquidGlass.Selection.fillOpacity` (0.08) and `.rimOpacity` (0.55). Stage 3's week card
  and stage 6 read them.

The two values are the ones History's shown day already draws, measured there: the rim reads 4.15:1
against the pane beside it and the white letter inside reads 7.4:1 (`docs/DESIGN.md`). Giving the tab
bar the same pair makes "selected" one drawing. This is a visual change with no unit test; Task 5
measures the caption inside the lozenge on both glass paths, and `AppTabTests` keeps pinning the three
slots.

- [ ] **Step 1: Add the tokens.** In `WaterBuddy/LiquidGlassModifier.swift`, insert after the closing
  brace of `enum Primary`:

```swift

    /// How a selected slot is marked: the tab bar's active tab and History's shown day.
    ///
    /// A fill and a lit rim, always both and never colour alone (rule `65-accessibility`). Both
    /// values were read off History's rendered week card before the tab bar borrowed them.
    enum Selection {

        /// The fill behind the selected slot. Low on purpose: it sits under a small white
        /// caption, and every point of white added here comes straight off that caption's
        /// contrast.
        nonisolated static let fillOpacity = 0.08

        /// The lit rim around it. A non-text mark, so its floor is 3:1.
        nonisolated static let rimOpacity = 0.55
    }
```

- [ ] **Step 2: History reads them.** In `WaterBuddy/HistoryView.swift`, in the day button's
  `.background`, replace

```swift
                Capsule()
                    .fill(.white.opacity(isShown ? 0.08 : 0))
                    .strokeBorder(.white.opacity(isShown ? 0.55 : 0), lineWidth: 1)
                    .padding(.horizontal, 3)
```

with

```swift
                Capsule()
                    .fill(.white.opacity(isShown ? LiquidGlass.Selection.fillOpacity : 0))
                    .strokeBorder(.white.opacity(isShown ? LiquidGlass.Selection.rimOpacity : 0), lineWidth: 1)
                    .padding(.horizontal, 3)
```

  Same values, so nothing on that screen changes. The comment above it stays.

- [ ] **Step 3: The tab bar's lozenge.** In `WaterBuddy/RootTabView.swift`, in `tabButton`, replace

```swift
            // The whole slot is the target, not just the glyph — 44pt is the floor and the width
            // is shared evenly (rule `65-accessibility`).
            .frame(maxWidth: .infinity, minHeight: 44)
            .contentShape(Rectangle())
```

with

```swift
            // The whole slot is the target, not just the glyph — 44pt is the floor and the width
            // is shared evenly (rule `65-accessibility`).
            .frame(maxWidth: .infinity, minHeight: 44)
            .background {
                // The active tab's lozenge: History's shown-day treatment, from the same two
                // tokens, so "selected" is drawn one way in the app. Present for every slot at
                // zero opacity rather than inserted for one, so moving the selection animates a
                // colour instead of a layer (rule `50-views`). It adds to the glyph's colour, its
                // glow and the `.isSelected` trait; it replaces none of them.
                Capsule()
                    .fill(.white.opacity(isActive ? LiquidGlass.Selection.fillOpacity : 0))
                    .strokeBorder(.white.opacity(isActive ? LiquidGlass.Selection.rimOpacity : 0), lineWidth: 1)
            }
            .contentShape(Rectangle())
```

  The bar's own `.animation(.smooth(duration: 0.28), value: selection)` already covers it.

- [ ] **Step 4: It compiles and the tab tests still pass.** Run the glass-suite command with
  `SUITE=AppTabTests`.

Expected: `✔ Test run with 6 tests in 1 suite passed`, `** TEST SUCCEEDED **`.

- [ ] **Step 5: Stage**

```bash
git add WaterBuddy/LiquidGlassModifier.swift WaterBuddy/HistoryView.swift WaterBuddy/RootTabView.swift
```

---

### Task 5: On the simulator — render both glass paths and measure

**Files:** create `WaterBuddyUITests/ZZGlassProbe.swift`, then **delete it** before anything else is
staged (`tasks/lessons.md`, 2026-10-07, *Renders without a product hook*). Create
`$SP/measure.swift`, which is outside the repository and stays there.

Run this **before** Task 7: the probe's first capture needs the first-run screen, and the UI suite
completes setup.

- [ ] **Step 1: Write the probe.** `WaterBuddyUITests/ZZGlassProbe.swift`:

```swift
// THROWAWAY — deleted before anything is staged. Captures for
// docs/superpowers/plans/2026-10-09-premium-redesign-stage-1.md, Task 5.
import XCTest

final class ZZGlassProbe: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    private func shot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Frames, in points, of the elements the measurements are taken beside. Multiply by the
    /// screen's scale to get pixels.
    private func frames(_ name: String, of elements: [(String, XCUIElement)]) {
        let lines = elements.map { label, element in
            element.exists ? "\(label): \(element.frame)" : "\(label): MISSING"
        }
        let attachment = XCTAttachment(string: lines.joined(separator: "\n"))
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func vessel(_ app: XCUIApplication, _ name: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "\(name),")).firstMatch
    }

    /// Today's millilitres, read from the vessel's spoken value: "45 percent. 900 of 2000
    /// millilitres." The checks below compare before and after, so the probe can be run again on
    /// a simulator that already holds its own pours.
    private func homeTotal(_ app: XCUIApplication) -> Int {
        let words = (app.otherElements["Today's hydration"].value as? String ?? "").split(separator: " ")
        return words.count > 2 ? Int(words[2]) ?? -1 : -1
    }

    /// First run, then every screen. Taps one of each interactive glass control on the way, so a
    /// control whose glass swallowed its tap fails here by name.
    func testA_WalkTheScreens() {
        let largeText = XCUIApplication()
        largeText.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        largeText.launch()
        if largeText.buttons["Get Started"].waitForExistence(timeout: 8) {
            sleep(2)
            shot("00-first-run-axxxl")
        }
        largeText.terminate()

        let app = XCUIApplication()
        app.launch()

        let getStarted = app.buttons["Get Started"]
        if getStarted.waitForExistence(timeout: 8) {
            sleep(2)
            shot("01-first-run")
            frames("01-first-run-frames", of: [("Get Started", getStarted), ("Daily water goal", app.sliders["Daily water goal"])])
            getStarted.tap()
        }

        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 10), "Get Started did not reach Home")
        sleep(2)
        shot("02-home-empty")

        app.buttons["History"].tap()
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 5), "the History tab did not open")
        sleep(2)
        shot("03-history-empty")

        app.buttons["Home"].tap()
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5))
        let beforePours = homeTotal(app)
        vessel(app, "Bottle").tap()
        sleep(1)
        vessel(app, "Glass").tap()
        sleep(1)
        vessel(app, "Cup").tap()
        sleep(4)
        shot("04-home-poured")
        frames("04-home-frames", of: [
            ("vessel", app.otherElements["Today's hydration"]),
            ("Cup", vessel(app, "Cup")), ("Glass", vessel(app, "Glass")), ("Bottle", vessel(app, "Bottle")),
            ("tab Home", app.buttons["Home"]), ("tab History", app.buttons["History"]), ("tab Settings", app.buttons["Settings"]),
        ])
        let afterPours = homeTotal(app)
        XCTAssertEqual(afterPours - beforePours, 900, "a quick-add tap did not log: Bottle 500, Glass 250, Cup 150")

        app.buttons["History"].tap()
        XCTAssertTrue(app.staticTexts["Last 7 days"].waitForExistence(timeout: 5))
        sleep(2)
        shot("05-history")
        let rows = app.buttons.matching(NSPredicate(format: "label ENDSWITH %@", " millilitres"))
        frames("05-history-frames", of: [
            ("Last 7 days", app.staticTexts["Last 7 days"]), ("day Today", app.buttons["Today"]),
            ("first row", rows.firstMatch), ("Add a serving", app.buttons["Add a serving"]),
            ("tab History", app.buttons["History"]),
        ])

        rows.firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Edit serving"].waitForExistence(timeout: 5), "a serving row's tap did not open the sheet")
        sleep(2)
        shot("06-sheet")
        frames("06-sheet-frames", of: [("Save", app.buttons["Save"]), ("Cancel", app.buttons["Cancel"])])
        app.buttons["Cancel"].tap()
        // The sheet's own title going away, not History's card being there: the card stays in
        // the tree behind a sheet, so its existence proves nothing about the sheet.
        XCTAssertTrue(app.staticTexts["Edit serving"].waitForNonExistence(timeout: 5), "Cancel did not dismiss the sheet")
        sleep(1)

        app.buttons["Add a serving"].tap()
        // The sheet's title is a static text; the + button carries the same words as a button.
        XCTAssertTrue(app.staticTexts["Add a serving"].waitForExistence(timeout: 5), "the + button's tap did not open the sheet")
        sleep(1)
        app.buttons["Save"].tap()
        XCTAssertTrue(app.staticTexts["Add a serving"].waitForNonExistence(timeout: 5), "Save did not dismiss the sheet")
        sleep(1)
        // The sheet opens on the Glass, 250 ml. The total is read back on Home, from the vessel's
        // spoken value, rather than the rows counted: the list is lazy, and a count stops growing
        // once rows run off the screen. History's header does not expose its value to a query.
        app.buttons["Home"].tap()
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5))
        sleep(1)
        XCTAssertEqual(homeTotal(app) - afterPours, 250, "Save did not add the Glass")

        app.buttons["Settings"].tap()
        XCTAssertTrue(app.sliders["Daily water goal"].waitForExistence(timeout: 5))
        sleep(2)
        shot("07-settings")
        frames("07-settings-frames", of: [
            ("Daily water goal", app.sliders["Daily water goal"]), ("Cup", app.sliders["Cup"]),
            ("Smart reminders", app.switches["Smart reminders"]), ("tab Settings", app.buttons["Settings"]),
        ])
        app.swipeUp()
        sleep(2)
        shot("08-settings-scrolled")
    }

    /// The sheet at the largest text size: *Save* and *Cancel* inside their capsules.
    func testB_TheSheetAtTheLargestTextSize() {
        let app = XCUIApplication()
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.buttons["History"].waitForExistence(timeout: 10))
        app.buttons["History"].tap()
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 5))
        app.buttons["Add a serving"].tap()
        XCTAssertTrue(app.buttons["Save"].waitForExistence(timeout: 5))
        sleep(2)
        shot("09-sheet-axxxl")
        app.buttons["Cancel"].tap()
    }
}
```

- [ ] **Step 2: Run it on Apple's glass and export**

```bash
pgrep -x xcodebuild >/dev/null || xcrun simctl shutdown all
rm -rf $SP/probe-26.xcresult $SP/shots-26
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyUITests/ZZGlassProbe -parallel-testing-enabled NO \
  -resultBundlePath $SP/probe-26.xcresult > $SP/p26.log 2>&1; echo "exit $?"
grep -E 'Executed [0-9]+ test|error:|XCTAssert|\*\* TEST' $SP/p26.log | sort -u | cut -c1-240
xcrun xcresulttool export attachments --path $SP/probe-26.xcresult --output-path $SP/shots-26
cat $SP/shots-26/manifest.json | head -80
```

Expected: `Executed 2 tests, with 0 failures`, `** TEST SUCCEEDED **`, and a manifest naming the ten
captures (`00` to `09`) and five frame lists. A failed `XCTAssert` names the control whose tap did not land
(Review Focus 1): stop and report it with the capture before it.

- [ ] **Step 3: Look at every capture.** Open each PNG with `Read`. Check, and write down for the
  report:
  - `01-first-run`, `00-first-run-axxxl`: *Get Started* is a white capsule with deep-blue text, fully
    inside its capsule at the largest text size; the goal card is glass.
  - `02-home-empty`, `04-home-poured`: the vessel and the three vessels are glass; nothing is blank or
    black; the readout is legible over the water.
  - `05-history`, `03-history-empty`: the card, the rows and `+` are glass; the shown day's rim is
    there.
  - `06-sheet`, `09-sheet-axxxl`: *Save* is white with deep-blue text, *Cancel* is glass, neither label
    leaves its capsule.
  - `07-settings`, `08-settings-scrolled`: four glass cards.
  - Every capture after the first: the tab bar, with a rimmed lozenge behind the selected tab.

  A blank pane, a clipped label or a missing lozenge is a defect of this change: stop and report it.

- [ ] **Step 4: Write the sampler.** `$SP/measure.swift`:

```swift
// Scratchpad tool, not part of the repository. Reads a rectangle of GROUND from a screenshot and
// prints the contrast of each foreground against it.
//   swift measure.swift <png> <x> <y> <w> <h> <foreground>...
// Pixels, origin top-left. A foreground is `white:<alpha>` or `rgb:<r>,<g>,<b>` (0...1).
import AppKit

let arguments = CommandLine.arguments
guard arguments.count >= 7,
      let data = FileManager.default.contents(atPath: arguments[1]),
      let image = NSBitmapImageRep(data: data),
      let x0 = Int(arguments[2]), let y0 = Int(arguments[3]),
      let width = Int(arguments[4]), let height = Int(arguments[5]) else {
    print("usage: swift measure.swift <png> <x> <y> <w> <h> white:<alpha>|rgb:<r>,<g>,<b> ...")
    exit(2)
}

func linear(_ c: Double) -> Double { c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4) }
func luminance(_ c: (Double, Double, Double)) -> Double {
    0.2126 * linear(c.0) + 0.7152 * linear(c.1) + 0.0722 * linear(c.2)
}
func contrast(_ a: Double, _ b: Double) -> Double { (max(a, b) + 0.05) / (min(a, b) + 0.05) }

var sum = (0.0, 0.0, 0.0)
var lightest = (0.0, 0.0, 0.0)
var darkest = (1.0, 1.0, 1.0)
for y in y0..<(y0 + height) {
    for x in x0..<(x0 + width) {
        guard let pixel = image.colorAt(x: x, y: y)?.usingColorSpace(.sRGB) else { continue }
        let c = (Double(pixel.redComponent), Double(pixel.greenComponent), Double(pixel.blueComponent))
        sum = (sum.0 + c.0, sum.1 + c.1, sum.2 + c.2)
        if luminance(c) > luminance(lightest) { lightest = c }
        if luminance(c) < luminance(darkest) { darkest = c }
    }
}
let count = Double(width * height)
let mean = (sum.0 / count, sum.1 / count, sum.2 / count)
print(String(format: "ground  mean (%.3f, %.3f, %.3f)  lightest (%.3f, %.3f, %.3f)  darkest (%.3f, %.3f, %.3f)",
             mean.0, mean.1, mean.2, lightest.0, lightest.1, lightest.2, darkest.0, darkest.1, darkest.2))

for spec in arguments.dropFirst(6) {
    let parts = spec.split(separator: ":")
    guard parts.count == 2 else { continue }
    // The colour the eye sees: the foreground composited over a given ground pixel.
    let seen: ((Double, Double, Double)) -> (Double, Double, Double)
    if parts[0] == "white", let alpha = Double(parts[1]) {
        seen = { g in (alpha + (1 - alpha) * g.0, alpha + (1 - alpha) * g.1, alpha + (1 - alpha) * g.2) }
    } else if parts[0] == "rgb" {
        let v = parts[1].split(separator: ",").compactMap { Double($0) }
        guard v.count == 3 else { continue }
        seen = { _ in (v[0], v[1], v[2]) }
    } else { continue }
    func ratio(_ g: (Double, Double, Double)) -> Double { contrast(luminance(seen(g)), luminance(g)) }
    print(String(format: "%@  mean %.2f:1  worst %.2f:1", spec, ratio(mean), min(ratio(lightest), ratio(darkest))))
}
```

- [ ] **Step 5: Measure every pair on Apple's glass.** For each row of the table below, find the text
  in its capture (the frame lists give the neighbourhood in points; the iPhone 17's scale is 3), then
  sample a rectangle of **clean ground inside the same pane, beside the text**: at least 8 by 8
  pixels, touching no glyph, no rim and no bar (`tasks/lessons.md`: a sample that takes in glyph ink
  reads the text as its own ground). Run, for example:

```bash
swift $SP/measure.swift $SP/shots-26/<file>.png <x> <y> <w> <h> white:1 white:0.72 rgb:0,0.85,0.85
```

  Record the **worst** figure for each.

| Capture | Pane | What is measured | Foreground | Floor |
|---|---|---|---|---|
| any, tab bar | bar, outside the lozenge | inactive caption / inactive glyph | `white:0.72` | 4.5 / 3 |
| any, tab bar | bar, inside the lozenge | active caption / cyan glyph / the rim | `white:1` / `rgb:0,0.85,0.85` / `white:0.55` | 4.5 / 3 / 3 |
| `05-history` | week card | title / weekday letter / average and best / disclosure | `white:1` / `white:0.72` / `white:0.75` / `white:0.70` | 4.5 each |
| `05-history` | week card | goal line / bar fill / shown day's rim | `white:0.45` / `rgb:0,0.85,0.85` / `white:0.55` | 3 each |
| `05-history` | week card, inside the shown day's rim | the shown day's letter | `white:1` | 4.5 |
| `05-history` | serving row | amount / time / drop glyph | `white:1` / `white:0.75` / `rgb:0,0.85,0.85` | 4.5 / 4.5 / 3 |
| `05-history` | `+` disc | the glyph | `white:1` | 3 |
| `03-history-empty` | empty-state card | title / body | `white:1` / `white:0.70` | 4.5 each |
| `06-sheet` | sheet card | *ml* beside the readout | `white:0.8` | 4.5 |
| `06-sheet` | *Cancel* capsule | the label | `white:1` | 4.5 |
| `07-settings` | goal card | title / *ml* / range labels | `white:1` / `white:0.8` / `white:0.6` | 4.5 each |
| `07-settings` | vessels card | names and amounts / note / glyph | `white:0.75` / `white:0.70` / `rgb:0,0.85,0.85` | 4.5 / 4.5 / 3 |
| `08-settings-scrolled` | reminders and language cards | titles and rows / footnotes | `white:1` / `white:0.75` | 4.5 each |
| `01-first-run` | goal card | *ml* / range labels | `white:0.8` / `white:0.6` | 4.5 each |
| `04-home-poured` | quick-add discs | the glyph | `white:1` | 3 |
| `02-home-empty` | vessel, glass only behind the text | `%` / the millilitre line | `white:0.8` / `white:0.85` | 3 / 4.5 |
| `04-home-poured` | vessel, at the readout | `%` / the millilitre line | `white:0.8` / `white:0.85` | 3 / 4.5 |

  The two primary buttons are not in the table: their fill is solid, and Task 3's test derives their
  figure.

- [ ] **Step 6: Decide from the table.**
  - **Every worst figure at or over its floor:** go to Step 7.
  - **A pair under its floor on Apple's glass:** apply the one remedy this plan authorises, a dark
    scrim between the regular glass and its content, the hand-made stack's own idea. In
    `LiquidGlassModifier.swift`, add inside `enum LiquidGlass`, after `systemVariant`:

```swift

    /// A black scrim laid over Apple's regular glass and under the content.
    ///
    /// Not zero because a measured pair required it: the figures, and the pair that forced this
    /// value, are in `docs/DESIGN.md`. Never above the hand-made stack's own frosted scrim.
    nonisolated static let systemScrimOpacity = 0.08
```

    and in `systemPane`, replace `content.glassEffect(systemGlass, in: shape)` with

```swift
            content
                .background {
                    // Only under the regular variant. The clear one is the vessel, whose
                    // readout has `WaterReadabilityScrim`.
                    shape.fill(Color.black.opacity(
                        LiquidGlass.systemVariant(density: density, interactive: interactive) == .regular
                            ? LiquidGlass.systemScrimOpacity : 0
                    ))
                }
                .glassEffect(systemGlass, in: shape)
```

    and add to `LiquidGlassRoutingTests`:

```swift
    /// The scrim over Apple's glass is a correction, bounded by the stack it borrows the idea
    /// from.
    @Test func theSystemScrimNeverExceedsTheHandMadeFrostedOne() {
        #expect(LiquidGlass.systemScrimOpacity > 0)
        #expect(LiquidGlass.systemScrimOpacity <= LiquidGlass.Density.frosted.scrimOpacity(for: .dark))
    }
```

    Then repeat Steps 2 and 5. If a pair still fails, raise the value one rung at a time through
    `0.12, 0.16, 0.20, 0.24, 0.28`, repeating Steps 2 and 5 each time, and stop at the first rung
    where every pair passes. **If a pair fails at `0.28`, or the failing pair is in the vessel, stop
    and report the table and the captures to the owner.** A different remedy is a design decision.

    > **Superseded on 2026-10-09 by the owner's rulings, after the stop above was reached.** The
    > scrim capped at `0.28` could not close it, so none of this step's code was written. The
    > remedy is Apple's own tint, `Glass.regular.tint(.black.opacity(…))`, through
    > `LiquidGlass.systemTintOpacity(for:)` — `0` for the clear variant — with the test
    > `onlyTheRegularVariantIsDarkened`; the goal slider's range labels go from white `0.6` to
    > `0.75` in `SettingsView.swift` (added to this plan's file list) and `GoalSetupView.swift`.
    > The value was climbed one rung at a time, each rendered and measured where the pane is
    > lightest: `0.40` and `0.44` failed at rest; `0.48` passed at rest and failed once the final
    > review had the aurora followed through its swing; **`0.52` is the first that passes** on
    > iOS 27.0, whose glass is lighter than iOS 26.5's. The week card's goal line, which no rung
    > carried at white `0.45`, is `0.55`. The pinned simulators never came back; by a
    > third ruling the passes ran on iOS 27.0's *iPhone 17* and on three simulators created for
    > them (iOS 27.0, 26.5 and 18.6). The 26.5 pass found what Review Focus 1 feared: a serving
    > row ignored a tap on its bare glass. `systemPane` now ends in `.contentShape(shape)`, and
    > `GoalSetupUITests.testAServingRowOpensItsSheetWhereverItIsTapped` (a seventh source file)
    > holds it. The ledger has every figure.
    The first-run captures are not retaken after the first pass (setup is complete); the goal card's
    two figures only improve under a darker pane.

- [ ] **Step 7: Increase Contrast.** Record the setting, switch it on, run the probe again, look, and
  put it back:

```bash
xcrun simctl ui EE56B958-E33F-40A3-99EA-B14D45963685 increase_contrast
xcrun simctl ui EE56B958-E33F-40A3-99EA-B14D45963685 increase_contrast enabled
rm -rf $SP/probe-26c.xcresult $SP/shots-26c
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyUITests/ZZGlassProbe -parallel-testing-enabled NO \
  -resultBundlePath $SP/probe-26c.xcresult > $SP/p26c.log 2>&1; echo "exit $?"
xcrun xcresulttool export attachments --path $SP/probe-26c.xcresult --output-path $SP/shots-26c
xcrun simctl ui EE56B958-E33F-40A3-99EA-B14D45963685 increase_contrast disabled
```

Expected: the first line prints `disabled`; the run passes (the first-run captures are simply absent
now). Open `05-history`, `07-settings` and `06-sheet` and re-measure the three tightest pairs from
Step 5. None may fall below its floor with the setting on.

- [ ] **Step 8: Reduce Transparency — attempted, not promised.** `simctl ui` has no option for it
  (`docs/AI_CONTEXT.md`) and `defaults write` is on the deny list, so the route is the Settings app.
  Add this method to the probe, run it alone, then run `testA_WalkTheScreens` and export as in Step 2
  to `$SP/shots-26rt`:

```swift
    /// Flips Reduce Transparency in Settings. The labels are iOS's and are read from the dump on a
    /// failure, never guessed twice.
    func testC_ToggleReduceTransparency() {
        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        settings.terminate()
        settings.launch()

        func open(_ label: String) {
            let cell = settings.staticTexts[label].firstMatch
            var swipes = 0
            while !(cell.exists && cell.isHittable) && swipes < 8 {
                settings.swipeUp()
                swipes += 1
            }
            guard cell.exists && cell.isHittable else {
                let dump = XCTAttachment(string: settings.debugDescription)
                dump.name = "missing \(label)"
                dump.lifetime = .keepAlways
                add(dump)
                return XCTFail("Settings shows no row labelled \(label)")
            }
            cell.tap()
            sleep(1)
        }

        open("Accessibility")
        open("Display & Text Size")
        let toggle = settings.switches["Reduce Transparency"].firstMatch
        XCTAssertTrue(toggle.waitForExistence(timeout: 5), "no Reduce Transparency switch")
        toggle.switches.firstMatch.exists ? toggle.switches.firstMatch.tap() : toggle.tap()
        sleep(1)
        shot("10-reduce-transparency-switch")
    }
```

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyUITests/ZZGlassProbe/testC_ToggleReduceTransparency -parallel-testing-enabled NO > $SP/p26rt.log 2>&1; echo "exit $?"
```

  With the setting on, every pane must be the opaque indigo fill with a lit rim, on glass and nowhere
  else, and the primary buttons unchanged. Run `testC_ToggleReduceTransparency` once more afterwards
  to switch it back off, and confirm with its capture. **Two failed attempts at driving Settings end
  this step:** ask the owner to flip *Settings → Accessibility → Display & Text Size → Reduce
  Transparency* in the booted simulator by hand, capture with `testA_WalkTheScreens`, and ask them to
  flip it back. If neither route works, report the step as not rendered. The branch itself is the old
  one, statement for statement, and Task 1 pins when it is taken.

- [ ] **Step 9: The fallback, on iOS 18.6.** The four glass suites, then the probe:

```bash
xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=18.6,name=iPhone 16' \
  -only-testing:WaterBuddyTests/LiquidGlassRoutingTests -only-testing:WaterBuddyTests/LiquidGlassInteractionTests \
  -only-testing:WaterBuddyTests/LiquidGlassBaseTests -only-testing:WaterBuddyTests/PrimarySurfaceTests \
  -parallel-testing-enabled NO > $SP/t18.log 2>&1; echo "exit $?"
grep -E 'error:|✔ Test run|✘ Test run|Expectation failed|\*\* TEST' $SP/t18.log | sed -E 's#^/[^ ]*/##' | sort -u | cut -c1-220
```

Expected: `✔ Test run with 17 tests in 4 suites passed` (18 if Step 6 added one).
`theAvailabilityFlagMatchesTheRunningSystem` passing here is the proof the flag is `false` below
iOS 26.

```bash
rm -rf $SP/probe-18.xcresult $SP/shots-18
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=18.6,name=iPhone 16' \
  -only-testing:WaterBuddyUITests/ZZGlassProbe/testA_WalkTheScreens \
  -only-testing:WaterBuddyUITests/ZZGlassProbe/testB_TheSheetAtTheLargestTextSize \
  -parallel-testing-enabled NO -resultBundlePath $SP/probe-18.xcresult > $SP/p18.log 2>&1; echo "exit $?"
grep -E 'Executed [0-9]+ test|error:|XCTAssert|\*\* TEST' $SP/p18.log | sort -u | cut -c1-240
xcrun xcresulttool export attachments --path $SP/probe-18.xcresult --output-path $SP/shots-18
xcrun simctl shutdown all
```

Expected: `Executed 2 tests, with 0 failures`. Look at every capture as in Step 3: the panes are the
hand-made glass, as on the shipped app, with the two white buttons and the lozenge added. Then
measure four pairs on this path and compare each with its figure in `docs/DESIGN.md`: the tab bar's
inactive caption (recorded 4.89:1), the active caption inside the new lozenge (floor 4.5; recorded
7.66:1 without a lozenge), the week card's disclosure (5.49:1) and the vessels note (5.50:1). A
recorded figure that moved by more than 0.3 without this change touching its pane is a finding to
report, not to fix here. **If the active caption inside the lozenge is under 4.5:1 on either path,
lower `LiquidGlass.Selection.fillOpacity` to the largest of `0.06`, `0.04`, `0.02` that passes on
both, and re-measure History's shown day, which shares it.**

- [ ] **Step 10: Delete the probe and prove it is gone**

```bash
rm WaterBuddyUITests/ZZGlassProbe.swift
git status --short
```

Expected: no line for `ZZGlassProbe.swift`, and no new untracked file under a target folder. Keep the
measured table: Task 8 hands it to the docs.

- [ ] **Step 11: Stage** whatever Steps 6 and 9 changed:

```bash
git add WaterBuddy/LiquidGlassModifier.swift WaterBuddyTests/LiquidGlassTests.swift
```

---

### Task 6: The rules

**Files:** `.claude/rules/60-design-system.md`, `.claude/rules/15-project.md`.

The spec's §10 approved these in summary; the wording below is what stage 1 applies. `.claude/` changes
only when the owner decides, and approving this plan is that decision for exactly this text. Apply it
verbatim; never re-word it while applying it.

- [ ] **Step 1: `60-design-system.md`, the opening line.** Replace

```
Every surface in WaterBuddy is glass over an aurora. The tokens are derived, not chosen — retuning
one by eye breaks a contrast figure somebody measured.
```

with

```
Every surface in WaterBuddy is glass over an aurora, except the one primary surface a screen may
carry. The tokens are derived, not chosen — retuning one by eye breaks a contrast figure somebody
measured.
```

- [ ] **Step 2: `60-design-system.md`, *Glass*.** After the first bullet (the one beginning
  `- Put content on glass only through`), insert:

```
- `.liquidGlass(…)` draws one of three panes, chosen by
  `LiquidGlass.rendering(base:reduceTransparency:systemGlassAvailable:)`: the opaque fill under
  Reduce Transparency; Apple's glass (`glassEffect`) for a `.material` base on iOS 26 and later; the
  hand-made stack everywhere else — a `.flat` base, iOS 17 to 25, and the watch until its own stage.
  Never call `glassEffect` at a call site
- The scrim, the tint ceiling, the specular, the lit rim and the two shadows are properties of the
  **hand-made** stack. On Apple's glass none of them is drawn; the system brings its own edge and
  depth
- A selected slot or day is marked with `LiquidGlass.Selection`'s fill **and** rim, present at zero
  opacity when unselected. Never a fill or a rim written as a literal in a view
```

  Then replace `- Elevation is always **two** shadows` with
  `- On the hand-made stack, elevation is always **two** shadows`, and replace
  `- \`compositingGroup()\` precedes the shadows in both branches` with
  `- \`compositingGroup()\` precedes the shadows in both hand-made branches`. The rest of each bullet
  stays.

- [ ] **Step 3: `60-design-system.md`, a new section.** Insert before `## Interaction`:

```
## The primary surface
- A screen's one main action is drawn with `.primarySurface(in:)`: solid white, `Aurora.top` content.
  It is the only surface that is not glass, and a screen carries at most one
- Its shade, its pressed wash, its ring and its shadows come from `LiquidGlass.Primary` and
  `Elevation.raised`. Never hand-roll one from `.background(.white)`
- The surface sets its content's colour. Never give a primary label a `.foregroundStyle` of its own
- It carries no glow. The cyan glow *Get Started* and *Save* once had is retired
- Its contrast is derived, not measured, because its fill is solid:
  `thePrimaryLabelClearsSevenToOneEvenAtTheFootOfTheShade`

```

- [ ] **Step 4: `60-design-system.md`, *Interaction*.** After the bullet beginning
  `- Keep \`interactive\` opt-in`, insert:

```
- On Apple's glass `interactive: true` becomes `Glass.interactive()`. `PressStyle` keeps its recoil on
  both paths and stays the only writer of `glassIsPressed`, which the hand-made stack and the primary
  surface read
```

- [ ] **Step 5: `15-project.md`.** After the bullet beginning
  `  - **The first version check is the control's.**` (it ends `compile-verified only`), insert:

```
  - **The second version check is the glass's.** `LiquidGlassModifier` draws Apple's glass inside
    `#if os(iOS)` and `if #available(iOS 26.0, *)`, and `LiquidGlass.systemGlassAvailable` answers the
    same question for the pure routing function; `theAvailabilityFlagMatchesTheRunningSystem` keeps
    the two in step. The file compiles into four targets on two floors, so the check is compiled for
    the widget extension and both watch targets as well; `#if os(iOS)` keeps the watch on the
    hand-made stack until the redesign's watch stage. Below iOS 26 the path is run-verified on iOS
    18.6 and compile-verified only at 17.0
```

- [ ] **Step 6: Stage**

```bash
git add .claude/rules/60-design-system.md .claude/rules/15-project.md
```

---

### Task 7: The gate and the warning comparison

**Files:** none changed.

- [ ] **Step 1: Read the diff against the rules** before running anything: `git diff --cached` for
  the six source files. Check each of: no colour literal; no magic number in a view; every new static
  a test reads is `nonisolated`; no `TODO`; comments say why; `.buttonStyle(PressStyle())` still on
  both primary buttons; the vessel's `.accessibilityElement` untouched.

- [ ] **Step 2: The five invocations**, foreground, as rule `85-testing` writes them, with the watch
  ones adapted to what this Mac can run:

```bash
pgrep -x xcodebuild >/dev/null || xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests -parallel-testing-enabled NO > $SP/g1.log 2>&1; echo "exit $?"
grep -E '✔ Test run|✘ Test run|Expectation failed|\*\* TEST' $SP/g1.log | cut -c1-220
```

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyUITests -parallel-testing-enabled NO \
  -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests > $SP/g2.log 2>&1; echo "exit $?"
grep -E 'Executed [0-9]+ test|error:|\*\* TEST' $SP/g2.log | sort -u | cut -c1-220
```

```bash
xcodebuild build-for-testing -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'generic/platform=watchOS Simulator' > $SP/g3.log 2>&1; echo "exit $?"
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' > $SP/g4.log 2>&1; echo "exit $?"
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget \
  -destination 'generic/platform=watchOS Simulator' > $SP/g5.log 2>&1; echo "exit $?"
grep -hE '\*\* (BUILD|TEST BUILD)' $SP/g3.log $SP/g4.log $SP/g5.log
```

Expected: `✔ Test run with 385 tests in 48 suites passed` (386 if Task 5 Step 6 added a test;
re-derive the count with `grep -chE '^[[:space:]]*@Test' WaterBuddyTests/*.swift | awk '{s+=$1} END {print s}'`);
`Executed 26 tests, with 0 failures`; `** TEST BUILD SUCCEEDED **`; `** BUILD SUCCEEDED **` twice.
**The watch tests are not run**: no watchOS 26 runtime is installed (known issue #77). Say so in the
report; the watch app and its tests are compiled, and this change leaves the watch on the hand-made
stack by `#if os(iOS)`. A UI run refused as `Busy` (#57):
`xcrun simctl bootstatus EE56B958-E33F-40A3-99EA-B14D45963685 -b`, then run it again and record both.

- [ ] **Step 3: Clean builds of HEAD and of the change, into empty DerivedData**

```bash
rm -rf $SP/wc && mkdir -p $SP/wc/base
git archive HEAD | tar -x -C $SP/wc/base
cp -R $SP/wc/base $SP/wc/change
for f in WaterBuddy/LiquidGlassModifier.swift WaterBuddy/PressStyle.swift WaterBuddy/GoalSetupView.swift \
         WaterBuddy/HistoryView.swift WaterBuddy/RootTabView.swift WaterBuddyTests/LiquidGlassTests.swift; do
  cp "$f" "$SP/wc/change/$f"
done
for side in base change; do
  xcodebuild build-for-testing -project $SP/wc/$side/WaterBuddy.xcodeproj -scheme WaterBuddy \
    -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' -derivedDataPath $SP/wc/dd-$side > $SP/wc/$side-app.log 2>&1; echo "$side app exit $?"
done
```

Then the other three schemes, each its own foreground invocation (the 600 s limit):

```bash
for side in base change; do
  xcodebuild build -project $SP/wc/$side/WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
    -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' -derivedDataPath $SP/wc/dd-$side > $SP/wc/$side-widget.log 2>&1; echo "$side widget exit $?"
done
```

```bash
for side in base change; do
  xcodebuild build -project $SP/wc/$side/WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
    -destination 'generic/platform=watchOS Simulator' -derivedDataPath $SP/wc/dd-$side > $SP/wc/$side-watch.log 2>&1; echo "$side watch exit $?"
done
```

```bash
for side in base change; do
  xcodebuild build -project $SP/wc/$side/WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget \
    -destination 'generic/platform=watchOS Simulator' -derivedDataPath $SP/wc/dd-$side > $SP/wc/$side-watchwidget.log 2>&1; echo "$side watchwidget exit $?"
done
```

If one invocation nears the limit, split it into its two sides.

- [ ] **Step 4: Compare per log, per file and message, line numbers stripped**

```bash
for log in app widget watch watchwidget; do
  for side in base change; do
    grep -E ': warning: ' $SP/wc/$side-$log.log | grep -vE '^\s+\|' \
      | sed -E 's#^/[^ ]*/(WaterBuddy[A-Za-z]*/[^:]+):[0-9]+:[0-9]+: #\1: #' | sort | uniq -c > $SP/wc/$side-$log.warn
  done
  echo "== $log"; diff $SP/wc/base-$log.warn $SP/wc/change-$log.warn && echo identical
done
grep -l 'LiquidGlassModifier.swift\|LiquidGlassTests.swift' $SP/wc/change-*.warn || echo "no warning in the glass files"
```

Expected: `identical` for all four, and `no warning in the glass files`. Any difference is a new
warning: fix it, then run Steps 2 to 4 again.

---

### Task 8: Records, docs — then stop

**Files:** `HISTORY.md`, `tasks/lessons.md`, and whatever `/doc_sync` writes under `docs/` and
`CLAUDE.md`.

- [ ] **Step 1: Append a checkpoint to `HISTORY.md`**, headed
  `## [2026-10-09] — The redesign's foundation: Apple's glass, the primary surface, the selected slot`
  (use the day it is actually written). It records: what changed; the rulings it rests on (the spec
  and its approval; the three items moved out of stage 1); the files touched; and the verification
  **that was actually run**, with real figures: the unit and UI counts and the destination; the watch
  tests as not run and why; the three builds; the warning comparison; Task 5's measured table for both
  glass paths, with the mapping and any scrim value it settled; Increase Contrast; Reduce Transparency
  as rendered or not; and what only the owner's device can show.

- [ ] **Step 2: Append to `tasks/lessons.md`** anything this stage taught that the next would repeat.
  If nothing did, append nothing.

- [ ] **Step 3: Run `/doc_sync`.** It carries the measured figures into `docs/DESIGN.md` (a section
  for Apple's glass beside the existing table, the primary surface's derived figure, the selection
  tokens), corrects the lines there that say Apple's API cannot be called, updates
  `docs/AI_CONTEXT.md` (test counts, gate result, the return to the pinned iOS 26.5 destination, known
  issue #77's remaining half), and retires known issue #79 against `eba1b1e` as the memory of
  2026-10-09 notes.

- [ ] **Step 4: Stage, explicit paths only, and stop**

```bash
git add HISTORY.md tasks/lessons.md docs/ CLAUDE.md \
  docs/superpowers/specs/2026-10-09-premium-redesign-design.md \
  docs/superpowers/plans/2026-10-09-premium-redesign-stage-1.md
git diff --cached --name-status
git diff --name-status
```

Expected: the second list shows only the paths left unstaged on purpose before this stage
(`.claude/settings.json`, the two watch schemes, the three Xcode-rewritten catalogues), and
`Screenshots/census/` stays untracked. **Do not commit.** Report to the owner: what was built, the
measured table, what was not run (the watch tests; anything in Task 5 that could not be rendered),
and the device check below. The commit is theirs, with `/commit`.

**The owner's device check for this stage** — what no simulator shows:

1. Apple's glass on an iPhone on iOS 26 or later, in daylight: every card and control on Home, History
   and Settings.
2. Press a quick-add vessel, `+`, a serving row and *Cancel*: each responds under the finger and acts.
3. *Save* in the sheet: white, obviously the main action, and it dims and recoils when pressed.
4. The tab bar's lozenge follows the selected tab.
5. The Home Screen widget, placed: unchanged from 1.1.
6. If an iPhone below iOS 26 is to hand: the same screens draw the old glass with the two white
   buttons and the lozenge.
