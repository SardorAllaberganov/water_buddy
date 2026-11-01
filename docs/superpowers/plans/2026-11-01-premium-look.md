# One finish: the premium look — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:executing-plans, in the main loop. `CLAUDE.md` has no implementation
> subagent. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give every screen of the iPhone app one finish: data that draws itself, figures that roll, sheets that land, a living
Premium rim, a touch that always answers, and a moment for buying.

**Architecture:** Three small shared parts (`Landing`, `RollingFigure`, the rim's lap) and new `Motion` numbers, then one stage per
surface using them. No store, key or model logic changes but export's `preview`. Every animation is driven by one presentation
flag that a screen owns, so nothing replays on a re-read and no spoken value depends on it.

**Tech Stack:** SwiftUI, swift-testing, XCTest. iOS 17.0 floor: `symbolEffect(.bounce)` and `numericText()` are iOS 17 or older.

**Specs:** `docs/superpowers/specs/2026-11-01-premium-look-design.md` (approved, "go", 2026-11-01), and stage 1's,
`docs/superpowers/specs/2026-11-01-finish-export-design.md`. Executors read both.

**Refinements while planning (each is the code winning over the spec's wording):**
- P1. `Landing` does not force `pageSettlesIn` on, as spec §4 proposed. It simply does not read it, which is simpler.
- P2. `Landing` has no `duration` of its own: a part lands on `Motion.land`, whose response is the 0.5 s the spec names.
- P3. A month's day tick and a chevron's tick already exist (`picks`, `steps`). Spec §4.1 said "gains": only the chevron's bounce
  is new.
- P4. The patterns stand below the fold, so a flag set on entering Month would finish before anyone scrolled to them. They draw
  the first time their row appears, from a second flag on `HistoryView`.
- P5. Settings' Premium card has two forms and only the offer carries a rim. The holder's gains it: it is the card that was paid for.
- P6. A *Thank you* stands in a pane, so the rim has something to run around. Both `held` forms take the pane.
- P7. Digits roll by `numericText()`: they roll in place, they do not tick upward as the board's CSS does. That is the app's own
  vocabulary, and the owner's iPhone judges it.
- P8. Spec M2 lists "the patterns'" figures. The patterns hold times of day and no hero figure, and a clock rolling up from zero
  says nothing, so only their bars draw (Task 15).
- P9. Task 11, Step 5 says no automated run reaches *Thank you*. One can, for its look: a temporary fake `PremiumStore.Source`, never
  staged, reached it on the simulator, recorded. A real purchase through StoreKit still takes a run from Xcode.

## Global Constraints

- **Never commit.** Stage by explicit path and stop; the owner runs `/commit` (rule `90-git`).
- **`xcodebuild` plain and in the foreground, one call per class, no script around it** (`tasks/lessons.md`, 2026-11-01).
- **Never `xcrun simctl shutdown all`:** `iPhone 16 Pro` and `OverlaneDrive 18.6` are booted by another project. List booted devices
  first, and shut down only what this work booted.
- `-parallel-testing-enabled NO` on every test run. Destination `platform=iOS Simulator,OS=27.0,name=iPhone 17`: the runtime makes
  the name unique.
- Count passed plus failed against what the filter chose, and grep the log for *Restarting after unexpected exit*.
- Tests first: seen RED, then GREEN. Never weaken an assertion; if a test and the code disagree, stop and report.
- Motion under about 20 pt or a fifth of a second reads as nothing (`tasks/lessons.md`, 2026-10-12). Show the bold version first.
- No bare `withAnimation`. Each animation is `.animation(_:value:)`, scoped. Every colour from `Aurora`. Volumes stay `Int`.
- A `static` on a `View` that a non-`@MainActor` suite reads is `nonisolated`.
- New suites `LandingTests`, `RollingFigureTests`, `PremiumRimTests` are not `@MainActor`, and join both canary lists.
- Under Reduce Motion nothing travels, and haptics stay.
- A stage that does not feel right on the owner's iPhone stops the run (spec D11). Other follow-up rulings: take the recommended
  option, ledger it in `.superpowers/sdd/2026-11-01-premium-look/progress.md`, report at the end.

## Review Focus

1. **A recap shared mid-draw.** The image must always be the whole card, however fast the user taps *Share*. Pinned in Task 12.
2. **A re-read while the month is on screen.** A pour from the watch or a `refresh()` republishes the same month, and the rings must
   not start again. Pinned in Task 14.
3. **A second chevron tap mid-draw.** The next month draws from nothing, with no ring of the month before left half swept. Pinned in
   Task 14.
4. **A restore, or an approved Ask to Buy.** Neither is a purchase landing here, and neither may set off the moment. Pinned in
   Task 11.
5. **A sheet closed before it lands.** The wait is cancelled, nothing is set on a gone view, and reopening starts from nothing.
   Pinned in Task 1.

---

## Stage 0: the parts

### Task 0: The branch and the rule wording

**Files:** `.claude/rules/60-design-system.md`, `65-accessibility.md`, `70-privacy.md`, `43-concurrency.md`, `85-testing.md`

- [ ] **Step 1: Branch**

```bash
git switch -c feature/premium-look
```

- [ ] **Step 2: Type the wording, and leave it unstaged for the owner** (rule `99-docs-cascade`)

In `60-design-system.md`, *Glass*, replace the rim's line with:

```markdown
- Premium's Settings card, in both its forms, History's locked month, the recap's card, the export sheet's card, Insights' lead
  pane and the paywall's held card are marked with `.premiumRim()` — `Aurora.cyan`, `Aurora.magenta` and `Aurora.blue` stroked around a standard pane —
  and nothing else is. Never a gradient stroke written in a view
- A rim runs one lap of light as it arrives, through `PremiumRim`, and two at a purchase. Never a lap on a loop
```

In *Interaction*, add:

```markdown
- A sheet's content arrives through `Landing`, after the sheet has landed: the sheet comes whole, then what is inside moves. A data
  surface draws from one flag on its screen. Each plays once per arrival: on opening a sheet, entering Month or Insights, or turning
  a month's page, never on a re-read, a return from the background or a row scrolled back into view
```

In *Haptics*, after the first bullet, add:

```markdown
- `goalReached` also marks a purchase landing: the two largest moments the app has
```

In `65-accessibility.md`, *Reduce Motion*, add:

```markdown
- Under Reduce Motion data stands drawn, figures stand final, a sheet's content fades in where it stands and the rim runs no lap.
  Haptics stay. No spoken value reads a flag that drives motion
```

and in *VoiceOver*, replace the export sheet's clause with:

```markdown
- Settings' *Export your servings* is one button — label the title it draws, its line the hint, value *Premium* while
  locked, or the line saying why nothing opened. The export sheet's heading carries the header trait and its close
  button is *Done*. Its card is one element, its label the count, the dates, the file's name and the note; the drawn figure, the
  rows and the line under them are hidden. *Share as a CSV file* is one button whose label is the words it draws
```

In `70-privacy.md`, *The export file*, third limit: "Built when the **card** is tapped, held in **Settings'** state". Fifth limit, add
"The press's haptic is presentation state, gone with the sheet" (remove again if Task 4 drops the haptic).

In `43-concurrency.md` and `85-testing.md`, add `ExportSheetTests`, `LandingTests`, `RollingFigureTests` and `PremiumRimTests` to each
list of suites that are not `@MainActor`.

### Task 1: `Motion`'s new numbers and `Landing`

**Files:**
- Create: `WaterBuddy/Landing.swift`, `WaterBuddyTests/LandingTests.swift`
- Modify: `WaterBuddy/Motion.swift`, `WaterBuddyTests/MotionTests.swift`

**Interfaces — produces:**
- `Motion.draw`, `Motion.drawn(at:)`, `Motion.popped(at:)`, `Motion.roll`, `Motion.drawDuration`, `Motion.drawStagger`,
  `Motion.popStagger`, `Motion.rollDuration`
- `Landing.wait`, `.rise`, `.stagger`, `.longestDelay`, `.delay(order:)`, `.opacity(landed:)`, `.lift(landed:reduceMotion:)`
- `View.lands(_ landed: Bool, order: Int)`, `View.tracksLanding(_ landed: Binding<Bool>)`

- [ ] **Step 1: Write the failing tests.** `WaterBuddyTests/LandingTests.swift`:

```swift
import Foundation
import Testing
@testable import WaterBuddy

/// How a sheet's content arrives, as numbers. Not `@MainActor`: ``Landing`` is `nonisolated` on purpose (rule
/// `43-concurrency`).
struct LandingTests {

    /// Under about 20 pt, motion reads as nothing (`tasks/lessons.md`, 2026-10-12): the owner, holding 10 pt on a phone, saw
    /// the screen "just appear". And a sheet travels further than a tab's page, which comes whole.
    @Test func theRiseIsFarEnoughToBeSeen() {
        #expect(Landing.rise >= 20)
        #expect(Landing.rise > Arrival.rise)
    }

    /// Long enough for the sheet to have landed, short enough that nobody sees it wait.
    @Test func itBeginsAsTheSheetLands() {
        #expect(Landing.wait >= .milliseconds(250))
        #expect(Landing.wait <= .milliseconds(500))
    }

    @Test func eachPartFollowsTheOneAboveIt() {
        #expect(Landing.delay(order: 0) == 0)
        #expect(Landing.delay(order: 1) > Landing.delay(order: 0))
        #expect(Landing.delay(order: 2) > Landing.delay(order: 1))
    }

    @Test func aLongSheetIsNotKeptWaiting() {
        #expect(Landing.delay(order: 500) == Landing.longestDelay)
        #expect(Landing.delay(order: -3) == 0)
        #expect(Landing.longestDelay + Motion.landResponse <= 1)
    }

    /// As ``Arrival/hiddenOpacity``: at exactly zero SwiftUI drops a view from the accessibility tree.
    @Test func aPartThatHasNotLandedIsNeverAtExactlyNothing() {
        #expect(Landing.opacity(landed: false) > 0)
        #expect(Landing.opacity(landed: true) == 1)
    }

    @Test func underReduceMotionAPartFadesWhereItStands() {
        #expect(Landing.lift(landed: false, reduceMotion: true) == 0)
        #expect(Landing.lift(landed: false, reduceMotion: false) == Landing.rise)
        #expect(Landing.lift(landed: true, reduceMotion: false) == 0)
    }

    /// Review Focus 5: a sheet dragged away at once sets nothing on a view that has gone.
    @Test func aSheetClosedBeforeItLandsSetsNothing() async {
        let waiting = Task { await Landing.waitForLanding() }
        waiting.cancel()
        #expect(await waiting.value == false)
    }
}
```

Add to `MotionTests`:

```swift
    /// A ring's sweep and a figure's roll are seen, and a month is done before anyone waits for it. Thirty-one days, each
    /// after the last.
    @Test func dataDrawsLongEnoughToBeSeenAndNoLonger() {
        #expect(Motion.drawDuration >= 0.4)
        #expect(Motion.rollDuration >= 0.4)
        #expect(Motion.drawDuration + 31 * Motion.drawStagger <= 1.5)
        #expect(Motion.landResponse + 31 * Motion.popStagger <= 1.5)
    }
```

- [ ] **Step 2: Run them and verify RED** (a build failure naming `Landing` is RED)

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/LandingTests -only-testing:WaterBuddyTests/MotionTests -parallel-testing-enabled NO
```

- [ ] **Step 3: Implement.** Add to `Motion`, before `// MARK: Water`:

```swift
    // MARK: Data drawing itself

    /// How long a ring takes to sweep to its value, a bar to grow.
    static let drawDuration: Double = 0.6

    /// How long each of a run of data waits for the one before: a month reads as a wave.
    static let drawStagger: Double = 0.018

    /// The same for what pops into place, which is seen one by one.
    static let popStagger: Double = 0.022

    /// How long a figure takes to roll to its value.
    static let rollDuration: Double = 0.8

    /// Data arriving: no overshoot, as a figure's: a ring past its value would show a wrong value.
    static var draw: Animation { .smooth(duration: drawDuration) }

    /// ``draw``, `index` places along a run.
    static func drawn(at index: Int) -> Animation {
        draw.delay(Double(max(index, 0)) * drawStagger)
    }

    /// ``land``, `index` places along a run of what pops: a dot has no value to overshoot.
    static func popped(at index: Int) -> Animation {
        land.delay(Double(max(index, 0)) * popStagger)
    }

    /// A figure rolling to its value.
    static var roll: Animation { .smooth(duration: rollDuration) }
```

Create `WaterBuddy/Landing.swift`:

```swift
//
//  Landing.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 01/11/26.
//

import SwiftUI

/// How a sheet's content arrives: **the sheet slides in whole, and what is inside moves once it has landed.**
///
/// A sheet is a page that slides in, and ``Arrival``'s DocC records what happens when a page's content moves during its
/// slide: the owner saw a header over sections still fading in. So nothing here starts until ``wait`` has passed.
///
/// It rises further than ``Arrival/rise``, which holds a tab's page to a few points. A sheet has come up from the foot of the
/// screen on the user's tap, so a part may travel, and under about 20 pt nobody sees it travel (`tasks/lessons.md`,
/// 2026-10-12).
///
/// It does not read ``EnvironmentValues/pageSettlesIn``. A sheet inherits that `false` from a page that was turned to.
///
/// A value at file scope and `nonisolated`, so `LandingTests` reads it off the main actor (rule `43-concurrency`).
nonisolated enum Landing {

    /// How long a sheet is given to land.
    static let wait: Duration = .milliseconds(350)

    /// How far a part rises, in points.
    static let rise: CGFloat = 28

    /// How long each part waits for the one above it.
    static let stagger: Double = 0.07

    /// The longest any part waits, however far down the sheet it is.
    static let longestDelay: Double = 0.42

    /// How long the part at `order` waits once the sheet has landed.
    static func delay(order: Int) -> Double {
        min(Double(max(order, 0)) * stagger, longestDelay)
    }

    /// Waits for the sheet to land: `false` if it was gone first, so nothing is set on a sheet that has left (rule
    /// `43-concurrency`).
    static func waitForLanding() async -> Bool {
        do { try await Task.sleep(for: wait) } catch { return false }
        return !Task.isCancelled
    }

    /// What a part is drawn at. Never exactly zero (``Arrival/hiddenOpacity``).
    static func opacity(landed: Bool) -> Double {
        landed ? 1 : Arrival.hiddenOpacity
    }

    /// How far below its place a part is drawn. Under Reduce Motion it fades in where it stands.
    static func lift(landed: Bool, reduceMotion: Bool) -> CGFloat {
        landed || reduceMotion ? 0 : rise
    }
}

private struct LandingModifier: ViewModifier {

    let landed: Bool
    let order: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(Landing.opacity(landed: landed))
            .offset(y: Landing.lift(landed: landed, reduceMotion: reduceMotion))
            // Scoped to the flag (rule `50-views`). There is no way out to animate: a sheet leaves whole.
            .animation(landed ? Motion.land.delay(Landing.delay(order: order)) : nil, value: landed)
    }
}

private struct LandingTracker: ViewModifier {

    @Binding var landed: Bool

    func body(content: Content) -> some View {
        content
            .task {
                if await Landing.waitForLanding() { landed = true }
            }
    }
}

extension View {

    /// Draws this view as arriving with its sheet: hidden until `landed`, then risen and faded in, `order` parts after the
    /// first. The sheet owns the flag and keeps it with ``tracksLanding(_:)``.
    func lands(_ landed: Bool, order: Int) -> some View {
        modifier(LandingModifier(landed: landed, order: order))
    }

    /// Keeps a sheet's landing flag: set ``Landing/wait`` after the sheet is built.
    func tracksLanding(_ landed: Binding<Bool>) -> some View {
        modifier(LandingTracker(landed: landed))
    }
}
```

- [ ] **Step 4: Run Step 2's command and verify GREEN:** 7 in `LandingTests` and `MotionTests`' count plus one, 0 failed.

- [ ] **Step 5: Stage**

```bash
git add WaterBuddy/Landing.swift WaterBuddy/Motion.swift WaterBuddyTests/LandingTests.swift WaterBuddyTests/MotionTests.swift
```

### Task 2: `RollingFigure`

**Files:** Create `WaterBuddy/RollingFigure.swift`, `WaterBuddyTests/RollingFigureTests.swift`

**Interfaces — produces:** `RollingFigure(start: String, final: String, rolled: Bool)`, a `View`; `RollingFigure.shown(start:final:rolled:reduceMotion:) -> String`.

- [ ] **Step 1: Write the failing test.** `WaterBuddyTests/RollingFigureTests.swift`:

```swift
import Testing
@testable import WaterBuddy

/// What a rolling figure draws. Not `@MainActor`: the value is `nonisolated` on purpose (rule `43-concurrency`).
struct RollingFigureTests {

    @Test func aFigureStartsAtItsStartAndEndsAtItsValue() {
        #expect(RollingFigure.shown(start: "0/30", final: "23/30", rolled: false, reduceMotion: false) == "0/30")
        #expect(RollingFigure.shown(start: "0/30", final: "23/30", rolled: true, reduceMotion: false) == "23/30")
    }

    /// Rolling is travel, and that setting turns travel off: the figure stands final from the first frame.
    @Test func underReduceMotionAFigureStandsFinal() {
        #expect(RollingFigure.shown(start: "0/30", final: "23/30", rolled: false, reduceMotion: true) == "23/30")
    }
}
```

- [ ] **Step 2: Run and verify RED**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/RollingFigureTests -parallel-testing-enabled NO
```

- [ ] **Step 3: Implement.** `WaterBuddy/RollingFigure.swift`:

```swift
//
//  RollingFigure.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 01/11/26.
//

import SwiftUI

/// A hero figure that rolls once, from `start` to `final`, as its data draws (spec `2026-11-01-premium-look-design.md`, M2).
///
/// Both ends are finished strings, each made by the caller's own formatter, so a figure in any language rolls between two
/// figures in that language. **Never read for VoiceOver:** the element around it speaks the real value from its first frame,
/// and a picture rendered for sharing passes `rolled: true`.
struct RollingFigure: View {

    let start: String
    let final: String
    let rolled: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    nonisolated static func shown(start: String, final: String, rolled: Bool, reduceMotion: Bool) -> String {
        rolled || reduceMotion ? final : start
    }

    var body: some View {
        Text(verbatim: Self.shown(start: start, final: final, rolled: rolled, reduceMotion: reduceMotion))
            .contentTransition(.numericText())
            .animation(Motion.roll, value: rolled)
    }
}
```

- [ ] **Step 4: Run and verify GREEN:** 2 passed.

- [ ] **Step 5: Stage**

```bash
git add WaterBuddy/RollingFigure.swift WaterBuddyTests/RollingFigureTests.swift
```

### Task 3: The rim's lap

**Files:** Modify `WaterBuddy/PremiumRim.swift`. Create `WaterBuddyTests/PremiumRimTests.swift`.

**Interfaces — produces:** `View.premiumRim(lit: Bool = false, laps: Int = 1)`; `PremiumRim.lapDuration`, `.purchaseLaps`, `.lightOpacity(turn:laps:)`. Existing `.premiumRim()` call sites compile unchanged.

- [ ] **Step 1: Write the failing test.** `WaterBuddyTests/PremiumRimTests.swift`:

```swift
import Testing
@testable import WaterBuddy

/// The rim's lap of light. Not `@MainActor`, as ``Motion``'s suite is not (rule `43-concurrency`).
struct PremiumRimTests {

    /// The light must be gone at both ends: a rim at rest is the rim, and a picture rendered for sharing never carries it.
    @Test func theLightIsGoneBeforeItStartsAndWhenItEnds() {
        #expect(PremiumRim.lightOpacity(turn: 0, laps: 1) == 0)
        #expect(PremiumRim.lightOpacity(turn: 1, laps: 1) == 0)
        #expect(PremiumRim.lightOpacity(turn: 2, laps: 2) == 0)
    }

    @Test func theLightIsWholeThroughTheLap() {
        #expect(PremiumRim.lightOpacity(turn: 0.5, laps: 1) == 1)
        #expect(PremiumRim.lightOpacity(turn: 1, laps: 2) == 1)
    }

    /// A spring's overshoot, or a corrupt value, never draws a light below nothing or above whole.
    @Test func theLightStaysInRange() {
        #expect(PremiumRim.lightOpacity(turn: -1, laps: 1) == 0)
        #expect(PremiumRim.lightOpacity(turn: 3, laps: 1) == 0)
    }

    /// Long enough to follow round the card (`tasks/lessons.md`, 2026-10-12), and a purchase is the bigger of the two.
    @Test func aLapIsSeenAndAPurchaseRunsLonger() {
        #expect(PremiumRim.lapDuration >= 1)
        #expect(PremiumRim.purchaseLaps > 1)
    }
}
```

- [ ] **Step 2: Run and verify RED**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/PremiumRimTests -parallel-testing-enabled NO
```

- [ ] **Step 3: Implement.** Replace `PremiumRim.swift`'s type and extension with:

```swift
/// Premium's mark: `Aurora`'s cyan, magenta and blue stroked around a standard pane (spec
/// `2026-10-21-premium-paywall-and-monthly-design.md` §3.5, rule `60-design-system`). The one place
/// the gradient is spelled. The pane under it stays the screen's own glass — the canvas's near-opaque
/// fill is not taken — and the rim is drawn over it, outside the pane's content, so it never changes
/// what a reader sees inside.
///
/// **It runs one lap of light as it arrives** (spec `2026-11-01-premium-look-design.md`, M4), from a flag its screen owns:
/// white, a sixth of the way round, gone at both ends. Never on a loop, never under Reduce Motion, and never in a picture
/// rendered for sharing, whose `lit` stays `false`.
struct PremiumRim: ViewModifier {

    /// The canvas's 1.5 pt.
    static let width: CGFloat = 1.5

    /// How long one lap takes.
    nonisolated static let lapDuration: Double = 1.5

    /// A purchase's laps: the largest moment the app has.
    nonisolated static let purchaseLaps = 2

    /// The share of a lap the light takes to come up, and to go.
    nonisolated private static let fade: Double = 0.12

    /// How strong the light is `turn` laps round, of `laps`.
    nonisolated static func lightOpacity(turn: Double, laps: Int) -> Double {
        max(0, min(1, turn / fade, (Double(laps) - turn) / fade))
    }

    let lit: Bool
    let laps: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: LiquidGlass.cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Aurora.cyan, Aurora.magenta, Aurora.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: Self.width
                    )
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
            .overlay {
                // Present at nothing while the flag is down, so what animates is a light and not a layer (rule `50-views`).
                RimLight(turn: lit && !reduceMotion ? Double(laps) : 0, laps: laps)
                    .animation(lit ? .easeInOut(duration: Self.lapDuration * Double(laps)) : nil, value: lit)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
    }
}

/// The light itself: an arc of an angular gradient, turned by `turn`, in the rim's own shape. `Animatable`, so each frame draws
/// its own angle; a `Gradient` does not interpolate on its own.
private struct RimLight: View, Animatable {

    var turn: Double
    let laps: Int

    var animatableData: Double {
        get { turn }
        set { turn = newValue }
    }

    private static let arc = Gradient(stops: [
        .init(color: .white.opacity(0), location: 0.8),
        .init(color: .white, location: 0.94),
        .init(color: .white.opacity(0), location: 1)
    ])

    var body: some View {
        RoundedRectangle(cornerRadius: LiquidGlass.cornerRadius, style: .continuous)
            .strokeBorder(
                AngularGradient(gradient: Self.arc, center: .center, angle: .degrees(turn * 360)),
                lineWidth: PremiumRim.width * 1.6
            )
            .opacity(PremiumRim.lightOpacity(turn: turn, laps: laps))
    }
}

extension View {

    /// Marks a pane as Premium's (rule `60-design-system` lists which). `lit`, once up, runs `laps` of light.
    func premiumRim(lit: Bool = false, laps: Int = 1) -> some View {
        modifier(PremiumRim(lit: lit, laps: laps))
    }
}
```

- [ ] **Step 4: Run and verify GREEN:** 4 passed. Read the build log for a new warning on `RimLight`'s `Animatable`: a new
concurrency warning is a failure (`CLAUDE.md`), and `WaveShape` is the codebase's precedent for how `animatableData` is written.

- [ ] **Step 5: Stage**

```bash
git add WaterBuddy/PremiumRim.swift WaterBuddyTests/PremiumRimTests.swift
```

---

## Stage 1: Export

Everything here is `2026-11-01-finish-export-design.md`, whose §3 and §4 are read beside these tasks. Its D6's rise is `Landing`'s.

### Task 4: Measure the share press first

**Files:** Modify `WaterBuddy/ExportSheet.swift`, `WaterBuddy/RecapSheet.swift`

- [ ] **Step 1: Add the press to both sheets' `ShareLink`, after `.buttonStyle(PressStyle())`**

```swift
        // A press, not a share: `ShareLink` reports nothing, and rule `70-privacy` forbids asking. Presentation state, gone with
        // the sheet.
        .simultaneousGesture(TapGesture().onEnded { shares += 1 })
```

with `@State private var shares = 0` and `.sensoryFeedback(Haptics.confirm, trigger: shares)` on each sheet's root.

- [ ] **Step 2: Measure on three runtimes.** The share sheet must still open and the sheet must still scroll at the largest text size:

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyUITests/ExportUITests/testAHoldersExportShowsItsSummaryAndOffersTheShareSheet -only-testing:WaterBuddyUITests/ExportUITests/testTheShareButtonIsReachableAtTheLargestTextSize -parallel-testing-enabled NO
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' -only-testing:WaterBuddyUITests/ExportUITests/testAHoldersExportShowsItsSummaryAndOffersTheShareSheet -only-testing:WaterBuddyUITests/ExportUITests/testTheShareButtonIsReachableAtTheLargestTextSize -parallel-testing-enabled NO
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=18.6,name=iPhone 16' -only-testing:WaterBuddyUITests/ExportUITests/testAHoldersExportShowsItsSummaryAndOffersTheShareSheet -only-testing:WaterBuddyUITests/ExportUITests/testTheShareButtonIsReachableAtTheLargestTextSize -parallel-testing-enabled NO
```

Each call runs separately and is watched to its end. Expected: 2 passed on each.

- [ ] **Step 3: Decide, and ledger it.** All three pass: keep it. Any fails: remove Step 1's code from both sheets, remove the rule's added sentence, and record that D8 fell.

- [ ] **Step 4: Stage**

```bash
git add WaterBuddy/ExportSheet.swift WaterBuddy/RecapSheet.swift
```

### Task 5: The file's first lines

**Files:** Modify `WaterBuddy/ServingsExport.swift`, `WaterBuddyTests/ServingsExportTests.swift`

**Interfaces — produces:** `ServingsExport.preview: [String]`, `ServingsExport.moreServings: Int`.

- [ ] **Step 1: Write the failing tests.** Add to `ServingsExportTests`:

```swift
    private func previewFile(servings: Int) throws -> ServingsExport {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "UTC"))
        calendar.locale = Locale(identifier: "en_US_POSIX")
        let start = Date(timeIntervalSince1970: 1_780_000_000)
        let rows = (0..<servings).map {
            ServingsExport.Serving(amount: 250 + $0, timestamp: start.addingTimeInterval(Double($0) * 3_600))
        }
        guard case .file(let export) = ServingsExport.outcome(of: rows, today: start, calendar: calendar) else {
            Issue.record("no file")
            throw CancellationError()
        }
        return export
    }

    /// The sheet says it shows what will leave, so what it shows is cut from the bytes, not written beside them.
    @Test func thePreviewIsTheFilesOwnFirstLines() throws {
        let export = try previewFile(servings: 40)
        let text = try #require(String(data: export.data, encoding: .utf8))
        let lines = text.components(separatedBy: "\r\n")
        #expect(export.preview == Array(lines.prefix(6)))
        #expect(export.preview.first == "date,time,amount_ml")
    }

    @Test func aShortFileIsPreviewedWhole() throws {
        let export = try previewFile(servings: 3)
        #expect(export.preview.count == 4)
        #expect(export.moreServings == 0)
    }

    @Test func theMoreCountIsWhatThePreviewLeavesOut() throws {
        #expect(try previewFile(servings: 5).moreServings == 0)
        #expect(try previewFile(servings: 6).moreServings == 1)
        #expect(try previewFile(servings: 1_204).moreServings == 1_199)
    }
```

- [ ] **Step 2: Run and verify RED**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/ServingsExportTests -parallel-testing-enabled NO
```

- [ ] **Step 3: Implement.** In `ServingsExport`, after `last`:

```swift
    /// The file's first lines, headings first, as they are in the file: what the sheet shows of what will leave. Cut from the
    /// same lines as ``data``, so it cannot say anything the file does not.
    let preview: [String]

    /// How many servings ``preview`` leaves out.
    var moreServings: Int { count - (preview.count - 1) }

    /// How many servings the sheet shows.
    private static let previewServings = 5
```

and in `outcome(of:today:calendar:)` add `preview: Array(lines.prefix(previewServings + 1))` after `last: last.timestamp`. Fix any fixture that builds `ServingsExport` by hand with the new argument (`preview: []`).

- [ ] **Step 4: Run and verify GREEN.**

- [ ] **Step 5: Stage**

```bash
git add WaterBuddy/ServingsExport.swift WaterBuddyTests/ServingsExportTests.swift
```

### Task 6: The sheet

**Files:**
- Create: `WaterBuddy/Hairline.swift`
- Modify: `WaterBuddy/ExportSheet.swift`, `WaterBuddy/SettingsView.swift`, `WaterBuddy/Localizable.xcstrings`
- Test: `WaterBuddyTests/ExportSheetTests.swift`, `WaterBuddyTests/LocalizationTests.swift`, `WaterBuddyUITests/ExportUITests.swift`

**Interfaces — consumes:** `lands`, `tracksLanding`, `RollingFigure`, `premiumRim(lit:)`, `preview`, `moreServings`. **Produces:** `ExportSheet.more(_:strings:locale:)`, `Hairline`.

- [ ] **Step 1: Write the failing tests.** Add to `ExportSheetTests`:

```swift
    /// `@MainActor` for `AppLanguage.locale` alone; the function it pins is `nonisolated`.
    @Test @MainActor func theMoreLineGroupsItsFigureInEveryLanguage() {
        let english = AppLanguage.english, russian = AppLanguage.russian
        #expect(ExportSheet.more(1_199, strings: english.bundle, locale: english.locale) == "and 1,199 more")
        let line = ExportSheet.more(1_199, strings: russian.bundle, locale: russian.locale)
        #expect(line.filter(\.isNumber) == "1199")
        #expect(!line.contains("1199"), "the figure was not grouped")
    }
```

Add `"Servings in this file"` and `"and %1$d more"` to `premiumKeys` in `LocalizationTests.swift`. In `ExportUITests.testAHoldersExportShowsItsSummaryAndOffersTheShareSheet`, change the summary's predicate to:

```swift
        let summary = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label BEGINSWITH %@ AND label CONTAINS %@ AND label CONTAINS %@", "1 serving,", "WaterBuddy-", "nothing else"))
```

- [ ] **Step 2: Run and verify RED**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/ExportSheetTests -only-testing:WaterBuddyTests/PremiumStringTests -parallel-testing-enabled NO
```

- [ ] **Step 3: Move `Hairline`.** Create `WaterBuddy/Hairline.swift` with the `private struct Hairline` body from `SettingsView.swift:1236`, made internal, and its opacity moved on to it:

```swift
//
//  Hairline.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 01/11/26.
//

import SwiftUI

/// A one-point rule across a card. Decoration: what it separates is already separate to VoiceOver.
struct Hairline: View {

    var body: some View {
        Rectangle()
            .fill(.white.opacity(Self.opacity))
            .frame(height: 1)
            .accessibilityHidden(true)
    }
}
```

Move `SettingsStyle.hairlineOpacity`'s value and comment to `private static let opacity` on `Hairline`, and delete it and the old struct from `SettingsView.swift`.

- [ ] **Step 4: Add the two strings** to `WaterBuddy/Localizable.xcstrings`, en, ru and uz, per the export spec's §3.8. Add them to #210's list when the docs are synced.

- [ ] **Step 5: Rewrite the sheet.** In `ExportSheet`, add the state:

```swift
    /// Whether the sheet has landed (``Landing``). Presentation state, gone with the sheet.
    @State private var landed = false

    /// A real magnitude, capped at its use site (rule `65-accessibility`).
    @ScaledMetric(relativeTo: .largeTitle) private var figureSize: CGFloat = 52
```

Replace the `VStack` content with `topBar`, `fileCard`, `Spacer(minLength: Self.gap)`, `shareButton`. Replace the detents with `.presentationDetents([.large])`, and add `.tracksLanding($landed)` after it. Replace `summary` with:

```swift
    /// The figure, the file and the note, on one card: sentence-length text never stands bare on the aurora
    /// (`tasks/lessons.md`, 2026-10-22). One element to VoiceOver, which reads the real count from the first frame.
    private var fileCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                RollingFigure(start: Self.zero(locale: locale), final: export.count.formatted(.number.locale(locale)), rolled: landed)
                    .font(.system(size: min(figureSize, Self.figureCeiling), weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("Servings in this file", bundle: strings)
                    .font(.headline)
                Text(Self.dates(first: export.first, last: export.last, locale: locale, calendar: .waterBuddyDay))
                    .font(.subheadline)
            }
            Hairline()
            file
            Hairline()
            Text(note)
                .font(.footnote)
        }
        .foregroundStyle(.white)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlass(density: .frosted, elevation: .raised)
        .premiumRim(lit: landed)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spoken)
    }

    /// The file's name and its own first lines. Capped: a line of a file cannot wrap and stay a line of a file, and everything
    /// here is spoken in the card's label.
    private var file: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label {
                Text(verbatim: export.name)
                    .lineLimit(1)
                    .truncationMode(.middle)
            } icon: {
                Image(systemName: "doc.text")
            }
            .font(.subheadline.weight(.semibold))
            .padding(.bottom, 4)

            ForEach(Array(export.preview.enumerated()), id: \.offset) { index, line in
                Text(verbatim: line)
                    .font(.system(.footnote, design: .monospaced))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .lands(landed, order: index)
            }
            if export.moreServings > 0 {
                Text(Self.more(export.moreServings, strings: strings, locale: locale))
                    .font(.footnote.weight(.semibold))
                    .lands(landed, order: export.preview.count)
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
    }

    private var note: String {
        strings.localizedString(
            forKey: "Date, time and amount in millilitres, nothing else. The file leaves your phone only when you send it.",
            value: nil, table: nil
        )
    }

    /// The sentence the card speaks: the count with its noun, in the app's language, as the sheet drew it before.
    private var spoken: String {
        [
            Self.count(export.count, strings: strings, locale: locale),
            Self.dates(first: export.first, last: export.last, locale: locale, calendar: .waterBuddyDay),
            export.name,
            note
        ].joined(separator: ", ")
    }
```

Add to the share glyph `.symbolEffect(.bounce, value: settled)`, with:

```swift
    /// The share glyph's one bounce: after the rows, so the eye ends on the action. Held down under Reduce Motion.
    @State private var settled = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
```

and on the root:

```swift
        .task(id: landed) {
            guard landed, !reduceMotion else { return }
            do { try await Task.sleep(for: .seconds(Landing.longestDelay + Motion.landResponse)) } catch { return }
            guard !Task.isCancelled else { return }
            settled = true
        }
```

Add the statics:

```swift
    /// *and 1,199 more*, its figure grouped the app's language's way (rule `50-views`).
    nonisolated static func more(_ count: Int, strings: Bundle, locale: Locale) -> String {
        strings.localized("and %1$d more", count, locale: locale)
    }

    /// Where the figure rolls from, in the app's own digits.
    nonisolated private static func zero(locale: Locale) -> String {
        0.formatted(.number.locale(locale))
    }

    private static let figureCeiling: CGFloat = 76
```

- [ ] **Step 6: Run Step 2's command, then the UI class, and verify GREEN**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyUITests/ExportUITests -parallel-testing-enabled NO
```

- [ ] **Step 7: Prove `LocalizationTests` reads the keys:** delete one key's `ru` value, see `PremiumStringTests` fail on it, restore it (`tasks/lessons.md`, 2026-11-01).

- [ ] **Step 8: Stage**

```bash
git add WaterBuddy/Hairline.swift WaterBuddy/ExportSheet.swift WaterBuddy/SettingsView.swift WaterBuddy/Localizable.xcstrings WaterBuddyTests/ExportSheetTests.swift WaterBuddyTests/LocalizationTests.swift WaterBuddyUITests/ExportUITests.swift
```

### Task 7: The Settings card, and #214's two lines

**Files:** Modify `WaterBuddy/SettingsView.swift`. Test `WaterBuddyTests/ExportSheetTests.swift`.

**Interfaces — produces:** `SettingsView.exportLine(_ problem: String?, gate: PremiumAccess.Gate) -> String?`.

- [ ] **Step 1: Write the failing test.** Add to `ExportSheetTests`:

```swift
    /// A lock never stands over a line about a file only a holder could have asked for, and VoiceOver says *Premium*.
    @Test func aLapsedCardDrawsNoProblem() {
        #expect(SettingsView.exportLine("Nothing to export yet.", gate: .open) == "Nothing to export yet.")
        #expect(SettingsView.exportLine("Nothing to export yet.", gate: .locked) == nil)
        #expect(SettingsView.exportLine("Nothing to export yet.", gate: .hidden) == nil)
        #expect(SettingsView.exportLine(nil, gate: .open) == nil)
    }
```

- [ ] **Step 2: Run and verify RED**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/ExportSheetTests -parallel-testing-enabled NO
```

- [ ] **Step 3: Implement.** Beside `behindTapOpensPaywall`:

```swift
    /// Why the export card's tap opened nothing, while the card is open. The line outlives a lapse otherwise: a lock over it,
    /// and VoiceOver speaking it in place of *Premium*.
    nonisolated static func exportLine(_ problem: String?, gate: PremiumAccess.Gate) -> String? {
        gate == .open ? problem : nil
    }
```

Pass it, and the counter, to the card:

```swift
                        ExportCard(
                            gate: premiumGate,
                            problem: Self.exportLine(exportProblem?.line(in: strings), gate: premiumGate),
                            opens: exportOpens,
                            action: startExport
                        )
```

Add `@State private var exportOpens = 0`. In `startExport()`, `case .file(let file): exportOpens += 1; exporting = file`. On the screen's root add:

```swift
        .sensoryFeedback(Haptics.select, trigger: exportOpens)
        // A watch pour, or a widget tap read on coming forward: the line that said there was nothing goes with the nothing.
        // Nothing in the suite can drive either (spec D11).
        .onChange(of: manager.currentWater) { exportProblem = nil }
```

In `ExportCard`, add `let opens: Int`, draw before the `VStack`:

```swift
                Image(systemName: "doc.text")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .symbolEffect(.bounce, value: opens)
                    .accessibilityHidden(true)
```

and give the line `.contentTransition(.opacity)`.

- [ ] **Step 4: Run and verify GREEN.**

- [ ] **Step 5: Stage**

```bash
git add WaterBuddy/SettingsView.swift WaterBuddyTests/ExportSheetTests.swift
```

### Task 8: The gate waits for the first read

**Files:** Modify `WaterBuddy/PremiumAccess.swift`, `WaterBuddyTests/PremiumAccessTests.swift`, `docs/superpowers/specs/2026-10-30-coaching-design.md:206`

- [ ] **Step 1: Change the ruling's test first.** In `PremiumAccessTests`, `gate(status: nil, offered: true)` moves from `.locked` to `.hidden`. **This is the spec's ruling, D14, not a weakened test.** Add:

```swift
    /// Every extra drawn in place waits for the first read together, so a holder's rows, month and card arrive at once, and no
    /// holder's tap in that window reaches the paywall.
    @Test func theGateAgreesWithTheMonthWhileTheFirstReadIsOut() {
        #expect(PremiumAccess.gate(status: nil, offered: true) == .hidden)
        #expect(!HistoryView.offersMonth(status: nil, offered: true))
    }
```

- [ ] **Step 2: Run and verify RED**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/PremiumAccessTests -parallel-testing-enabled NO
```

- [ ] **Step 3: Implement.**

```swift
    /// How a Premium extra drawn in place of a free screen shows (spec `2026-10-30-coaching-design.md` D4).
    nonisolated enum Gate: Sendable, Equatable {
        /// Nothing is drawn: the paywall is not offered here, or StoreKit has not answered yet.
        case hidden
        /// Drawn with a lock; a tap opens the paywall.
        case locked
        case open
    }

    /// One answer for every extra drawn in place: open for Premium, locked where the paywall is offered, hidden where it is
    /// not, and hidden until StoreKit has answered, as Premium's card and History's switch wait (spec
    /// `2026-11-01-finish-export-design.md` D14).
    static func gate(status: Status?, offered: Bool) -> Gate {
        guard let status else { return .hidden }
        if status.isPremium { return .open }
        return offered ? .locked : .hidden
    }
```

Mark the coaching spec's line 206 *(amended 2026-11-01: hidden, not locked; finishing export's D14)*.

- [ ] **Step 4: Run and verify GREEN, then the two UI classes it touches**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyUITests/CoachingUITests -parallel-testing-enabled NO
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyUITests/PremiumUITests -parallel-testing-enabled NO
```

A failure of `testAFreeUsersCoachingRowsAreLockedAndOpenThePaywall` under load (#215): run it alone once, and report either way.

- [ ] **Step 5: Stage**

```bash
git add WaterBuddy/PremiumAccess.swift WaterBuddyTests/PremiumAccessTests.swift docs/superpowers/specs/2026-10-30-coaching-design.md
```

### Task 9: Stage 1's check

- [ ] **Step 1: Read the render.** Write a throwaway `WaterBuddyUITests/ProbeUITests.swift` that launches as `ExportUITests` does and attaches a `XCUIScreen.main.screenshot()` of Settings' card and of the sheet, with `lifetime = .keepAlways`, at the default size and at `UICTContentSizeCategoryAccessibilityXXXL`, in English and with `-AppleLanguages (ru)`. Export with `xcrun xcresulttool export attachments`, Read each image, and delete the probe.

- [ ] **Step 2: Measure #213** on the `.large` sheet, through one full drift period, by `docs/DESIGN.md`'s method: white on the card at the figure, the rows, *and N more* and the note, the rim beside them, the heading on the aurora, and the glyph on Settings' card. **A pair under its floor stops the work and is reported.**

- [ ] **Step 3: Install on the owner's iPhone**

```bash
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'id=00008130-00123DD93410001C' -derivedDataPath <scratchpad>/device
xcrun devicectl device install app --device 00008130-00123DD93410001C <scratchpad>/device/Build/Products/Debug-iphoneos/WaterBuddy.app
xcrun devicectl device process launch --device 00008130-00123DD93410001C sardor.WaterBuddy -- -WaterBuddyFreshStart YES -WaterBuddyPremiumHeld YES -WaterBuddyStoreSample YES
```

`<scratchpad>` is this session's scratchpad directory, so nothing lands in the repository. If `xcrun xctrace list devices` no longer shows the phone, ask the owner to connect it.

- [ ] **Step 4: The owner holds it.** Tell them what to feel: the card's bounce and tick, the rows, the roll, the lap, the share press. Tune `Landing.wait` there. **The next stage starts only on their word.**

---

## Stage 2: The paywall

### Task 10: The paywall arrives

**Files:** Modify `WaterBuddy/PaywallView.swift`

- [ ] **Step 1: Add the flag, and draw the preview from it.** Add `@State private var landed = false`, `@Environment(\.accessibilityReduceMotion) private var reduceMotion`, `private var drawn: Bool { landed || reduceMotion }`, and `.tracksLanding($landed)` on the root. In `preview`, change each dot and bar:

```swift
                ForEach(0..<35, id: \.self) { day in
                    Circle()
                        .fill(PaywallStyle.quietDays.contains(day) ? .white.opacity(PaywallStyle.restOpacity) : Aurora.cyan)
                        .frame(width: PaywallStyle.dot, height: PaywallStyle.dot)
                        .scaleEffect(drawn ? 1 : 0)
                        .animation(drawn ? Motion.popped(at: day) : nil, value: drawn)
                }
```

```swift
                    Capsule()
                        .fill(index == PaywallStyle.tallestBar ? Aurora.cyan : .white.opacity(PaywallStyle.barOpacity))
                        .frame(height: PaywallStyle.barHeight * PaywallStyle.bars[index])
                        .scaleEffect(y: drawn ? 1 : 0, anchor: .bottom)
                        .animation(drawn ? Motion.drawn(at: index * 4) : nil, value: drawn)
```

- [ ] **Step 2: The rows rise, and a chosen tile springs**

```swift
            ForEach(Array(Self.shownSets(debug: Self.isDebug).flatMap(\.features).enumerated()), id: \.element) { index, feature in
                featureRow(feature)
                    .lands(landed, order: index)
            }
```

In `planTile`, after `.liquidGlass(in: shape, density: .frosted, elevation: .resting, interactive: true)`:

```swift
            // Chosen, it stands forward: this is the screen's one decision, and it is felt as well as marked.
            .scaleEffect(isSelected ? 1.03 : 1)
            .animation(Motion.land, value: isSelected)
```

- [ ] **Step 3: Run the Premium classes**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyUITests/PremiumUITests -parallel-testing-enabled NO
```

- [ ] **Step 4: Stage**

```bash
git add WaterBuddy/PaywallView.swift
```

### Task 11: Buying is a moment

**Files:** Modify `WaterBuddy/PaywallView.swift`, `WaterBuddyTests/PremiumAccessTests.swift`

- [ ] **Step 1: Pin what is not a moment.** Add to `PaywallScreenTests`:

```swift
    /// A restore, a purchase made earlier and an Ask to Buy approved later are all *held*, never thanked: the moment is the
    /// user's own purchase landing here, and a re-read must not set it off.
    @Test func onlyAPurchaseLandingHereIsThanked() {
        #expect(PaywallView.screen(status: .lifetime, purchase: .idle) == .held)
        #expect(PaywallView.screen(status: .lifetime, purchase: .pending) == .held)
        #expect(PaywallView.screen(status: .lifetime, purchase: .buying) == .held)
        #expect(PaywallView.screen(status: .lifetime, purchase: .failed) == .held)
    }
```

- [ ] **Step 2: Run it.** It passes on arrival: `screen` already says this. Keep it: it pins what the moment now hangs on. Prove it by changing `screen` to return `.thanks` for `.idle`, seeing it fail, and restoring.

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/PaywallScreenTests -parallel-testing-enabled NO
```

- [ ] **Step 3: The moment.** Replace `purchases` with:

```swift
    /// Bumped by the buy button's press.
    @State private var presses = 0
    /// Bumped once, as *Thank you* appears: the card is what fills, so the confetti and the laps belong to it.
    @State private var moments = 0
```

On the root, replace the `purchases` feedback with:

```swift
        .sensoryFeedback(Haptics.confirm, trigger: presses)
        .sensoryFeedback(Haptics.goalReached, trigger: moments)
```

`buyButton`'s action drops its `purchases` line and begins `presses += 1`. In `held(thanks:)`, put the `VStack` of words on a pane:

```swift
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 28)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .liquidGlass(density: .frosted, elevation: .raised)
            .premiumRim(lit: moments > 0, laps: PremiumRim.purchaseLaps)
            .overlay { ConfettiOverlay(burst: moments) }
            .accessibilityElement(children: .combine)
            .task(id: thanks) {
                if thanks { moments += 1 }
            }
```

Change *Thank you*'s and *You have Premium.*'s fonts to `.largeTitle.weight(.heavy)`, and remove `.legibleOnBackdrop()`, now it stands on a pane.

- [ ] **Step 4: Run the suite and the class**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/PaywallScreenTests -parallel-testing-enabled NO
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyUITests/PremiumUITests -parallel-testing-enabled NO
```

- [ ] **Step 5: Render, measure and hand over.** Read the paywall at the default and largest sizes (Task 9, Step 1's method), and measure the words on the new pane through `-WaterBuddyPremiumHeld`'s *You have Premium.*, the same pane. **No automated run reaches *Thank you*:** a purchase needs the scheme's local StoreKit configuration, which only a run from Xcode carries, and App Store Connect has no products yet (#155). So the owner runs the scheme from Xcode to their iPhone, launched with `-WaterBuddyPremium YES`, and buys a plan there. That is how the moment is first seen.

- [ ] **Step 6: Stage, and wait for the owner's word**

```bash
git add WaterBuddy/PaywallView.swift WaterBuddyTests/PremiumAccessTests.swift
```

---

## Stage 3: The recap

### Task 12: The card draws itself, and the image never does

**Files:** Modify `WaterBuddy/RecapCard.swift`. Test `WaterBuddyTests/RecapImageTests.swift`.

**Interfaces — produces:** `RecapCard(month:drawn:lit:)`, `drawn` defaulting `true`, `lit` defaulting `false`.

- [ ] **Step 1: Write the failing test.** Add to `RecapImageTests`, using that suite's own month fixture:

```swift
    /// One view is both the card on screen and the image that leaves the phone, so the image's whole state must be the default
    /// and never the sheet's: a tap on *Share* in the first second must not send a half-drawn month.
    @Test func theImageIsNeverHalfDrawn() throws {
        let card = RecapCard(month: try month())
        #expect(card.drawn)
        #expect(!card.lit)
    }
```

- [ ] **Step 2: Run and verify RED**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/RecapImageTests -parallel-testing-enabled NO
```

- [ ] **Step 3: Implement.** After `let month: MonthHistory`:

```swift
    /// Whether the month has drawn. **`true` unless the sheet says otherwise:** ``Rendered`` passes nothing, so the image is
    /// always the whole card.
    var drawn = true

    /// Whether the rim runs its lap. The image never does.
    var lit = false
```

Change `.premiumRim()` to `.premiumRim(lit: lit)`. In `hero`, replace the figure's `Text` with:

```swift
            RollingFigure(
                start: strings.figure("%1$@/%2$@", 0, month.daysCounted, locale: locale),
                final: strings.figure("%1$@/%2$@", month.daysMet, month.daysCounted, locale: locale),
                rolled: drawn
            )
```

keeping its modifiers. In `dots`, give each dot its place in the month:

```swift
                    ForEach(row, id: \.summary.dayOrdinal) { day in
                        dot(for: day)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                            .scaleEffect(drawn ? 1 : 0)
                            .animation(drawn ? Motion.popped(at: day.summary.dayOrdinal % 100 - 1) : nil, value: drawn)
                    }
```

Change `tile(_:label:)` to `tile(_ figure: String, from start: String, label: Text)`, drawing `RollingFigure(start: start, final: figure, rolled: drawn)` in place of `Text(figure)`, with `strings.localized("%1$@ L", HistoryView.litres(0, locale: locale), locale: locale)` and `strings.figure("%1$@ ml", 0, locale: locale)` as the two starts.

- [ ] **Step 4: Run and verify GREEN**, `theSharedPictureKeepsItsPixels` and `theLargestMonthStillRenders` among them.

- [ ] **Step 5: Stage**

```bash
git add WaterBuddy/RecapCard.swift WaterBuddyTests/RecapImageTests.swift
```

### Task 13: The recap sheet

**Files:** Modify `WaterBuddy/RecapSheet.swift`, `WaterBuddy/HistoryView.swift` (the row)

- [ ] **Step 1: Land the sheet.** Add `@State private var landed = false`, `@Environment(\.accessibilityReduceMotion) private var reduceMotion`, and `.tracksLanding($landed)` on the root. Lay out:

```swift
                    VStack(alignment: .leading, spacing: Self.gap) {
                        topBar
                        RecapCard(month: month, drawn: landed || reduceMotion, lit: landed)
                        streak
                            .lands(landed, order: 6)
                        Spacer(minLength: Self.gap)
                        footnote
                        shareButton
                    }
```

The image stays rendered from `.task` through `RecapCard.image(of:)`, so the button works from the first frame and sends the whole card. `streak`'s order 6 stands it last. The share press is Task 4's.

- [ ] **Step 2: The recap row answers.** On `HistoryView`, add `@State private var recapOpens = 0`, bump it in `openRecap(_:)`, when `recap` is non-nil, add `.sensoryFeedback(Haptics.select, trigger: recapOpens)`, and pass `opens: recapOpens` to `RecapRow`, whose leading glyph takes `.symbolEffect(.bounce, value: opens)`.

- [ ] **Step 3: Run the classes that reach it**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/RecapImageTests -only-testing:WaterBuddyTests/MonthRecapTests -parallel-testing-enabled NO
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyUITests/PremiumUITests -parallel-testing-enabled NO
```

- [ ] **Step 4: Render, measure the note and the button where they now stand, install, and wait for the owner's word.** Launch with `-WaterBuddyFreshStart YES -WaterBuddyPremiumHeld YES -WaterBuddyStoreSample YES`.

- [ ] **Step 5: Stage**

```bash
git add WaterBuddy/RecapSheet.swift WaterBuddy/HistoryView.swift
```

---

## Stage 4: History

### Task 14: The month draws itself

**Files:** Modify `WaterBuddy/HistoryView.swift`. Test `WaterBuddyTests/HistoryViewTests.swift` (suite `MonthLayoutTests`, not `@MainActor`).

**Interfaces — produces:** `HistoryView.drawsMonth(raised: Int?, month: Int?, reduceMotion: Bool) -> Bool`; `MonthCard(… drawn: Bool, steps: Int)`; `MonthFigures(month:drawn:)`.

- [ ] **Step 1: Write the failing test** in `MonthLayoutTests`:

```swift
    /// A re-read republishes the same month, and the rings stand. The next month draws from nothing, whatever the last was
    /// doing, and a month not yet read draws nothing.
    @Test func aMonthDrawsOncePerArrival() {
        #expect(HistoryView.drawsMonth(raised: 20261001, month: 20261001, reduceMotion: false))
        #expect(!HistoryView.drawsMonth(raised: 20261001, month: 20260901, reduceMotion: false))
        #expect(!HistoryView.drawsMonth(raised: nil, month: 20261001, reduceMotion: false))
        #expect(!HistoryView.drawsMonth(raised: nil, month: nil, reduceMotion: false))
        #expect(HistoryView.drawsMonth(raised: nil, month: 20261001, reduceMotion: true))
    }
```

- [ ] **Step 2: Run and verify RED**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/MonthLayoutTests -parallel-testing-enabled NO
```

- [ ] **Step 3: Implement the flag on `HistoryView`,** where a row the `List` recycles cannot lose it. Its root has no Reduce Motion read yet, so add one:

```swift
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The month whose rings have been let draw. A turn behind the shown month whenever that changes, which is the moment they
    /// stand at nothing. Keyed on the month, so a re-read of the same month leaves them standing.
    @State private var raisedMonth: Int?

    private var shownMonth: Int? { showsMonth ? manager.month?.firstDay : nil }

    /// Whether `month`'s data has drawn: once `raised` has caught up with it, and at once under Reduce Motion.
    nonisolated static func drawsMonth(raised: Int?, month: Int?, reduceMotion: Bool) -> Bool {
        reduceMotion || (month != nil && raised == month)
    }

    private var monthDrawn: Bool {
        Self.drawsMonth(raised: raisedMonth, month: shownMonth, reduceMotion: reduceMotion)
    }
```

On the root:

```swift
        .task(id: shownMonth) {
            guard let shownMonth else {
                raisedMonth = nil
                return
            }
            // One frame at nothing, so there is something to draw from (``Arrival/hiddenFirst``).
            do { try await Task.sleep(for: Arrival.hiddenFirst) } catch { return }
            guard !Task.isCancelled else { return }
            raisedMonth = shownMonth
        }
```

Pass `drawn: monthDrawn, steps: steps` to `MonthCard`, and `drawn: monthDrawn` to `MonthFigures`.

- [ ] **Step 4: The rings.** In `MonthCard.dayButton`, the arc:

```swift
                Circle()
                    .inset(by: arc / 2)
                    .trim(from: 0, to: drawn ? day.fraction : 0)
                    .stroke(day.isMet ? Aurora.cyan : Color.white, style: StrokeStyle(lineWidth: arc, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(drawn ? Motion.drawn(at: ordinal % 100 - 1) : nil, value: drawn)
```

and in `arrow(to:systemName:)`, on the `Image`, `.symbolEffect(.bounce, value: steps)`.

- [ ] **Step 5: The figures.** Change `MonthFigures.tile` to take `from start: String`, and draw `RollingFigure(start: start, final: figure, rolled: drawn)` in place of `Text(figure)`, with starts `strings.figure("%1$@/%2$@", 0, month.daysCounted, locale: locale)`, `strings.localized("%1$d days", 0, locale: locale)` and `strings.localized("%1$@ L", HistoryView.litres(0, locale: locale), locale: locale)`.

- [ ] **Step 6: Run and verify GREEN, then the UI class**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/MonthLayoutTests -parallel-testing-enabled NO
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyUITests/PremiumUITests -parallel-testing-enabled NO
```

- [ ] **Step 7: Stage**

```bash
git add WaterBuddy/HistoryView.swift WaterBuddyTests/HistoryViewTests.swift
```

### Task 15: The patterns draw when they are reached

**Files:** Modify `WaterBuddy/HistoryView.swift`

- [ ] **Step 1: A second flag.** The patterns stand below the fold, so they wait until their row appears (P4). On `HistoryView`:

```swift
    /// The month whose patterns have been reached. On the screen, so scrolling back never replays them.
    @State private var raisedPatterns: Int?
```

In `monthRows`:

```swift
                if let patterns = month.patterns {
                    let drawn = Self.drawsMonth(raised: raisedPatterns, month: month.firstDay, reduceMotion: reduceMotion)
                    HoursChart(patterns: patterns, drawn: drawn)
                        .historyRow()
                        .task(id: month.firstDay) {
                            do { try await Task.sleep(for: Arrival.hiddenFirst) } catch { return }
                            guard !Task.isCancelled else { return }
                            raisedPatterns = month.firstDay
                        }
                    WeekSplit(split: patterns.split(weekend: Self.weekend(in: locale)), drawn: drawn)
                        .historyRow()
```

- [ ] **Step 2: Bars.** `HoursChart` gains `let drawn: Bool`. Each bar's height becomes `drawn && bars[hour] > 0 ? max(proxy.size.height * bars[hour], barWidth) : 0`, with `.animation(drawn ? Motion.drawn(at: hour) : nil, value: drawn)` on the bar. `WeekSplit` gains the same `let drawn: Bool`, its fill's width becomes `drawn && side.fraction > 0 ? max(proxy.size.width * side.fraction, proxy.size.height) : 0`, and the bar takes `.animation(drawn ? Motion.draw : nil, value: drawn)`.

- [ ] **Step 3: Run the class**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyUITests/PremiumUITests -parallel-testing-enabled NO
```

- [ ] **Step 4: Stage**

```bash
git add WaterBuddy/HistoryView.swift
```

### Task 16: Insights

**Files:** Modify `WaterBuddy/HistoryView.swift`

- [ ] **Step 1: The flag.** On `HistoryView`:

```swift
    /// Whether Insights has arrived: down each time it is left, so entering it plays once.
    @State private var insightsLanded = false
```

On the root:

```swift
        .task(id: showsInsights) {
            insightsLanded = false
            guard showsInsights else { return }
            do { try await Task.sleep(for: Arrival.hiddenFirst) } catch { return }
            guard !Task.isCancelled else { return }
            insightsLanded = true
        }
```

- [ ] **Step 2: The lead pane.** `OneThingPane` gains `let lit: Bool`. Its heading becomes `.font(.title2.weight(.heavy))`, its sparkle takes `.symbolEffect(.bounce, value: lit)`, and after `.liquidGlass(density: .frosted, elevation: .raised)` add `.premiumRim(lit: lit)`. Pass `lit: insightsLanded`.

- [ ] **Step 3: The rest rise after it.** Before each `.historyRow()` in `insightPanes`: `InsightPane(kind: .working, …).lands(insightsLanded, order: 2)`, `InsightPane(kind: .worthKnowing, …).lands(insightsLanded, order: 3)`, `InsightFooter(source: footer).lands(insightsLanded, order: 4)`.

- [ ] **Step 4: Run the class**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyUITests/PremiumUITests -parallel-testing-enabled NO
```

- [ ] **Step 5: Render Month, the patterns and Insights; measure Insights' lead pane; install; wait for the owner's word.** A long month on the iPhone: watch for dropped frames in the wave, and halve the stagger only if the owner sees them.

- [ ] **Step 6: Stage**

```bash
git add WaterBuddy/HistoryView.swift
```

---

## Stage 5: The rest

### Task 17: Settings' Premium card and the schedule sheet

**Files:** Modify `WaterBuddy/SettingsView.swift`, `WaterBuddy/ReminderScheduleSheet.swift`

- [ ] **Step 1: The card.** `PremiumCard` gains `let lit: Bool`, passed `arrived` from `SettingsView`. In `offer`, `.premiumRim()` becomes `.premiumRim(lit: lit)`. In `held(_:)`, after `.settingsCard()`, add `.premiumRim(lit: lit)` (P5).

- [ ] **Step 2: The schedule sheet lands.** Add `@State private var landed = false` and `.tracksLanding($landed)`. In the `VStack`: both `hourRow`s, `intervals`, `days` and `standardButton` take `.lands(landed, order: 0…4)` in that order.

- [ ] **Step 3: Run the classes**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyUITests/CoachingUITests -parallel-testing-enabled NO
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyUITests/PremiumUITests -parallel-testing-enabled NO
```

- [ ] **Step 4: Stage**

```bash
git add WaterBuddy/SettingsView.swift WaterBuddy/ReminderScheduleSheet.swift
```

### Task 18: The water rises as the app opens

**Files:** Modify `WaterBuddy/HomeView.swift`. Test `WaterBuddyTests/ArrivalTests.swift`.

**Interfaces — produces:** `HomeView.openingLevel(_:arrived:settles:reduceMotion:) -> Double`.

- [ ] **Step 1: Write the failing test.** Add to `ArrivalTests`:

```swift
    /// The app opens with its water rising, once. A tab's turn comes whole, as a return from the background does, because
    /// neither builds an opening page, and Reduce Motion stands it at today's level.
    @Test func theWaterRisesOnlyAsTheAppOpens() {
        #expect(HomeView.openingLevel(0.65, arrived: false, settles: true, reduceMotion: false) == 0)
        #expect(HomeView.openingLevel(0.65, arrived: true, settles: true, reduceMotion: false) == 0.65)
        #expect(HomeView.openingLevel(0.65, arrived: false, settles: false, reduceMotion: false) == 0.65)
        #expect(HomeView.openingLevel(0.65, arrived: false, settles: true, reduceMotion: true) == 0.65)
    }
```

- [ ] **Step 2: Run and verify RED**

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/ArrivalTests -parallel-testing-enabled NO
```

- [ ] **Step 3: Implement.** On `HomeView`:

```swift
    /// The level the vessel draws: nothing until the page the app opens on has arrived, then today's, on ``Motion/water``.
    /// The readouts never read this: they say today's figure from the first frame.
    nonisolated static func openingLevel(_ progress: Double, arrived: Bool, settles: Bool, reduceMotion: Bool) -> Double {
        arrived || !settles || reduceMotion ? progress : 0
    }
```

Add `@Environment(\.pageSettlesIn) private var settles`, and pass `level: Self.openingLevel(manager.progress, arrived: arrived, settles: settles, reduceMotion: reduceMotion)` to `WaterVessel`.

- [ ] **Step 4: Run and verify GREEN.** Then watch a cold launch on the simulator, because a test cannot see this: the water rises once, a tab turn and a return from the background do not replay it, and the first pour still lands.

- [ ] **Step 5: Install, and let the owner decide.** This is spec D9, the one the owner may strike alone.

- [ ] **Step 6: Stage**

```bash
git add WaterBuddy/HomeView.swift WaterBuddyTests/ArrivalTests.swift
```

### Task 19: The whole gate, and the records

**Files:** `WaterBuddyUITests/AppStoreScreenshotUITests.swift`, docs through `/doc_sync`

- [ ] **Step 1: The capture waits for the longest draw.** In `capture(_:)` (`AppStoreScreenshotUITests.swift:391`), before the screenshot:

```swift
        // The longest draw: a month's rings and a lap of the rim (spec `2026-11-01-premium-look-design.md` §5).
        Thread.sleep(forTimeInterval: 1.6)
```

- [ ] **Step 2: Booted devices.** `xcrun simctl list devices booted`. Shut down only what this work booted.

- [ ] **Step 3: The five invocations on 27.0,** each its own foreground call, the UI one class by class: rule `85-testing`'s commands, with `-only-testing:WaterBuddyUITests/<Class>` per call and `AppStoreScreenshotUITests` never among them.

- [ ] **Step 4: The UI suite on 26.5,** every class, closing #212: `OS=26.5`, one call per class.

- [ ] **Step 5: Warnings.** Clean builds into empty DerivedData of `-scheme WaterBuddy`, against a `git archive 9086f06` export, compared by file and message. Expected: no line new, or each new one reported.

- [ ] **Step 6: `/doc_sync`.** It writes: #212, #213 and #214 closed, D13 accepted; the lapse with the sheet open added to #211; the strings to #210; `docs/ROADMAP.md`'s stale "not committed" corrected and a new item for this work; `docs/DESIGN.md`'s figures and *Export*; `CLAUDE.md`; `HISTORY.md`; `tasks/lessons.md`.

- [ ] **Step 7: Stage by path and stop.** The owner runs `/commit`.
